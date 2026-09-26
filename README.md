# brwr-trmnl

**A 10.3" e-paper display for the fridge door, run by Home Assistant. Say
"show the calendar on the fridge" to your voice speaker, and it does.**

![brwr-trmnl on the fridge: a 10.3-inch e-paper panel in a printed frame with three buttons below it](docs/images/enclosure-front.png)

[TRMNL](https://trmnl.com) makes calm, low-power e-paper displays and
publishes its [firmware](https://github.com/usetrmnl/trmnl-firmware) and
[server API](https://docs.trmnl.com/go/diy/byos) so you can build and host
your own. brwr-trmnl is the large-format version (the TRMNL X's panel size
and resolution) built from parts you can buy anywhere, in a 3D-printed frame
that holds onto the fridge with magnets. Its firmware has Home Assistant
built in, so everything stays on your own network.

- **10.3", 1872 × 1404, 16 grays.** Sharp enough for small text,
  calendars and graphs at 227 dpi.
- **Three buttons, no touchscreen:** back, refresh and next, like a TRMNL.
  Presses are also Home Assistant triggers.
- **Lives on the fridge.** Four rubber-coated magnets on the back, placed
  and checked so their field stays clear of the electronics
  ([magnets.md](docs/magnets.md)). Or stand it on a desk.
- **Home Assistant built in.** One setup page. It appears as an MQTT device
  with its battery, what's on screen, a screen picker and settings.
- **Voice.** Any Home Assistant voice satellite (the open speaker, a Voice
  PE, your phone) can put a screen or a note on the fridge.
- **Your screens:** Home Assistant dashboards rendered for e-paper, or
  TRMNL's plugins and playlists from the self-hosted
  [Terminus](https://github.com/usetrmnl/terminus) server. No cloud account.
- **Weeks to months per charge,** depending on how quickly you want it
  to react ([power.md](docs/power.md)). USB-C charging.
- **About $233 in parts,** $157 of it the display.

## How it works

```
 Voice speaker ──► Home Assistant ─────────────────────────────┐
 "show the         Assist → script → MQTT                      │ MQTT: commands, settings
  calendar on      TRMNL HA add-on: dashboards → 16-gray PNG   │ ◄── state, battery, buttons
  the fridge"      Terminus add-on: TRMNL plugins, playlists   │
                          │ image                              │
                          ▼                                    ▼
                   brwr-trmnl: XIAO ESP32-S3 ──► IT8951 HAT ──► 10.3" e-paper
                   (sleeps between refreshes; the panel's supply is switched off)
```

Each refresh, the display wakes, switches on the 5 V supply to the panel's
IT8951 controller, fetches the current screen, draws it at 16 grays, reports
to Home Assistant over MQTT and goes back to sleep. In **Always ready** mode
it stays connected in light sleep between refreshes, so a voice command
is on screen in about ten seconds; in **Deep sleep** it only checks in when it wakes, and
the battery lasts months.

## Build one

| | |
|---|---|
| [Bill of materials](docs/bom.md) | Parts, suppliers and prices ([CSV](hardware/bom.csv)) |
| [Build guide](docs/build-guide.md) | Printing, soldering, flashing and assembly, step by step |
| [Wiring](hardware/wiring.md) | Pin map, [schematic](docs/images/schematic.svg), [wiring](docs/images/wiring.svg), [carrier board](docs/images/carrier-layout.svg) and [button board](docs/images/button-board.svg) layouts |
| [Enclosure](hardware/enclosure/README.md) | Parametric OpenSCAD frame, STLs and print settings |
| [Magnets](docs/magnets.md) | Holding force, and why the magnets don't disturb the electronics |
| [Power](docs/power.md) | Battery life, power modes, charging |
| [Home Assistant](docs/home-assistant.md) | Add-ons, setup, entities, screens, MQTT topics |
| [Voice](docs/voice.md) | Voice commands through Home Assistant Assist |

## Buttons

| | TRMNL server | Home Assistant screens |
|---|---|---|
| **BACK** | The previous image (from the display's cache, instant) | The previous screen |
| **REFRESH** | Fetch now (the playlist moves on) | Redraw the current screen |
| **NEXT** | The next playlist item | The next screen |
| **REFRESH** double press | TRMNL's special function | — |
| Any button, long press (1–5 s) | Only a Home Assistant trigger, for your own automations | same |
| **REFRESH**, hold 5 s | Wi-Fi and Home Assistant setup | same |
| **REFRESH**, hold 15 s (let go within 30 s) | Reset: forget Wi-Fi, the server and the Home Assistant settings | same |

Short and double presses also reach Home Assistant as triggers. Set
**Buttons** to *Home Assistant only* and every press is yours to automate
(setup and reset still work). A button held down for more than 30 seconds
counts as stuck: it's ignored, stops waking the display, and shows up as
**Last error** in Home Assistant until it's released.

## Firmware

A fork of [usetrmnl/trmnl-firmware](https://github.com/usetrmnl/trmnl-firmware),
imported into [`firmware/`](firmware/) with `git subtree`. The changes are
listed in [`firmware/BRWR.md`](firmware/BRWR.md). In short:

- a `brwr_trmnl` board for the XIAO ESP32-S3 and the Waveshare IT8951 HAT
  over SPI, using upstream's IT8951 driver for the reTerminal E1003 (the same
  1872 × 1404 panel)
- three buttons, a switched panel supply and a battery gauge
- Home Assistant over MQTT: discovery, state, settings, commands, button
  triggers, and **Always ready** light sleep
- Home Assistant screens rendered by the TRMNL HA add-on, as an alternative
  to a TRMNL server
- the Home Assistant fields on the setup page

It still works with TRMNL's cloud or any other TRMNL-compatible server. CI
builds both firmware variants on every push; the build output includes a
single `merged_firmware.bin` to flash at `0x0`.

```sh
cd firmware
pio run -e brwr_trmnl -t upload
```

## Repository

| Path | |
|---|---|
| [`firmware/`](firmware/) | trmnl-firmware with the `brwr_trmnl` board ([changes](firmware/BRWR.md)) |
| [`homeassistant/`](homeassistant/) | Package (screens, scripts, voice intents), voice sentences, example fridge dashboard |
| [`hardware/enclosure/`](hardware/enclosure/) | OpenSCAD source, export script, STLs |
| [`hardware/diagrams/`](hardware/diagrams/) | Scripts that draw the schematic and wiring diagrams |
| [`hardware/analysis/`](hardware/analysis/) | Magnetic field model behind [magnets.md](docs/magnets.md) |
| [`hardware/bom.csv`](hardware/bom.csv), [`hardware/wiring.md`](hardware/wiring.md) | Parts and wiring |
| [`docs/`](docs/) | Build guide and reference |

## Status

**Designed, not yet built.** What has been checked so far:

- The firmware builds for both variants, locally and in CI. It has not run
  on hardware yet.
- The Home Assistant package's templates, and the voice sentences against
  Home Assistant's sentence matcher.
- The enclosure renders, its parts are manifold, and its clearances are
  checked by assertions in the OpenSCAD source.
- The magnetic field numbers come from a model of a bare magnet (worse
  than the real, steel-cupped one).

The battery life, the IT8951's current draw, the magnets' grip on a real
fridge door and the print tolerances are estimates until someone builds
one. If you do, please open an issue with what you find.

## Credits

[TRMNL](https://trmnl.com) for the device, the firmware and the server API;
[Terminus](https://github.com/usetrmnl/terminus) and
[trmnl-home-assistant](https://github.com/usetrmnl/trmnl-home-assistant) for
the self-hosted server and the Home Assistant add-ons;
[FastEPD](https://github.com/bitbank2/FastEPD) for the IT8951 driver. This is
an independent project, not affiliated with TRMNL.

## License

GPL-3.0, the same as the TRMNL firmware it's based on. See [LICENSE](LICENSE).
