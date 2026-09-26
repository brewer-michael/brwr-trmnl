# Build guide

From a box of parts to a display on the fridge. Plan on a weekend: about a
day of printing, which runs unattended, and an afternoon of soldering and
assembly.

**Before you start**, read the whole guide once, and skim
[wiring.md](../hardware/wiring.md) and the
[schematic](images/schematic.svg).

| You need | |
|---|---|
| Parts | [Bill of materials](bom.md) |
| Tools | Soldering iron with a fine tip and a heat-set insert tip, multimeter, flush cutters, wire strippers, tweezers, hobby knife |
| Printer | Bed at least **250 × 210 mm** (the bezel is 229 × 204 mm) |
| Computer | Chrome or Edge to flash from the browser, or PlatformIO |
| Home Assistant | With the Mosquitto broker; see [home-assistant.md](home-assistant.md) |

> **Handle the panel with care.** It's 0.78 mm glass. Pick it up by its
> edges, keep it flat on its foam, never bend the flex cable along its
> bottom edge or press on its face, and keep it in its box until step 8.

## 1. Print the enclosure

Print in PETG, 0.2 mm layers, 3–4 walls, 20% infill, **no supports**.
The STLs are in [`hardware/enclosure/stl/`](../hardware/enclosure/stl/);
[`hardware/enclosure/README.md`](../hardware/enclosure/README.md) has the
orientation for each part and how to change sizes.

| Part | Qty | Prints |
|---|---|---|
| `bezel.stl` | 1 | Face down |
| `back.stl` | 1 | Outside face down |
| `button_caps.stl` | 1 set of 3 | Face down |
| `stand.stl` | 1, optional | As exported |

Let the parts cool on the bed so they stay flat.

## 2. Heat-set inserts

With the insert tip at about 230 °C for PETG, press each insert in square
and flush, and let it cool before moving on.

- **Bezel:** 8 × M3 around the edge (for the back cover), 2 × M2.5 in the
  chin (for the button strip).
- **Back cover:** 4 × M2.5 on the tall standoffs (driver HAT), 2 × M2.5 in
  the carrier tray.

## 3. Build the carrier board

Follow [the carrier layout](images/carrier-layout.svg), viewed from the
component side. Cut the protoboard to 70 × 35 mm (score both sides along a
row of holes and snap it), and drill the two 2.7 mm mounting holes where the
layout shows them.

1. **Prepare the XIAO.** Its BAT+ and BAT− pads are on the underside, so
   solder a short 26 AWG wire to each first (BAT− is the pad nearer the USB
   connector). If you'll plug it into female headers, solder its male pins
   now too.
2. **Place, don't solder yet:** the XIAO (directly, or on two 1 × 7 female
   headers), the MiniBoost, the charger module, the JST-PH socket, the
   1 × 8 header for the HAT cable and the 1 × 4 header for the buttons. The
   two USB-C connectors must overhang the board's top edge by 1.5 mm, or
   the plugs won't reach them through the case.
3. **Solder the modules and headers**, and the XIAO's two battery wires
   through the board.
4. **Add the passives:** R1–R4, C1, and the two electrolytics C2 and C3
   lying flat. The stripe on an electrolytic marks `−`.
5. **Wire the underside** as the layout shows: thick (26 AWG) wire for the
   battery, `VBAT_SYS`, 5 V and ground; thin wire for the signals. Every
   ground goes to the charger's **OUT−**, never to **B−**.
6. **Check it** with the meter before connecting anything: no short from
   `VBAT_SYS` or the HAT header's 5V pin to ground, and each header pin
   reaching the right XIAO pin ([pin table](../hardware/wiring.md#xiao-esp32-s3-pins)).
7. Cover the underside with Kapton tape.

## 4. Build the button strip

Cut protoboard to 84 × 20 mm and drill two 2.7 mm holes at ±38 mm from the
centre, as in [the button board layout](images/button-board.svg). Solder the
three 12 × 12 mm switches at −26, 0 and +26 mm, with the plungers facing the
front. Join one side of all three to a common ground wire, and give each
switch its own signal wire: **BACK** (left, seen from the front), **REFRESH**
(middle), **NEXT** (right). About 15 cm of four-wire lead reaches the
carrier; crimp or solder a 1 × 4 socket to match the carrier's header.

## 5. Check the battery lead

JST-PH batteries don't all use the same polarity, and a reversed battery
destroys the charger module the moment it's plugged in. So before the
battery goes near the carrier, find its plug's positive pin with the meter,
then check which pin of the carrier's socket is wired to the charger's
**B+**. They must meet. If they don't, swap the two wires in the battery's
plug (lift each plastic latch with a pin and slide the contact out), or buy
a battery with the other polarity.

## 6. Flash the firmware

1. **Get the firmware.** On GitHub, open **Actions › Firmware**, pick the
   latest green run, download the **brwr_trmnl** artifact (you need to be
   signed in) and unzip it. You want `merged_firmware.bin`. Or build it
   yourself (below).
2. **Connect the XIAO** to your computer with a USB-C data cable, using the
   XIAO's own port (not the charger module's).
3. **Flash from the browser.** Open
   [Espressif's esptool-js page](https://espressif.github.io/esptool-js/)
   in Chrome or Edge, click **Connect** and pick the XIAO's serial port.
   Set the flash address to `0x0`, choose `merged_firmware.bin`, and click
   **Program**.
   - No serial port? Hold the XIAO's **BOOT** button, press and release
     **RESET**, then release BOOT, and connect again.

From a terminal instead:

```sh
pip install esptool
esptool --chip esp32s3 write-flash 0x0 merged_firmware.bin
```

To build it yourself (the first build downloads the ESP-IDF toolchain and
takes a while):

```sh
pip install platformio
cd firmware
pio run -e brwr_trmnl -t upload
pio device monitor              # the log, at 115200 baud
```

Flash the `brwr_trmnl` build. The `brwr_trmnl_arduino` build is only a
fallback: it can't light-sleep, so in **Always ready** it stays fully awake
and empties the battery in about a week.

## 7. Test it on the bench

Before anything goes into the case, prove the panel, the HAT and the
firmware work together.

1. Set the HAT's **interface switch to SPI**.
2. Lay the panel face down on its foam, clean and flat. Connect its flex to
   the small adapter board, and the adapter board to the HAT with the 40-pin
   flat cable: lift each connector's latch, slide the cable in square, close
   the latch. Check the contacts face the right way (Waveshare's manual has
   photos).
3. Plug the HAT's 8-wire cable into the HAT, and its sockets onto the
   carrier's 1 × 8 header in the printed order: 5V, GND, MISO, MOSI, SCK, CS,
   RST, HRDY. Match the labels on the HAT, not the wire colours.
4. Plug in the button strip, the Wi-Fi antenna (press the U.FL plug straight
   down until it clicks), and last, the battery.
5. The display draws the TRMNL logo, then setup instructions. If it stays
   blank, see [troubleshooting](#troubleshooting).
6. **Set it up:** join the Wi-Fi hotspot `brwr-trmnl-XXXXXX` from a phone;
   the setup page opens (or go to `http://4.3.2.1`). Pick your Wi-Fi, and
   fill in the **Home Assistant** section: its address, where screens come
   from, the MQTT user and password, and the **panel VCOM** printed on the
   panel's flex cable (such as `-1.52`). Details:
   [home-assistant.md](home-assistant.md#2-connect-the-display).
7. Within a minute or so it draws its first screen and appears in Home
   Assistant. Press each button: NEXT and BACK change the screen, and
   **Last refresh** updates in Home Assistant.
8. Plug a USB-C charger into the charger module's port: its LED turns red
   while it charges.

Unplug the battery before assembly.

## 8. Assemble

Work on a clean, soft surface. Clean the inside of the window and the
panel's face with a blower or a soft brush; any dust in there stays there.

**The bezel** (lying face down):

1. **Button caps.** From inside, drop the three caps into their holes in
   the chin, faces first, symbols the right way up: ◀ left, ● middle, ▶ right
   (seen from the front). The key on each stem fits the slot in its hole.
2. **Button strip.** Screw it onto the two M2.5 inserts in the chin, switches
   facing the caps. Press each cap from the front: it should click and
   spring back.
3. **Gasket.** Run the 0.5 mm foam tape around the window lip, in four
   straight strips, without covering the window.
4. **Panel.** Lower the panel face down into its pocket, flex edge towards
   the chin, and let it settle. Fold the flex gently back over the panel's
   back without creasing it, so the adapter board lies behind the panel's
   bottom centre.
5. **Antenna.** Peel the FPC antenna and stick it into the shallow recess on
   the inside of the top wall.

**The back cover** (lying outside face down):

6. **Magnets.** Put each magnet in its pocket on the outside, rubber face
   out, and screw an **M4 × 6** screw into it from inside. Snug, not tight.
   Never use a longer screw.
7. **Driver HAT.** Screw it onto the four tall standoffs, components facing
   up (towards the panel) and its 40-pin flat-cable socket towards the
   centre.
8. **Carrier.** Fit it into its tray at the top edge, USB-C connectors
   outwards, and screw it down with two M2.5 screws.
9. **Battery.** Put a 1 mm foam pad in the cradle and lay the battery on it,
   its lead out through the cradle's slot. Nothing may press on it or
   pierce it.
10. **Foam.** Stick 1 mm foam strips along the tops of the panel-support
    ribs. They hold the panel flat and evenly once the case is closed.

**Together:**

11. **Connect.** Stand the back cover up along the bezel's bottom edge and
    connect: the flat cable from the adapter board to the HAT, the HAT's
    8-wire cable to the carrier, the button lead, the antenna's coax to the
    XIAO's U.FL socket (press straight down until it clicks), and last,
    the battery. Route the wires through the channels so nothing crosses
    the battery or sits on a rib.
12. **Close.** Fold the back cover down onto the bezel, checking that no
    wire is pinched at the edges and the USB-C connectors meet their slots
    in the top wall (**USB** and **CHARGE**). Drive the eight M3 × 8 screws
    in a cross pattern, snug only. Plug a cable into each USB-C port from
    outside to check it seats.

## 9. Hang it

1. Test the spot on your fridge with any magnet: many stainless-steel doors
   aren't magnetic ([magnets.md](magnets.md#will-it-work-on-my-fridge)).
2. Wipe the spot clean and dry, and put it on, flat.
3. Open and slam the door a few times with a towel on the floor below.
4. Check **Wi-Fi signal** in Home Assistant. Better than about −75 dBm is
   fine.

## 10. Make it yours

- **Screens:** Home Assistant dashboards or TRMNL plugins,
  [home-assistant.md](home-assistant.md#4-home-assistant-screens).
- **Voice:** [voice.md](voice.md).
- **Battery life:** choose **Always ready** or **Deep sleep**,
  [power.md](power.md).

## Troubleshooting

| Symptom | Check |
|---|---|
| Nothing on the panel at all | HAT interface switch on SPI; both flat-cable latches closed with the cable square; the 8-wire cable order; the battery charged. The log (`pio device monitor`) says whether the IT8951 answered |
| Log says the IT8951 didn't answer | SCK/MOSI/MISO/CS swapped; HRDY not connected; the MiniBoost not switching on (its OUT pin should read 5.2 V while the display draws) |
| Washed-out or smudged picture | Panel VCOM: enter the value printed on the flex cable |
| Resets when it starts to draw | Battery flat, or C3/C2 missing or reversed; ground to the HAT too thin or too long |
| Buttons do nothing | Each switch must connect its signal wire to ground when pressed; the cap must reach the plunger (press it: it should click) |
| Doesn't wake from a button in deep sleep | The buttons must be on D0–D2 (GPIO1–3) |
| No setup hotspot | Hold REFRESH for 5–15 seconds to open it again |
| Doesn't appear in Home Assistant | The MQTT user and password; the broker's log; [home-assistant.md](home-assistant.md#troubleshooting) |
| Battery reads wrong | R1 and R2 must both be 220 kΩ; the divider midpoint goes to D3 |
| Charges from USB-A but not from a USB-C charger | The charger module lacks the USB-C CC resistors ([power.md](power.md#charging)) |
