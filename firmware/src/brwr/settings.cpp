#ifdef BOARD_BRWR_TRMNL

#include <ArduinoJson.h>
#include <Preferences.h>
#include <brwr/settings.h>
#include <trmnl_log.h>

namespace brwr {

  static const char *NS = "brwr";

  // NVS keys (max 15 characters)
  static const char *K_HA_HOST = "ha_host";
  static const char *K_MQTT_HOST = "mqtt_host";
  static const char *K_MQTT_PORT = "mqtt_port";
  static const char *K_MQTT_USER = "mqtt_user";
  static const char *K_MQTT_PASS = "mqtt_pass";
  static const char *K_ADDON_PORT = "addon_port";
  static const char *K_SOURCE = "source";
  static const char *K_POWER = "power";
  static const char *K_BUTTONS = "buttons";
  static const char *K_REFRESH = "refresh_min";
  static const char *K_HOLD = "hold_min";
  static const char *K_VCOM = "vcom_mv";
  static const char *K_SCREENS = "screens";
  static const char *K_CURRENT = "screen";

  static Settings s_settings;
  static String s_screensJson;

  Settings &settings() { return s_settings; }

  void settings_load() {
    Preferences p;
    if (!p.begin(NS, true)) {
      // Namespace doesn't exist yet (first boot): keep the defaults.
      Log_info("brwr: no saved settings, using defaults");
      return;
    }
    Settings &s = s_settings;
    s.haHost = p.getString(K_HA_HOST, "");
    s.mqttHost = p.getString(K_MQTT_HOST, "");
    s.mqttPort = p.getUShort(K_MQTT_PORT, kDefaultMqttPort);
    s.mqttUser = p.getString(K_MQTT_USER, "");
    s.mqttPass = p.getString(K_MQTT_PASS, "");
    s.addonPort = p.getUShort(K_ADDON_PORT, kDefaultAddonPort);
    s.source = (Source)p.getUChar(K_SOURCE, (uint8_t)Source::Trmnl);
    s.power = (PowerMode)p.getUChar(K_POWER, (uint8_t)PowerMode::AlwaysReady);
    s.buttons = (ButtonMode)p.getUChar(K_BUTTONS, (uint8_t)ButtonMode::Local);
    s.refreshMinutes = p.getUShort(K_REFRESH, 0);
    s.holdMinutes = p.getUShort(K_HOLD, 60);
    s.vcomMv = p.getUShort(K_VCOM, 0);
    String json = p.getString(K_SCREENS, "");
    s.currentScreen = p.getUChar(K_CURRENT, 0);
    p.end();

    if (json.length() > 0) settings_parse_screens(json);
    if (s.currentScreen >= s.screenCount) s.currentScreen = 0;
    Log_info("brwr: settings loaded (ha=%s, source=%s, power=%s, %d screens)", s.haHost.c_str(), source_name(s.source),
             power_name(s.power), s.screenCount);
  }

  void settings_save_connection() {
    Preferences p;
    p.begin(NS, false);
    p.putString(K_HA_HOST, s_settings.haHost);
    p.putString(K_MQTT_HOST, s_settings.mqttHost);
    p.putUShort(K_MQTT_PORT, s_settings.mqttPort);
    p.putString(K_MQTT_USER, s_settings.mqttUser);
    p.putString(K_MQTT_PASS, s_settings.mqttPass);
    p.putUShort(K_ADDON_PORT, s_settings.addonPort);
    p.end();
  }

  void settings_save_behaviour() {
    Preferences p;
    p.begin(NS, false);
    p.putUChar(K_SOURCE, (uint8_t)s_settings.source);
    p.putUChar(K_POWER, (uint8_t)s_settings.power);
    p.putUChar(K_BUTTONS, (uint8_t)s_settings.buttons);
    p.putUShort(K_REFRESH, s_settings.refreshMinutes);
    p.putUShort(K_HOLD, s_settings.holdMinutes);
    p.putUShort(K_VCOM, s_settings.vcomMv);
    p.end();
  }

  void settings_save_screens(const String &json) {
    Preferences p;
    p.begin(NS, false);
    p.putString(K_SCREENS, json);
    p.putUChar(K_CURRENT, s_settings.currentScreen);
    p.end();
  }

  void settings_save_current_screen() {
    Preferences p;
    p.begin(NS, false);
    p.putUChar(K_CURRENT, s_settings.currentScreen);
    p.end();
  }

  bool settings_parse_screens(const String &json) {
    JsonDocument doc;
    DeserializationError err = deserializeJson(doc, json);
    if (err || !doc.is<JsonArray>()) {
      Log_error("brwr: screens list is not a JSON array (%s)", err.c_str());
      return false;
    }
    Settings &s = s_settings;
    String previous = s.screenCount > 0 ? s.screens[s.currentScreen].name : String();
    uint8_t count = 0;
    for (JsonObject item : doc.as<JsonArray>()) {
      if (count >= kMaxScreens) break;
      const char *name = item["name"] | "";
      const char *path = item["path"] | (item["url"] | "");
      if (!*name || !*path) continue;
      s.screens[count].name = name;
      s.screens[count].path = path;
      count++;
    }
    s.screenCount = count;
    s_screensJson = json;
    // Keep showing the same screen if it survived the update.
    s.currentScreen = 0;
    if (previous.length() > 0) {
      int idx = find_screen(previous);
      if (idx >= 0) s.currentScreen = idx;
    }
    return true;
  }

  String settings_screens_json() { return s_screensJson; }

  bool mqtt_configured() { return mqtt_host().length() > 0; }

  String mqtt_host() { return s_settings.mqttHost.length() > 0 ? s_settings.mqttHost : s_settings.haHost; }

  String dashboard_url(const String &path) {
    String p = path;
    if (!p.startsWith("/")) p = "/" + p;
    String url = "http://" + s_settings.haHost + ":" + String(s_settings.addonPort) + p;
    url += (p.indexOf('?') >= 0) ? "&" : "?";
    // 1872x1404, Floyd-Steinberg dithered to 16 grays, 4-bit PNG: what the panel shows natively.
    url += "viewport=1872x1404&dithering&dither_method=floyd-steinberg&palette=gray-16&format=png";
    return url;
  }

  String screen_url(const Screen &screen) {
    if (screen.path.startsWith("http://") || screen.path.startsWith("https://")) return screen.path;
    return dashboard_url(screen.path);
  }

  int find_screen(const String &name) {
    for (uint8_t i = 0; i < s_settings.screenCount; i++) {
      if (s_settings.screens[i].name.equalsIgnoreCase(name)) return i;
    }
    return -1;
  }

  // "http://homeassistant.local:8123/lovelace" -> "homeassistant.local"
  static String host_only(String host) {
    host.trim();
    int scheme = host.indexOf("://");
    if (scheme >= 0) host = host.substring(scheme + 3);
    int end = host.length();
    for (const char *sep : {"/", ":"}) {
      int i = host.indexOf(sep);
      if (i >= 0 && i < end) end = i;
    }
    return host.substring(0, end);
  }

  String portal_settings_json() {
    JsonDocument doc;
    Settings &s = s_settings;
    doc["host"] = s.haHost;
    doc["source"] = s.source == Source::HomeAssistant ? "ha" : "trmnl";
    doc["mqttUser"] = s.mqttUser;
    doc["mqttHost"] = s.mqttHost;
    doc["mqttPort"] = s.mqttPort;
    doc["hasPassword"] = s.mqttPass.length() > 0;
    if (s.vcomMv) doc["vcom"] = -(s.vcomMv / 1000.0f);
    String out;
    serializeJson(doc, out);
    return out;
  }

  void portal_save(JsonObject ha) {
    Settings &s = s_settings;
    s.haHost = host_only(ha["host"] | "");
    s.mqttHost = host_only(ha["mqttHost"] | "");
    s.mqttUser = ha["mqttUser"] | "";
    String pass = ha["mqttPass"] | "";
    if (pass.length() || s.mqttUser.isEmpty()) s.mqttPass = pass; // blank keeps the saved password
    int port = ha["mqttPort"] | 0;
    s.mqttPort = (port > 0 && port < 65536) ? port : kDefaultMqttPort;
    float vcom = fabsf(ha["vcom"] | 0.0f);
    if (vcom >= 0.5f && vcom <= 5.0f) s.vcomMv = (uint16_t)lroundf(vcom * 1000.0f);
    String source = ha["source"] | "trmnl";
    s.source = source == "ha" ? Source::HomeAssistant : Source::Trmnl;
    settings_save_connection();
    settings_save_behaviour();
    Log_info("brwr: setup page saved Home Assistant at '%s', screens from %s", s.haHost.c_str(), source_name(s.source));
  }

  const char *source_name(Source source) {
    return source == Source::HomeAssistant ? "Home Assistant screens" : "TRMNL server";
  }

  const char *power_name(PowerMode power) { return power == PowerMode::DeepSleep ? "Deep sleep" : "Always ready"; }

  const char *button_mode_name(ButtonMode mode) {
    return mode == ButtonMode::HomeAssistantOnly ? "Home Assistant only" : "Change screens";
  }

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
