# brwr-trmnl

**A 10.3" e-paper dashboard for Home Assistant, built from off-the-shelf parts:
TRMNL's open-source firmware on an ESP32-S3, with Home Assistant built in, served
entirely from your own network.**

[TRMNL](https://trmnl.com) makes calm, low-power e-paper displays, and publishes
its [firmware](https://github.com/usetrmnl/trmnl-firmware) and
[server API](https://docs.trmnl.com/go/diy/byos) so you can build and host your own.
This project builds the large-format version, the same panel size and resolution
as the TRMNL X, from parts you can buy anywhere, in a 3D-printed frame. The
firmware ships already set up for Home Assistant, so there's no cloud account
and nothing to wire together after you flash it.

- **10.3", 1872 × 1404, 16 grays**: sharp enough for small text, calendars and
  graphs at 227 PPI.
- **Home Assistant first**: the setup page asks for your Home Assistant address
  and the device does the rest. It shows your dashboards, TRMNL plugins and
  playlists from the [Terminus](https://github.com/usetrmnl/terminus) add-on,
  and appears in Home Assistant as a device with battery, Wi-Fi signal and a
  button.
- **Local only**: no TRMNL account, no BYOD licence, and nothing leaves your
  network. TRMNL's cloud is still an option if you want its plugin library.
- **Months per charge**: the ESP32-S3 sleeps between refreshes, and the panel
  controller is powered off entirely while it does.
- **Off-the-shelf**: an e-paper HAT, a XIAO board, a boost converter and a
  battery. There's one small resistor divider to solder; everything else plugs
  together.
- **A parametric enclosure**: an OpenSCAD picture frame that stands on a desk or
  hangs on a wall, printed without supports.

## How it works

```
 brwr-trmnl (XIAO ESP32-S3)                    Home Assistant
 ┌──────────────────────────────┐   wake     ┌─────────────────────────────────┐
 │ sleep (deep sleep, panel off)│  ───────►  │ Terminus add-on (TRMNL BYOS)    │
 │   │ timer or button          │  GET image │  plugins, playlists, schedules  │
 │   ▼                          │  ◄──────── │  or: TRMNL HA add-on            │
 │ wake, power up IT8951 ───────┼─► 10.3"    │   screenshots of HA dashboards, │
 │ draw, report, sleep again    │   e-paper  │   dithered to 16 grays          │
 │                              │  ───────►  │ MQTT: battery, Wi-Fi, button,   │
 │ battery ─► boost ─► 5 V      │   state    │  refresh interval, refresh now  │
 └──────────────────────────────┘            └─────────────────────────────────┘
```

On each wake the device:

1. Switches on the 5 V supply to the panel's IT8951 controller.
2. Asks the server for the current screen (`/api/display`) and draws it at 16
   grays.
3. Publishes its state to Home Assistant over MQTT and picks up any settings
   changed there since it last woke.
4. Switches the panel supply off and sleeps until the next refresh or a button
   press.

## Home Assistant integration

The difference from stock TRMNL firmware is that Home Assistant is part of the
firmware, not something you set up afterwards.

- **One setup page.** On first boot the device opens a Wi-Fi hotspot. Its setup
  page asks for your Wi-Fi network, your Home Assistant address, and MQTT
  details if your broker needs them. It fills in the server address for the
  [Terminus add-on](https://github.com/usetrmnl/trmnl-home-assistant) itself
  (port 2300), so you don't need the *Advanced › Custom Server* step.
- **Two image sources.**
  - *Terminus* (default): the full TRMNL experience, run locally. Plugins,
    playlists and recipes, managed from the Terminus dashboard inside Home
    Assistant.
  - *Home Assistant dashboard*: the device fetches a pre-rendered screenshot
    of a Lovelace dashboard from the
    [TRMNL HA add-on](https://github.com/usetrmnl/trmnl-home-assistant/blob/main/trmnl-ha/DOCS.md)'s
    fetch URL. The add-on handles the rendering, dithering and 16-gray
    palette, so a dashboard designed at 1872 × 1404 appears as you laid it out.
- **A device in Home Assistant, over MQTT discovery.** Nothing extra to install
  in Home Assistant beyond an MQTT broker (Mosquitto add-on).

  | Entity | Type | |
  |---|---|---|
  | Battery | sensor | percentage and voltage |
  | Wi-Fi signal | sensor | RSSI at the last wake |
  | Last refresh | sensor | timestamp |
  | Button | device trigger | single, double and long press, for automations |
  | Refresh interval | number | applied at the next wake |
  | Image source | select | Terminus or Home Assistant dashboard |
  | Refresh now | button | applied at the next wake, or at once if the device is awake |

  The device sleeps most of the time, so settings changed in Home Assistant
  are published as retained MQTT messages and picked up on the next wake.

## Hardware

| | |
|---|---|
| Display | [Waveshare 10.3inch e-Paper HAT](https://www.waveshare.com/wiki/10.3inch_e-Paper_HAT): 1872 × 1404, 16 grays, IT8951 controller, driven over SPI. The flexible HAT (D) version also works and is lighter. |
| Microcontroller | Seeed Studio XIAO ESP32S3 (8 MB flash, 8 MB PSRAM, built-in LiPo charger, USB-C) |
| Power | 3.7 V LiPo, 5000 mAh or larger, JST-PH 2.0 connector |
| 5 V for the panel | Pololu U3V16F5 boost regulator, switched off in sleep via its EN pin |
| Battery sense | 2 × 220 kΩ resistors (voltage divider into an ADC pin) |
| Controls | 1 × 12 mm tactile button (wake, refresh, and Home Assistant triggers) |
| Enclosure | PETG or PLA picture frame, stands on a desk or hangs on a wall; M2.5 screws |

About $180 in parts, most of it the panel. The bill of materials will list
suppliers and alternatives.

### Wiring

| XIAO ESP32S3 | GPIO | To |
|---|---|---|
| D0 | 1 | Button to GND (wake from deep sleep) |
| D1 | 2 | Battery divider midpoint |
| D2 | 3 | HAT `CS` |
| D3 | 4 | HAT `HRDY` |
| D4 | 5 | HAT `RST` |
| D5 | 6 | Boost regulator `EN` |
| D8 | 7 | HAT `SCLK` |
| D9 | 8 | HAT `MISO` |
| D10 | 9 | HAT `MOSI` |
| BAT+ / BAT− | | LiPo; boost regulator `VIN` / `GND` |
| GND | | HAT `GND` |

The boost regulator's 5 V output goes to the HAT's `5V` pin. Set the HAT's
interface switch to **SPI**, and set the panel's VCOM value (printed on the
panel's ribbon cable) in the firmware configuration. The wrong VCOM gives a
washed-out image.

## Firmware

A fork of [usetrmnl/trmnl-firmware](https://github.com/usetrmnl/trmnl-firmware)
(PlatformIO, Arduino on ESP-IDF), with:

- a `brwr_trmnl` build environment for the XIAO ESP32S3 and the pins above
- an IT8951 display driver for the 1872 × 1404 panel, with 4-bit (16-gray)
  images decoded into PSRAM and streamed to the controller
- panel power switching through the boost regulator
- the Home Assistant setup page, image sources and MQTT device described above
- everything else unchanged, so the device still works with TRMNL's cloud or
  any other BYOS server

Changes are kept as small, separate commits so they can be rebased onto new
upstream releases, and offered upstream where they're useful to others.

## Getting started

1. **Build**: wire the parts on the desk, then print and assemble the frame.
2. **Flash** from a browser, or build with PlatformIO:

   ```sh
   pio run -e brwr_trmnl -t upload
   ```

3. **Home Assistant**: install the Mosquitto broker and the
   [Terminus add-on](https://github.com/usetrmnl/trmnl-home-assistant).
   Optionally add the TRMNL HA add-on to show Lovelace dashboards.
4. **Connect**: join the `brwr-trmnl` Wi-Fi hotspot, enter your Wi-Fi and Home
   Assistant details, and the device appears in Home Assistant under
   *Settings › Devices › MQTT*.

## Repository (planned)

| Path | |
|---|---|
| `firmware/` | Fork of trmnl-firmware with the `brwr_trmnl` environment |
| `hardware/enclosure/` | Parametric OpenSCAD frame and export script |
| `hardware/wiring.md` | Wiring and power budget |
| `homeassistant/` | Example dashboards sized for 1872 × 1404, and automations using the button |
| `docs/` | Build guide, bill of materials, Home Assistant guide |

## Status

**Design stage.** This README is the specification; nothing has been built or
flashed yet. The parts, pins and power design follow the datasheets, but the
battery life, the IT8951 controller's current draw and the enclosure dimensions
have still to be measured on real hardware.

## Credits

[TRMNL](https://trmnl.com) for the device concept, firmware and server API,
[Terminus](https://github.com/usetrmnl/terminus) for the self-hosted server, and
[trmnl-home-assistant](https://github.com/usetrmnl/trmnl-home-assistant) for the
Home Assistant add-ons. This is an independent project, not affiliated with
TRMNL.

## License

GPL-3.0, the same as the TRMNL firmware it's based on. See [LICENSE](LICENSE).
