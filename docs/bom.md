# Bill of materials

About **$240** for one display, $157 of it the e-paper panel. The
spreadsheet version, with part numbers and links, is
[`hardware/bom.csv`](../hardware/bom.csv).

Prices are in US dollars, without shipping or tax. "Seen" prices were
checked on 26 September 2026 (some through search results, where the
supplier's site couldn't be loaded); "typical" ones are ordinary prices for
common parts, which you may already have or can buy anywhere. Several small
parts only come in packs, so the first build costs more than the per-unit
total, and a second one much less.

## Electronics — $205.93

| Ref | Qty | Part | Notes | Price |
|---|---|---|---|---|
| U2 | 1 | [Waveshare 10.3inch e-Paper HAT](https://www.waveshare.com/10.3inch-e-paper-hat.htm) (SKU 18434) | 1872 × 1404, 16 grays. The kit includes the panel, the IT8951 driver board, the adapter board, the 40-pin flat cable and the 8-wire PH2.0 cable. The driver is shaped as a Raspberry Pi HAT, but no Pi is used: it's only the panel's controller, wired to the XIAO over SPI. Its Pi header and 8-pin socket come off in this build (see the [build guide](build-guide.md#3-prepare-the-driver-hat)). Also on Amazon (B08KDMY48R) | $157.00 seen |
| U1 | 1 | [Seeed Studio XIAO ESP32S3](https://www.seeedstudio.com/XIAO-ESP32S3-p-5627.html) (113991114) | 8 MB flash, 8 MB PSRAM, USB-C, U.FL antenna socket. Not the Sense version. Its bundled antenna is too tall for the case | $7.49 seen |
| ANT1 | 1 | [Taoglas FXP831](https://www.digikey.com/en/products/detail/FXP831.07.0100C/931-1121-ND/2690271) (FXP831.07.0100C) | Peel-and-stick Wi-Fi antenna, 45 × 7 mm, 100 mm lead with a U.FL plug. It sticks to a fin on the back cover. Any 2.4 GHz FPC antenna up to 45 × 7 mm with a U.FL lead of at least 100 mm works | $5.14 seen |
| U3 | 1 | [Adafruit MiniBoost 5V @ 1A](https://www.adafruit.com/product/4654) (4654) | TPS61023 booster with an enable pin that disconnects the output completely | $3.95 seen |
| U4 | 1 | TP4056 USB-C charger module with protection | 1 A, DW01A + FS8205A, pads B+/B− and OUT+/OUT−. Search "TP4056 Type-C protection"; 10-packs ~$8–10. **Buy one that lists 5.1k CC resistors.** Without them, a USB-C charger with a C-to-C cable sends no power and the module only charges from a USB-A-to-C cable ([power.md](power.md#charging)) | $1.00 typical |
| BT1 | 1 | LiPo 3.7 V 5000 mAh, 6 × 60 × 100 mm ("6060100") | With protection board and JST-PH 2.0 lead. **No thicker than 6 mm**, and **check the lead's polarity** | $16.00 typical |
| SW1–SW3 | 3 | Tactile switch 12 × 12 × 4.3 mm, flat plunger | Omron B3F-4000 or any equivalent; the printed caps press them | $1.65 |
| R1, R2 | 2 | 220 kΩ 1%, ¼ W | Battery voltage divider | $0.20 |
| R3 | 1 | 1 kΩ 1%, ¼ W | In series with the HAT's reset line | $0.10 |
| R4 | 1 | 4.7 kΩ 1%, ¼ W | Keeps the booster off while the ESP32 boots | $0.10 |
| C1 | 1 | 100 nF ceramic | Smooths the battery reading | $0.30 |
| C2 | 2 | 47 µF 10 V X5R ceramic, 1210 | 5 V at the HAT, two in parallel (Murata GRM32ER61A476KE20L). Low enough to lie flat on the carrier | $0.90 |
| C3 | 2 | 100 µF 6.3 V X5R ceramic, 1210 | Battery rail at the booster, two in parallel (Murata GRM32ER60J107ME20L) | $1.10 |
| J1 | 1 | JST-PH 2-pin pigtail | A short lead with a JST-PH plug for the battery, soldered to the carrier | $0.50 |
| J4 | 1 | JST-PH 4-pin plug and socket, pre-wired pair | Inline in the button lead, so the frame and the back cover come apart. Leads 20 cm or longer. J2 and J3 have no connector: their wires solder straight into the carrier, where there's no room for one | $1.00 |
| | 1 | 40-pin FFC, 0.5 mm pitch, same-side contacts (type A), 150 mm | Only if the kit's flat cable is too short: it has to reach from the adapter board to the HAT with the back cover propped open, about 10 cm | $2.00 |
| PCB1, PCB2 | 1 | Protoboard, double-sided, 2.54 mm, 9 × 15 cm | Both boards come out of one: the carrier (27 × 13 holes) and the 84 × 20 mm button strip. A 5 × 7 cm board is too short for either | $2.50 |
| | 1 | Hook-up wire | 26 AWG silicone for power, 28–30 AWG for signals | $5.00 |
| SW4 | 1 | Wire link | A short piece of the hook-up wire: it joins the charger's output to everything else. A slide switch fits the same holes, but it would be sealed inside the case | $0.00 |

## Mounting and enclosure — $36.40

| Ref | Qty | Part | Notes | Price |
|---|---|---|---|---|
| M1–M4 | 4 | [N52 disc magnet, 20 × 3 mm](https://suprememagnets.com/products/n52-neodymium-magnet-disc-20mm-od-x-3mm-h) | About 4.3–5.4 kg pull each, on thick steel. Hidden inside the back cover | $4.00 |
| | 4 | Steel disc, round, 20 mm across, 1.5–2 mm thick | Mild (magnetic) steel, one on each magnet inside the case. It works like the cup of a pot magnet: more grip on the door, less stray field inside. Steel blanks sold for magnets, or M10 flat washers (DIN 125: 20 mm across, 2 mm thick). The pockets are round, 20.3 mm: squares don't fit | $1.00 |
| | 4 | Self-adhesive rubber pad, 25 mm, 0.5–1 mm thick | Over each magnet on the back: grip, and no scratches on the door | $3.00 |
| | 1 m | Steel rod, 3 mm | Stiffens the thin case: two straight rods across the back and four bent L-rods in the frame's corners ([cut list](../hardware/enclosure/README.md#steel-rod-cut-list)) | $4.00 |
| | 1 | Two-part epoxy, 30-minute or slower | Rods, magnets and steel discs | $7.00 |
| | 9 | M3 heat-set insert (4 mm long) + M3 × 6 **countersunk** screw | Back cover to frame ([Adafruit 4255](https://www.adafruit.com/product/4255) or similar). Countersunk, so the heads sit flush | $2.25 |
| | 1 | M2.5 hardware | 2 heat-set inserts and 2 × M2.5 × 5 pan-head screws (button strip); 4 × M2.5 × 8 and 2 × M2.5 × 6 countersunk screws with 6 nuts (HAT, carrier) | $2.00 |
| | 250 g | PETG filament | Frame rails ~51 g, back halves ~110 g, caps ~2 g, desk stand ~70 g | $5.00 (at ~$20/kg) |
| | 1 | Foam tape: 1 mm double-sided, 0.5 mm for the window gasket | Holds the panel flat without point loads | $5.00 |
| | 1 | [Kapton tape](https://www.adafruit.com/product/3057), 10 mm | Insulates the back of the boards | $3.00 |
| | 3 | Zip ties, 2.5 mm | Hold the button wires in the three tie blocks up the back cover | $0.15 |

For a wall instead of the fridge: a thin steel plate for the magnets to hold
(for example 1 mm galvanised steel, about 200 × 150 mm), and two screws.

## Tools

- Soldering iron with a fine tip, and a heat-set insert tip (or an old tip
  you don't mind using for inserts)
- Multimeter (battery polarity, first power-up checks)
- 3D printer with a bed of at least **220 × 220 mm**. The two long frame
  rails print diagonally; with a 250 × 210 mm bed or bigger you can print
  the one-piece frame and back instead
- Flush cutters, wire strippers, tweezers, a hobby knife
- Hex keys, 1.5 mm (M2.5 countersunk screws) and 2 mm (M3), a small
  screwdriver for the button strip's pan-head screws, and small pliers or a
  5 mm nut driver for the M2.5 nuts
- A drill, or a pin vise, with a 2.7 mm bit: four mounting holes in the
  protoboards
- A vise (or two pairs of pliers) to bend the 3 mm rod, and a hacksaw or
  bolt cutters to cut it
- A computer with Chrome or Edge (flashing from the browser), or PlatformIO

## Changes from the first draft

The [README](../README.md) as first written listed a Pololu U3V16F5 booster,
used the XIAO's built-in charger, and the first enclosure was 25 mm deep.
This design changes that:

- **Adafruit MiniBoost instead of the Pololu U3V16F5.** The Pololu's `EN`
  pin only stops the switching; when it's off, the battery still reaches
  the output through the inductor and diode, so the HAT would be powered
  all the time at battery voltage. The MiniBoost's TPS61023 disconnects its
  output completely.
- **A TP4056 charger module.** The XIAO charges at only 100 mA, about 50
  hours for a 5000 mAh cell. The module charges at 1 A (5–6 hours) through
  its own USB-C port, and adds a second layer of battery protection.
- **13 mm thin, like the TRMNL X (12 mm):** the HAT loses its unused Pi
  header, a 7 mm antenna replaces the XIAO's 21 mm one, flat 4.3 mm switches
  replace 7.3 mm ones, ceramic capacitors replace electrolytics, and hidden
  3 mm disc magnets with steel backing replace 6 mm rubber pot magnets.
  Epoxied steel rods make up for the thinner walls.
