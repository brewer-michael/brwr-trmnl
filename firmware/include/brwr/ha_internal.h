#pragma once
//
// Shared between the Home Assistant modules (ha.cpp, screens.cpp, sleep.cpp).
//
#ifdef BOARD_BRWR_TRMNL

#include <Arduino.h>
#include <brwr/brwr.h>
#include <freertos/FreeRTOS.h>
#include <freertos/event_groups.h>

namespace brwr {

  // Event bits raised by the MQTT task.
  enum : EventBits_t {
    EV_CONNECTED = BIT0,
    EV_SYNCED = BIT1,     // all retained messages up to our sync marker have arrived
    EV_COMMAND = BIT2,    // a one-shot command (screen, cmd, show) is waiting
    EV_REDRAW = BIT3,     // a setting that changes the picture (source, screens, VCOM)
    EV_RESLEEP = BIT4,    // a setting that changes the sleep plan (power mode, refresh)
    EV_HA_ONLINE = BIT5,  // Home Assistant restarted: publish discovery again
    EV_BUTTON = BIT6,     // raised by the idle loop's GPIO interrupt
  };

  EventGroupHandle_t ha_events();

  String topic(const char *suffix); // "brwr-trmnl/<id>/<suffix>"
  bool mqtt_connected();
  void mqtt_publish(const String &topic, const String &payload, bool retain, int qos = 1);
  void mqtt_clear_retained(const char *suffix); // delete a handled one-shot command
  bool mqtt_flush(uint32_t timeout_ms);         // wait until queued QoS 1 messages are acknowledged
  void mqtt_stop();                             // graceful: no last-will "offline"

  bool commands_pending(); // a one-shot command arrived after display_takeover() ran

  void ha_publish_state();
  void ha_publish_button(Button button, Press press);
  void ha_publish_discovery(bool force);

  String ha_host(); // Home Assistant host, with .local names resolved once per wake
  float battery_volts();

  void show_battery_empty(); // screens.cpp

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
