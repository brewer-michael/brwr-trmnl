#ifdef BOARD_BRWR_TRMNL
//
// Front buttons: which one woke the device, and how it was pressed.
//
//   short      < 1 s
//   double     two taps within 0.5 s
//   long       1-5 s
//   very long  5-15 s   (REFRESH: open the Wi-Fi setup hotspot)
//   reset      >= 15 s  (REFRESH: forget Wi-Fi and server credentials)
//
#include <Arduino.h>
#include <brwr/board.h>
#include <brwr/brwr.h>
#include <brwr/state.h>
#include <esp_sleep.h>
#include <trmnl_log.h>

namespace brwr {

  static constexpr uint32_t DEBOUNCE_MS = 30;
  static constexpr uint32_t DOUBLE_WINDOW_MS = 500;
  static constexpr uint32_t LONG_MS = 1000;
  static constexpr uint32_t VERY_LONG_MS = 5000;
  static constexpr uint32_t RESET_MS = 15000;
  static constexpr uint32_t MAX_HOLD_MS = 20000;

  static bool is_down(uint8_t pin) { return digitalRead(pin) == LOW; }

  static bool wait_for_second_press(uint8_t pin) {
    uint32_t start = millis();
    while (millis() - start < DOUBLE_WINDOW_MS) {
      if (is_down(pin)) {
        delay(DEBOUNCE_MS);
        while (is_down(pin) && millis() - start < MAX_HOLD_MS)
          delay(10);
        return true;
      }
      delay(10);
    }
    return false;
  }

  // `already_held_ms`: time the button was down before we started watching it
  // (the boot time after a deep-sleep wake-up).
  static Press classify(uint8_t pin, uint32_t already_held_ms) {
    if (!is_down(pin)) {
      // Released before we could look: a short tap.
      return wait_for_second_press(pin) ? PRESS_DOUBLE : PRESS_SHORT;
    }
    uint32_t start = millis();
    while (is_down(pin) && millis() - start < MAX_HOLD_MS)
      delay(10);
    uint32_t held = millis() - start + already_held_ms;
    if (held >= RESET_MS) return PRESS_RESET;
    if (held >= VERY_LONG_MS) return PRESS_VERY_LONG;
    if (held >= LONG_MS) return PRESS_LONG;
    return wait_for_second_press(pin) ? PRESS_DOUBLE : PRESS_SHORT;
  }

  Press classify_press(uint8_t pin) { return classify(pin, 0); }

  static Button button_for_pin(uint8_t pin) {
    switch (pin) {
    case BRWR_BUTTON_BACK_PIN:
      return BUTTON_BACK;
    case BRWR_BUTTON_REFRESH_PIN:
      return BUTTON_REFRESH;
    case BRWR_BUTTON_NEXT_PIN:
      return BUTTON_NEXT;
    default:
      return BUTTON_NONE;
    }
  }

  bool button_wake(Button *button, Press *press) {
    // Captured by the always-ready idle loop before it restarted us.
    if (wake().resumed == Pending::Button && rtc.pendingButton != BUTTON_NONE) {
      *button = rtc.pendingButton;
      *press = rtc.pendingPress;
      rtc.pendingButton = BUTTON_NONE;
      rtc.pendingPress = PRESS_NONE;
      Log_info("brwr: %s button (%s press) from always-ready idle", button_name(*button), press_name(*press));
      return true;
    }

    if (esp_sleep_get_wakeup_cause() != ESP_SLEEP_WAKEUP_EXT1) return false;

    uint64_t status = esp_sleep_get_ext1_wakeup_status();
    for (uint8_t pin : BUTTON_PINS) {
      if (status & (1ULL << pin)) {
        *button = button_for_pin(pin);
        *press = classify(pin, millis()); // millis() ~ time since the wake-up began
        Log_info("brwr: woken by the %s button (%s press)", button_name(*button), press_name(*press));
        return true;
      }
    }
    return false;
  }

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
