# brwr-trmnl changes to trmnl-firmware

This directory is [usetrmnl/trmnl-firmware](https://github.com/usetrmnl/trmnl-firmware)
imported with `git subtree`, plus the changes below for the brwr-trmnl board:
a Seeed XIAO ESP32-S3 driving a Waveshare 10.3" e-Paper HAT (IT8951 over SPI,
1872 × 1404, 16 grays), three front buttons, and Home Assistant over MQTT.

Upstream base: `f5f87b7` (main, 2026-09-21, v1.8.16 + 30 commits).

## Build

```sh
cd firmware
pio run -e brwr_trmnl -t upload        # recommended
pio device monitor -e brwr_trmnl       # logs over USB
```

| Environment | Framework | Use |
|---|---|---|
| `brwr_trmnl` | Arduino as an ESP-IDF component | Recommended. Power management is enabled, so **Always ready** idles in light sleep with Wi-Fi and MQTT connected. |
| `brwr_trmnl_debug` | same | Waits for the serial monitor at boot and logs more. |
| `brwr_trmnl_arduino` | precompiled Arduino core | Builds without downloading ESP-IDF components. It has no light sleep, so **Always ready** stays fully awake (~25 mA): use it on USB power. |

Each build also writes `.pio/build/<env>/merged_firmware.bin`, a single image
to flash at offset `0x0` (`esptool.py --chip esp32s3 write_flash 0x0 merged_firmware.bin`).

## What changed

Everything new lives in `src/brwr/` and `include/brwr/`. Upstream files only
gain small `#ifdef BOARD_BRWR_TRMNL` blocks that call into it:

| File | Change |
|---|---|
| `platformio.ini` | `brwr_trmnl`, `brwr_trmnl_debug` and `brwr_trmnl_arduino` environments (appended). |
| `boards/brwr_trmnl_8MB.csv` | Partition table for the XIAO's 8 MB flash: two 3 MB app slots, 1.9 MB LittleFS image cache. |
| `sdkconfigs/sdkconfig.brwr_trmnl` | Copy of the reTerminal E1003 config with 8 MB flash, `CONFIG_PM_ENABLE` and FreeRTOS tickless idle. |
| `scripts/extra/post_build_brwr.py` | Writes the merged image. |
| `include/config.h` | Pins, battery ADC pin, `brwr-trmnl` hostname, and `API_DEVICE_MODEL` (`x`, so Terminus serves 1872 × 1404 16-gray screens). |
| `src/display.cpp` | Device-list entry; IT8951 init shared with the E1003, then VCOM and SPI clock; HAT pins released after sleep. |
| `src/bl.cpp` | Hooks: early init, three buttons, no logo on button or timer wakes, Home Assistant before the server fetch, state report, sleep. Keeps Wi-Fi up after the download. Skips server-pushed OTA and log uploads without a TRMNL server. Keeps the cached-screen order for the Back button. |
| `src/bl.cpp`, `src/services/device_setup.cpp` | Send `API_DEVICE_MODEL` in the `Model` header. |
| `src/CMakeLists.txt` | Requires `mqtt` and `esp_pm`. |
| `lib/wificaptive/` | Setup page: Home Assistant address, screen source, MQTT login and panel VCOM. The section only appears when the firmware reports it, so other boards are unchanged. Hotspot name `brwr-trmnl-XXXXXX`. |

Why no over-the-air updates from the server: the device reports itself as a
TRMNL X to get the right screen format, and a TRMNL X firmware image would not
run on this hardware. Flash updates over USB (or the merged image).

## Updating from upstream

```sh
git subtree pull --prefix=firmware https://github.com/usetrmnl/trmnl-firmware.git <tag-or-commit> --squash
```

Conflicts, if any, are in the `BOARD_BRWR_TRMNL` blocks listed above. Then
build `brwr_trmnl` and `brwr_trmnl_arduino`; CI (`.github/workflows/firmware.yml`)
builds both on every push.
