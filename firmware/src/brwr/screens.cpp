#ifdef BOARD_BRWR_TRMNL
//
// What goes on the screen: Home Assistant commands, the "Home Assistant
// screens" source, holds, and the buttons' back/next/refresh actions.
// Anything not handled here falls through to upstream's TRMNL server flow.
//
#include <Arduino.h>
#include <ArduinoJson.h>
#include <FastEPD.h>
#include <Preferences.h>
#include <brwr/board.h>
#include <brwr/brwr.h>
#include <brwr/ha_internal.h>
#include <brwr/settings.h>
#include <brwr/state.h>
#include <config.h>
#include <display.h>
#include <displayed_image.h>
#include <esp_rom_crc.h>
#include <filesystem.h>
#include <globals.h>
#include <services/http_retry_request.h>
#include <trmnl_log.h>

#include "fonts/Roboto_Black_24.h"

extern FASTEPD bbep; // display.cpp

namespace brwr {

  static const char *PLAYLIST = "Playlist";
  static constexpr uint32_t RENDER_TIMEOUT_S = 60; // the add-on may cold-start a browser

// ---- drawing ----------------------------------------------------------------

// A plain text notice (errors, "battery empty"). 1-bit, centred.
  static void show_message(const String &title, const String &detail) {
    bbep.setMode(BB_MODE_1BPP);
    bbep.fillScreen(BBEP_WHITE);
    bbep.setFont(Roboto_Black_24);
    bbep.setTextColor(BBEP_BLACK, BBEP_WHITE);
    BB_RECT r;
    int y = bbep.height() / 2 - 40;
    bbep.getStringBox(title.c_str(), &r);
    bbep.setCursor((bbep.width() - r.w) / 2, y);
    bbep.print(title);
    if (detail.length()) {
      bbep.getStringBox(detail.c_str(), &r);
      bbep.setCursor((bbep.width() - r.w) / 2, y + 60);
      bbep.print(detail);
    }
    bbep.fullUpdate(CLEAR_SLOW, false);
    DisplayedImage::clear();
    rtc.shownCrc = 0;
  }

  void show_battery_empty() {
    bbep.setMode(BB_MODE_1BPP);
    bbep.fillScreen(BBEP_WHITE);
    // A large empty battery, readable from across the kitchen.
    const int w = 520, h = 260, t = 16;
    const int x = (bbep.width() - w) / 2, y = (bbep.height() - h) / 2 - 80;
    for (int i = 0; i < t; i++)
      bbep.drawRect(x + i, y + i, w - 2 * i, h - 2 * i, BBEP_BLACK);
    bbep.fillRect(x + w, y + h / 2 - 60, 40, 120, BBEP_BLACK);
    bbep.fillRect(x + t + 14, y + t + 14, 40, h - 2 * (t + 14), BBEP_BLACK);
    bbep.setFont(Roboto_Black_24);
    bbep.setTextColor(BBEP_BLACK, BBEP_WHITE);
    const char *msg = "Battery empty - charge from the CHARGE port, then press any button";
    BB_RECT r;
    bbep.getStringBox(msg, &r);
    bbep.setCursor((bbep.width() - r.w) / 2, y + h + 110);
    bbep.print(msg);
    bbep.fullUpdate(CLEAR_SLOW, false);
    DisplayedImage::clear();
    rtc.shownCrc = 0;
    set_shown("Battery empty", "");
  }

  // Downloads an image and draws it. Skips the panel refresh when the bytes
  // are identical to what is already on screen, unless `force`.
  static bool show_url(const String &url, const String &name, bool force, https_request_err_e *result) {
    Log_info("brwr: showing '%s' from %s", name.c_str(), url.c_str());
    HttpRetryRequestConfig cfg;
    cfg.url = url;
    cfg.readTimeoutSeconds = RENDER_TIMEOUT_S;
    HttpRetryRequest request(cfg);
    https_request_err_e err = request.execute();
    if (err != HTTPS_NO_ERR) {
      *result = err;
      wake().error = "Couldn't load " + name + " (" + https_request_err_str(err) + ", HTTP " + request.httpCode() + ")";
      Log_error("brwr: %s", wake().error.c_str());
      return false;
    }
    uint8_t *body = request.body();
    uint32_t size = request.bodySize();
    bool png = size > 8 && body[0] == 0x89 && body[1] == 'P' && body[2] == 'N' && body[3] == 'G';
    bool jpeg = size > 2 && body[0] == 0xff && body[1] == 0xd8;
    bool bmp = size > 2 && body[0] == 'B' && body[1] == 'M';
    if (!png && !jpeg && !bmp) {
      *result = HTTPS_WRONG_IMAGE_FORMAT;
      wake().error = name + " is not a PNG, JPEG or BMP image";
      return false;
    }
    if (png && size >= MAX_IMAGE_SIZE) {
      *result = HTTPS_IMAGE_FILE_TOO_BIG;
      wake().error = name + " is too large (" + String(size / 1024) + " KB)";
      return false;
    }
    uint32_t crc = esp_rom_crc32_le(0, body, size);
    if (!force && crc == rtc.shownCrc && url == rtc.shownUrl) {
      Log_info("brwr: '%s' hasn't changed; leaving the panel alone", name.c_str());
      set_shown(name, url);
      *result = HTTPS_NO_ERR;
      return true;
    }
    display_show_image(body, size, true);
    DisplayedImage::clear(); // upstream's own image cache no longer matches the panel
    rtc.shownCrc = crc;
    rtc.lastRefresh = now_epoch();
    set_shown(name, url);
    wake().drewScreen = true;
    wake().error = "";
    *result = HTTPS_SUCCESS;
    return true;
  }

  static bool show_screen(uint8_t index, bool force, https_request_err_e *result) {
    Settings &s = settings();
    if (index >= s.screenCount) return false;
    return show_url(screen_url(s.screens[index]), s.screens[index].name, force, result);
  }

  static bool show_current_screen(bool force, https_request_err_e *result) {
    Settings &s = settings();
    if (s.screenCount == 0) {
      wake().error = "No Home Assistant screens yet: add them in the brwr_trmnl package";
      if (strcmp(rtc.shownName, "No screens") != 0) {
        show_message("No Home Assistant screens yet", "Add them in the brwr_trmnl package, then press REFRESH");
        set_shown("No screens", "");
      }
      *result = HTTPS_NO_ERR;
      return true;
    }
    return show_screen(s.currentScreen, force, result);
  }

  static void start_hold(uint16_t minutes) {
    uint32_t now = now_epoch();
    rtc.holdUntil = (minutes > 0 && now) ? now + minutes * 60u : 0;
  }

  // TRMNL server source: step through images already downloaded, like the
  // TRMNL X touch bar. Uses upstream's playlist order in NVS.
  static bool show_cached(int offset) {
    String order = preferences.getString(PREFERENCES_PLAYLIST_ORDER_KEY, "");
    String items[MAX_CACHED_IMAGES];
    int count = 0, start = 0;
    while (start <= (int)order.length() && count < MAX_CACHED_IMAGES) {
      int sep = order.indexOf('|', start);
      String entry = sep < 0 ? order.substring(start) : order.substring(start, sep);
      if (entry.length() && filesystem_file_exists(entry.c_str())) items[count++] = entry;
      if (sep < 0) break;
      start = sep + 1;
    }
    if (count == 0) {
      Log_info("brwr: no cached screens to browse");
      return false;
    }
    String current = preferences.getString(PREFERENCES_BROWSE_PATH_KEY, "");
    if (current.isEmpty()) current = preferences.getString(PREFERENCES_CURRENT_PATH_KEY, "");
    int idx = count - 1;
    for (int i = 0; i < count; i++) {
      if (items[i] == current) idx = i;
    }
    int next = (idx + offset + count) % count;
    int size = 0;
    uint8_t *buf = display_read_file(items[next].c_str(), &size);
    if (!buf || size <= 0) return false;
    display_show_image(buf, size, true);
    free(buf);
    DisplayedImage::remember(items[next].c_str());
    preferences.putString(PREFERENCES_BROWSE_PATH_KEY, items[next]);
    rtc.shownCrc = 0;
    rtc.lastRefresh = now_epoch();
    set_shown(PLAYLIST, "");
    wake().drewScreen = true;
    Log_info("brwr: browsing cached screens %d/%d", next + 1, count);
    return true;
  }

  // ---- commands -------------------------------------------------------------

  enum class Outcome { Handled, ToServer, Ignored };

  // <base>/show: {"screen": "Calendar"} | {"path": "fridge/note", "name": "Note"}
  //              | {"url": "http://...", "name": "Doorbell"}, each with optional "hold" (minutes).
  //              A bare screen name or URL also works.
  static Outcome handle_show(const String &payload, https_request_err_e *result) {
    Settings &s = settings();
    String screenName, url, name;
    int hold = -1;
    if (payload.startsWith("{")) {
      JsonDocument doc;
      if (deserializeJson(doc, payload)) {
        wake().error = "Show command is not valid JSON";
        return Outcome::Ignored;
      }
      screenName = doc["screen"] | "";
      String path = doc["path"] | "";
      url = doc["url"] | "";
      name = doc["name"] | "";
      hold = doc["hold"] | -1;
      if (url.isEmpty() && path.length()) url = dashboard_url(path);
    } else if (payload.startsWith("http://") || payload.startsWith("https://")) {
      url = payload;
    } else {
      screenName = payload;
    }

    if (screenName.length()) {
      int idx = find_screen(screenName);
      if (idx < 0) {
        wake().error = "No screen called " + screenName;
        return Outcome::Ignored;
      }
      if (s.source == Source::HomeAssistant && hold < 0) {
        s.currentScreen = idx; // it becomes the scheduled screen
        settings_save_current_screen();
        rtc.holdUntil = 0;
        show_screen(idx, true, result);
        return Outcome::Handled;
      }
      url = screen_url(s.screens[idx]);
      name = s.screens[idx].name;
    }
    if (url.isEmpty()) {
      wake().error = "Show command needs a screen, path or url";
      return Outcome::Ignored;
    }
    if (name.isEmpty()) name = "Home Assistant";
    if (show_url(url, name, true, result)) start_hold(hold >= 0 ? hold : s.holdMinutes);
    return Outcome::Handled;
  }

  // The Screen select in Home Assistant.
  static Outcome handle_select(const String &option, https_request_err_e *result) {
    Settings &s = settings();
    rtc.holdUntil = 0;
    if (option.equalsIgnoreCase(PLAYLIST)) {
      if (s.source == Source::HomeAssistant) {
        show_current_screen(true, result);
        return Outcome::Handled;
      }
      return Outcome::ToServer;
    }
    int idx = find_screen(option);
    if (idx < 0) {
      wake().error = "No screen called " + option;
      return Outcome::Ignored;
    }
    if (s.source == Source::HomeAssistant) {
      s.currentScreen = idx;
      settings_save_current_screen();
      show_screen(idx, true, result);
    } else if (show_screen(idx, true, result)) {
      start_hold(s.holdMinutes);
    }
    return Outcome::Handled;
  }

  static Action action_for_cmd(const String &cmd) {
    if (cmd.equalsIgnoreCase("next")) return Action::Next;
    if (cmd.equalsIgnoreCase("back") || cmd.equalsIgnoreCase("previous")) return Action::Back;
    if (cmd.equalsIgnoreCase("refresh")) return Action::Refresh;
    return Action::None;
  }

  // ---- hooks ------------------------------------------------------------------

  bool uses_trmnl_server() { return settings().source == Source::Trmnl; }

  ButtonAction handle_button(Button button, Press press) {
    WakeState &w = wake();
    w.button = button;
    w.press = press;

    // Setup and reset stay on the REFRESH button whatever the button mode.
    if (button == BUTTON_REFRESH && press == PRESS_RESET) return ButtonAction::FactoryReset;
    if (button == BUTTON_REFRESH && press == PRESS_VERY_LONG) return ButtonAction::WifiSetup;
    if (settings().buttons == ButtonMode::HomeAssistantOnly) return ButtonAction::None;

    if (press == PRESS_SHORT) {
      if (button == BUTTON_BACK) w.action = Action::Back;
      if (button == BUTTON_NEXT) w.action = Action::Next;
      if (button == BUTTON_REFRESH) w.action = Action::Refresh;
    } else if (button == BUTTON_REFRESH && press == PRESS_DOUBLE && uses_trmnl_server()) {
      return ButtonAction::SpecialFunction; // upstream's TRMNL special function
    }
    return ButtonAction::None;
  }

  void after_display_init(float battery_volts) {
    WakeState &w = wake();
    if (battery_volts > 1.0f && battery_volts < BRWR_BATTERY_EMPTY_V) {
      // Stop refreshing; tell the user once, then sleep until a button press (sleep.cpp).
      w.lowBattery = true;
      if (strcmp(rtc.shownName, "Battery empty") != 0) show_battery_empty();
      return;
    }
    // Browsing back through cached TRMNL screens needs no network: do it now
    // so the panel responds before Wi-Fi connects.
    if (w.action == Action::Back && uses_trmnl_server() && show_cached(-1)) {
      rtc.holdUntil = 0;
      w.action = Action::None;
    }
  }

  bool display_takeover(https_request_err_e *result) {
    WakeState &w = wake();
    Settings &s = settings();
    *result = HTTPS_NO_ERR;
    if (w.lowBattery) return true;

    bool force = rtc.forceRedraw;
    rtc.forceRedraw = false;
    if (force) DisplayedImage::clear(); // upstream redraws even an unchanged playlist image

  // 1. One-shot commands from Home Assistant, deleted from the broker once read.
    if (w.show.length()) {
      String payload = w.show;
      w.show = "";
      mqtt_clear_retained("show");
      if (handle_show(payload, result) == Outcome::Handled) return true;
    }
    if (w.selectScreen.length()) {
      String option = w.selectScreen;
      w.selectScreen = "";
      mqtt_clear_retained("set/screen");
      Outcome o = handle_select(option, result);
      if (o == Outcome::Handled) return true;
      if (o == Outcome::ToServer) return false;
    }
    if (w.cmd.length()) {
      Action a = action_for_cmd(w.cmd);
      w.cmd = "";
      mqtt_clear_retained("cmd");
      if (a != Action::None) w.action = a;
    }

    // 2. Buttons (or the matching Home Assistant buttons).
    Action action = w.action;
    w.action = Action::None;
    switch (action) {
    case Action::Refresh:
      rtc.holdUntil = 0;
      if (s.source == Source::HomeAssistant) return show_current_screen(true, result);
      return false; // the server sends the next playlist item
    case Action::Next:
      rtc.holdUntil = 0;
      if (s.source == Source::HomeAssistant && s.screenCount > 0) {
        s.currentScreen = (s.currentScreen + 1) % s.screenCount;
        settings_save_current_screen();
        return show_current_screen(true, result);
      }
      return false;
    case Action::Back:
      rtc.holdUntil = 0;
      if (s.source == Source::HomeAssistant && s.screenCount > 0) {
        s.currentScreen = (s.currentScreen + s.screenCount - 1) % s.screenCount;
        settings_save_current_screen();
        return show_current_screen(true, result);
      }
      if (w.drewScreen || show_cached(-1)) return true;
      return false;
    default:
      break;
    }
    if (w.drewScreen) return true; // already browsed back before Wi-Fi came up

  // 3. A commanded screen is being held.
    if (hold_active() && !force) {
      Log_info("brwr: holding '%s' for another %u s", rtc.shownName, (unsigned)(rtc.holdUntil - now_epoch()));
      return true;
    }
    rtc.holdUntil = 0;

    // 4. Scheduled refresh.
    if (s.source == Source::HomeAssistant) return show_current_screen(force, result);
    return false; // upstream: /api/display on the TRMNL server
  }

  void note_server_image(https_request_err_e result, const char *image_url) {
    // Upstream drew (or kept) a playlist image from the TRMNL server.
    if (wake().drewScreen) return;
    if (result == HTTPS_SUCCESS || result == HTTPS_NO_ERR) {
      set_shown(PLAYLIST, image_url && image_url[0] ? String(image_url) : String(rtc.shownUrl));
      if (result == HTTPS_SUCCESS) rtc.lastRefresh = now_epoch();
      rtc.shownCrc = 0;
    }
  }

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
