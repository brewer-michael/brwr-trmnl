#pragma once
//
// brwr-trmnl: board support and Home Assistant integration for the DIY
// 10.3" display (XIAO ESP32-S3 + Waveshare 10.3" e-Paper HAT, IT8951).
//
// Upstream files call these hooks from small `#ifdef BOARD_BRWR_TRMNL`
// blocks so the fork stays easy to rebase. Everything else lives in
// src/brwr/.
//
#ifdef BOARD_BRWR_TRMNL

#include <Arduino.h>
#include <types.h>

namespace brwr {

  // Front buttons, left to right.
  enum Button : uint8_t { BUTTON_NONE = 0, BUTTON_BACK = 1, BUTTON_REFRESH = 2, BUTTON_NEXT = 3 };
  // short < 1 s, double = two taps within 0.5 s, long 1-5 s, very long 5-15 s, reset >= 15 s
  enum Press : uint8_t { PRESS_NONE = 0, PRESS_SHORT, PRESS_DOUBLE, PRESS_LONG, PRESS_VERY_LONG, PRESS_RESET };

  const char *button_name(Button button);  // "back", "refresh", "next"
  const char *press_name(Press press);     // "short", "double", "long", "very_long", "reset"

// ---- Board (src/brwr/board.cpp) ----------------------------------------

// First thing in bl_init(): RTC state, settings, panel supply off, HAT
// lines released, buttons configured, sleep holds released.
  void early_init();
  void board_init();

  // After FastEPD has initialised the IT8951: set the panel's VCOM (printed on
  // its ribbon cable) and the SPI clock used for hand-wired jumpers.
  void panel_after_init();

  // After display_sleep(): make every HAT signal high-impedance so the
  // unpowered HAT is never fed through its I/O pins.
  void panel_release_lines();

  // Battery state of charge estimate from the resting voltage.
  int battery_percent(float volts);

  // ---- Wake handling (src/brwr/buttons.cpp) --------------------------------

  // Works out which button (if any) woke the device and how it was pressed.
  // Covers deep-sleep wakes (EXT1) and presses captured by the always-ready
  // idle loop before it restarted the device.
  bool button_wake(Button *button, Press *press);

  // Waits for the button to be released and classifies the press.
  Press classify_press(uint8_t pin);

  // ---- Home Assistant (src/brwr/ha.cpp, src/brwr/screens.cpp) -----------

  // Wi-Fi is up: connect to MQTT, publish discovery if needed and collect the
  // retained settings and commands from Home Assistant.
  void ha_begin(float volts);

  // What bl.cpp has to do for a button press; everything else is handled here.
  enum class ButtonAction : uint8_t {
    None,
    WifiSetup,       // REFRESH held 5-15 s: open the setup hotspot (upstream long press)
    FactoryReset,    // REFRESH held >= 15 s: forget credentials (upstream soft reset)
    SpecialFunction, // REFRESH double press: upstream TRMNL special function
  };

  // A button woke the device. Records it for Home Assistant (sent once MQTT is
  // up) and queues the local action (back / next / refresh).
  ButtonAction handle_button(Button button, Press press);

  // The display is initialised: show the "battery empty" screen if needed, and
  // do local actions that need no network (step back through cached TRMNL
  // screens) before Wi-Fi connects.
  void after_display_init(float battery_volts);

  // Called where upstream would fetch /api/display. Returns true if brwr drew
  // the screen itself: a Home Assistant command, the Home Assistant screens
  // source, or a screen held on display. `result` is set in that case.
  bool display_takeover(https_request_err_e *result);

  // Upstream drew a TRMNL server image (its URL is upstream's `filename`).
  void note_server_image(https_request_err_e result, const char *image_url);

  // After the refresh: publish state (battery, signal, what is on screen).
  void ha_report(https_request_err_e result);

  // Refresh interval to sleep for, after Home Assistant overrides and holds.
  uint32_t sleep_seconds(uint32_t upstream_seconds);

  // Never returns. Either idles with Wi-Fi and MQTT connected, ready for
  // commands and buttons ("always ready"), or deep-sleeps with timer and button
  // wake-ups. `seconds` == 0 means wake on buttons only.
  [[noreturn]] void sleep(uint32_t seconds);

  // True if the upstream TRMNL server flow (setup, /api/display, logs) should run.
  bool uses_trmnl_server();

  // Show upstream's logo screen? Only on power-up, and not over the
  // battery-empty screen. Button and timer wakes go straight to content.
  bool wants_boot_logo();

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
