#pragma once
//
// State kept across sleep cycles (RTC memory: survives deep sleep, not power
// loss) and the hand-off between modules within one wake.
//
#ifdef BOARD_BRWR_TRMNL

#include <Arduino.h>
#include <brwr/brwr.h>

namespace brwr {

  // What the next wake should do before anything else. Set by the always-ready
  // idle loop just before it restarts the device through a short deep sleep.
  enum class Pending : uint8_t {
    None = 0,
    Timer,   // refresh interval elapsed
    Button,  // a front button (details in pendingButton/pendingPress)
    Command, // a Home Assistant command arrived over MQTT (re-read from the broker)
  };

  struct RtcState {
    uint32_t magic;
    Pending pending;
    Button pendingButton;
    Press pendingPress;
    uint32_t holdUntil;    // epoch seconds; while now < holdUntil the shown screen stays
    uint32_t lastRefresh;  // epoch seconds of the last redraw
    uint32_t shownCrc;     // CRC32 of the last image brwr drew (skip identical redraws)
    char shownName[48];    // "Playlist" or a screen name, reported to Home Assistant
    char shownUrl[384];    // image URL of what's on screen, for the HA image entity
    uint32_t discoveryHash; // hash of the last discovery payload published
    uint16_t wakeCount;
    bool forceRedraw;      // a setting changed (e.g. VCOM): redraw even if the image didn't
  };

  extern RtcState rtc;

  // Actions a button press asks for, decided in handle_button() and carried
  // out once Wi-Fi is up (display_takeover) or by bl.cpp (setup/reset).
  enum class Action : uint8_t {
    None = 0,
    Refresh,          // redraw the current screen / fetch the next playlist item
    Next,
    Back,
    WifiSetup,        // open the setup hotspot (upstream long press)
    FactoryReset,     // forget credentials (upstream 15 s press)
    SpecialFunction,  // upstream TRMNL special function (double press)
  };

  // Set during this wake and consumed by display_takeover().
  struct WakeState {
    Pending resumed = Pending::None; // why the idle loop restarted us, if it did
    Button button = BUTTON_NONE;
    Press press = PRESS_NONE;
    Action action = Action::None;

    // Commands from Home Assistant (one-shot, cleared on the broker once done)
    String cmd;          // "refresh" | "next" | "back"
    String selectScreen; // from the Screen select
    String show;         // JSON or plain text from <base>/show

    bool haConnected = false;
    bool drewScreen = false;
    bool lowBattery = false;
    bool reported = false;
    String error;        // last error, reported to Home Assistant
  };

  WakeState &wake();

  void rtc_init();
  bool hold_active();
  uint32_t now_epoch();
  void set_shown(const String &name, const String &url);

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
