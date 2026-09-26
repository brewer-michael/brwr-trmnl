# Magnets: on the fridge, clear of the electronics

brwr-trmnl hangs on the fridge door by four magnets hidden inside its back
cover. Each is capped with a steel disc, which works like the cup of a pot
magnet: it turns the field towards the door and away from the electronics.
They hold it through a slammed door, and they're far enough from the boards
that their field doesn't matter there.

## The magnets

Four **N52 neodymium discs, 20 × 3 mm**, each with a **20 mm steel disc**
(1–2 mm thick) on top.

- Each sits in a pocket that opens to the inside of the back cover, behind a
  0.6 mm skin of plastic. The steel disc goes on top, and epoxy fills the
  rest. Nothing metal shows outside.
- A self-adhesive rubber pad (25 mm, 0.5–1 mm thick) over each one outside is
  all that touches the door: grip, and no scratches.
- They sit at the four corners of the back, at (±90, ±65) mm from the
  centre.
- The steel disc matters: a bare disc magnet sends as much field backwards
  (into the case) as forwards. The disc carries the back of the field round
  to the front, so the magnet grips harder and less of its field reaches the
  boards.

## Will it hold?

| | |
|---|---|
| brwr-trmnl, complete | about 0.45 kg (estimate: 160 g of printed case, 90 g battery, 80 g panel and HAT, 45 g of steel rod, 45 g magnets and discs) |
| One magnet on thick steel, touching | ~4.3–5.4 kg pull (the supplier's figure for a bare 20 × 3 mm N52 disc) |
| Four, on a fridge door (estimate) | ~4 kg pull, ~2.5 kg sideways |
| Margin (estimate) | ~5 × against sliding down, ~9 × against being pulled off |

The estimate allows for the 0.6 mm skin and the rubber pad (together they
roughly halve a disc magnet's pull), gains back some for the steel backing,
and takes a third of that for a fridge door's thin painted steel. Rubber on
paint gives the sideways grip. These are estimates: hang it, and open and
slam the door a few times with a towel on the floor below. Thinner (0.5 mm)
pads grip harder.

### Will it work on my fridge?

Test the spot with any fridge magnet first.

- **Many stainless-steel doors aren't magnetic** (austenitic stainless,
  such as 304, isn't). The sides of the same fridge are often painted steel
  and are.
- **Glass, wood or "panel-ready" fronts** aren't magnetic either.
- **No magnetic surface?** Stick a thin steel plate or two adhesive steel
  discs on it (sold for phone mounts and "magnetic mounting plates"), or use
  the printed desk stand. On a wall, screw up a steel plate
  ([build guide](build-guide.md#10-hang-it)).

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
magnet's edge**, where even a bare magnet (without its steel disc) produces
**under 5 mT**. That's about 1% of what a ferrite core saturates at, and a
hundred times the Earth's field. The enclosure's source enforces the rule
with `assert()`s on the actual positions (36 mm from each magnet's centre).

![Magnet field versus distance: the sideways field is 2.4 mT at the closest board, 26.75 mm from a magnet's edge](images/magnet-field.svg)

| Distance | Sideways (mT) | Straight out (mT) |
|---|---|---|
| 5 mm | 59.1 | 128.7 |
| 10 mm | 18.5 | 62.0 |
| 15 mm | 8.4 | 30.5 |
| 20 mm | 4.6 | 16.4 |
| 25 mm | 2.8 | 9.6 |
| 30 mm | 1.8 | 6.0 |
| 40 mm | 0.9 | 2.8 |
| 50 mm | 0.5 | 1.5 |
| 60 mm | 0.3 | 0.9 |

*Field of a bare, axially magnetised N52 disc, 20 × 3 mm, without its steel
disc, modelled with [Magpylib](https://magpylib.readthedocs.io/). Sideways
is measured from the magnet's edge in the plane of the back cover, towards
the boards; straight out from its face. The script is
[`hardware/analysis/magnet_field.py`](../hardware/analysis/magnet_field.py).*

The real field inside the case is lower than this: the steel disc on each
magnet carries most of what would go backwards or sideways round to the
front. Straight out behind each magnet there's only the steel disc and, a
few mm further, the panel, which doesn't care.

### Distances in the layout

| From the nearest magnet to | Centre to edge | Magnet edge to edge | Field there (bare-magnet model) |
|---|---|---|---|
| Driver HAT (IT8951, panel supplies) | 36.75 mm | 26.75 mm | 2.4 mT |
| Carrier board (XIAO, MiniBoost, charger) | 55 mm | 45 mm | 0.7 mT |
| Wi-Fi antenna | 35.2 mm | 25.2 mm | not affected by a steady field; kept away from metal instead |

### The steel rods

The thin case is stiffened by 3 mm steel rods epoxied into it: two across
the back cover and one in each corner of the frame. They're plain steel, so
the magnets attract them, but they're epoxied in place, and every rod stays
at least 8 mm from a magnet's edge, so it doesn't pick up and carry the
magnets' field anywhere. They also stay 10 mm from the antenna. The
enclosure's source asserts both rules.

## Wi-Fi next to a steel door

The door is a large sheet of steel right behind the display, and steel
reflects and detunes a nearby antenna. So the antenna (a Taoglas FXP831,
45 × 7 mm) is stuck to the inside of the **top** wall, where it stands out
from the door instead of lying flat against it, with its front edge against
the front face and no metal within 10 mm. Check the **Wi-Fi signal** sensor
in Home Assistant once it's hung. Anything better than about −75 dBm is
fine; if it's weaker, a Wi-Fi access point in the kitchen helps more than
anything you can do to the display.

## Changing the magnets

The magnet size and positions are parameters at the top of
[`hardware/enclosure/brwr-trmnl.scad`](../hardware/enclosure/brwr-trmnl.scad):
`mag_d`, `mag_h`, `steel_disc`, and `mag_pos` with one `[X, Y]` per magnet.
The render fails with a message if a magnet ends up too close to a board or
the antenna, or a rod too close to a magnet. With the default layout there's
no room for a fifth or sixth magnet that keeps 25 mm from the boards. If you
move a magnet closer to a board than 25 mm, rerun the field model with the
new gap:

```sh
pip install magpylib numpy
CLEARANCE_MM=20 python3 hardware/analysis/magnet_field.py
```

## Safety

Neodymium magnets this size pinch fingers hard when they snap together or
onto steel, and can interfere with pacemakers and other implants: keep them
at least 15 cm away, and keep loose magnets away from children. Once
they're set in epoxy they can't come loose. They won't harm the fridge, but
they can wipe magnetic-stripe cards pressed right against them.
