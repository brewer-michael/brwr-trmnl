#pragma once
//
// Settings for the Home Assistant side of brwr-trmnl, kept in their own NVS
// namespace ("brwr") so they survive upstream changes to the "data" namespace.
// The setup page writes the connection details; Home Assistant changes the
// rest over MQTT (retained messages, applied at the next wake).
//
#ifdef BOARD_BRWR_TRMNL

#include <Arduino.h>
#include <ArduinoJson.h>

namespace brwr {

  // Where scheduled screens come from.
  enum class Source : uint8_t {
    Trmnl = 0,         // TRMNL server: Terminus add-on, TRMNL cloud or any BYOS server
    HomeAssistant = 1, // Home Assistant dashboards rendered by the TRMNL HA add-on
  };

  enum class PowerMode : uint8_t {
    AlwaysReady = 0, // Wi-Fi stays associated in light sleep; commands land in seconds
    DeepSleep = 1,   // longest battery life; commands wait for the next wake
  };

  enum class ButtonMode : uint8_t {
    Local = 0,             // buttons change screens and also fire Home Assistant triggers
    HomeAssistantOnly = 1, // buttons only fire Home Assistant triggers
  };

  constexpr uint8_t kMaxScreens = 12;
  constexpr uint16_t kDefaultAddonPort = 10000; // TRMNL HA add-on (dashboard screenshots)
  constexpr uint16_t kDefaultTerminusPort = 2300;
  constexpr uint16_t kDefaultMqttPort = 1883;
  constexpr uint16_t kDefaultHaRefreshMinutes = 30; // Home Assistant screens, when not set

  struct Screen {
    String name; // shown in Home Assistant and matched by voice commands
    String path; // dashboard path for the TRMNL HA add-on, or a full http(s) image URL
  };

  struct Settings {
    // Connection (setup page)
    String haHost;    // Home Assistant address, e.g. 192.168.1.20
    String mqttHost;  // empty = haHost
    uint16_t mqttPort = kDefaultMqttPort;
    String mqttUser;
    String mqttPass;
    uint16_t addonPort = kDefaultAddonPort;

    // Behaviour (Home Assistant)
    Source source = Source::Trmnl;
    PowerMode power = PowerMode::AlwaysReady;
    ButtonMode buttons = ButtonMode::Local;
    uint16_t refreshMinutes = 0; // 0 = automatic (server's rate, or 30 min for HA screens)
    uint16_t holdMinutes = 60;   // how long a screen shown on command stays up
    uint16_t vcomMv = 0;         // panel VCOM in mV without the minus sign; 0 = driver default (1500)

  // Home Assistant screens
    Screen screens[kMaxScreens];
    uint8_t screenCount = 0;
    uint8_t currentScreen = 0;
  };

  Settings &settings();
  void settings_load();

  // Persist individual groups after a change.
  void settings_save_connection();
  void settings_save_behaviour();
  void settings_save_screens(const String &json);
  void settings_save_current_screen();
  void settings_clear(); // the 15-second reset: back to defaults

  // Parses the JSON list Home Assistant publishes:
  // [{"name":"Calendar","path":"fridge-dashboard/calendar"}, ...]
  bool settings_parse_screens(const String &json);
  String settings_screens_json(); // last accepted list, as stored

  bool mqtt_configured();
  String mqtt_host();

  // Image URL for a screen: full URLs pass through; dashboard paths become a
  // TRMNL HA add-on URL rendering 1872x1404 at 16 grays.
  String screen_url(const Screen &screen);
  String dashboard_url(const String &path);
  int find_screen(const String &name); // case-insensitive, -1 if not found

// Setup page (lib/wificaptive): current values as JSON, and saving the form.
  String portal_settings_json();
  void portal_save(JsonObject ha);

  const char *source_name(Source source);
  const char *power_name(PowerMode power);
  const char *button_mode_name(ButtonMode mode);

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
