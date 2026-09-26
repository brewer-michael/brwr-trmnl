"""Magnetic field around a fridge magnet, versus distance: the numbers behind
docs/magnets.md, drawn as docs/images/magnet-field.svg.

Worst case on purpose: a bare, axially magnetised N42 disc (20 x 5 mm), larger
than the magnet inside a 22 mm pot magnet, with no steel cup around it. The
real ITNG-22 is a multipole magnet in a steel cup, whose field falls off
faster, especially behind and beside it.

    pip install magpylib numpy
    python hardware/analysis/magnet_field.py
"""

import math
import os

import magpylib as magpy
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "docs", "images", "magnet-field.svg"))

DIAMETER_MM, HEIGHT_MM, BR_T = 20.0, 5.0, 1.30  # N42
LIMIT_MT = 5.0        # design limit at an inductor
CLEARANCE_MM = float(os.environ.get("CLEARANCE_MM", 25.75))  # tightest magnet-edge-to-board gap in the layout

magnet = magpy.magnet.Cylinder(polarization=(0, 0, BR_T), dimension=(DIAMETER_MM / 1000, HEIGHT_MM / 1000))


def field_mt(point_m):
    return float(np.linalg.norm(magnet.getB(point_m)) * 1000)


def axial(d_mm):  # straight out from the face (the direction of the fridge, or of the steel cup's back)
    return field_mt((0, 0, (HEIGHT_MM / 2 + d_mm) / 1000))


def sideways(d_mm):  # in the plane of the back cover, from the magnet's edge toward the boards
    return field_mt(((DIAMETER_MM / 2 + d_mm) / 1000, 0, 0))


distances = [float(d) for d in np.arange(5, 80.5, 1.0)]
series = [
    ("Sideways, toward the boards", "s1", [sideways(d) for d in distances]),
    ("Straight out from the face", "s2", [axial(d) for d in distances]),
]


def below_limit_from(fn):
    return next(x for x in np.arange(1, 100, 0.5) if fn(x) < LIMIT_MT)


SIDEWAYS_OK_MM, AXIAL_OK_MM = below_limit_from(sideways), below_limit_from(axial)

# ---- chart geometry --------------------------------------------------------
W, H = 900, 520
L, R, T, B = 78, 210, 64, 64          # plot margins (right side holds direct labels)
PW, PH = W - L - R, H - T - B
X0, X1 = 0.0, 80.0
Y_TICKS = [0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200]
Y0, Y1 = math.log10(0.15), math.log10(250)


def sx(d):
    return L + (d - X0) / (X1 - X0) * PW


def sy(v):
    return T + (1 - (math.log10(v) - Y0) / (Y1 - Y0)) * PH


def path(xs, ys):
    pts = [(sx(x), sy(y)) for x, y in zip(xs, ys) if 0.15 <= y <= 250]
    return "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in pts)


svg = []
add = svg.append
add(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" '
    'role="img" aria-labelledby="t d">')
add('<title id="t">Magnet field strength versus distance</title>')
add('<desc id="d">Worst-case field of a bare 20 by 5 mm N42 disc magnet, on a log scale. Sideways, toward '
    f'the boards, it drops below {LIMIT_MT:g} millitesla by about {SIDEWAYS_OK_MM:g} mm from the magnet\'s edge; '
    f'straight out from the face it takes about {AXIAL_OK_MM:g} mm. The closest board is {CLEARANCE_MM:g} mm from a '
    f'magnet\'s edge, where the field is {sideways(CLEARANCE_MM):.1f} millitesla.</desc>')
add("""<style>
  .viz { --surface:#fcfcfb; --ink:#0b0b0b; --ink2:#52514e; --muted:#898781; --grid:#e1e0d9; --axis:#c3c2b7;
         --s1:#2a78d6; --s2:#eb6834; }
  @media (prefers-color-scheme: dark) {
    .viz { --surface:#1a1a19; --ink:#ffffff; --ink2:#c3c2b7; --muted:#898781; --grid:#2c2c2a; --axis:#383835;
           --s1:#3987e5; --s2:#d95926; }
  }
  text { font-family: system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
  .title { font-size:17px; font-weight:600; fill:var(--ink); }
  .sub { font-size:13px; fill:var(--ink2); }
  .tick { font-size:12px; fill:var(--muted); font-variant-numeric: tabular-nums; }
  .axis-label { font-size:12px; fill:var(--ink2); }
  .label { font-size:13px; fill:var(--ink); }
  .note { font-size:12px; fill:var(--ink2); }
</style>""")
add('<g class="viz">')
add(f'<rect width="{W}" height="{H}" fill="var(--surface)"/>')
add(f'<text class="title" x="{L}" y="28">How far the magnet field reaches</text>')
add(f'<text class="sub" x="{L}" y="48">Worst case: bare 20 × 5 mm N42 disc, no steel cup. Field strength in mT, '
    'log scale.</text>')

# grid + y ticks
for v in Y_TICKS:
    y = sy(v)
    add(f'<line x1="{L}" x2="{L + PW}" y1="{y:.1f}" y2="{y:.1f}" stroke="var(--grid)" stroke-width="1"/>')
    add(f'<text class="tick" x="{L - 10}" y="{y + 4:.1f}" text-anchor="end">{v:g}</text>')
# x ticks
for d in range(0, 81, 10):
    x = sx(d)
    add(f'<line x1="{x:.1f}" x2="{x:.1f}" y1="{T + PH}" y2="{T + PH + 5}" stroke="var(--axis)" stroke-width="1"/>')
    add(f'<text class="tick" x="{x:.1f}" y="{T + PH + 20}" text-anchor="middle">{d}</text>')
add(f'<line x1="{L}" x2="{L + PW}" y1="{T + PH}" y2="{T + PH}" stroke="var(--axis)" stroke-width="1"/>')
add(f'<text class="axis-label" x="{L + PW / 2:.0f}" y="{H - 16}" text-anchor="middle">'
    'Distance from the magnet (mm): from its edge sideways, from its face straight out</text>')
add(f'<text class="axis-label" transform="translate(20,{T + PH / 2:.0f}) rotate(-90)" text-anchor="middle">'
    'Field (mT)</text>')

# design limit (horizontal) and layout clearance (vertical), labelled as references
yl = sy(LIMIT_MT)
add(f'<line x1="{L}" x2="{L + PW}" y1="{yl:.1f}" y2="{yl:.1f}" stroke="var(--ink2)" stroke-width="1"/>')
add(f'<text class="note" x="{L + PW - 6}" y="{yl - 6:.1f}" text-anchor="end">Design limit at an inductor, '
    f'{LIMIT_MT:g} mT</text>')
xc = sx(CLEARANCE_MM)
add(f'<line x1="{xc:.1f}" x2="{xc:.1f}" y1="{T}" y2="{T + PH}" stroke="var(--ink2)" stroke-width="1"/>')
add(f'<text class="note" x="{xc + 6:.1f}" y="{T + 14}">Closest board to a magnet, {CLEARANCE_MM:g} mm</text>')

# series lines, end dots with a surface ring, direct labels at the right edge
for name, key, values in series:
    add(f'<path d="{path(distances, values)}" fill="none" stroke="var(--{key})" stroke-width="2" '
        'stroke-linejoin="round" stroke-linecap="round"/>')
for name, key, values in series:
    ex, ey = sx(distances[-1]), sy(values[-1])
    add(f'<circle cx="{ex:.1f}" cy="{ey:.1f}" r="4.5" fill="var(--{key})" stroke="var(--surface)" '
        'stroke-width="2"/>')
    add(f'<text class="label" x="{ex + 12:.1f}" y="{ey + 4:.1f}">{name}</text>')
    add(f'<text class="note" x="{ex + 12:.1f}" y="{ey + 20:.1f}">{values[-1]:.1f} mT at 80 mm</text>')

# the one value the story is about: the sideways field at the layout's tightest gap
v = sideways(CLEARANCE_MM)
cx, cy = sx(CLEARANCE_MM), sy(v)
add(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="4.5" fill="var(--s1)" stroke="var(--surface)" stroke-width="2"/>')
add(f'<text class="label" x="{cx - 10:.1f}" y="{cy + 20:.1f}" text-anchor="end">{v:.1f} mT</text>')

# legend (identity never by colour alone)
lx, ly = L + 12, T + PH - 46
for i, (name, key, _) in enumerate(series):
    y = ly + i * 20
    add(f'<line x1="{lx}" x2="{lx + 18}" y1="{y}" y2="{y}" stroke="var(--{key})" stroke-width="2" '
        'stroke-linecap="round"/>')
    add(f'<text class="label" x="{lx + 26}" y="{y + 4}">{name}</text>')
add('</g></svg>')

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w") as f:
    f.write("\n".join(svg) + "\n")
print(f"wrote {OUT}")

# The table in docs/magnets.md
print("| Distance | Sideways (mT) | Straight out (mT) |")
print("|---|---|---|")
for d in (5, 10, 15, 20, 25, 30, 40, 50, 60):
    print(f"| {d} mm | {sideways(d):.1f} | {axial(d):.1f} |")
print(f"below {LIMIT_MT:g} mT sideways from {SIDEWAYS_OK_MM:.1f} mm, straight out from {AXIAL_OK_MM:.1f} mm")
print(f"at the tightest gap ({CLEARANCE_MM:g} mm): {sideways(CLEARANCE_MM):.2f} mT sideways")
