#ifdef BOARD_BRWR_TRMNL
//
// Home Assistant over MQTT: discovery, state, button triggers and commands.
//
// Topics (<base> = brwr-trmnl/<last 6 hex digits of the MAC>):
//   <base>/status        online / offline (retained, last will)     device -> HA
//   <base>/state         JSON state (retained)                      device -> HA
//   <base>/image         URL of the image on screen (retained)      device -> HA
//   <base>/button        "<button>_<press>" device-trigger events   device -> HA
//   <base>/set/<name>    settings, retained by HA:                  HA -> device
//                        source, power, buttons, refresh, hold, vcom, screens
//   <base>/set/screen    Screen select (one-shot, cleared once shown) HA -> device
//   <base>/cmd           refresh | next | back (one-shot)          HA -> device
//   <base>/show          show a screen or URL now (one-shot, JSON)  HA -> device
//   brwr-trmnl/all/...   set/screens, show, cmd for every display: the Home
//                        Assistant package uses these, so it needs no device id.
//                        show and cmd carry "ts" (epoch seconds) and stay retained;
//                        each display handles a given ts once and ignores stale ones.
//
// Home Assistant publishes one-shot commands with retain so a device in deep
// sleep still gets them at its next wake; the device deletes them once done.
//
#include <Arduino.h>
#include <ArduinoJson.h>
#include <ESPmDNS.h>
#include <WiFi.h>
#include <brwr/board.h>
#include <brwr/brwr.h>
#include <brwr/ha_internal.h>
#include <brwr/settings.h>
#include <brwr/state.h>
#include <config.h>
#include <device_id.h>
#include <freertos/semphr.h>
#include <mqtt_client.h>
#include <trmnl_log.h>

namespace brwr {

  static const char *ORIGIN_URL = "https://github.com/brewer-michael/brwr-trmnl";
  static const char *PLAYLIST = "Playlist"; // Screen option meaning "back to the schedule"

  static esp_mqtt_client_handle_t s_client = nullptr;
  static EventGroupHandle_t s_events = nullptr;
  static SemaphoreHandle_t s_lock = nullptr;
  static String s_id;       // a1b2c3
  static String s_base;     // brwr-trmnl/a1b2c3
  static String s_syncToken;
  static String s_rxTopic, s_rxData;
  static String s_haHost;   // resolved once per wake
  static float s_batteryVolts = 0;

  // esp-mqtt keeps pointers to these for the life of the client.
  static String s_cfgHost, s_cfgUser, s_cfgPass, s_cfgClientId, s_cfgWillTopic;

  float battery_volts() { return s_batteryVolts; }

  EventGroupHandle_t ha_events() {
    if (!s_events) s_events = xEventGroupCreate();
    return s_events;
  }

  static void ensure_ids() {
    if (s_id.length()) return;
    String mac = device_mac_address(); // AA:BB:CC:DD:EE:FF
    mac.replace(":", "");
    mac.toLowerCase();
    s_id = mac.substring(mac.length() - 6);
    s_base = "brwr-trmnl/" + s_id;
  }

  String topic(const char *suffix) {
    ensure_ids();
    return s_base + "/" + suffix;
  }

  String ha_host() {
    if (s_haHost.length()) return s_haHost;
    String host = settings().haHost;
    if (host.endsWith(".local")) {
      // lwIP may not resolve mDNS names; ask the mDNS responder upstream started.
      IPAddress ip = MDNS.queryHost(host.substring(0, host.length() - 6).c_str(), 2000);
      if (ip != IPAddress((uint32_t)0)) {
        Log_info("brwr: %s is %s", host.c_str(), ip.toString().c_str());
        host = ip.toString();
      }
    }
    s_haHost = host;
    return s_haHost;
  }

  bool mqtt_connected() { return s_client && (xEventGroupGetBits(ha_events()) & EV_CONNECTED); }

  void mqtt_publish(const String &t, const String &payload, bool retain, int qos) {
    if (!mqtt_connected()) return;
    // publish() (not enqueue) sends payloads larger than the buffer in fragments.
    esp_mqtt_client_publish(s_client, t.c_str(), payload.c_str(), payload.length(), qos, retain ? 1 : 0);
  }

  void mqtt_clear_retained(const char *suffix) { mqtt_publish(topic(suffix), "", true, 1); }

  bool mqtt_flush(uint32_t timeout_ms) {
    if (!s_client) return true;
    uint32_t start = millis();
    while (esp_mqtt_client_get_outbox_size(s_client) > 0) {
      if (millis() - start > timeout_ms || !mqtt_connected()) return false;
      delay(20);
    }
    return true;
  }

  void mqtt_stop() {
    if (!s_client) return;
    mqtt_flush(3000);
    esp_mqtt_client_disconnect(s_client); // sends DISCONNECT: the broker drops the last will
    esp_mqtt_client_stop(s_client);
    esp_mqtt_client_destroy(s_client);
    s_client = nullptr;
    xEventGroupClearBits(ha_events(), EV_CONNECTED);
  }

  // ---- incoming messages ---------------------------------------------------

  static bool option_is(const String &payload, const char *option) { return payload.equalsIgnoreCase(option); }

  static void apply_setting(const String &name, const String &payload) {
    Settings &s = settings();
    bool redraw = false, resleep = false, changed = false;

    if (name == "source") {
      Source v = option_is(payload, source_name(Source::HomeAssistant)) ? Source::HomeAssistant : Source::Trmnl;
      if (v != s.source) {
        s.source = v;
        changed = redraw = true;
      }
    } else if (name == "power") {
      PowerMode v =
        option_is(payload, power_name(PowerMode::DeepSleep)) ? PowerMode::DeepSleep : PowerMode::AlwaysReady;
      if (v != s.power) {
        s.power = v;
        changed = resleep = true;
      }
    } else if (name == "buttons") {
      ButtonMode v = option_is(payload, button_mode_name(ButtonMode::HomeAssistantOnly)) ? ButtonMode::HomeAssistantOnly
                                                                                         : ButtonMode::Local;
      if (v != s.buttons) {
        s.buttons = v;
        changed = true;
      }
    } else if (name == "refresh") {
      uint16_t v = (uint16_t)constrain(payload.toFloat(), 0, 1440);
      if (v != s.refreshMinutes) {
        s.refreshMinutes = v;
        changed = resleep = true;
      }
    } else if (name == "hold") {
      uint16_t v = (uint16_t)constrain(payload.toFloat(), 1, 1440);
      if (v != s.holdMinutes) {
        s.holdMinutes = v;
        changed = true;
      }
    } else if (name == "vcom") {
      // Entered in volts as printed on the panel's ribbon cable, e.g. -1.52
      uint16_t v = (uint16_t)lroundf(fabsf(payload.toFloat()) * 1000.0f);
      if (v >= 500 && v <= 5000 && v != s.vcomMv) {
        s.vcomMv = v;
        changed = redraw = true;
      }
    } else if (name == "screens") {
      if (payload != settings_screens_json() && settings_parse_screens(payload)) {
        settings_save_screens(payload);
        rtc.discoveryHash = 0; // Screen select options changed
        if (s.source == Source::HomeAssistant) redraw = true;
      }
      return;
    } else {
      return;
    }

    if (changed) {
      settings_save_behaviour();
      Log_info("brwr: Home Assistant set %s = %s", name.c_str(), payload.c_str());
      if (redraw) xEventGroupSetBits(ha_events(), EV_REDRAW);
      if (resleep) xEventGroupSetBits(ha_events(), EV_RESLEEP);
    }
  }

  bool commands_pending() {
    if (!s_lock) return false;
    xSemaphoreTake(s_lock, portMAX_DELAY);
    bool pending = wake().cmd.length() || wake().show.length() || wake().selectScreen.length() ||
                   wake().allShow.length() || wake().allCmd.length();
    xSemaphoreGive(s_lock);
    return pending;
  }

  static void handle_message(const String &t, const String &payload) {
    if (t == "homeassistant/status") {
      if (payload == "online") xEventGroupSetBits(ha_events(), EV_HA_ONLINE);
      return;
    }
    if (t.startsWith("brwr-trmnl/all/")) {
      String name = t.substring(15);
      xSemaphoreTake(s_lock, portMAX_DELAY);
      if (name == "set/screens") {
        apply_setting("screens", payload);
      } else if (name == "show" && payload.length()) {
        wake().allShow = payload;
        xEventGroupSetBits(ha_events(), EV_COMMAND);
      } else if (name == "cmd" && payload.length()) {
        wake().allCmd = payload;
        xEventGroupSetBits(ha_events(), EV_COMMAND);
      }
      xSemaphoreGive(s_lock);
      return;
    }
    if (!t.startsWith(s_base + "/")) return;
    String name = t.substring(s_base.length() + 1);

    xSemaphoreTake(s_lock, portMAX_DELAY);
    if (name == "sync") {
      if (payload == s_syncToken) xEventGroupSetBits(ha_events(), EV_SYNCED);
    } else if (name == "set/screen") {
      if (payload.length()) {
        wake().selectScreen = payload;
        xEventGroupSetBits(ha_events(), EV_COMMAND);
      }
    } else if (name.startsWith("set/")) {
      apply_setting(name.substring(4), payload);
    } else if (name == "cmd") {
      if (payload.length()) {
        wake().cmd = payload;
        xEventGroupSetBits(ha_events(), EV_COMMAND);
      }
    } else if (name == "show") {
      if (payload.length()) {
        wake().show = payload;
        xEventGroupSetBits(ha_events(), EV_COMMAND);
      }
    }
    xSemaphoreGive(s_lock);
  }

  static void on_mqtt_event(void *, esp_event_base_t, int32_t event_id, void *event_data) {
    auto *e = (esp_mqtt_event_handle_t)event_data;
    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
      xEventGroupSetBits(ha_events(), EV_CONNECTED);
      break;
    case MQTT_EVENT_DISCONNECTED:
      xEventGroupClearBits(ha_events(), EV_CONNECTED);
      break;
    case MQTT_EVENT_DATA:
      // Large messages arrive in fragments; the topic is only in the first one.
      if (e->current_data_offset == 0) {
        s_rxTopic = String(e->topic, e->topic_len);
        s_rxData = "";
        s_rxData.reserve(e->total_data_len);
      }
      s_rxData.concat(e->data, e->data_len);
      if (e->current_data_offset + e->data_len >= e->total_data_len) handle_message(s_rxTopic, s_rxData);
      break;
    case MQTT_EVENT_ERROR:
      Log_error("brwr: MQTT error (type %d)", e->error_handle ? e->error_handle->error_type : -1);
      break;
    default:
      break;
    }
  }

  static bool mqtt_start(uint32_t timeout_ms) {
    ensure_ids();
    if (!s_lock) s_lock = xSemaphoreCreateMutex();
    Settings &s = settings();

    s_cfgHost = mqtt_host();
    if (s_cfgHost == s.haHost) s_cfgHost = ha_host();
    s_cfgUser = s.mqttUser;
    s_cfgPass = s.mqttPass;
    s_cfgClientId = "brwr-trmnl-" + s_id;
    s_cfgWillTopic = topic("status");

    esp_mqtt_client_config_t cfg = {};
    cfg.broker.address.hostname = s_cfgHost.c_str();
    cfg.broker.address.port = s.mqttPort;
    cfg.broker.address.transport = MQTT_TRANSPORT_OVER_TCP;
    cfg.credentials.client_id = s_cfgClientId.c_str();
    if (s_cfgUser.length()) cfg.credentials.username = s_cfgUser.c_str();
    if (s_cfgPass.length()) cfg.credentials.authentication.password = s_cfgPass.c_str();
    cfg.session.last_will.topic = s_cfgWillTopic.c_str();
    cfg.session.last_will.msg = "offline";
    cfg.session.last_will.msg_len = 7;
    cfg.session.last_will.qos = 1;
    cfg.session.last_will.retain = 1;
    cfg.session.keepalive = 120;
    cfg.network.timeout_ms = 5000;
    cfg.network.reconnect_timeout_ms = 5000;
    cfg.buffer.size = 2048;
    cfg.buffer.out_size = 6144; // discovery is ~5 kB

    s_client = esp_mqtt_client_init(&cfg);
    if (!s_client) return false;
    esp_mqtt_client_register_event(s_client, MQTT_EVENT_ANY, on_mqtt_event, nullptr);
    if (esp_mqtt_client_start(s_client) != ESP_OK) return false;

    EventBits_t bits = xEventGroupWaitBits(ha_events(), EV_CONNECTED, pdFALSE, pdFALSE, pdMS_TO_TICKS(timeout_ms));
    return bits & EV_CONNECTED;
  }

  // Subscribe, then publish a marker to ourselves. The broker delivers retained
  // messages for each subscription before anything published afterwards, so
  // once the marker comes back every retained setting and command is in.
  static bool mqtt_subscribe_and_sync(uint32_t timeout_ms) {
    for (const char *all : {"brwr-trmnl/all/set/screens", "brwr-trmnl/all/show", "brwr-trmnl/all/cmd"})
      esp_mqtt_client_subscribe(s_client, all, 1);
    const char *subs[] = {"set/+", "cmd", "show", "sync"};
    for (const char *suffix : subs)
      esp_mqtt_client_subscribe(s_client, topic(suffix).c_str(), 1);
    esp_mqtt_client_subscribe(s_client, "homeassistant/status", 1);

    s_syncToken = String((uint32_t)esp_random(), HEX);
    xEventGroupClearBits(ha_events(), EV_SYNCED);
    esp_mqtt_client_publish(s_client, topic("sync").c_str(), s_syncToken.c_str(), 0, 1, 0);
    EventBits_t bits = xEventGroupWaitBits(ha_events(), EV_SYNCED, pdFALSE, pdFALSE, pdMS_TO_TICKS(timeout_ms));
    return bits & EV_SYNCED;
  }

  // ---- outgoing ------------------------------------------------------------

  static uint32_t fnv1a(const String &s) {
    uint32_t h = 2166136261u;
    for (size_t i = 0; i < s.length(); i++)
      h = (h ^ (uint8_t)s[i]) * 16777619u;
    return h;
  }

  static void add_trigger(JsonObject cmps, const char *button, const char *subtype, const char *press,
                          const char *type) {
    String key = String("btn_") + button + "_" + press;
    JsonObject c = cmps[key].to<JsonObject>();
    c["p"] = "device_automation";
    c["atype"] = "trigger";
    c["t"] = topic("button");
    c["type"] = type;
    c["stype"] = subtype;
    c["pl"] = String(button) + "_" + press;
  }

  static JsonObject add_entity(JsonObject cmps, const char *key, const char *platform, const char *name) {
    JsonObject c = cmps[key].to<JsonObject>();
    c["p"] = platform;
    c["uniq_id"] = "brwr_trmnl_" + s_id + "_" + key;
    c["name"] = name;
    return c;
  }

  void ha_publish_discovery(bool force) {
    if (!mqtt_connected()) return;
    Settings &s = settings();
    JsonDocument doc;

    JsonObject dev = doc["dev"].to<JsonObject>();
    dev["ids"][0] = "brwr_trmnl_" + s_id;
    dev["name"] = "brwr-trmnl " + s_id;
    dev["mf"] = "brwr";
    dev["mdl"] = "brwr-trmnl 10.3\" e-paper";
    dev["sw"] = FW_VERSION_STRING "-brwr";
    dev["hw"] = "XIAO ESP32-S3 + IT8951";
    dev["cns"][0][0] = "mac";
    dev["cns"][0][1] = device_mac_address();
    JsonObject o = doc["o"].to<JsonObject>();
    o["name"] = "brwr-trmnl";
    o["sw"] = FW_VERSION_STRING "-brwr";
    o["url"] = ORIGIN_URL;
    doc["avty_t"] = topic("status");
    doc["stat_t"] = topic("state"); // shared by every entity below
    doc["qos"] = 1;

    JsonObject cmps = doc["cmps"].to<JsonObject>();
    JsonObject c;

    c = add_entity(cmps, "battery", "sensor", "Battery");
    c["dev_cla"] = "battery";
    c["unit_of_meas"] = "%";
    c["stat_cla"] = "measurement";
    c["val_tpl"] = "{{ value_json.battery }}";

    c = add_entity(cmps, "voltage", "sensor", "Battery voltage");
    c["dev_cla"] = "voltage";
    c["unit_of_meas"] = "V";
    c["stat_cla"] = "measurement";
    c["sug_dsp_prc"] = 2;
    c["ent_cat"] = "diagnostic";
    c["val_tpl"] = "{{ value_json.voltage }}";

    c = add_entity(cmps, "rssi", "sensor", "Wi-Fi signal");
    c["dev_cla"] = "signal_strength";
    c["unit_of_meas"] = "dBm";
    c["stat_cla"] = "measurement";
    c["ent_cat"] = "diagnostic";
    c["val_tpl"] = "{{ value_json.rssi }}";

    c = add_entity(cmps, "refreshed", "sensor", "Last refresh");
    c["dev_cla"] = "timestamp";
    c["ent_cat"] = "diagnostic";
    c["val_tpl"] = "{{ value_json.refreshed }}";

    c = add_entity(cmps, "showing", "sensor", "Showing");
    c["ic"] = "mdi:image-frame";
    c["val_tpl"] = "{{ value_json.showing }}";

    c = add_entity(cmps, "error", "sensor", "Last error");
    c["ent_cat"] = "diagnostic";
    c["ic"] = "mdi:alert-circle-outline";
    c["val_tpl"] = "{{ value_json.error }}";

    c = add_entity(cmps, "screen", "select", "Screen");
    c["cmd_t"] = topic("set/screen");
    c["val_tpl"] = "{{ value_json.screen }}";
    c["ret"] = true;
    c["ic"] = "mdi:monitor-dashboard";
    JsonArray ops = c["ops"].to<JsonArray>();
    ops.add(PLAYLIST);
    for (uint8_t i = 0; i < s.screenCount; i++)
      ops.add(s.screens[i].name);

    c = add_entity(cmps, "source", "select", "Image source");
    c["cmd_t"] = topic("set/source");
    c["val_tpl"] = "{{ value_json.source }}";
    c["ret"] = true;
    c["ent_cat"] = "config";
    c["ops"][0] = source_name(Source::Trmnl);
    c["ops"][1] = source_name(Source::HomeAssistant);

    c = add_entity(cmps, "power", "select", "Power mode");
    c["cmd_t"] = topic("set/power");
    c["val_tpl"] = "{{ value_json.power }}";
    c["ret"] = true;
    c["ent_cat"] = "config";
    c["ops"][0] = power_name(PowerMode::AlwaysReady);
    c["ops"][1] = power_name(PowerMode::DeepSleep);

    c = add_entity(cmps, "buttons", "select", "Buttons");
    c["cmd_t"] = topic("set/buttons");
    c["val_tpl"] = "{{ value_json.buttons }}";
    c["ret"] = true;
    c["ent_cat"] = "config";
    c["ops"][0] = button_mode_name(ButtonMode::Local);
    c["ops"][1] = button_mode_name(ButtonMode::HomeAssistantOnly);

    c = add_entity(cmps, "refresh", "number", "Refresh interval");
    c["cmd_t"] = topic("set/refresh");
    c["val_tpl"] = "{{ value_json.refresh }}";
    c["ret"] = true;
    c["ent_cat"] = "config";
    c["min"] = 0;
    c["max"] = 1440;
    c["step"] = 1;
    c["mode"] = "box";
    c["unit_of_meas"] = "min";
    c["ic"] = "mdi:timer-refresh-outline";

    c = add_entity(cmps, "hold", "number", "Hold commanded screen");
    c["cmd_t"] = topic("set/hold");
    c["val_tpl"] = "{{ value_json.hold }}";
    c["ret"] = true;
    c["ent_cat"] = "config";
    c["min"] = 1;
    c["max"] = 1440;
    c["step"] = 1;
    c["mode"] = "box";
    c["unit_of_meas"] = "min";
    c["ic"] = "mdi:pin-outline";

    c = add_entity(cmps, "vcom", "number", "Panel VCOM");
    c["cmd_t"] = topic("set/vcom");
    c["val_tpl"] = "{{ value_json.vcom }}";
    c["ret"] = true;
    c["ent_cat"] = "config";
    c["min"] = -3.0;
    c["max"] = -0.5;
    c["step"] = 0.01;
    c["mode"] = "box";
    c["unit_of_meas"] = "V";
    c["ic"] = "mdi:contrast-box";

    c = add_entity(cmps, "refresh_now", "button", "Refresh");
    c["cmd_t"] = topic("cmd");
    c["pl_prs"] = "refresh";
    c["ret"] = true;
    c.remove("stat_t");

    c = add_entity(cmps, "next", "button", "Next screen");
    c["cmd_t"] = topic("cmd");
    c["pl_prs"] = "next";
    c["ret"] = true;

    c = add_entity(cmps, "back", "button", "Previous screen");
    c["cmd_t"] = topic("cmd");
    c["pl_prs"] = "back";
    c["ret"] = true;

    c = add_entity(cmps, "on_screen", "image", "On screen");
    c["url_t"] = topic("image");

    const char *buttons[] = {"back", "refresh", "next"};
    const char *subtypes[] = {"button_1", "button_2", "button_3"};
    for (int i = 0; i < 3; i++) {
      add_trigger(cmps, buttons[i], subtypes[i], "short", "button_short_press");
      add_trigger(cmps, buttons[i], subtypes[i], "double", "button_double_press");
      add_trigger(cmps, buttons[i], subtypes[i], "long", "button_long_press");
    }

    String payload;
    serializeJson(doc, payload);
    uint32_t hash = fnv1a(payload);
    if (!force && hash == rtc.discoveryHash) return;
    mqtt_publish("homeassistant/device/brwr_trmnl_" + s_id + "/config", payload, true, 1);
    rtc.discoveryHash = hash;
    Log_info("brwr: published Home Assistant discovery (%u bytes)", payload.length());
  }

  static String iso8601(uint32_t epoch) {
    if (!epoch) return "";
    time_t t = epoch;
    struct tm tm;
    gmtime_r(&t, &tm);
    char buf[32];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &tm);
    return buf;
  }

  void ha_publish_state() {
    if (!mqtt_connected()) return;
    Settings &s = settings();
    JsonDocument doc;
    doc["battery"] = battery_percent(s_batteryVolts);
    doc["voltage"] = roundf(s_batteryVolts * 100) / 100;
    doc["rssi"] = WiFi.RSSI();
    doc["refreshed"] = iso8601(rtc.lastRefresh);
    doc["showing"] = rtc.shownName;
    // The Screen select only accepts its own options.
    bool listed = find_screen(rtc.shownName) >= 0;
    doc["screen"] = listed ? String(rtc.shownName) : String(PLAYLIST);
    doc["source"] = source_name(s.source);
    doc["power"] = power_name(s.power);
    doc["buttons"] = button_mode_name(s.buttons);
    doc["refresh"] = s.refreshMinutes;
    doc["hold"] = s.holdMinutes;
    doc["vcom"] = s.vcomMv ? -(s.vcomMv / 1000.0f) : -1.5f;
    doc["held_until"] = iso8601(hold_active() ? rtc.holdUntil : 0);
    doc["error"] = wake().error.length() ? wake().error : stuck_buttons_error();
    String payload;
    serializeJson(doc, payload);
    mqtt_publish(topic("state"), payload, true, 1);
    if (rtc.shownUrl[0]) mqtt_publish(topic("image"), rtc.shownUrl, true, 1);
  }

  void ha_publish_button(Button button, Press press) {
    if (press != PRESS_SHORT && press != PRESS_DOUBLE && press != PRESS_LONG) return;
    mqtt_publish(topic("button"), String(button_name(button)) + "_" + press_name(press), false, 1);
  }

  void ha_begin(float volts) {
    s_batteryVolts = volts;
    s_haHost = "";
    if (!mqtt_configured()) {
      Log_info("brwr: no Home Assistant address set; running as a plain TRMNL client");
      return;
    }
    if (!mqtt_start(6000)) {
      Log_error("brwr: can't reach the MQTT broker at %s:%u", mqtt_host().c_str(), settings().mqttPort);
      wake().error = "MQTT broker unreachable";
      mqtt_stop();
      return;
    }
    wake().haConnected = true;
    mqtt_publish(topic("status"), "online", true, 1);
    if (!mqtt_subscribe_and_sync(3000)) Log_error("brwr: timed out waiting for retained settings");
    ha_publish_discovery(false);
    // The idle loop already sent presses it captured before restarting us.
    if (wake().button != BUTTON_NONE && wake().resumed != Pending::Button)
      ha_publish_button(wake().button, wake().press);
  }

  void ha_report(https_request_err_e result) {
    wake().reported = true;
    if (!wake().haConnected) return;
    if (xEventGroupGetBits(ha_events()) & EV_HA_ONLINE) {
      ha_publish_discovery(true);
      xEventGroupClearBits(ha_events(), EV_HA_ONLINE);
    }
    if (wake().error.length() == 0 && result != HTTPS_NO_ERR && result != HTTPS_SUCCESS) {
      wake().error = https_request_err_str(result);
    }
    ha_publish_state();
    mqtt_flush(3000);
  }

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
