#ifdef BOARD_BRWR_TRMNL
//
// Sleeping between refreshes.
//
// Deep sleep: everything off except the RTC; a timer or any button wakes
// the device, which then reconnects and polls. Commands from Home Assistant
// wait for that wake-up.
//
// Always ready: the ESP32-S3 light-sleeps between Wi-Fi beacons with Wi-Fi
// and MQTT still connected (needs CONFIG_PM_ENABLE and tickless idle; see
// sdkconfigs/sdkconfig.brwr_trmnl). A command, a button or the refresh timer
// then restarts the refresh cycle through a 20 ms deep sleep, so every refresh
// runs the same well-tested upstream path.
//
#include <Arduino.h>
#include <WiFi.h>
#include <battery.h>
#include <brwr/board.h>
#include <brwr/brwr.h>
#include <brwr/ha_internal.h>
#include <brwr/settings.h>
#include <brwr/state.h>
#include <driver/gpio.h>
#include <esp_pm.h>
#include <esp_sleep.h>
#include <esp_wifi.h>
#include <globals.h>
#include <trmnl_log.h>

namespace brwr {

  static constexpr uint32_t HOP_US = 20000;                  // restart through a 20 ms deep sleep
  static constexpr uint32_t WIFI_LOST_GIVE_UP_MS = 120000;   // then fall back to deep sleep
  static constexpr uint32_t STATE_REPORT_MS = 30 * 60 * 1000; // battery/signal while idling
  static constexpr uint32_t MIN_SLEEP_S = 5;

  static volatile uint32_t s_pressedPins = 0;
  static EventGroupHandle_t s_isrEvents = nullptr; // captured before the ISR is armed

  uint32_t sleep_seconds(uint32_t upstream_seconds) {
    Settings &s = settings();
    uint32_t secs = upstream_seconds;
    if (s.refreshMinutes > 0) {
      secs = s.refreshMinutes * 60u;
    } else if (s.source == Source::HomeAssistant) {
      secs = kDefaultHaRefreshMinutes * 60u;
    }
    if (hold_active()) secs = rtc.holdUntil - now_epoch() + 2; // wake when the hold ends
    return secs < MIN_SLEEP_S ? MIN_SLEEP_S : secs;
  }

  [[noreturn]] static void deep_sleep(uint32_t seconds, Pending pending) {
    rtc.pending = pending;
    mqtt_stop();
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);
    sleep_prepare_pins();
    if (seconds > 0) esp_sleep_enable_timer_wakeup((uint64_t)seconds * 1000000ULL);
    Log_info("brwr: deep sleep for %u s", (unsigned)seconds);
    esp_deep_sleep_start();
    for (;;) {
    }
  }

  [[noreturn]] static void hop(Pending pending) {
    // Leave cleanly (DISCONNECT, so Home Assistant doesn't see "offline"),
    // then restart through a very short deep sleep. The wake-up runs as a
    // timer wake: no logo, no button re-read.
    rtc.pending = pending;
    mqtt_stop();
    sleep_prepare_pins();
    esp_sleep_enable_timer_wakeup(HOP_US);
    esp_deep_sleep_start();
    for (;;) {
    }
  }

  static void IRAM_ATTR on_button(void *arg) {
    uint32_t pin = (uint32_t)arg;
    gpio_intr_disable((gpio_num_t)pin);
    s_pressedPins |= 1u << pin;
    BaseType_t woken = pdFALSE;
    xEventGroupSetBitsFromISR(s_isrEvents, EV_BUTTON, &woken);
    portYIELD_FROM_ISR(woken);
  }

  static void arm_buttons() {
    s_isrEvents = ha_events();
    gpio_install_isr_service(0); // "already installed" (by the Arduino core) is fine
    for (uint8_t pin : BUTTON_PINS) {
      gpio_set_intr_type((gpio_num_t)pin, GPIO_INTR_LOW_LEVEL);
      gpio_isr_handler_add((gpio_num_t)pin, on_button, (void *)(uint32_t)pin);
      gpio_wakeup_enable((gpio_num_t)pin, GPIO_INTR_LOW_LEVEL); // wakes the chip from light sleep
      gpio_intr_enable((gpio_num_t)pin);
    }
    esp_sleep_enable_gpio_wakeup();
  }

  static Button button_for_pin(uint8_t pin) {
    if (pin == BRWR_BUTTON_BACK_PIN) return BUTTON_BACK;
    if (pin == BRWR_BUTTON_NEXT_PIN) return BUTTON_NEXT;
    return BUTTON_REFRESH;
  }

  // Idles with Wi-Fi and MQTT up. Returns only if it had to give up (Wi-Fi
  // lost, power mode changed); every other outcome restarts the device.
  static void idle(uint32_t seconds) {
    esp_pm_config_t pm = {};
    pm.max_freq_mhz = 80;
    pm.min_freq_mhz = 40;
    pm.light_sleep_enable = true;
    esp_err_t err = esp_pm_configure(&pm);
    esp_pm_lock_handle_t awake = nullptr;
    if (err == ESP_OK) {
      esp_pm_lock_create(ESP_PM_NO_LIGHT_SLEEP, 0, "brwr_button", &awake);
    } else {
      Log_info("brwr: light sleep unavailable (%s); idling awake. Use the brwr_trmnl build on battery.",
               esp_err_to_name(err));
    }
    // Bits raised while retained settings synced at wake-up are stale: this
    // refresh already used them. A command that arrived since is not.
    xEventGroupClearBits(ha_events(), EV_REDRAW | EV_RESLEEP | EV_COMMAND);
    if (commands_pending()) hop(Pending::Command);

    esp_wifi_set_ps(WIFI_PS_MAX_MODEM);
    arm_buttons();

    uint32_t start = millis();
    uint32_t deadline_ms = seconds * 1000u;
    uint32_t lastReport = millis();
    uint32_t wifiLostSince = 0;
    Log_info("brwr: always ready; next refresh in %u s", (unsigned)seconds);

    for (;;) {
      uint32_t elapsed = (uint32_t)(millis() - start);
      if (seconds > 0 && elapsed >= deadline_ms) hop(Pending::Timer);
      uint32_t wait_ms = 60000;
      if (seconds > 0 && deadline_ms - elapsed < wait_ms) wait_ms = deadline_ms - elapsed;

      EventBits_t bits =
        xEventGroupWaitBits(ha_events(), EV_BUTTON | EV_COMMAND | EV_REDRAW | EV_RESLEEP | EV_HA_ONLINE, pdTRUE,
                            pdFALSE, pdMS_TO_TICKS(wait_ms));

      if (bits & EV_BUTTON) {
        if (awake) esp_pm_lock_acquire(awake); // time the press without dozing off
        uint32_t pins = s_pressedPins;
        s_pressedPins = 0;
        for (uint8_t pin : BUTTON_PINS) {
          if (!(pins & (1u << pin))) continue;
          Button button = button_for_pin(pin);
          Press press = classify_press(pin);
          Log_info("brwr: %s button (%s press)", button_name(button), press_name(press));
          ha_publish_button(button, press); // straight to Home Assistant
          bool local = settings().buttons == ButtonMode::Local || button == BUTTON_REFRESH;
          bool acts = press == PRESS_SHORT || press == PRESS_VERY_LONG || press == PRESS_RESET ||
                      (press == PRESS_DOUBLE && button == BUTTON_REFRESH);
          if (local && acts) {
            mqtt_flush(1000);
            rtc.pendingButton = button;
            rtc.pendingPress = press;
            hop(Pending::Button);
          }
          gpio_intr_enable((gpio_num_t)pin);
        }
        if (awake) esp_pm_lock_release(awake);
      }
      if (bits & EV_REDRAW) {
        rtc.forceRedraw = true;
        hop(Pending::Command);
      }
      if (bits & EV_COMMAND) hop(Pending::Command); // the command stays retained until it's handled
      if (bits & EV_RESLEEP) {
        if (settings().power == PowerMode::DeepSleep) {
          uint32_t done = (uint32_t)(millis() - start);
          uint32_t left = (seconds > 0 && done < deadline_ms) ? (deadline_ms - done) / 1000 : 0;
          deep_sleep(seconds > 0 ? left : 0, Pending::None);
        }
        seconds = sleep_seconds(refreshInterval.seconds());
        start = millis();
        deadline_ms = seconds * 1000u;
        ha_publish_state();
      }
      if (bits & EV_HA_ONLINE) {
        ha_publish_discovery(true);
        ha_publish_state();
      }

      if (WiFi.status() != WL_CONNECTED || !mqtt_connected()) {
        if (!wifiLostSince) wifiLostSince = millis();
        if (millis() - wifiLostSince > WIFI_LOST_GIVE_UP_MS) {
          Log_error("brwr: lost Wi-Fi/MQTT while idling; falling back to deep sleep");
          return;
        }
      } else {
        wifiLostSince = 0;
      }

      if (millis() - lastReport > STATE_REPORT_MS) {
        lastReport = millis();
        ha_publish_state();
      }
    }
  }

  [[noreturn]] void sleep(uint32_t seconds) {
    if (!wake().reported) ha_report(HTTPS_NO_ERR); // early exits (setup, retries) still report
    float volts = battery_volts();
    if (volts > 1.0f && volts < BRWR_BATTERY_EMPTY_V) {
      // Protect the cell and don't brown out mid-refresh: stop until a button is pressed after charging.
      Log_error("brwr: battery at %.2f V, sleeping until a button press", volts);
      wake().error = "Battery empty";
      ha_publish_state();
      mqtt_flush(2000);
      deep_sleep(0, Pending::None);
    }

    if (settings().power == PowerMode::AlwaysReady && mqtt_connected() && WiFi.status() == WL_CONNECTED) {
      idle(seconds);
      // idle() gave up: finish the current interval in deep sleep.
    }
    deep_sleep(seconds, Pending::None);
  }

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
