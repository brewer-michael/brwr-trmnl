"""wiring.svg: how the modules connect, seen from the back of the device.

All positions are front-view coordinates in mm (origin at the enclosure centre, +X right,
+Y up), taken from hardware/enclosure/brwr-trmnl.scad. The drawing is the view from the
back, so X is mirrored on screen.
"""

from __future__ import annotations

import math

import carrier as C
from svgkit import COL, Svg, text_w

W, H = 1400, 1015
K = 4.3                              # px per mm
CX, CY = 40 + 114.5 * K, 118 + 102 * K

# Enclosure and module geometry (front view, mm) -----------------------------------
OUT_W, OUT_H, WALL = 229.0, 204.0, 2.5
PANEL = (-108.35, -78.0, 108.35, 96.41)               # x0, y0, x1, y1
CAR_TOP = (OUT_H - 2 * WALL) / 2                       # 99.5: carrier top edge against the top wall
CARRIER = (-35.0, CAR_TOP - 35.0, 35.0, CAR_TOP)
HAT = (-73 - 32.5, -28.25, -73 + 32.5, 28.25)
BATT = (56 - 50, -30.0, 56 + 50, 30.0)
FLEX = (-70.5, -78.0, 70.5, -60.0)                     # folded flex behind the panel
FLEX_ZONE = (-72.0, -78.0, 72.0, -38.0)
ADAPTER = (-25 - 15, -69.0, -25 + 15, -54.0)
STRIP = (-42.0, -99.0, 42.0, -79.0)                    # button board, 84 x 20, centre (0, -89)
BTN_X = {"BACK": -26.0, "REFRESH": 0.0, "NEXT": 26.0}
MAGNETS = [(-90, 65), (90, 65), (-90, -65), (90, -65)]
ANT = (38.0, 80.0)                                     # X range on the inside of the top wall
WIRE_X = -30.0                                         # button wires run up the back cover here (clear of its joint at -39)


def B(x, y):
    """Front-view mm -> back-view px (X mirrored)."""
    return CX - x * K, CY - y * K


def brect(s: Svg, r, **kw):
    x0, y0, x1, y1 = r
    (ax, ay), (bx, by) = B(x1, y1), B(x0, y0)
    s.rect(ax, ay, bx - ax, by - ay, **kw)
    return ax, ay, bx - ax, by - ay


def car(xc, yc):
    """Carrier-layout coordinates (component side, mm from the board centre / top edge) -> front mm."""
    return xc, CAR_TOP - yc


def smooth(pts):
    """Catmull-Rom through px points -> SVG path d."""
    d = f"M {pts[0][0]:.1f} {pts[0][1]:.1f}"
    for i in range(len(pts) - 1):
        p0 = pts[i - 1] if i > 0 else pts[i]
        p1, p2 = pts[i], pts[i + 1]
        p3 = pts[i + 2] if i + 2 < len(pts) else p2
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d += f" C {c1[0]:.1f} {c1[1]:.1f} {c2[0]:.1f} {c2[1]:.1f} {p2[0]:.1f} {p2[1]:.1f}"
    return d


def offset(pts, dist):
    """Offset a px polyline sideways by dist (for drawing parallel wires in a bundle)."""
    out = []
    for i, (x, y) in enumerate(pts):
        a = pts[max(i - 1, 0)]
        b = pts[min(i + 1, len(pts) - 1)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        n = math.hypot(dx, dy) or 1
        out.append((x - dy / n * dist, y + dx / n * dist))
    return out


def bundle(s: Svg, pts, colors, gap=3.2, width=2.2, hidden_until=0, hidden_from=None):
    """Parallel coloured wires along a smooth path (px). A grey sleeve behind keeps them readable."""
    n = len(colors)
    s.path(smooth(pts), stroke="#ffffff", width=gap * n + 5)
    for i, c in enumerate(colors):
        o = (i - (n - 1) / 2) * gap
        s.path(smooth(offset(pts, o)), stroke=c, width=width)


def hatch_defs(s: Svg):
    s.defs.append('<pattern id="hatch" width="6" height="6" patternUnits="userSpaceOnUse" '
                  'patternTransform="rotate(45)"><rect width="6" height="6" fill="#eceff1"/>'
                  '<line x1="0" y1="0" x2="0" y2="6" stroke="#546e7a" stroke-width="1.6"/></pattern>')
    s.defs.append('<pattern id="flexfill" width="8" height="8" patternUnits="userSpaceOnUse">'
                  '<rect width="8" height="8" fill="#f3c16b"/>'
                  '<line x1="0" y1="0" x2="8" y2="0" stroke="#e0a73d" stroke-width="1"/></pattern>')


def label(s: Svg, x, y, rows, anchor="middle", size=12.5, box=True, bold_first=True):
    """Multi-line label with an optional white box behind it (px coordinates, y = first baseline)."""
    lh = size + 4
    w = max(text_w(r, size, bold_first and i == 0) for i, r in enumerate(rows)) + 12
    h = lh * len(rows) + 6
    x0 = x - w / 2 if anchor == "middle" else (x - 6 if anchor == "start" else x - w + 6)
    if box:
        s.rect(x0, y - size - 3, w, h, fill="#ffffff", stroke="#90a4ae", width=1, rx=4, opacity=0.95)
    for i, r in enumerate(rows):
        s.text(x0 + w / 2, y + i * lh, r, size=size, anchor="middle",
               weight="bold" if (bold_first and i == 0) else "normal",
               fill=COL["text"] if i == 0 else COL["text2"])
    return x0, y - size - 3, w, h


# ------------------------------------------------------------------------------ drawing
def draw_enclosure(s: Svg):
    r = (-OUT_W / 2, -OUT_H / 2, OUT_W / 2, OUT_H / 2)
    brect(s, r, fill="#cfd4da", stroke="#37474f", width=2, rx=5 * K)
    brect(s, (r[0] + WALL, r[1] + WALL, r[2] - WALL, r[3] - WALL), fill="#eef0f3", stroke="#90a4ae", width=1,
          rx=3 * K)
    brect(s, PANEL, fill="#dde1e6", stroke="#9aa5b1", width=1.2)
    # magnet keep-out rule: 36 mm from the magnet centre to any board edge (clipped to the interior)
    ax, ay = B(OUT_W / 2 - WALL, OUT_H / 2 - WALL)
    s.defs.append(f'<clipPath id="inside"><rect x="{ax:.1f}" y="{ay:.1f}" width="{(OUT_W - 2 * WALL) * K:.1f}" '
                  f'height="{(OUT_H - 2 * WALL) * K:.1f}"/></clipPath>')
    circles = "".join(f'<circle cx="{B(mx, my)[0]:.1f}" cy="{B(mx, my)[1]:.1f}" r="{36 * K:.1f}" fill="none" '
                      f'stroke="#e57373" stroke-width="1.1" stroke-dasharray="5 4"/>' for mx, my in MAGNETS)
    s.add(f'<g clip-path="url(#inside)">{circles}</g>')


def draw_flex(s: Svg):
    brect(s, FLEX_ZONE, fill="none", stroke="#c28a2c", width=1, stroke_dasharray="6 4")
    brect(s, FLEX, fill="url(#flexfill)", stroke="#b7791f", width=1.2)
    x, y, w, h = brect(s, ADAPTER, fill="#2f6b4f", stroke="#1b4332", width=1.4, rx=3)
    s.text(x + 8, y + h / 2 + 4.5, "adapter", size=12, anchor="start", fill="#ffffff", weight="bold")  # clear of the button lead


def draw_battery(s: Svg):
    x, y, w, h = brect(s, BATT, fill="#4f5b66", stroke="#263238", width=1.6, rx=6)
    s.text(x + w / 2, y + h / 2 - 8, "BT1  LiPo 3.7 V  5000 mAh", size=14, anchor="middle", weight="bold",
           fill="#ffffff")
    s.text(x + w / 2, y + h / 2 + 12, "100 × 60 × 6 mm, in its cradle", size=12.5, anchor="middle", fill="#e0e0e0")


def draw_hat(s: Svg):
    x, y, w, h = brect(s, HAT, fill="#2f6b4f", stroke="#1b4332", width=1.6, rx=4)
    # 2x20 header along the +Y edge, facing the back cover (visible from here)
    hx0, hy0 = -73 - 25.4, 28.25 - 3.5 - 2.55
    brect(s, (hx0, hy0, hx0 + 50.8, hy0 + 5.1), fill="#1c1c1c", stroke="#000000", width=1)
    for sx_, sy_ in [(-73 + a * 29, b * 24.75) for a in (-1, 1) for b in (-1, 1)]:
        cx, cy = B(sx_, sy_)
        s.circle(cx, cy, 1.4 * K, fill="#eef0f3", stroke="#9e9e9e", width=1)
    # FFC socket on the +X edge (panel side, drawn dashed)
    brect(s, (-40.5 - 5, -15, -40.5, 15), fill="none", stroke="#ffffff", width=1.4, stroke_dasharray="4 3")
    # PH2.0 host connector (panel side)
    brect(s, (-40.5 - 8, 16.0, -40.5 - 1.5, 24.0), fill="none", stroke="#ffffff", width=1.4, stroke_dasharray="4 3")
    s.text(x + w / 2 + 14, y + h / 2 - 2, "U2  driver HAT", size=14, anchor="middle", weight="bold", fill="#ffffff")
    s.text(x + w / 2 + 14, y + h / 2 + 17, "IT8951, DIP switches: SPI", size=12, anchor="middle", fill="#e8f5e9")
    s.text(x + w / 2 + 14, y + h / 2 + 34, "2×20 header faces you", size=12, anchor="middle", fill="#e8f5e9")


def draw_carrier(s: Svg):
    """Carrier seen from its solder side: board, holes, and the parts on the far side dashed."""
    x0, y0, x1, y1 = CARRIER
    brect(s, CARRIER, fill="#efe2c4", stroke="#8d7b5a", width=1.4, rx=2)
    for k in range(27):
        for r in range(13):
            cx, cy = B(*car(C.hx(k), C.hy(r)))
            s.circle(cx, cy, 1.5, fill="#c9ab76", stroke="none", width=0)
    for mx, my in C.MOUNT:
        cx, cy = B(*car(mx, my))
        s.circle(cx, cy, 1.35 * K, fill="#ffffff", stroke="#616161", width=1.2)
    # far-side parts (component side faces the panel)
    far = dict(fill="#ffffff", stroke="#546e7a", width=1.2, stroke_dasharray="4 3", opacity=0.9)
    for part, name in ((C.U4, "U4 charger"), (C.XIAO, "U1 XIAO"), (C.U3, "U3")):
        xa, ya = car(part["x0"], part["y0"])
        xb, yb = car(part["x0"] + part["w"], part["y0"] + part["h"])
        bx, by, bw, bh = brect(s, (xa, yb, xb, ya), **far)
        ly = by + 48 if name == "U1 XIAO" else by + bh - 10
        s.text(bx + bw / 2, ly, name, size=11.5, anchor="middle", weight="bold", fill="#37474f")
    # USB-C connectors overhang the top edge
    for ux in (-7.62, 22.0):
        brect(s, (ux - 4.47, CAR_TOP - 5.8, ux + 4.47, CAR_TOP + 1.5), fill="#b0bec5", stroke="#546e7a", width=1.2,
              rx=4)
    # headers and sockets on the far side
    for (k, r0, n) in ((15, 2, 8), (5, 0, 4)):
        xa, ya = car(C.hx(k) - 1.27, C.hy(r0) - 1.27)
        xb, yb = car(C.hx(k) + 1.27, C.hy(r0 + n - 1) + 1.27)
        brect(s, (xa, yb, xb, ya), fill="#455a64", stroke="#263238", width=1, opacity=0.55)
    jx = (C.hx(20) + C.hx(21)) / 2
    xa, ya = car(jx - 3.95, C.hy(11) - 1.6)
    xb, yb = car(jx + 3.95, C.hy(11) + 4.0)
    brect(s, (xa, yb, xb, ya), fill="#f5f0e1", stroke="#8d8672", width=1.2, opacity=0.9)


def draw_strip(s: Svg):
    x, y, w, h = brect(s, STRIP, fill="#efe2c4", stroke="#8d7b5a", width=1.4, rx=2)
    for bx in (-38.0, 38.0):
        cx, cy = B(bx, -89.0)
        s.circle(cx, cy, 1.35 * K, fill="#ffffff", stroke="#616161", width=1.2)
    for name, bx in BTN_X.items():
        brect(s, (bx - 6, -95, bx + 6, -83), fill="#ffffff", stroke="#546e7a", width=1.2, stroke_dasharray="4 3")
        cx, cy = B(bx, -89.0)
        s.circle(cx, cy, 3.2 * K, fill="none", stroke="#90a4ae", width=1, stroke_dasharray="3 3")
        s.text(cx, cy + 4, name, size=11.5, anchor="middle", weight="bold", fill="#1b5e20")


def draw_antenna(s: Svg):
    y_in = OUT_H / 2 - WALL
    x, y, w, h = brect(s, (ANT[0], y_in - 1.6, ANT[1], y_in + 0.6), fill="#c9a227", stroke="#8d6e1f", width=1.2)
    return (ANT[0] + 3, y_in - 1.0)


def draw_cables(s: Svg, feed):
    P = lambda pts: [B(x, y) for x, y in pts]
    # 40-pin FFC: adapter -> HAT socket on its +X edge
    fx0, fy0 = B(-29, -54)
    fx1, fy1 = B(-29, -14)
    fx2, fy2 = B(-40.5, 0)
    d = (f"M {fx0:.1f} {fy0:.1f} L {fx1:.1f} {fy1:.1f} "
         f"Q {fx1:.1f} {fy2:.1f} {fx2:.1f} {fy2:.1f}")
    for col, wd in (("#9e9e9e", 11 * K + 3), ("#fbfbfb", 11 * K)):
        s.add(f'<path d="{d}" fill="none" stroke="{col}" stroke-width="{wd:.1f}" stroke-linejoin="round"/>')
    s.path(d, stroke="#d6d6d6", width=1)
    # battery lead: cradle slot on the -X wall (front) -> J1 on the carrier's bottom edge
    jx = (C.hx(20) + C.hx(21)) / 2
    bat = P([(6.5, 2), (4, 22), (10, 44), (jx, 58), (jx, 65.6)])
    bundle(s, bat, [COL["gnd"], COL["vbat"]], gap=3.4, width=2.6)
    # button lead: strip -> up the back cover at X = -30 -> under the carrier to J3
    j3 = car(C.hx(5), C.hy(1.5))
    btn_vis = P([(WIRE_X, -79), (WIRE_X, -40), (WIRE_X, 30), (WIRE_X, 52), (-30, 62), (-24.5, CAR_TOP - 35)])
    bundle(s, btn_vis, [COL["btn"], COL["btn"], COL["btn"], COL["gnd"]])
    btn_hid = P([(-24.5, CAR_TOP - 35), (-21.5, 80), j3])
    s.path(smooth(btn_hid), stroke=COL["btn"], width=2.4, stroke_dasharray="5 4")
    # HAT cable (kit PH2.0 8-pin): J2 -> under the carrier -> HAT host connector
    j2 = car(C.hx(15), C.hy(6))
    hat_hid = P([j2, (4.0, 72), (3.0, CAR_TOP - 35)])
    s.path(smooth(hat_hid), stroke=COL["spi"], width=2.4, stroke_dasharray="5 4")
    hat_vis = P([(3.0, CAR_TOP - 35), (-2, 52), (-18, 40), (-34, 32), (-44.75, 24.5)])
    bundle(s, hat_vis, [COL["v5"], COL["gnd"], COL["spi"], COL["spi"], COL["spi"], COL["spi"], COL["ctl"],
                        COL["ctl"]], gap=2.6, width=1.9)
    # antenna coax: feed at the antenna's -X end (front) -> over the carrier (hidden) -> U.FL on U1
    ufl = car(*C.UFL)
    coax = P([feed, (39, 94), (36.5, 90)])
    s.path(smooth(coax), stroke=COL["coax"], width=2.6, stroke_dasharray="6 4")
    coax_h = P([(36.5, 90), (24, 86), (6, 83), ufl])
    s.path(smooth(coax_h), stroke=COL["coax"], width=2.2, stroke_dasharray="3 4")
    cx, cy = B(*ufl)
    s.circle(cx, cy, 3.4, fill="#c9a227", stroke="#6d5b1f", width=1)


def draw_magnets(s: Svg):
    for mx, my in MAGNETS:
        cx, cy = B(mx, my)
        s.circle(cx, cy, 11 * K, fill="url(#hatch)", stroke="#37474f", width=1.6)
        s.circle(cx, cy, 2.2 * K, fill="#ffffff", stroke="#37474f", width=1.2)
    # the nearest board to a magnet edge: the HAT, 25.75 mm below the upper-right magnet (back view)
    x, y_top = B(-90, 65 - 11)
    _, y_hat = B(-90, 28.25)
    s.line(x, y_top, x, y_hat, stroke="#c62828", width=1.4)
    for yy, sgn in ((y_top, 1), (y_hat, -1)):
        s.polygon([(x, yy), (x - 4, yy + 8 * sgn), (x + 4, yy + 8 * sgn)], fill="#c62828", stroke="none", width=0)
        s.line(x - 12, yy, x + 12, yy, stroke="#c62828", width=1)
    return x, (y_top + y_hat) / 2


def build() -> str:
    s = Svg(W, H, "brwr-trmnl v1 wiring, back view",
            "Where each module sits and how the cables run, seen from the back with the back cover off: carrier, "
            "driver HAT, battery, panel flex and adapter, button board, antenna and magnets.")
    hatch_defs(s)
    s.text(40, 40, "brwr-trmnl v1 — wiring, seen from the back", size=22, weight="bold")
    s.text(40, 66, "Back cover off, looking at the back of the panel: left and right are swapped compared with the "
                   "front. The HAT is on the right here", size=13.5, fill=COL["text2"])
    s.text(40, 86, "and on the left seen from the front. Dashed outlines are parts on the far side of a board, "
                   "facing the panel. Positions from the enclosure model.", size=13.5, fill=COL["text2"])

    draw_enclosure(s)
    draw_flex(s)
    draw_battery(s)
    draw_hat(s)
    draw_carrier(s)
    draw_strip(s)
    feed = draw_antenna(s)
    draw_cables(s, feed)
    dim_x, dim_y = draw_magnets(s)
    annotate(s, dim_x, dim_y)
    return s.render()


def num(s: Svg, x, y, n, r=10):
    s.circle(x, y, r, fill="#ffffff", stroke="#37474f", width=1.6)
    s.text(x, y + 4.5, str(n), size=12.5, anchor="middle", weight="bold")


def annotate(s: Svg, dim_x, dim_y):
    # top edge: antenna and USB-C slots
    y = 108
    s.text(B(62, 0)[0], y, "ANT1 on the top wall", size=12, anchor="middle", weight="bold")
    s.text(B(22, 0)[0], y, "USB-C charging", size=12, anchor="middle", weight="bold")
    s.text(B(-7.62, 0)[0], y, "USB-C flash, logs", size=12, anchor="middle", weight="bold")

    # carrier tags and label
    def tag(x, y, t):
        w = text_w(t, 12, True) + 10
        s.rect(x - w / 2, y - 10, w, 20, fill="#ffffff", stroke="#455a64", width=1.1, rx=4)
        s.text(x, y + 4.3, t, size=12, anchor="middle", weight="bold")

    tag(B(C.hx(15), 0)[0], B(0, CAR_TOP - 6.4)[1] - 6, "J2")
    tag(B(C.hx(5), 0)[0], B(0, CAR_TOP - 16.2)[1], "J3")
    tag(B(21.59 - 10.2, 0)[0], B(0, CAR_TOP - 32.3)[1], "J1")
    label(s, 778, 154, ["Carrier", "solder side faces you;", "parts face the panel"], size=12)

    # cable numbers
    num(s, *B(-12, 44.5), 1)
    num(s, *B(8.5, 40), 2)
    num(s, *B(WIRE_X, -20), 3)
    num(s, *B(38.6, 93.5), 4)
    num(s, *B(-29, -30), 5)

    # module labels
    label(s, 232, 934, ["Button board", "SW1–SW3 face the front"], size=12)
    s.text(B(40, 0)[0], B(0, -71)[1] + 4, "panel flex, folded behind the panel", size=12, anchor="middle",
           weight="bold", fill="#5d4037")
    s.text(B(40, 0)[0], B(0, -42)[1], "flex zone, 144 × 40 mm, kept clear", size=11.5, anchor="middle",
           fill="#8d6e1f")
    s.text(B(55, 0)[0], B(0, -35.5)[1] + 4, "Back of the 10.3″ panel", size=12.5, anchor="middle",
           fill=COL["text2"], weight="bold")
    label(s, dim_x + 10, dim_y - 8, ["≥ 25 mm", "from any board"], anchor="start", size=12)
    label(s, B(90, 0)[0], B(0, -65 - 17)[1], ["Magnet Ø22 (4×)"], size=12)

    # ---- side panel
    x0 = 1045
    s.legend(x0, 118, title="Colour code", col_w=320, size=12.5,
             extra=[(lambda sv, cx, cy: (sv.line(cx, cy, cx + 36, cy, stroke="#9e9e9e", width=9,
                                                  stroke_linecap="butt"),
                                          sv.line(cx, cy, cx + 36, cy, stroke="#fbfbfb", width=7,
                                                  stroke_linecap="butt")),
                     "40-pin FFC (panel)")])
    y = 392
    s.rect(x0, y, 344, 262, fill="#ffffff", stroke=COL["blockline"], width=1.2, rx=6)
    s.text(x0 + 12, y + 22, "Cables", size=13, weight="bold")
    cables = [("PH2.0 8-pin, from the kit:", "carrier J2 → HAT host connector"),
              ("JST-PH 2-pin: battery → J1.", "Check polarity with a meter first."),
              ("4-wire lead: button board → J3,", "tied up the back cover at X = −30"),
              ("U.FL coax, 80 mm: antenna → U1,", "over the carrier's parts"),
              ("40-pin FFC: adapter → HAT socket", "on the HAT's +X edge")]
    for i, (a, b) in enumerate(cables):
        yy = y + 50 + i * 42
        num(s, x0 + 22, yy - 4, i + 1)
        s.text(x0 + 40, yy, a, size=12.5, weight="bold")
        s.text(x0 + 40, yy + 17, b, size=12.5, fill=COL["text2"])
    y = 670
    notes = ["Front-view X is mirrored here: the charger",
             "(X = +22) is left of the XIAO (X = −8), and the",
             "MiniBoost (X = −28) is at the carrier's right end.",
             "",
             "The carrier and HAT face the panel. Their plugs",
             "sit between board and panel; route the cables",
             "around the board edges as drawn.",
             "",
             "Magnets stay ≥ 25 mm from any board edge",
             "(dashed circles: 36 mm from each centre).",
             "",
             "Enclosure 229 × 204 × 25 mm."]
    s.rect(x0, y, 344, 36 + len(notes) * 18, fill=COL["note"], stroke=COL["noteline"], width=1.2, rx=6)
    s.text(x0 + 12, y + 22, "Notes", size=13, weight="bold")
    for i, n in enumerate(notes):
        s.text(x0 + 12, y + 44 + i * 18, n, size=12.5)
