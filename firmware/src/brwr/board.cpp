#ifdef BOARD_BRWR_TRMNL
//
// Board support for the XIAO ESP32-S3 + Waveshare 10.3" e-Paper HAT.
// Wiring: hardware/wiring.md. Pin numbers: include/config.h and brwr/board.h.
//
#include <Arduino.h>
#include <FastEPD.h>
#include <SPI.h>
#include <brwr/board.h>
#include <brwr/brwr.h>
#include <brwr/settings.h>
#include <brwr/state.h>
#include <config.h>
#include <driver/gpio.h>
#include <driver/rtc_io.h>
#include <esp_sleep.h>
#include <trmnl_log.h>

extern FASTEPD bbep; // display.cpp

// FastEPD's IT8951 helpers (external linkage in FastEPD.inl).
void it8951WriteCmdCode(FASTEPDSTATE *pState, uint16_t cmd);
void it8951WriteData(FASTEPDSTATE *pState, uint16_t data);
uint16_t it8951ReadData(FASTEPDSTATE *pState);

namespace brwr {

  namespace {

    // FastEPD keeps its IT8951 state (chip select, SPI clock) in a protected
    // member. A pointer-to-member taken through a derived class reaches it
    // without modifying the library.
    struct EpdState : FASTEPD {
      static FASTEPDSTATE *of(FASTEPD &epd) { return &(epd.*(&EpdState::_state)); }
    };

    constexpr uint16_t IT8951_CMD_VCOM = 0x0039; // USDEF_I80_CMD_VCOM
    constexpr uint16_t VCOM_READ = 0x0000;
    constexpr uint16_t VCOM_WRITE = 0x0001;

  } // namespace

  void early_init() {
    rtc_init();
    settings_load();
    board_init();
  }

  bool wants_boot_logo() {
    return esp_sleep_get_wakeup_cause() == ESP_SLEEP_WAKEUP_UNDEFINED && !wake().drewScreen && !wake().lowBattery;
  }

  void board_init() {
    // The panel supply may still be held low from deep sleep; release the hold
    // and drive it low ourselves until FastEPD powers the HAT up.
    gpio_hold_dis((gpio_num_t)EPD_EN_PIN);
    gpio_deep_sleep_hold_dis();
    pinMode(EPD_EN_PIN, OUTPUT);
    digitalWrite(EPD_EN_PIN, LOW);

    panel_release_lines();

    for (uint8_t pin : BUTTON_PINS) {
      rtc_gpio_deinit((gpio_num_t)pin); // back to a digital pin after an ext1 wake
      pinMode(pin, INPUT_PULLUP);
    }
  }

  void panel_after_init() {
    FASTEPDSTATE *state = EpdState::of(bbep);

    // Hand-wired jumpers are slower than the reTerminal's PCB traces.
    state->spi_frequency = BRWR_IT8951_SPI_HZ;

    uint16_t vcom = settings().vcomMv;
    if (vcom < 500 || vcom > 5000) {
      Log_info("brwr: VCOM not set, keeping the driver default (-1.50 V). Set it in Home Assistant.");
      return;
    }
    it8951WriteCmdCode(state, IT8951_CMD_VCOM);
    it8951WriteData(state, VCOM_WRITE);
    it8951WriteData(state, vcom);

    it8951WriteCmdCode(state, IT8951_CMD_VCOM);
    it8951WriteData(state, VCOM_READ);
    uint16_t readback = it8951ReadData(state);
    Log_info("brwr: VCOM set to -%u mV (controller reports -%u mV)", vcom, readback);
  }

  void panel_release_lines() {
    // With the HAT unpowered, any pin driven high would feed its logic
    // through the protection diodes. Detach SPI and float every line; the
    // booster enable stays low (R4 pulls it down as well).
    SPI.end();
    const uint8_t lines[] = {EPD_CS_PIN, EPD_SCK_PIN, EPD_MOSI_PIN, EPD_MISO_PIN, EPD_RST_PIN, EPD_BUSY_PIN};
    for (uint8_t pin : lines) {
      pinMode(pin, INPUT);
    }
    digitalWrite(EPD_EN_PIN, LOW);
  }

  int battery_percent(float volts) {
    // Resting single-cell LiPo curve (typical), linear between points.
    static const float V[] = {3.30f, 3.60f, 3.70f, 3.75f, 3.80f, 3.85f, 3.95f, 4.05f, 4.15f};
    static const int P[] = {0, 10, 20, 30, 40, 50, 65, 80, 100};
    const int n = sizeof(V) / sizeof(V[0]);
    if (volts <= V[0]) return 0;
    if (volts >= V[n - 1]) return 100;
    for (int i = 1; i < n; i++) {
      if (volts < V[i]) {
        float t = (volts - V[i - 1]) / (V[i] - V[i - 1]);
        return (int)lroundf(P[i - 1] + t * (P[i] - P[i - 1]));
      }
    }
    return 100;
  }

  void sleep_prepare_pins() {
    // Keep the booster disabled through deep sleep.
    digitalWrite(EPD_EN_PIN, LOW);
    gpio_hold_en((gpio_num_t)EPD_EN_PIN);
    gpio_deep_sleep_hold_en();

    // Buttons: RTC pull-ups, wake when any of them goes low.
    uint64_t mask = 0;
    for (uint8_t pin : BUTTON_PINS) {
      rtc_gpio_init((gpio_num_t)pin);
      rtc_gpio_set_direction((gpio_num_t)pin, RTC_GPIO_MODE_INPUT_ONLY);
      rtc_gpio_pulldown_dis((gpio_num_t)pin);
      rtc_gpio_pullup_en((gpio_num_t)pin);
      mask |= 1ULL << pin;
    }
    esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_ON); // keeps the pull-ups powered
    esp_sleep_enable_ext1_wakeup(mask, ESP_EXT1_WAKEUP_ANY_LOW);
  }

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
