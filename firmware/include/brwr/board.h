#pragma once
//
// brwr-trmnl pin map (XIAO ESP32-S3). The e-paper pins are in config.h next
// to upstream's other boards; everything else is here. See hardware/wiring.md.
//
//   D0  GPIO1   BACK button to GND         (RTC pin: wakes from deep sleep)
//   D1  GPIO2   REFRESH button to GND      (RTC pin)
//   D2  GPIO3   NEXT button to GND         (RTC pin)
//   D3  GPIO4   battery divider 220k/220k  (ADC1_CH3)
//   D4  GPIO5   HAT CS
//   D5  GPIO6   MiniBoost EN (panel 5 V), 4.7k pull-down
//   D6  GPIO43  HAT RST through 1 kOhm
//   D7  GPIO44  HAT HRDY
//   D8  GPIO7   HAT SCK
//   D9  GPIO8   HAT MISO
//   D10 GPIO9   HAT MOSI
//
#ifdef BOARD_BRWR_TRMNL

#include <stdint.h>

#define BRWR_BUTTON_BACK_PIN    1
#define BRWR_BUTTON_REFRESH_PIN 2
#define BRWR_BUTTON_NEXT_PIN    3

// SPI clock for the IT8951 once it's running. FastEPD uses 20 MHz on
// Seeed's reTerminal PCB; 12 MHz leaves margin for 10-20 cm jumper wires
// and still loads a full 16-gray frame in about a second.
#ifndef BRWR_IT8951_SPI_HZ
#define BRWR_IT8951_SPI_HZ 12000000
#endif

// Below this the booster can't hold 5 V through a full refresh; stop
// refreshing and wait for a charge.
#define BRWR_BATTERY_EMPTY_V 3.35f

namespace brwr {

  constexpr uint8_t BUTTON_PINS[3] = {BRWR_BUTTON_BACK_PIN, BRWR_BUTTON_REFRESH_PIN, BRWR_BUTTON_NEXT_PIN};

  // Holds the booster off and arms the ext1 button wake-up.
  void sleep_prepare_pins();

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
