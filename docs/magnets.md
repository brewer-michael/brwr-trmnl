# Magnets: on the fridge, clear of the electronics

brwr-trmnl hangs on the fridge door by four rubber-coated magnets screwed
into the back cover. They're strong enough to hold it through a slammed door,
and far enough from the electronics that their field doesn't matter there.

## The magnets

Four **supermagnete ITNG-22** pot magnets, or any equivalent: a neodymium
magnet in a steel cup, Ø22 × 6 mm, coated in rubber, with an M4 thread in
the middle.

- Each sits in a pocket on the outside of the back cover, held by an
  **M4 × 6 mm** stainless screw from inside. A longer screw would push
  through the magnet's face, so the enclosure's source checks the screw
  length against the pocket and the thread.
- Their rubber faces stand 0.5 mm proud of the back, so only rubber touches
  the door: no scratches, and it doesn't slide.
- They sit at the four corners of the back, at (±90, ±65) mm from the
  centre.

## Will it hold?

| | |
|---|---|
| brwr-trmnl, complete | about 0.55 kg (estimate: 270 g of printed case, 90 g battery, 80 g panel and HAT, 50 g magnets) |
| One ITNG-22 on thick steel | ~5.9 kg pull, ~1.8 kg sideways (shear) |
| Four, on a fridge door | ~8 kg pull and ~2.5 kg shear, allowing for thin door steel and paint (× 0.35) |
| Margin | ~4.5 × against sliding down, ~15 × against being pulled off |

A fridge door's steel skin is thin (about 0.5 mm) and painted, so a magnet
grips it far less well than the thick steel plate it's rated on. The 0.35
derating is an estimate; the margins are big enough that it shouldn't
matter, but try it: hang it, and open and slam the door a few times with a
towel on the floor below.

### Will it work on my fridge?

Test the spot with any fridge magnet first.

- **Many stainless-steel doors aren't magnetic** (austenitic stainless,
  such as 304, isn't). The sides of the same fridge are often painted steel
  and are.
- **Glass, wood or "panel-ready" fronts** aren't magnetic either.
- **No magnetic surface?** Stick a thin steel plate or two adhesive steel
  discs on it (sold for phone mounts and "magnetic mounting plates"), or use
  the printed desk stand.

## Why the magnets don't disturb anything

A magnet's steady field can only affect parts that are themselves magnetic.
In this design, that's the power **inductors**: the MiniBoost's on the
carrier board, and the ones for the panel's supplies on the driver HAT. A
strong enough field partly saturates an inductor's core and lowers its
current rating. Nothing else inside cares:

- **The e-paper panel** moves charged pigments with electric fields;
  magnetic fields don't affect it.
- **The ESP32-S3, its flash, the crystal, the battery** and the charger are
  not magnetic.
- There are no Hall sensors, reed switches, compasses or speakers.

So the design rule is simple: **keep every board at least 25 mm from a
magnet's edge**, where even a bare magnet (worse than the real ones)
produces **under 5 mT**. That's about 1% of what a ferrite core saturates at,
and a hundred times the Earth's field. The enclosure's source enforces the
rule with `assert()`s on the actual positions.

![Magnet field versus distance: the sideways field is 3.9 mT at the closest board, 25.75 mm from a magnet's edge](images/magnet-field.svg)

| Distance | Sideways (mT) | Straight out (mT) |
|---|---|---|
| 5 mm | 81.9 | 168.9 |
| 10 mm | 26.9 | 81.2 |
| 15 mm | 12.4 | 40.5 |
| 20 mm | 6.8 | 22.1 |
| 25 mm | 4.1 | 13.1 |
| 30 mm | 2.7 | 8.3 |
| 40 mm | 1.4 | 3.9 |
| 50 mm | 0.8 | 2.1 |
| 60 mm | 0.5 | 1.3 |

*Field of a bare, axially magnetised N42 disc, 20 × 5 mm (a bigger magnet
than the one inside an ITNG-22, and without its steel cup), modelled with
[Magpylib](https://magpylib.readthedocs.io/). Sideways is measured from the
magnet's edge in the plane of the back cover, towards the boards; straight out
from its face. The script is
[`hardware/analysis/magnet_field.py`](../hardware/analysis/magnet_field.py).*

The real magnets are gentler than this model: a pot magnet's steel cup
carries the field round to the front face, so much less of it reaches
sideways or behind. Nothing sits straight out from the magnets' faces
inside the case (that's where the panel is, and it doesn't care).

### Distances in the layout

| From the nearest magnet to | Centre to edge | Magnet edge to edge | Field there (bare-magnet model) |
|---|---|---|---|
| Driver HAT (IT8951, panel supplies) | 36.75 mm | 25.75 mm | 3.9 mT |
| Carrier board (XIAO, MiniBoost, charger) | 55 mm | 44 mm | 1.1 mT |
| Wi-Fi antenna | 35.9 mm | 24.9 mm | not affected by a steady field; kept away from the steel instead |

## Wi-Fi next to a steel door

The door is a large sheet of steel right behind the display, and steel
reflects and detunes a nearby antenna. So the XIAO's antenna is stuck to the
inside of the **top** wall, where it stands out from the door instead of
lying flat against it, clear of the magnets and of any metal. Check the **Wi-Fi
signal** sensor in Home Assistant once it's hung. Anything better than about
−75 dBm is fine; if it's weaker, a Wi-Fi access point in the kitchen helps
more than anything you can do to the display.

## Changing the magnets

The magnet size and positions are parameters at the top of
[`hardware/enclosure/brwr-trmnl.scad`](../hardware/enclosure/brwr-trmnl.scad):
`mag_d`, `mag_h`, and `mag_pos` with one `[X, Y]` per magnet. The render
fails with a message if a magnet ends up too close to a board or the
antenna, or if the M4 screw would reach the magnet's face. With the default
layout there's no room for a fifth or sixth magnet that keeps 25 mm from the
boards. If you move a magnet closer to a
board than 25 mm, rerun the field model with the new gap:

```sh
pip install magpylib numpy
CLEARANCE_MM=20 python3 hardware/analysis/magnet_field.py
```

## Safety

Neodymium magnets this size pinch fingers hard when they snap together, and
can interfere with pacemakers and other implants: keep them at least 15 cm away, and
keep loose magnets away from children. Once they're screwed into the back
they can't come loose. They won't harm the fridge, but they can wipe
magnetic-stripe cards pressed right against them.
