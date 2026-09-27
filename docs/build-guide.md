# Build guide

From a box of parts to a display on the fridge. Plan on a weekend: about a
day of printing, which runs unattended, and an afternoon of soldering and
assembly, plus overnight for the epoxy to cure.

**Before you start**, read the whole guide once, and skim
[wiring.md](../hardware/wiring.md) and the
[schematic](images/schematic.svg).

| You need | |
|---|---|
| Parts | [Bill of materials](bom.md) |
| Tools | Soldering iron with a fine tip and a heat-set insert tip, multimeter, flush cutters, wire strippers, tweezers, hobby knife, a drill or pin vise with a 2.7 mm bit, hex keys (1.5 and 2 mm) and a small screwdriver, small pliers or a 5 mm nut driver, a vise or pliers for bending rod, a hacksaw or bolt cutters |
| Printer | Bed at least **220 × 220 mm** |
| Computer | Chrome or Edge to flash from the browser, or PlatformIO |
| Home Assistant | With the Mosquitto broker; see [home-assistant.md](home-assistant.md) |

The case is 229 × 204 × **13 mm**. There's no spare room in it, so the parts
have to be low: the steps below say where to trim.

> **Handle the panel with care.** It's 0.78 mm glass. Pick it up by its
> edges, keep it flat on its foam, never crease its flex cable or bend it
> sharply (in step 9 it folds back over the panel in a gentle curve), never
> press on its face, and keep it in its box until step 8.

## 1. Print the enclosure

Print in PETG, 0.2 mm layers, 3–4 walls, 20% infill, **no supports**. The
frame is four rails and the back cover two halves, so every part fits a
220 × 220 mm bed; the two long rails print diagonally. The STLs are in
[`hardware/enclosure/stl/`](../hardware/enclosure/stl/);
[`hardware/enclosure/README.md`](../hardware/enclosure/README.md) has the
details.

![The four print jobs on a 220 × 220 mm bed](images/enclosure-plates.png)

| Print job | Parts | Orientation |
|---|---|---|
| 1 | `bezel_bottom.stl` (the chin) + `button_caps.stl` | Face down; the chin turned 45° |
| 2 | `bezel_top.stl` + `bezel_left.stl` + `bezel_right.stl` | Face down; the top rail turned 45° |
| 3 | `back_right.stl` | Outside face down |
| 4 | `back_left.stl` + `stand.stl` (optional) | Outside face down; stand on its base |

With a bed of 250 × 210 mm or more you can print the frame and the back each
in one piece instead (`stl/one-piece/`).

Let the parts cool on the bed so they stay flat.

## 2. Heat-set inserts

With the insert tip at about 230 °C for PETG, press each insert in square
and flush, and let it cool before moving on.

- **Frame rails:** 9 × M3 in their bosses (for the back cover).
- **Chin:** 2 × M2.5 in the bosses behind it (for the button strip).

## 3. Prepare the driver HAT

The driver board comes shaped to sit on a Raspberry Pi. This build doesn't
use a Pi, and those parts are too tall for the case.

1. **The 40-pin Pi header on its back.** Cut the black plastic body away with
   flush cutters, a bit at a time, then clip the metal pins flush with the
   board: no more than 1 mm may stick out. Take care not to lever on the
   board or cut into it.
2. **The tall parts on its front.** Nothing on the component side may stand
   more than 3 mm. Desolder the white 8-pin cable socket (or cut its housing
   away), and clip or desolder any upright pin header.
3. **The 8 wires.** Cut the plug off the kit's 8-wire cable. Solder the wires
   to the HAT's 5V, GND, MISO, MOSI, SCK, CS, RST and HRDY pads, matching its
   silkscreen, and note which colour went where. Their other ends go to the
   carrier in the next step.
4. **Interface switch:** set it to **SPI**.

## 4. Build the carrier board

Follow [the carrier layout](images/carrier-layout.svg), viewed from the
component side.

Cut a piece of protoboard **27 holes wide and 13 holes tall**. Score the top
edge along the next row of holes up, so a row of half holes stays on that
edge (a wire runs in the margin there), and the other three edges midway
between holes; score both sides and snap it. That gives 68.6 × 34.3 mm.
Anything up to the layout's 70 × 35 mm fits, because the screws, not the
edges, place the board. Then drill the two mounting holes, 2.7 mm, each
through the middle of the four holes in a corner: top left and bottom
right, seen from the component side. The drill centres itself there.

1. **Prepare the XIAO.** Its BAT+ pad is on the underside: solder a short
   26 AWG wire to it first, to pass through the hole beneath it. (BAT−, the
   pad nearer the USB connector, is the same as GND and needs no wire.)
2. **Place, don't solder yet:** the XIAO, the charger module and the
   MiniBoost, all flat on the board, not on headers. The XIAO's pads go on
   the holes the layout shows, which puts its connector where the case's
   slot is; its end hangs 0.3 mm over the board's top edge. Put the charger
   module's end level with the XIAO's, no further out: the case's top wall
   is there.
3. **Solder the modules**, and the XIAO's battery wire through the board.
   Glue the charger module down with a thin layer of epoxy or double-sided
   tape: its four wires alone won't take the force of plugging in a cable.
4. **Add the passives:** R1–R4 and C1 lying flat, and the four ceramic
   capacitors, C2 (2 × 47 µF) and C3 (2 × 100 µF), each soldered flat
   across two adjacent pads.
5. **The battery pigtail (J1) and SW4:** solder the JST-PH pigtail's leads
   where the layout shows J1, and a wire link at SW4. The link joins the
   charger's output to everything else: without it nothing gets power. (A
   switch fits there too, but it would be sealed inside the case.)
6. **Wire the underside** as the layout shows: thick (26 AWG) wire for the
   battery, `VBAT_SYS`, 5 V and ground; thin wire for the signals. Every
   ground goes to the charger's **OUT−**, never to **B−**.
7. **J2 and J3: wires straight into the board.** There's no room for
   connectors here.
   - **J2:** cut the HAT's 8 wires to about 12 cm (the route in the
     [wiring diagram](images/wiring.svg), with a little slack) and solder
     them into J2's holes: 5V, GND, MISO, MOSI, SCK, CS, RST, HRDY from the
     top. The HAT and the carrier are now one assembly.
   - **J3:** take one half of the JST-PH 4-pin pair (J4), cut its wires to
     about 17 cm and solder them into J3's holes: BACK, REFRESH, NEXT, GND
     from the top.
8. **Keep it low.** Nothing may stand taller than the MiniBoost, 5.6 mm
   above the board, and the joints underneath must be trimmed to 1.2 mm:
   the MiniBoost ends up only 1.1 mm from the back of the panel.
9. **Check it** with the meter before connecting anything: no short from
   `VBAT_SYS` or the HAT's 5V pad to ground, and each HAT pad and each pin
   of the JST-PH plug reaching the right XIAO pin
   ([pin table](../hardware/wiring.md#xiao-esp32-s3-pins)).
10. Cover the underside with Kapton tape.

## 5. Build the button strip

Follow [the button board drawing](images/button-board.svg).

1. Cut protoboard to 84 × 20 mm, 32 holes by 7 (or midway between holes,
   81.3 × 17.8 mm). Put the middle switch at the centre, and the other two
   10 holes (25.4 mm) either side, plungers facing the front: the caps are
   the same distance apart. The legs sit 5 holes by 2 holes apart; spread
   them slightly to fit (the grid is a little wider than the legs), press
   each switch flat, solder, and trim the legs to 2 mm under the board.
2. Drill out the 15th hole either side of the centre, on the middle row,
   to 2.7 mm: the second hole in from each end.
3. **Ground:** each switch's bottom-right leg (seen from the front) to a bare
   wire along the bottom row.
4. **Signals:** each switch's top-left leg, diagonally opposite its ground
   leg, to its own insulated wire. Diagonal legs are always on opposite
   sides of the switch, whichever way round it's fitted.
5. **The lead:** the other half of the JST-PH pair, its wires cut to about
   7 cm, which reaches the plug with the back cover propped open (step 9).
   Plug the two halves together, find with the meter which of this
   half's wires meets J3's BACK, REFRESH, NEXT and GND, and solder each into
   its hole on the strip as the drawing shows: the signals on the top row
   above BACK, GND at the end of the bus. From the front, BACK is on the
   left. Keep the wires clear of the two screw holes.
6. With the pair plugged together, check with the meter at the carrier:
   each of D0–D2 reads open to ground, and closed while its button is
   pressed.

## 6. Check the battery lead

JST-PH batteries don't all use the same polarity, and a reversed battery
destroys the charger module the moment it's plugged in. So before the
battery goes near the carrier, find its plug's positive pin with the meter,
then check which lead of the carrier's pigtail is wired to the charger's
**B+**. They must meet. If they don't, swap the two wires in the battery's
plug (lift each plastic latch with a pin and slide the contact out), or buy
a battery with the other polarity.

## 7. Flash the firmware

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

`merged_firmware.bin` is for the first flash: it also clears the saved Wi-Fi
and settings. To update a display that's set up, write `firmware.bin` (in the
same artifact) at `0x10000` instead, or upload with PlatformIO (below).

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

## 8. Test it on the bench

Before anything goes into the case, prove the panel, the HAT and the
firmware work together.

1. Lay the panel face down on its foam, clean and flat. Connect its flex to
   the small adapter board, and the adapter board to the HAT with the 40-pin
   flat cable: lift each connector's latch, slide the cable in square, close
   the latch. Check the contacts face the right way (Waveshare's manual has
   photos).
2. Plug in the button strip's lead (J4), the Wi-Fi antenna (press the U.FL
   plug straight down until it clicks), and last, the battery.
3. The display draws the TRMNL logo, then setup instructions. If it stays
   blank, see [troubleshooting](#troubleshooting).
4. **Set it up:** join the Wi-Fi hotspot `brwr-trmnl-XXXXXX` from a phone;
   the setup page opens (or go to `http://4.3.2.1`). Pick your Wi-Fi, and
   fill in the **Home Assistant** section: its address, where screens come
   from, the MQTT user and password, and the **panel VCOM** printed on the
   panel's flex cable (such as `-1.52`). Details:
   [home-assistant.md](home-assistant.md#2-connect-the-display).
5. Within a minute or so it draws its first screen and appears in Home
   Assistant. Press each button: NEXT and BACK change the screen, and
   **Last refresh** updates in Home Assistant.
6. Plug a USB-C charger into the charger module's port: its LED turns red
   while it charges.

Before assembly, unplug the battery, the flat cable at the HAT and the
button lead (J4). The antenna can stay plugged into the XIAO: it goes on the
back cover too.

## 9. Assemble

Work on a clean, flat, soft surface. Clean the inside of the window and the
panel's face with a blower or a soft brush; any dust in there stays there.

**Cut and bend the rods.** From the 3 mm steel rod, following the
[cut list](../hardware/enclosure/README.md#steel-rod-cut-list): two straight
206 mm rods for the back, and four L-rods for the frame's corners (top-left
40 + 40 mm, top-right 15.5 + 40 mm, bottom-left and bottom-right
40 + 48 mm). Bend each L over a 3 mm pin held in a vise so the inside of the
bend is tight. Dry-fit every rod in its groove before mixing any epoxy.

**The back cover** (both halves outside face down on the table):

1. **Magnets.** Into each of the four pockets, drop a magnet, all with the
   **same side facing out**, then a steel disc on top of it, and fill the
   pocket with epoxy to just over the disc. Nothing metal shows outside.
   The magnets pull hard toward each other and toward steel: keep them apart
   and away from the rods until they're set in.
2. **Join the halves.** Slide the three tabs on `back_left` into the pockets
   under `back_right` so the seam closes flat. Epoxy the two 206 mm rods into
   their channels across the seam; they hold the halves together. Glue on
   the seam itself is optional. Let it cure flat, weighted if needed.
3. Once cured, stick a rubber pad over each magnet on the outside face.

**The frame** (the four rails front face down on the table):

4. **Rails.** Push them together at the corners: each side rail slides in
   between the top rail and the chin, and the joints line up the front faces.
   Epoxy the four L-rods into the corner grooves; they bridge the joints and
   they're structural, not optional. Glue on the joint faces is optional.
   Let it cure flat.
5. **Button caps.** From inside, drop the three caps into their holes in the
   chin, faces first, with the key on each stem towards the bottom so the
   symbols read ◀ ● ▶ from the front.
6. **Button strip.** Screw it onto the two M2.5 inserts in the chin
   (M2.5 × 5), switches facing the caps. Press each cap from the front: it
   should click and spring back.
7. **Gasket.** Run the 0.5 mm foam tape around the window lip, in four
   straight strips, without covering the window.
8. **Panel.** Lower the panel face down into its pocket, flex edge towards
   the chin, and let it settle. Fold the flex gently back over the panel's
   back without creasing it, so the adapter board lies behind the panel's
   bottom centre.

**The electronics** (into the back cover, inside facing up):

9. **Driver HAT.** Components facing up (towards the panel), its 40-pin
   flat-cable socket towards the centre, on its four low standoffs: M2.5 × 8
   countersunk screws from the outside, nuts on top. The carrier is wired
   to it, so keep it close.
10. **Carrier.** Into its recess at the top edge, USB-C connectors outwards,
    with M2.5 × 6 countersunk screws from the outside and nuts on top. Lay
    the HAT's wires through the wire gap in the rib, as the
    [wiring diagram](images/wiring.svg) shows.
11. **Antenna.** Peel the FPC antenna and stick it to the thin fin along the
    top edge, right of the carrier (seen from inside), on the fin's face
    towards the middle of the case, its lead at the carrier's end. Its coax
    runs over the carrier to the XIAO's U.FL socket: if it isn't plugged in
    already, press the plug straight down until it clicks.
12. **Battery.** Foam pad in its recessed cradle, battery on top, its lead
    out through the cradle's slot and the gap in the rib above it, to J1.
    Nothing may press on the cell or pierce it.

**Together:**

13. **Connect.** Prop the back cover open along the frame's bottom edge at
    about 45° (lean it against something), inside facing the frame. Connect
    the flat cable from the adapter board to the HAT, and the button strip's
    plug to its mate (J4), then plug in the battery. The flat cable needs
    about 10 cm to reach at that angle; with a shorter one, work with the
    cover nearer closed, or use a longer cable (see the
    [BOM](bom.md)). Lay J4 flat on the back cover beside
    the adapter board, not under it, with the strip's spare lead beside it,
    and zip-tie the button wires to the three tie blocks. Put foam strips on
    the rib tops and the magnet tubes.
14. **Close.** Fold the back cover down onto the frame, checking that no wire
    is pinched at the edges, the antenna's fin slides in beside the top
    wall, and the USB-C connectors meet their slots in it (**USB** and
    **CHARGE**). Drive the nine M3 × 6 screws in a cross pattern, snug only.
    Plug a cable into each USB-C port from outside to check it seats.

## 10. Hang it

1. Test the spot on your fridge with any magnet: many stainless-steel doors
   aren't magnetic ([magnets.md](magnets.md#will-it-work-on-my-fridge)).
2. Wipe the spot clean and dry, and put it on, flat.
3. Open and slam the door a few times with a towel on the floor below.
4. Check **Wi-Fi signal** in Home Assistant. Better than about −75 dBm is
   fine.

**On a wall** (the back is too thin for keyholes): screw a thin steel plate
to the wall, for example 1 mm galvanised steel of about 200 × 150 mm, or four
30 × 30 mm squares at the magnets' positions, 90 mm either side of the
centre and 65 mm above and below it. The magnets hold the frame on it. Or
stand it on the desk stand.

## 11. Make it yours

- **Screens:** Home Assistant dashboards or TRMNL plugins,
  [home-assistant.md](home-assistant.md#4-home-assistant-screens).
- **Voice:** [voice.md](voice.md).
- **Battery life:** choose **Always ready** or **Deep sleep**,
  [power.md](power.md).

## Troubleshooting

| Symptom | Check |
|---|---|
| Nothing on the panel at all | HAT interface switch on SPI; both flat-cable latches closed with the cable square; the 8 HAT wires on the right pads; the battery charged. The log (`pio device monitor`) says whether the IT8951 answered |
| Log says the IT8951 didn't answer | SCK/MOSI/MISO/CS swapped; HRDY not connected; the MiniBoost not switching on (its OUT pin should read 5.2 V while the display draws) |
| Washed-out or smudged picture | Panel VCOM: enter the value printed on the flex cable |
| Resets when it starts to draw | Battery flat, or C2/C3 missing; ground to the HAT too thin or too long |
| Buttons do nothing | Each switch must connect its signal wire to ground when pressed; the cap must reach the plunger (press it: it should click) |
| **Last error** says "Button stuck down" | That switch is pressed all the time: a cap pressing on it (see `cap_preload` in the [enclosure README](../hardware/enclosure/README.md)) or a solder bridge on the button strip. It's ignored until the first refresh after it's released |
| Doesn't wake from a button in deep sleep | The buttons must be on D0–D2 (GPIO1–3) |
| No setup hotspot | Hold REFRESH for 5–15 seconds to open it again |
| Doesn't appear in Home Assistant | The MQTT user and password; the broker's log; [home-assistant.md](home-assistant.md#troubleshooting) |
| Weak Wi-Fi | The antenna stuck flat on its fin; its coax clicked onto the U.FL socket; no wire or metal lying over it |
| Case won't close flat | Something is too tall: trim the carrier's joints (1.2 mm) and the strip's legs (2 mm); check the HAT's clipped header pins, and that the button plug lies flat beside the adapter board |
| Battery reads wrong | R1 and R2 must both be 220 kΩ; the divider midpoint goes to D3 |
| Charges from USB-A but not from a USB-C charger | The charger module lacks the USB-C CC resistors ([power.md](power.md#charging)) |
