# brwr-trmnl enclosure

A two-part printed frame for the 10.3" panel, 229 × 204 × 25 mm. The **bezel**
holds the front face, walls, panel pocket and buttons. The **back cover**
carries the electronics, the ribs that hold the panel flat and the magnet
pockets. The frame sticks to a fridge door with four rubber-coated pot
magnets, hangs on two wall screws through keyholes, or leans back 15° in the
optional desk stand.

| Front | Back |
|---|---|
| ![Front](../../docs/images/enclosure-front.png) | ![Back](../../docs/images/enclosure-back.png) |
| **Exploded** | **Inside, back cover removed (seen from behind, so left and right are swapped)** |
| ![Exploded](../../docs/images/enclosure-exploded.png) | ![Inside](../../docs/images/enclosure-inside.png) |

The whole design is one parametric file, [`brwr-trmnl.scad`](brwr-trmnl.scad).
Running [`./export.sh`](export.sh) renders the STLs into `stl/` and these
pictures into `docs/images/`. It stops on any OpenSCAD warning, including a
failed design-rule check.

## Parts

| Part | File | Print orientation | Size as printed | Mass |
|---|---|---|---|---|
| Bezel | `stl/bezel.stl` | front face down | 229 × 204 × 23 mm | ~95 g |
| Back cover | `stl/back.stl` | outside face down (magnet pockets open to the bed) | 229 × 204 × 21 mm | ~172 g |
| Button caps (3) | `stl/button_caps.stl` | face down | 48 × 13 × 5.3 mm | ~2 g |
| Desk stand (optional) | `stl/stand.stl` | base down | 100 × 92 × 74 mm | ~78 g |

Print in **PETG with 0.2 mm layers, 3–4 walls and 20 % infill, with no
supports**. Every overhang is 45° or bridged, including the magnet-pocket
ceilings, the cap flanges and the boss gussets. The bezel and back cover need a
**250 × 210 mm bed** (Prusa MK4 or similar). They do **not** fit a 220 × 220 mm
bed.

Masses are for PETG at 1.27 g/cm³: the STL volume, with a 1.2 mm solid shell
on every surface and 20 % infill inside it. The bezel and back cover are
mostly thin walls, so they print almost solid.

## Hardware

- 8 × M3 heat-set inserts (hole Ø4.0 × 5 mm) in the bezel, and 8 × M3 × 8
  countersunk screws (ISO 10642) through the back cover.
- 8 × M2.5 heat-set inserts (hole Ø3.6 × 4.2 mm), with 8 × M2.5 × 6 pan-head
  screws:
  - 4 driver-HAT standoffs, 10 mm tall
  - 2 carrier bosses
  - 2 button-strip bosses behind the chin
- 4 × supermagnete ITNG-22 pot magnets (Ø22 × 6 mm, M4 thread) and 4 × M4 × 6
  A2 pan- or button-head screws, driven from inside the back cover.
- 3 × 12 × 12 × 7.3 mm tactile switches on an 84 × 20 mm protoboard strip.
- Foam:
  - a 0.5 mm gasket on the window lip
  - 1 mm × 4 mm strips on the rib tops
  - a 1 mm double-sided pad under the battery
  - a thin layer over the folded flex
- 2.5 mm zip ties for the button wires, through the tie blocks at X = −34.

## Assembly

1. **Inserts.** Heat-set the M3 inserts into the bezel's wall bosses and the
   M2.5 inserts into the two bosses behind the chin. Then do the six on the back
   cover.
2. **Magnets.** Screw each magnet into its pocket from inside. The rubber face
   ends 0.5 mm proud of the back. The screw engages 4 mm of thread and its tip
   stays 2 mm behind the magnet's face.
3. **Buttons.** Push the caps into the bezel from behind, with the key toward
   the bottom. Then screw the switch strip onto its two bosses.
4. **Panel.** Lay the gasket on the lip and drop the panel in face-down, with
   its flex at the chin. Fold the flex over the back of the panel. The zone
   144 × 40 mm above the panel's bottom edge is kept free of ribs for the flex
   and adapter board.
5. **Electronics.**
   - Driver HAT on its standoffs, header toward the back cover.
   - Battery on its foam pad in the cradle, lead out through the slot toward
     the middle.
   - Antenna in the 0.6 mm recess inside the top wall, front edge against the
     front face.
   - Carrier in its tray, drilled to match the bosses. Measured from the
     board's top-left corner with the components facing you, one hole is 5 mm
     right and 5 mm down, the other 65 mm right and 31 mm down.
6. **Close up.** Put foam strips on the rib pads, tie the button wires up the
   middle, and close the case with the 8 M3 screws. The two tongues on the back
   cover close the bottom of the USB slots.

## Changing the main parameters

Open the file in OpenSCAD and use the Customizer. Each dimension has a
comment with its unit and source. The console prints every module's position
and the measured magnet distances. The model also runs `assert()` design rules
and stops with a message when one fails.

- **Magnets:** `mag_d`, `mag_h` and `mag_pos`, with one `[X, Y]` per magnet;
  the count is the number of entries. The rules are:
  - every centre is at least `mag_keep_board` (36 mm) from the driver and
    carrier boards, and at least `mag_keep_ant` (35 mm) from the antenna recess
  - magnets stay out of the flex zone and the battery cradle
  - the M4 screw engages at least 3 mm and stays at least 1 mm behind the
    magnet's face

  With the default module layout, no fifth or sixth spot passes these rules.
- **Battery:** `bat_size = [L, W, T]` in landscape, for example `[80, 50, 10]`
  for a 105080 cell, and `bat_pos` for its centre. The cradle, ribs and checks
  follow.
- **Button feel:** `cap_preload` defaults to −0.2 mm, a free gap above the
  plunger, because the switch only travels 0.25 mm. Raise it toward 0 if the
  caps rattle. Lower it if a switch clicks by itself when the case is closed.
- **Size and depth:** `outer_w`, `outer_h`, `depth`, `border_top`. The antenna
  needs `depth - 4` ≥ `ant_h`.

Use `part = "fit_check"` to see all module envelopes inside a see-through case.
Use `part = "clash"` to render every overlap between the printed parts and the
modules. It is empty when everything fits, and OpenSCAD reports "top level
object is empty".

Coordinates follow the front view: X and Y are measured from the centre of the
outline (+X right, +Y up). Z is measured from the back face (the fridge side)
toward the front.

## Differences from the brief

- **Depth is 25 mm, not ~22.** The antenna reservation is 21 mm tall and sits
  on the inside of the top wall. At 22 mm deep the inside of that wall is only
  18 mm.
- **Magnets are at (±90, ±65) under a 36 mm board rule.** The brief had
  (±90, ±58) and 30 mm. The 6-magnet option is dropped.
- **Cap preload is −0.2 mm, a gap.** The brief had +0.3 mm, which exceeds the
  switch's 0.25 mm travel.
- **Caps have a keyway.** The keyway sits behind the face, so the ◀ ● ▶
  symbols stay upright.
- **The right carrier screw is 4 mm above the board's bottom edge.** The brief
  had it 5 mm below the top edge. At that spot it sat under the charger
  module, and its brass insert was within 10 mm of the antenna.
- **The USB slots are open toward the back edge.** Tongues on the back cover
  close them. The carrier rides in on the back cover, so a closed slot could
  not be assembled.
- **The back-cover text is engraved, not embossed.** Embossed text on the
  bed-side face cannot be printed.
- **The flex relief is 144 mm wide, matching the flex zone.** The brief asked
  for at least 141 mm.
