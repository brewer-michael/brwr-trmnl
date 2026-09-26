"""carrier-layout.svg: protoboard layout of the 70 x 35 mm carrier (component side).

Seen from the component side, as the board sits in the back cover: the same left
and right as the front of the display. X in mm from the board centre (right +),
Y in mm down from the top edge. Holes: 27 x 13 on a 2.54 mm grid, hole (k, r) at
X = -33.02 + 2.54 k, Y = 2.88 + 2.54 r (first row 2.88 mm below the top edge, so
the XIAO sits flush with it and its USB-C overhangs by 1.55 mm).
"""

from __future__ import annotations

import math

from svgkit import COL, Svg, text_w

W, H = 1400, 1052
S = 12.6                     # px per mm
BX, BY = 118, 196            # px of the board's top-left corner
BW, BH = 70.0, 35.0
PITCH = 2.54
STRIP_Y = 1.05               # solder-side wire along the top margin, above the first hole row
MARGIN_X = 34.3              # solder-side wire along the right margin

# Part geometry (mm) ----------------------------------------------------------------
XIAO = dict(x0=-16.51, y0=0.0, w=17.78, h=21.0)             # soldered flat, castellations on k7 / k13
BATM = (-16.51 + 4.445, 8.21)                                  # BAT- pad (underside)
BATP = (-16.51 + 4.445, 10.12)                                 # BAT+ pad (underside)
UFL = (-7.62 - 4.85, 19.36)
U4 = dict(x0=13.25, y0=-0.5, w=17.5, h=28.0)                  # TP4056 module, USB-C centre at X = +22
U4PADS = {"OUT−": 15.05, "B−": 19.45, "B+": 24.05, "OUT+": 28.45}
U4PAD_Y = 25.8
U3 = dict(x0=-34.925, y0=7.96, w=11.43, h=17.78)             # MiniBoost, header 2.54 mm above its bottom edge
MOUNT = [(-30.0, 5.0), (30.0, 31.0)]                           # M2.5: 5 mm below the top / 4 mm above the bottom


def hx(k):
    return -33.02 + PITCH * k


def hy(r):
    return 2.88 + PITCH * r


def px(x):
    return BX + (x + BW / 2) * S


def py(y):
    return BY + y * S


def P(k, r):
    """Hole (k, r) -> px. Half steps are channels between holes."""
    return px(hx(k)), py(hy(r))


def Q(x, y):
    """mm -> px."""
    return px(x), py(y)


XL = ["D0", "D1", "D2", "D3", "D4", "D5", "D6"]                  # k7, r0..r6
XR = ["5V", "GND", "3V3", "D10", "D9", "D8", "D7"]               # k13, r0..r6
J2PINS = ["5V", "GND", "MISO", "MOSI", "SCK", "CS", "RST", "HRDY"]  # k15, r2..r9
J3PINS = ["BACK", "REFRESH", "NEXT", "GND"]                         # k5, r0..r3
U3PINS = ["VIN", "GND", "5V", "EN"]                                 # k0..k3, r8

# Solder-side wires: (net, width class, points). Points are (k, r) holes, or ("mm", x, y).
M = lambda x, y: ("mm", x, y)
WIRES = [
    # --- buses along the bottom: GND r10, 5V r11, VBAT r12
    ("gnd", "bus", [(16, 10), (1, 10)]),
    ("v5", "bus", [(2, 11), (17, 11)]),
    ("vbat", "bus", [(23, 12), (0, 12)]),
    ("gnd", "bus", [(1, 8), (1, 10)]),                 # U3 GND
    ("v5", "bus", [(2, 8), (2, 11)]),                  # U3 5V
    ("vbat", "bus", [(0, 12), (0, 8)]),                # U3 VIN
    # --- VBAT branch up the right margin and along the top margin to the XIAO's BAT+ wire
    ("vbat", "pwr", [(23, 12), (26, 12), M(MARGIN_X, hy(12)), M(MARGIN_X, STRIP_Y), M(hx(8), STRIP_Y), (8, 3)]),
    # --- 5V up to C2 and J2, GND from J2 / C2 down to the bus
    ("v5", "pwr", [(17, 11), (17, 2), (15, 2)]),
    ("gnd", "pwr", [(15, 3), (16, 3), (16, 10)]),
    ("gnd", "sig", [(13, 1), (14, 2), (15, 3)]),       # U1 GND pin -> J2 GND
    # --- J1 links (battery side of U4: not GND)
    ("gnd", "sig", [(19, 11), (20, 11)]),
    ("vbat", "sig", [(22, 11), (21, 11)]),
    # --- buttons D0-D2 -> J3, J3 GND -> U3 GND under the MiniBoost
    ("btn", "sig", [(7, 0), (5, 0)]),
    ("btn", "sig", [(7, 1), (5, 1)]),
    ("btn", "sig", [(7, 2), (5, 2)]),
    ("gnd", "sig", [(5, 3), (4.5, 3.5), (1.5, 3.5), (1.5, 8), (1, 8)]),
    # --- EN: D5 -> U3 EN, and down to R4 (upright at k4, r9-r10)
    ("ctl", "sig", [(7, 5), (6.4, 5.6), (4.6, 5.6), (4, 6.2), (4, 7.4), (3, 8)]),
    ("ctl", "sig", [(4, 7.4), (4, 9)]),
    # --- BATT_SENSE: D3 -> R2 top (k5, r6) and R1 top (k6, r8); C1 at (k7, r8)-(k7, r9)
    ("sense", "sig", [(7, 3), (6.3, 3.7), (5.6, 4.4), (5.6, 5.5), (5, 6)]),
    ("sense", "sig", [(5, 6), (6, 7), (6, 8)]),
    ("sense", "sig", [(6, 8), (7, 8)]),
    ("gnd", "sig", [(7, 9), (7, 10)]),
    # --- SPI and HRDY hops, U1 right column -> J2 (k15, r2..r9)
    ("spi", "sig", [(13, 4), (15, 4)]),                                   # MISO
    ("spi", "sig", [(13, 3), (13.6, 3.6), (14.3, 4.8), (15, 5)]),          # MOSI
    ("spi", "sig", [(13, 5), (14, 5.7), (15, 6)]),                          # SCK
    ("ctl", "sig", [(13, 6), (13.5, 6.5), (13.5, 8.4), (14.3, 9), (15, 9)]),  # HRDY
    # --- CS: under U1 and out below its right column
    ("spi", "sig", [(7, 4), (7.6, 4.6), (11.5, 4.6), (11.5, 7), (15, 7)]),
    # --- RST: D6 -> R3 (k10..k14 on r8) -> J2
    ("ctl", "sig", [(7, 6), (7, 7), (7.4, 7.25), (9.3, 7.25), (10, 8)]),
    ("ctl", "sig", [(14, 8), (15, 8)]),
]
WIDTH = {"bus": 5.0, "pwr": 4.0, "sig": 2.6}

JOINTS = {
    "gnd": [(1, 10), (5, 10), (4, 10), (7, 10), (16, 10), (16, 3), (15, 3), (13, 1), (1, 8), (5, 3),
            (19, 11), (20, 11)],
    "v5": [(2, 11), (17, 11), (17, 4), (17, 2), (15, 2), (2, 8)],
    "vbat": [(0, 12), (0, 8), (6, 12), (1, 12), (23, 12), (8, 3), (21, 11), (22, 11)],
    "sense": [(7, 3), (5, 6), (6, 8), (7, 8)],
    "ctl": [(7, 5), (3, 8), (4, 9), (7, 6), (10, 8), (14, 8), (15, 8), (15, 9), (13, 6)],
}


# ------------------------------------------------------------------------------ drawing helpers
def to_px(p):
    if isinstance(p, tuple) and len(p) == 3 and p[0] == "mm":
        return Q(p[1], p[2])
    return P(*p)


def path_d(pts, rad=5.0):
    """Polyline (px) with rounded corners."""
    if len(pts) == 2:
        (x1, y1), (x2, y2) = pts
        return f"M {x1:.1f} {y1:.1f} L {x2:.1f} {y2:.1f}"
    d = f"M {pts[0][0]:.1f} {pts[0][1]:.1f}"
    for i in range(1, len(pts) - 1):
        (xa, ya), (xb, yb), (xc, yc) = pts[i - 1], pts[i], pts[i + 1]
        la = math.hypot(xb - xa, yb - ya) or 1
        lc = math.hypot(xc - xb, yc - yb) or 1
        r = min(rad, la / 2, lc / 2)
        p1 = (xb - (xb - xa) / la * r, yb - (yb - ya) / la * r)
        p2 = (xb + (xc - xb) / lc * r, yb + (yc - yb) / lc * r)
        d += f" L {p1[0]:.1f} {p1[1]:.1f} Q {xb:.1f} {yb:.1f} {p2[0]:.1f} {p2[1]:.1f}"
    return d + f" L {pts[-1][0]:.1f} {pts[-1][1]:.1f}"


def mm_rect(s: Svg, x0, y0, w, h, **kw):
    s.rect(px(x0), py(y0), w * S, h * S, **kw)


def wire(s: Svg, pts_px, color, w):
    d = path_d(pts_px)
    s.path(d, stroke="#ffffff", width=w + 3.4)
    s.path(d, stroke=color, width=w)


def jumper(s: Svg, pts_px, color):
    """Insulated wire lying on the component side."""
    d = path_d(pts_px, rad=10)
    s.path(d, stroke="#212121", width=6.4)
    s.path(d, stroke=color, width=3.8)
    for x, y in (pts_px[0], pts_px[-1]):
        s.circle(x, y, 3.6, fill="#bdbdbd", stroke="#616161", width=1)


def tag(s: Svg, x, y, text, size=12, fill="#ffffff", stroke="#455a64"):
    w = text_w(text, size, True) + 10
    s.rect(x - w / 2, y - size / 2 - 4, w, size + 8, fill=fill, stroke=stroke, width=1.1, rx=4)
    s.text(x, y + size * 0.36, text, size=size, anchor="middle", weight="bold")
    return w


BANDS = {
    "220k1": ["#d32f2f", "#d32f2f", "#111111", "#f57c00", "#6d4c41"],   # red red black orange brown
    "1k": ["#6d4c41", "#111111", "#d32f2f", "#c9a227"],                 # brown black red gold
    "4k7": ["#fbc02d", "#7b1fa2", "#d32f2f", "#c9a227"],                # yellow violet red gold
}


def resistor(s: Svg, a, b, bands):
    """Axial resistor lying between holes a and b; returns its body rect (px)."""
    (x1, y1), (x2, y2) = P(*a), P(*b)
    s.line(x1, y1, x2, y2, stroke="#9e9e9e", width=2.2)
    L = math.hypot(x2 - x1, y2 - y1)
    ux, uy = (x2 - x1) / L, (y2 - y1) / L
    bl, bw = 6.3 * S, 2.4 * S
    cx, cy = (x1 + x2) / 2, (y1 + y2) / 2
    horiz = abs(ux) > abs(uy)
    box = (cx - bl / 2, cy - bw / 2, bl, bw) if horiz else (cx - bw / 2, cy - bl / 2, bw, bl)
    s.rect(*box, fill="#ead2a4", stroke="#8d6e3f", width=1.2, rx=bw / 2.2)
    n = len(bands)
    for i, c in enumerate(bands):
        t = -0.32 + i * (0.5 / (n - 2)) if i < n - 1 else 0.36
        bx, by = cx + ux * t * bl, cy + uy * t * bl
        if horiz:
            s.rect(bx - 2.2, cy - bw / 2 + 0.6, 4.4, bw - 1.2, fill=c, stroke="none", width=0)
        else:
            s.rect(cx - bw / 2 + 0.6, by - 2.2, bw - 1.2, 4.4, fill=c, stroke="none", width=0)
    return ("rect",) + box


def ecap_top(s: Svg, cx, cy, dia, plus_ang, label):
    """Standing electrolytic seen from above; plus_ang points to the + lead."""
    r = dia / 2 * S
    s.circle(cx, cy, r, fill="#20406e", stroke="#0d2240", width=1.4)
    a = plus_ang + math.pi
    a0, a1 = a - 0.8, a + 0.8
    s.path(f"M {cx + r * math.cos(a0):.1f} {cy + r * math.sin(a0):.1f} A {r:.1f} {r:.1f} 0 0 1 "
           f"{cx + r * math.cos(a1):.1f} {cy + r * math.sin(a1):.1f} "
           f"L {cx + 0.6 * r * math.cos(a1):.1f} {cy + 0.6 * r * math.sin(a1):.1f} "
           f"A {0.6 * r:.1f} {0.6 * r:.1f} 0 0 0 {cx + 0.6 * r * math.cos(a0):.1f} {cy + 0.6 * r * math.sin(a0):.1f} Z",
           fill="#b0bec5", stroke="none", width=0)
    s.text(cx, cy + 5, label, size=13, anchor="middle", weight="bold", fill="#ffffff")
    s.text(cx + 0.72 * r * math.cos(plus_ang), cy + 0.72 * r * math.sin(plus_ang) + 5, "+", size=14,
           anchor="middle", weight="bold", fill="#ffffff")
    return ("circle", cx, cy, r)


def ecap_flat(s: Svg, x0, y0, x1, y1, lead_end, label):
    """Electrolytic lying flat (can outline x0..x1, y0..y1 in mm); lead_end 'bottom' or 'top'."""
    mm_rect(s, x0, y0, x1 - x0, y1 - y0, fill="#20406e", stroke="#0d2240", width=1.4, rx=1.2 * S)
    # minus stripe along the left side
    mm_rect(s, x0 + 0.3, y0 + 0.9, 1.3, (y1 - y0) - 1.8, fill="#b0bec5", stroke="none", width=0, rx=2)
    cy = (y0 + y1) / 2
    s.text(px((x0 + x1) / 2 + 0.4), py(cy) + 5, label, size=13, anchor="middle", weight="bold", fill="#ffffff")
    return ("rect", px(x0), py(y0), (x1 - x0) * S, (y1 - y0) * S)


def header_v(s: Svg, k, r0, n, pin_colors=None):
    """Vertical 1 x n male header."""
    x0, y0 = px(hx(k) - 1.27), py(hy(r0) - 1.27)
    s.rect(x0, y0, 2.54 * S, 2.54 * n * S, fill="#263238", stroke="#000000", width=1, rx=2)
    for i in range(n):
        cx, cy = P(k, r0 + i)
        s.rect(cx - 4.2, cy - 4.2, 8.4, 8.4, fill=(pin_colors or {}).get(i, "#d4af37"), stroke="#6d5b1f",
               width=0.8, rx=1)
    return ("rect", x0, y0, 2.54 * S, 2.54 * n * S)


def xiao_pads(s: Svg):
    for i in range(7):
        for k, names in ((7, XL), (13, XR)):
            cx_, cy_ = P(k, i)
            lab = names[i]
            wpad = max(2.0 * S, text_w(lab, 11, True) + 6)
            s.rect(cx_ - wpad / 2, cy_ - 0.8 * S, wpad, 1.6 * S, fill="#e3c35a", stroke="#8d6e1f", width=0.8, rx=2)
            s.text(cx_, cy_ + 4, lab, size=11, anchor="middle", fill="#1a1a1a", weight="bold")


# ------------------------------------------------------------------------------ board
def draw_board(s: Svg):
    clips = []

    # board, grid, mounting holes, centre line
    s.rect(px(-35), py(0), BW * S, BH * S, fill="#f1e6cc", stroke="#8d7b5a", width=1.6, rx=6)
    for k in range(27):
        for r in range(13):
            x, y = hx(k), hy(r)
            if any((x - mx) ** 2 + (y - my) ** 2 < 2.7 ** 2 for mx, my in MOUNT):
                continue
            cx, cy = P(k, r)
            s.circle(cx, cy, 0.8 * S, fill="#dcc08d", stroke="none", width=0)
            s.circle(cx, cy, 0.42 * S, fill="#ffffff", stroke="none", width=0)
    for mx, my in MOUNT:
        s.circle(px(mx), py(my), 2.75 * S, fill="none", stroke="#9e9e9e", width=1, stroke_dasharray="3 3")
        s.circle(px(mx), py(my), 1.35 * S, fill="#ffffff", stroke="#616161", width=1.6)
    s.line(px(0), py(0) - 26, px(0), py(35) + 26, stroke="#9e9e9e", width=1, stroke_dasharray="10 4 2 4")

    # solder-side wires (white halo marks crossings: insulated, not joined)
    for net, cls, pts in WIRES:
        wire(s, [to_px(p) for p in pts], COL[net], WIDTH[cls])
    for net, pts in JOINTS.items():
        for k, r in pts:
            x, y = P(k, r)
            s.circle(x, y, 4.3, fill=COL[net], stroke="#ffffff", width=1)

    # U4 charger module
    u = U4
    mm_rect(s, u["x0"], u["y0"], u["w"], u["h"], fill="#1f5fae", stroke="#0d3c75", width=1.4, rx=0.8 * S)
    clips.append(("rect", px(u["x0"]), py(u["y0"]), u["w"] * S, u["h"] * S))
    ux = u["x0"] + u["w"] / 2
    mm_rect(s, ux - 4.47, -1.5, 8.94, 7.3, fill="#cfd8dc", stroke="#78909c", width=1.2, rx=0.9 * S)
    mm_rect(s, ux - 3.3, -1.0, 6.6, 1.6, fill="#90a4ae", stroke="none", width=0, rx=0.5 * S)
    mm_rect(s, ux - 2.6, 9.5, 5.2, 4.4, fill="#212121", stroke="#000000", width=1, rx=1)      # TP4056
    mm_rect(s, ux - 5.8, 17.0, 3.2, 3.0, fill="#212121", stroke="#000000", width=1, rx=1)     # DW01A
    mm_rect(s, ux - 0.5, 16.7, 4.4, 3.4, fill="#212121", stroke="#000000", width=1, rx=1)     # 8205A
    for i, c in enumerate(("#e53935", "#1e88e5")):
        mm_rect(s, u["x0"] + u["w"] - 3.2, 8.7 + i * 2.6, 1.6, 1.0, fill=c, stroke="none", width=0)
    s.text(px(ux), py(8.0), "U4", size=15, anchor="middle", fill="#ffffff", weight="bold")
    s.text(px(ux), py(15.9), "TP4056", size=11, anchor="middle", fill="#ffffff", weight="bold")
    for name, x in U4PADS.items():
        s.rect(px(x) - 1.1 * S, py(U4PAD_Y) - 1.2 * S, 2.2 * S, 2.4 * S, fill="#e0c068", stroke="#8d6e1f",
               width=1, rx=2)
        s.text(px(x), py(U4PAD_Y) - 1.6 * S - 2, name, size=11, anchor="middle", fill="#ffffff", weight="bold")

    # U1 XIAO ESP32-S3, soldered flat
    x = XIAO
    mm_rect(s, x["x0"], x["y0"], x["w"], x["h"], fill="#263447", stroke="#101820", width=1.4, rx=1.0 * S)
    clips.append(("rect", px(x["x0"]), py(x["y0"]), x["w"] * S, x["h"] * S))
    cxm = x["x0"] + x["w"] / 2
    mm_rect(s, cxm - 4.5, -1.55, 9.0, 7.35, fill="#cfd8dc", stroke="#78909c", width=1.2, rx=0.9 * S)
    mm_rect(s, cxm - 3.3, -1.05, 6.6, 1.6, fill="#90a4ae", stroke="none", width=0, rx=0.5 * S)
    mm_rect(s, cxm - 4.6, 6.2, 9.6, 10.8, fill="#d7dde3", stroke="#90a4ae", width=1.2, rx=0.5 * S)  # shield can
    s.text(px(cxm + 0.9), py(12.2), "U1", size=15, anchor="middle", weight="bold")
    s.text(px(cxm - 0.3), py(16.5), "XIAO ESP32-S3", size=11.5, anchor="middle")
    for (bx, by), nm in ((BATM, "BAT−"), (BATP, "BAT+")):
        s.rect(px(bx) - 1.25 * S, py(by) - 0.55 * S, 2.5 * S, 1.1 * S, fill="#263447", stroke="#ffffff",
               width=1.2, stroke_dasharray="3 2")
        s.text(px(bx) + 1.45 * S, py(by) + 4, nm, size=11, fill="#1a1a1a", weight="bold")
    mm_rect(s, UFL[0] - 1.2, UFL[1] - 1.2, 2.4, 2.4, fill="#c8a24a", stroke="#6d5b1f", width=1, rx=2)
    s.circle(px(UFL[0]), py(UFL[1]), 0.55 * S, fill="#eeeeee", stroke="#6d5b1f", width=1)
    s.text(px(UFL[0]) + 1.6 * S, py(UFL[1]) + 4, "U.FL", size=11, fill="#ffffff", weight="bold")

    # U3 MiniBoost (header at its bottom edge: VIN GND 5V EN)
    m = U3
    mm_rect(s, m["x0"], m["y0"], m["w"], m["h"], fill="#2e3440", stroke="#111111", width=1.4, rx=0.6 * S)
    clips.append(("rect", px(m["x0"]), py(m["y0"]), m["w"] * S, m["h"] * S))
    mm_rect(s, m["x0"] + 3.683 - 2.5, 16.98 - 2.5, 5.0, 5.0, fill="#9e9e9e", stroke="#616161", width=1, rx=1)
    s.text(px(m["x0"] + 3.683), py(16.98) + 4, "L1", size=11, anchor="middle", fill="#212121", weight="bold")
    mm_rect(s, m["x0"] + 7.874 - 0.8, 16.98 - 0.8, 1.6, 1.6, fill="#000000", stroke="none", width=0)
    s.circle(px(m["x0"] + 2.54), py(10.5), 1.25 * S, fill="#ffffff", stroke="#c9a227", width=2)
    s.text(px(-26.2), py(13.9), "U3", size=15, anchor="middle", fill="#ffffff", weight="bold")
    for i, nm in enumerate(U3PINS):
        cx_, cy_ = P(i, 8)
        s.rect(cx_ - 4.2, cy_ - 4.2, 8.4, 8.4, fill="#d4af37", stroke="#6d5b1f", width=0.8, rx=1)
        s.text(cx_, cy_ - 11, nm, size=11, anchor="middle", fill="#ffffff", weight="bold")

    # headers
    clips.append(header_v(s, 15, 2, 8))
    clips.append(header_v(s, 5, 0, 4))

    # J1: JST-PH side entry at the bottom edge, mouth facing down; pins (k20, r11) -, (k21, r11) +
    jx = (hx(20) + hx(21)) / 2
    mm_rect(s, jx - 3.95, hy(11) - 1.6, 7.9, 5.6, fill="#f5f0e1", stroke="#8d8672", width=1.3, rx=0.5 * S)
    mm_rect(s, jx - 3.0, hy(11) + 1.6, 6.0, 2.2, fill="#e3dcc6", stroke="#b0a888", width=1, rx=2)
    for k in (20, 21):
        cx_, cy_ = P(k, 11)
        s.rect(cx_ - 3.4, cy_ - 3.4, 6.8, 6.8, fill="#d4af37", stroke="#6d5b1f", width=0.8, rx=1)
    s.text(P(20, 11)[0], P(20, 11)[1] + 22, "−", size=14, anchor="middle", weight="bold")
    s.text(P(21, 11)[0], P(21, 11)[1] + 22, "+", size=14, anchor="middle", weight="bold")
    clips.append(("rect", px(jx - 3.95), py(hy(11) - 1.6), 7.9 * S, 5.6 * S))

    # resistors, C1
    clips.append(resistor(s, (5, 6), (5, 10), BANDS["220k1"]))       # R2
    clips.append(resistor(s, (6, 8), (6, 12), BANDS["220k1"]))       # R1
    clips.append(resistor(s, (10, 8), (14, 8), BANDS["1k"]))         # R3
    # R4 upright: body over (k4, r10), bent lead to (k4, r9)
    (rx1, ry1), (rx2, ry2) = P(4, 9), P(4, 10)
    s.line(rx1, ry1, rx2, ry2, stroke="#9e9e9e", width=2.2)
    s.circle(rx2, ry2, 1.3 * S, fill="#ead2a4", stroke="#8d6e3f", width=1.2)
    s.circle(rx2, ry2, 0.9 * S, fill="none", stroke="#fbc02d", width=2.2)
    clips.append(("circle", rx2, ry2, 1.3 * S))
    (c1x, c1y), (c2x, c2y) = P(7, 8), P(7, 9)
    s.line(c1x, c1y, c2x, c2y, stroke="#9e9e9e", width=2)
    s.rect(c1x - 1.3 * S, (c1y + c2y) / 2 - 2.0 * S, 2.6 * S, 4.0 * S, fill="#e0a526", stroke="#8d6200",
           width=1.2, rx=1.2 * S)
    clips.append(("rect", c1x - 1.3 * S, (c1y + c2y) / 2 - 2.0 * S, 2.6 * S, 4.0 * S))

    # electrolytics: C2 lying flat in the pocket right of J2, C3 standing low-profile at U3's input
    clips.append(ecap_flat(s, 6.55, 0.75, 12.85, 11.95, "bottom", "C2"))
    for k in (16, 17):
        x_, y_ = P(k, 4)
        s.line(x_, py(11.95), x_, y_, stroke="#9e9e9e", width=2.2)
    s.text(P(17, 4)[0] + 1, py(11.2), "+", size=14, anchor="middle", weight="bold", fill="#ffffff")
    c3 = P(1, 11)
    clips.append(ecap_top(s, c3[0], c3[1], 6.3, math.pi / 2, "C3"))

    # SW4 position (right margin): wire link or switch leads between (k23, r10) and (k23, r12)
    (a1, b1), (a2, b2) = P(23, 10), P(23, 12)
    d = f"M {a1:.1f} {b1:.1f} Q {a1 + 20:.1f} {(b1 + b2) / 2:.1f} {a2:.1f} {b2:.1f}"
    s.path(d, stroke="#212121", width=6.4)
    s.path(d, stroke=COL["vbat"], width=3.8, stroke_dasharray="7 4")

    # hidden solder-side wires under parts: dashed overlay clipped to the part outlines
    shapes = "".join(
        f'<rect x="{c[1]:.1f}" y="{c[2]:.1f}" width="{c[3]:.1f}" height="{c[4]:.1f}"/>' if c[0] == "rect"
        else f'<circle cx="{c[1]:.1f}" cy="{c[2]:.1f}" r="{c[3]:.1f}"/>' for c in clips)
    s.defs.append(f'<clipPath id="hid">{shapes}</clipPath>')
    inner = []
    for net, cls, pts in WIRES:
        dd = path_d([to_px(p) for p in pts])
        wdt = min(WIDTH[cls], 3.4)
        inner.append(f'<path d="{dd}" fill="none" stroke="#ffffff" stroke-width="{wdt + 2.4:.1f}" '
                     f'stroke-dasharray="6 4" stroke-linecap="butt"/>')
        inner.append(f'<path d="{dd}" fill="none" stroke="{COL[net]}" stroke-width="{wdt:.1f}" '
                     f'stroke-dasharray="6 4" stroke-linecap="butt"/>')
    s.add('<g clip-path="url(#hid)">' + "".join(inner) + "</g>")
    xiao_pads(s)

    # component-side wires: U4 pads to the grid, XIAO BAT+ lead
    pad = lambda n: (px(U4PADS[n]), py(U4PAD_Y))
    jumper(s, [pad("OUT−"), Q(U4PADS["OUT−"], 27.9), P(16, 10)], COL["gnd"])
    jumper(s, [pad("B−"), Q(U4PADS["B−"], 28.2), P(19, 11)], COL["gnd"])
    jumper(s, [pad("B+"), Q(U4PADS["B+"], 28.2), P(22, 11)], COL["vbat"])
    jumper(s, [pad("OUT+"), Q(U4PADS["OUT+"], 27.8), P(23, 10)], COL["vbat"])
    # BAT+ pad wire goes straight down through hole (k8, r3) (drawn as a short hidden stub)
    bp = Q(BATP[0], BATP[1])
    s.path(path_d([bp, P(8, 3)]), stroke="#ffffff", width=5.4, stroke_dasharray="4 3")
    s.path(path_d([bp, P(8, 3)]), stroke=COL["vbat"], width=3.2, stroke_dasharray="4 3")
    return s


def leader(s: Svg, x1, y1, x2, y2):
    s.line(x1, y1, x2, y2, stroke="#607d8b", width=1.1)
    s.circle(x1, y1, 2.2, fill="#607d8b", stroke="none", width=0)


def annotate(s: Svg):
    s.text(40, 44, "brwr-trmnl v1 — carrier board layout", size=22, weight="bold")
    s.text(40, 70, "70 × 35 mm protoboard, 27 × 13 holes at 2.54 mm. Seen from the component side, as it sits in the "
                   "back cover", size=13.5, fill=COL["text2"])
    s.text(40, 90, "(same left and right as the front of the display). Solder-side wires are drawn as if seen through "
                   "the board.", size=13.5, fill=COL["text2"])

    # dimensions
    s.dimension(px(-35), 118, px(35), 118, "70 mm", size=12)
    for xx in (px(-35), px(35)):
        s.line(xx, 112, xx, py(0) - 4, stroke="#bdbdbd", width=0.8, stroke_dasharray="3 3")
    s.dimension(100, py(0), 100, py(35), "35 mm", size=12, text_side=-1)
    for yy in (py(0), py(35)):
        s.line(94, yy, px(-35) - 4, yy, stroke="#bdbdbd", width=0.8, stroke_dasharray="3 3")

    # USB-C labels
    s.text(px(-7.62), 146, "USB-C: flash and logs (U1)", size=12.5, anchor="middle", weight="bold")
    s.text(px(22), 146, "USB-C: charging (U4)", size=12.5, anchor="middle", weight="bold")
    s.text(px(-7.62), 164, "overhangs 1.5 mm", size=11.5, anchor="middle", fill=COL["text2"])
    s.text(px(22), 164, "overhangs 1.5 mm", size=11.5, anchor="middle", fill=COL["text2"])

    # header and part tags
    tag(s, px(-20.32), 152, "J3")
    leader(s, px(-20.32), py(1.6), px(-20.32), 161)
    tag(s, px(5.08), py(4.35), "J2")
    tag(s, px(-2.54), py(26.0), "R3")
    s.text(px(-26.9), py(5) + 4, "M2.5", size=11, weight="bold", fill=COL["text2"])
    row1, row2 = py(35) + 24, py(35) + 52
    for name, x, y_part, row in (("R4", hx(4), hy(10) + 1.3, row1), ("R1", hx(6), 31.45, row1),
                                 ("R2", hx(5), 26.35, row2), ("C1", hx(7), 26.5, row2),
                                 ("J1 battery", (hx(20) + hx(21)) / 2, 34.0, row1), ("SW4", hx(23), 33.4, row2),
                                 ("M2.5", 30.0, 32.4, row1)):
        leader(s, px(x), py(y_part), px(x), row - 11)
        tag(s, px(x), row, name)

    # ---- right panel: header pinouts and parts
    x0 = 1030
    y = 150
    s.text(x0, y, "J2 → HAT", size=14, weight="bold")
    s.text(x0 + 76, y, "kit PH2.0 8-pin cable, pin 1 at the top", size=12, fill=COL["text2"])
    rows = [("5V", "v5", "U3 5V (5V_EPD), C2+"), ("GND", "gnd", "GND"), ("MISO", "spi", "U1 D9 · GPIO8"),
            ("MOSI", "spi", "U1 D10 · GPIO9"), ("SCK", "spi", "U1 D8 · GPIO7"), ("CS", "spi", "U1 D4 · GPIO5"),
            ("RST", "ctl", "U1 D6 · GPIO43, via R3"), ("HRDY", "ctl", "U1 D7 · GPIO44")]
    for i, (nm, key, to) in enumerate(rows):
        yy = y + 24 + i * 20
        s.text(x0 + 8, yy, str(i + 1), size=12, anchor="middle", fill=COL["text2"])
        s.line(x0 + 20, yy - 4, x0 + 40, yy - 4, stroke=COL[key], width=4, stroke_linecap="butt")
        s.text(x0 + 48, yy, nm, size=12.5, weight="bold")
        s.text(x0 + 104, yy, to, size=12.5)
    y = y + 24 + 8 * 20 + 16
    s.text(x0, y, "J3 → button board", size=14, weight="bold")
    s.text(x0 + 150, y, "4-wire lead, pin 1 at the top", size=12, fill=COL["text2"])
    for i, (nm, key, to) in enumerate([("BACK", "btn", "U1 D0 · GPIO1"), ("REFRESH", "btn", "U1 D1 · GPIO2"),
                                       ("NEXT", "btn", "U1 D2 · GPIO3"), ("GND", "gnd", "GND")]):
        yy = y + 24 + i * 20
        s.text(x0 + 8, yy, str(i + 1), size=12, anchor="middle", fill=COL["text2"])
        s.line(x0 + 20, yy - 4, x0 + 40, yy - 4, stroke=COL[key], width=4, stroke_linecap="butt")
        s.text(x0 + 48, yy, nm, size=12.5, weight="bold")
        s.text(x0 + 124, yy, to, size=12.5)
    y = y + 24 + 4 * 20 + 16
    s.text(x0, y, "J1 → battery", size=14, weight="bold")
    s.text(x0 + 104, y, "JST-PH 2-pin, side entry", size=12, fill=COL["text2"])
    s.text(x0, y + 22, "− to U4 B−, + to U4 B+", size=12.5)
    y = y + 22 + 30
    s.text(x0, y, "Parts", size=14, weight="bold")
    parts = [("R1, R2", "220 kΩ 1 % (red red black orange brown)"), ("R3", "1 kΩ (brown black red)"),
             ("R4", "4.7 kΩ (yellow violet red), upright"), ("C1", "100 nF ceramic"),
             ("C2", "220 µF 10 V low-ESR, lying flat"), ("C3", "470 µF 6.3 V low-ESR, ≤ 8 mm tall"),
             ("SW4", "optional power switch, or a wire link")]
    for i, (a_, b_) in enumerate(parts):
        yy = y + 22 + i * 19
        s.text(x0, yy, a_, size=12.5, weight="bold")
        s.text(x0 + 58, yy, b_, size=12.5)

    # ---- legend, line styles, notes
    ly = 736
    s.legend(40, ly, keys=["vbat", "v5", "gnd", "spi", "ctl", "btn", "sense"], cols=2, col_w=292,
             title="Colour code")

    kx, kw = 660, 700
    s.rect(kx, ly, kw, 128, fill="#ffffff", stroke=COL["blockline"], width=1.2, rx=6)
    s.text(kx + 12, ly + 22, "Wires", size=13, weight="bold")
    items = [
        ("sig", "Solder-side wire, seen through the board"),
        ("bus", "Bus wire, 20–22 AWG"),
        ("jump", "Insulated wire on the component side"),
        ("hid", "Dashed: runs under a part"),
        ("dot", "Solder joint"),
        ("cross", "White gap: wires cross, not joined"),
    ]
    for i, (kind, label) in enumerate(items):
        cx = kx + 14 + (i // 3) * 340
        cy = ly + 46 + (i % 3) * 26
        if kind == "sig":
            s.line(cx, cy, cx + 40, cy, stroke=COL["spi"], width=2.6)
        elif kind == "bus":
            s.line(cx, cy, cx + 40, cy, stroke=COL["vbat"], width=5)
        elif kind == "jump":
            s.line(cx, cy, cx + 40, cy, stroke="#212121", width=6.4, stroke_linecap="round")
            s.line(cx, cy, cx + 40, cy, stroke=COL["gnd"], width=3.8, stroke_linecap="round")
            s.line(cx + 1, cy, cx + 39, cy, stroke=COL["vbat"], width=3.8)
        elif kind == "hid":
            s.line(cx, cy, cx + 40, cy, stroke=COL["ctl"], width=2.6, stroke_dasharray="6 4")
        elif kind == "dot":
            s.line(cx, cy, cx + 40, cy, stroke=COL["sense"], width=2.6)
            s.circle(cx + 20, cy, 4.3, fill=COL["sense"], stroke="#ffffff", width=1)
        else:
            s.line(cx + 20, cy - 11, cx + 20, cy + 11, stroke=COL["spi"], width=2.6)
            s.line(cx, cy, cx + 40, cy, stroke="#ffffff", width=6)
            s.line(cx, cy, cx + 40, cy, stroke=COL["ctl"], width=2.6)
        s.text(cx + 52, cy + 4.5, label, size=12.5)

    ny = 884
    notes = [
        "U1 is soldered flat, flush with the top edge. Both USB-C connectors overhang the top edge by 1.5 mm.",
        "Before fitting U1, solder a short wire to its BAT+ pad and pass it through the hole beneath it. "
        "BAT− is the same net as the GND pin.",
        "VBAT_SYS leaves SW4 along the bottom (U3, C3, R1) and along the top margin (U1 BAT+). GND and 5V_EPD "
        "run along the bottom.",
        "The enclosure leaves 9 mm above the board: lay C2 flat, use a low-profile C3, and fit J2 and J3 with "
        "right-angle pins, or solder the leads.",
        "U4's pad order varies between makers: follow its silkscreen. J1 is 2.0 mm pitch: splay its pins. "
        "Check the battery's polarity with a meter.",
        "M2.5 holes, from the top-left corner: 5 mm right and 5 mm down; 65 mm right and 31 mm down.",
    ]
    s.rect(40, ny, 1320, 34 + len(notes) * 22, fill=COL["note"], stroke=COL["noteline"], width=1.2, rx=6)
    s.text(54, ny + 24, "Notes", size=13, weight="bold")
    for i, n in enumerate(notes):
        s.text(54, ny + 50 + i * 22, f"{i + 1}. {n}", size=12.5)


def build() -> str:
    s = Svg(W, H, "brwr-trmnl v1 carrier board layout",
            "Component-side layout of the 70 x 35 mm protoboard carrier as it sits in the back cover: XIAO "
            "ESP32-S3, TP4056 charger, MiniBoost, divider, series and pull-down resistors, capacitors, battery "
            "socket and headers, with the solder-side wiring shown through the board.")
    draw_board(s)
    annotate(s)
    return s.render()
