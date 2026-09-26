# Bill of materials

About **$234** for one display, $157 of it the e-paper panel. The
spreadsheet version, with part numbers and links, is
[`hardware/bom.csv`](../hardware/bom.csv).

Prices are in US dollars, without shipping or tax. "Seen" prices were
checked on the supplier's site on 26 September 2026; "typical" ones are
ordinary prices for common parts, which you may already have or can buy
anywhere. Several small parts only come in packs, so the first build costs
more than the per-unit total, and a second one much less.

## Electronics — $197.64

| Ref | Qty | Part | Notes | Price |
|---|---|---|---|---|
| U2 | 1 | [Waveshare 10.3inch e-Paper HAT](https://www.waveshare.com/10.3inch-e-paper-hat.htm) (SKU 18434) | 1872 × 1404, 16 grays, IT8951 driver board. The kit includes the panel, adapter board, 40-pin flat cable and the 8-wire PH2.0 cable. Also on Amazon (B08KDMY48R) | $157.00 seen |
| U1 | 1 | [Seeed Studio XIAO ESP32S3](https://www.seeedstudio.com/XIAO-ESP32S3-p-5627.html) (113991114) | 8 MB flash, 8 MB PSRAM, USB-C, U.FL antenna (included). Not the Sense version | $7.49 seen |
| U3 | 1 | [Adafruit MiniBoost 5V @ 1A](https://www.adafruit.com/product/4654) (4654) | TPS61023 booster with an enable pin that disconnects the output completely | $3.95 seen |
| U4 | 1 | TP4056 USB-C charger module with protection | 1 A, DW01A + FS8205A, pads B+/B− and OUT+/OUT−. Search "TP4056 Type-C protection"; 10-packs ~$8–10. Prefer one that lists 5.1k CC resistors | $1.00 typical |
| BT1 | 1 | LiPo 3.7 V 5000 mAh, 6 × 60 × 100 mm ("6060100") | With protection board and JST-PH 2.0 lead. A 10 × 50 × 80 mm ("105080") cell also fits. **Check the lead's polarity** | $16.00 typical |
| SW1–SW3 | 3 | Tactile switch 12 × 12 × 7.3 mm, through-hole | Omron B3F-4050 or any equivalent; the printed caps replace the switch caps | $1.80 typical |
| R1, R2 | 2 | 220 kΩ 1%, ¼ W | Battery voltage divider | $0.20 |
| R3 | 1 | 1 kΩ 1%, ¼ W | In series with the HAT's reset line | $0.10 |
| R4 | 1 | 4.7 kΩ 1%, ¼ W | Keeps the booster off while the ESP32 boots | $0.10 |
| C1 | 1 | 100 nF ceramic, radial | Smooths the battery reading | $0.30 |
| C2 | 1 | 220 µF 10 V low-ESR electrolytic | 5 V rail at the HAT (Panasonic EEU-FR1A221) | $0.40 |
| C3 | 1 | 470 µF 6.3 V low-ESR electrolytic | Battery rail at the booster (Panasonic EEU-FR0J471) | $0.45 |
| J1 | 1 | [JST-PH 2-pin socket or pigtail](https://www.adafruit.com/product/261) | So the battery can be unplugged | $0.75 seen |
| J2, J3 | 1 | Pin headers, 2.54 mm | A 1 × 40 male strip cut to 1 × 8 (HAT cable) and 1 × 4 (buttons); optionally 2 × 1 × 7 female for the XIAO | $1.00 |
| PCB1, PCB2 | 2 | Protoboard, double-sided, 2.54 mm, 5 × 7 cm | Cut to 70 × 35 mm (carrier) and 84 × 20 mm (buttons) | $1.60 |
| | 1 | Hook-up wire | 26 AWG silicone for power, 28–30 AWG for signals | $5.00 |
| SW4 | 1 | Slide switch, SPDT (optional) | Power switch for storage | $0.50 |

## Mounting and enclosure — $36.60

| Ref | Qty | Part | Notes | Price |
|---|---|---|---|---|
| M1–M4 | 4 | [Rubber-coated pot magnet, Ø22 mm, M4 thread](https://www.supermagnete.de/eng/magnet-systems-internal-threads/neodymium-magnet-system-22mm-black-rubber-coated-with-internal-thread_ITNG-22) (supermagnete ITNG-22) | ~5.9 kg pull and ~1.8 kg shear each, on thick steel. Any 22 mm rubber-coated magnet with an M4 female thread works; for another size, change the enclosure parameter | $18.00 (≈ €4.07 each) |
| | 4 | M4 × 6 mm button-head screw, A2 stainless | Holds each magnet from inside. **No longer than 6 mm** | $1.00 |
| | 8 | M3 heat-set insert (4.0 mm hole × 5 mm) + M3 × 8 screw | Back cover to bezel ([Adafruit 4255](https://www.adafruit.com/product/4255) or similar) | $2.00 |
| | 8 | M2.5 heat-set insert + M2.5 screw | Driver board (4), carrier (2), button strip (2) | $1.60 |
| | 4 | M2.5 × 10 mm standoff | Lifts the driver board | $1.00 |
| | 250 g | PETG filament | Bezel, back cover, button caps, stand | $5.00 (at ~$20/kg) |
| | 1 | Foam tape: 1 mm double-sided, 0.5 mm for the window gasket | Holds the panel flat without point loads | $5.00 |
| | 1 | [Kapton tape](https://www.adafruit.com/product/3057), 10 mm | Insulates the back of the boards | $3.00 |

## Tools

- Soldering iron with a fine tip, and a heat-set insert tip (or an old tip
  you don't mind using for inserts)
- Multimeter (battery polarity, first power-up checks)
- 3D printer with a bed of at least **250 × 210 mm** for the bezel (a
  Prusa MK4 or Bambu P1S/X1 fits; a 220 × 220 mm bed does not)
- Flush cutters, wire strippers, tweezers, a hobby knife
- A computer with Chrome or Edge (flashing from the browser), or PlatformIO

## Changes from the first draft

The [README](../README.md) as first written listed a Pololu U3V16F5 booster
and used the XIAO's built-in charger. This design replaces both:

- **Adafruit MiniBoost instead of the Pololu U3V16F5.** The Pololu's `EN`
  pin only stops the switching; when it's off, the battery still reaches
  the output through the inductor and diode, so the HAT would be powered
  all the time at battery voltage. The MiniBoost's TPS61023 disconnects its
  output completely.
- **A TP4056 charger module.** The XIAO charges at only 100 mA, about 50
  hours for a 5000 mAh cell. The module charges at 1 A (5–6 hours) through
  its own USB-C port, and adds a second layer of battery protection.
