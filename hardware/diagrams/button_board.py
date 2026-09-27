"""The button strip: three 12 x 12 x 4.3 mm tactile switches (Omron B3F-4000) on an 84 x 20 mm
protoboard, behind the bezel's chin. Component side (as seen from the front
of the display) and solder side (as seen from the back, mirrored), a switch
pin detail and build notes."""

from __future__ import annotations

from svgkit import COL, Svg, circled

PITCH = 2.54
STRIP_W, STRIP_H = 84.0, 20.0           # mm
CX, CY = STRIP_W / 2, STRIP_H / 2       # middle switch centre = strip centre
SW_X = [-10 * PITCH, 0.0, 10 * PITCH]   # 25.4 mm apart, the same as the caps
SW_NAMES = ["BACK", "REFRESH", "NEXT"]  # left to right, seen from the front
SW_SYMBOL = ["◀", "●", "▶"]
LEG_DX, LEG_DY = 2.5 * PITCH, PITCH     # legs 5 holes (12.7 mm) x 2 holes (5.08 mm) apart
HOLE_X = 14.5 * PITCH                   # M2.5 mounting holes: the 15th hole either side of the centre
COLS = [CX + (k + 0.5) * PITCH for k in range(-16, 16)]   # half-pitch columns, so the legs land on holes
ROWS = [CY + j * PITCH for j in range(-3, 4)]             # ROWS[3] is the switches' centre line
BUS_Y = ROWS[6]                         # ground bus on the bottom row, clear of every leg
# Where the lead's wires are soldered (front-view mm): the signals on the top row above the BACK
# switch, ground at the end of the bus. Nothing passes the screw hole at the left end.
HOLE = {"BACK": (CX - 11.5 * PITCH, ROWS[0]), "REFRESH": (CX - 10.5 * PITCH, ROWS[0]),
        "NEXT": (CX - 9.5 * PITCH, ROWS[0]), "GND": (CX - 13.5 * PITCH, BUS_Y)}
LANE = {"BACK": ROWS[0], "REFRESH": ROWS[1], "NEXT": ROWS[0]}   # row each signal wire runs along

S = 8.0                                 # px per mm
BOARD_FILL, BOARD_LINE, PAD = "#f3e3c3", "#c9a96b", "#d8b46a"


def leg(i: int, sx: int, sy: int) -> tuple[float, float]:
    """Leg of switch i: sx, sy = -1/+1 for left/right and top/bottom, front-view mm."""
    return CX + SW_X[i] + sx * LEG_DX, CY + sy * LEG_DY


def signal_leg(i):   # top left
    return leg(i, -1, -1)


def ground_leg(i):   # bottom right: diagonally opposite, so always the other contact
    return leg(i, 1, 1)


class View:
    """Maps strip mm (front view, origin top-left) to canvas px; mirrored for the solder side."""

    def __init__(self, x0: float, y0: float, mirrored: bool):
        self.x0, self.y0, self.mirrored = x0, y0, mirrored

    def __call__(self, x: float, y: float) -> tuple[float, float]:
        if self.mirrored:
            x = STRIP_W - x
        return self.x0 + x * S, self.y0 + y * S

    @property
    def top(self) -> float:
        return self.y0

    @property
    def bottom(self) -> float:
        return self.y0 + STRIP_H * S


def board(s: Svg, v: View) -> None:
    s.rect(v.x0, v.y0, STRIP_W * S, STRIP_H * S, fill=BOARD_FILL, stroke=BOARD_LINE, width=1.5, rx=4)
    for cx in COLS:
        for cy in ROWS:
            px, py = v(cx, cy)
            s.circle(px, py, 4.2, fill=PAD, stroke="none", width=0)
            s.circle(px, py, 1.6, fill="#ffffff", stroke="none", width=0)
    for sx in (-1, 1):
        px, py = v(CX + sx * HOLE_X, CY)
        s.circle(px, py, 1.35 * S, fill="#ffffff", stroke="#8a7550", width=1.2)


def names_below(s: Svg, v: View, with_refs: bool) -> None:
    for i, name in enumerate(SW_NAMES):
        px, _ = v(CX + SW_X[i], CY)
        s.text(px, v.bottom + 22, name, size=13, anchor="middle", weight="bold")
        if with_refs:
            s.text(px, v.bottom + 38, f"SW{i + 1}", size=12, anchor="middle", fill=COL["text2"])


def switches_front(s: Svg, v: View) -> None:
    for i in range(3):
        px, py = v(CX + SW_X[i], CY)
        half = 6 * S
        s.rect(px - half, py - half, 2 * half, 2 * half, fill="#2b2e33", stroke="#15171a", width=1.2, rx=3)
        s.circle(px, py, 3.5 * S, fill="#5b6068", stroke="#9aa0a8", width=1.2)
        s.text(px, py + 7, SW_SYMBOL[i], size=20, anchor="middle", fill="#ffffff")
        for sx in (-1, 1):
            for sy in (-1, 1):
                lx, ly = v(*leg(i, sx, sy))
                s.circle(lx, ly, 3.2, fill="#c0c4c9", stroke="#6b7079", width=1)


def wire(s: Svg, v: View, pts, color, width=3.2) -> None:
    s.poly([v(*p) for p in pts], stroke=color, width=width)


def solder_side(s: Svg, v: View) -> None:
    # switch legs, with the bodies seen through the board
    for i in range(3):
        px, py = v(CX + SW_X[i], CY)
        s.rect(px - 6 * S, py - 6 * S, 12 * S, 12 * S, fill="none", stroke="#8a8f98", width=1,
               stroke_dasharray="4 4", rx=3)
        s.text(px, py + 4, f"SW{i + 1}", size=12, anchor="middle", fill=COL["text2"])
        for sx in (-1, 1):
            for sy in (-1, 1):
                lx, ly = v(*leg(i, sx, sy))
                s.circle(lx, ly, 4.6, fill="#b9bec5", stroke="#5f656e", width=1.2)
    # ground: a bare bus along the bottom row, a short link from each switch's ground leg
    far = max(ground_leg(i)[0] for i in range(3))
    wire(s, v, [HOLE["GND"], (far, BUS_Y)], COL["gnd"], width=3.6)
    for i in range(3):
        x, y = ground_leg(i)
        wire(s, v, [(x, y), (x, BUS_Y)], COL["gnd"], width=3.6)
        s.dot(*v(x, BUS_Y), COL["gnd"], r=4.5)
        s.dot(*v(x, y), COL["gnd"], r=4.2)
    # signals: insulated wire from each switch's top-left leg to its hole
    for i, name in enumerate(SW_NAMES):
        lx, ly = signal_leg(i)
        hx, hy = HOLE[name]
        wire(s, v, [(lx, ly), (lx, LANE[name]), (hx, LANE[name]), (hx, hy)], COL["btn"], width=3.2)
        s.dot(*v(lx, ly), COL["btn"], r=4.2)
    for name, (hx, hy) in HOLE.items():
        s.circle(*v(hx, hy), 5.4, fill="#ffffff", stroke=COL["gnd" if name == "GND" else "btn"], width=2.4)


def lead(s: Svg, v: View) -> float:
    """The lead: signal wires off the top edge, ground round the end of the strip.
    Returns the x of the ground wire."""
    top_y = v.top - 46
    for name in SW_NAMES:
        hx, hy = v(*HOLE[name])
        s.poly([(hx, hy), (hx, top_y)], stroke=COL["btn"], width=2.6)
        s.text(hx + 4, top_y - 4, name, size=12, anchor="start", weight="bold", rotate=-90)
    gx, gy = v(*HOLE["GND"])
    x_gnd = v.x0 + STRIP_W * S + 18
    s.poly([(gx, gy), (x_gnd, gy), (x_gnd, top_y)], stroke=COL["gnd"], width=2.6)
    s.text(x_gnd + 4, top_y - 4, "GND", size=12, anchor="start", weight="bold", rotate=-90)
    left = min(v(*HOLE[n])[0] for n in SW_NAMES)
    s.text(left - 16, v.top - 36, "4-wire lead, about 5 cm, to one half of a 4-pin JST-PH pair (J4):",
           size=12.5, anchor="end", fill=COL["text2"])
    s.text(left - 16, v.top - 18, "pin 1 BACK, then REFRESH, NEXT, GND. The other half goes on to J3.",
           size=12.5, anchor="end", fill=COL["text2"])
    return x_gnd


def switch_detail(s: Svg, x: float, y: float) -> None:
    """One 12 x 12 mm switch from its component side: legs and contacts."""
    k = 9.0   # px per mm
    s.text(x, y, "One switch (12 × 12 × 4.3 mm), component side", size=15, weight="bold")
    cx, cy = x + 190, y + 120
    half = 6 * k
    s.rect(cx - half, cy - half, 2 * half, 2 * half, fill="#2b2e33", stroke="#15171a", width=1.2, rx=4)
    s.circle(cx, cy, 3.5 * k, fill="#5b6068", stroke="#9aa0a8", width=1.2)
    dy = 2.5 * k
    reach = 6.25 * k
    for sx in (-1, 1):
        for sy in (-1, 1):
            lx, ly = cx + sx * reach, cy + sy * dy
            s.circle(lx, ly, 5, fill="#c0c4c9", stroke="#6b7079", width=1.2)
            s.text(lx + sx * 13, ly + 4.5, "A" if sy < 0 else "B", size=13, anchor="start" if sx > 0 else "end",
                   weight="bold")
    for sy in (-1, 1):   # the pairs joined inside the switch
        s.line(cx - reach + 6, cy + sy * dy, cx + reach - 6, cy + sy * dy, stroke="#e0b64a", width=1.8,
               stroke_dasharray="5 4")
    s.dimension(cx - reach, cy + half + 20, cx + reach, cy + half + 20, "12.5 mm (5 holes)", size=12)
    s.dimension(cx + reach + 40, cy - dy, cx + reach + 40, cy + dy, "5 mm (2 holes)", size=12)
    s.lines(x, cy + half + 62, [
        "A–A and B–B are joined inside the switch (dashed); pressing it",
        "joins A to B. Two diagonally opposite legs are always A and B,",
        "whichever way round the switch is fitted.",
    ], size=12.5, fill=COL["text2"])


def build() -> str:
    W, H = 1400, 880
    s = Svg(W, H, "brwr-trmnl v1 button board",
            "Three 12 by 12 millimetre tactile switches on an 84 by 20 millimetre protoboard strip: the component "
            "side seen from the front, and the solder side seen from the back with a ground bus and three signal "
            "wires to a four-wire lead.")
    s.text(40, 44, "brwr-trmnl v1 — button board", size=22, weight="bold")
    s.text(40, 70, "84 × 20 mm protoboard behind the bezel's chin. Three Omron B3F-4000 switches (12 × 12 × "
                   "4.3 mm, flat plunger), no resistors (the ESP32-S3's pull-ups). Both views at the same scale.",
           size=13.5,
           fill=COL["text2"])

    # --- component side ---------------------------------------------------
    front = View(60, 150, mirrored=False)
    s.text(60, 112, "Component side, as seen from the front of the display", size=15, weight="bold")
    board(s, front)
    switches_front(s, front)
    names_below(s, front, with_refs=True)
    s.dimension(front.x0, front.top - 14, front.x0 + STRIP_W * S, front.top - 14, "84 mm", size=12)
    s.dimension(front.x0 + STRIP_W * S + 16, front.top, front.x0 + STRIP_W * S + 16, front.bottom, "20 mm",
                size=12)
    y_sw = front.bottom + 62
    s.dimension(front(CX + SW_X[0], 0)[0], y_sw, front(CX, 0)[0], y_sw, "25.4 mm", size=12)
    s.dimension(front(CX, 0)[0], y_sw, front(CX + SW_X[2], 0)[0], y_sw, "25.4 mm", size=12)
    y_holes = front.bottom + 96
    s.dimension(front(CX - HOLE_X, 0)[0], y_holes, front(CX + HOLE_X, 0)[0], y_holes,
                f"{2 * HOLE_X:.1f} mm (29 pitches) between the Ø2.7 mm holes", size=12)
    px_mid, _ = front(CX, CY)
    circled(s, px_mid + 52, front.bottom + 30, 1)
    rx_, ry_ = front(*leg(2, 1, 1))
    circled(s, rx_ + 22, ry_ + 30, 2)
    hx, hy = front(CX - HOLE_X, CY)
    circled(s, hx, hy - 26, 3)

    # --- solder side --------------------------------------------------------
    back = View(60, 560, mirrored=True)
    s.text(60, 452, "Solder side, as seen from the back (left and right swapped)", size=15, weight="bold")
    board(s, back)
    solder_side(s, back)
    x_lead = lead(s, back)
    names_below(s, back, with_refs=False)
    lx_, ly_ = back(*signal_leg(1))
    circled(s, lx_ - 20, ly_ - 18, 4)
    circled(s, x_lead + 24, back.top - 30, 5)
    bus_end = back(max(ground_leg(i)[0] for i in range(3)), BUS_Y)   # far end of the bus
    s.line(bus_end[0], bus_end[1], bus_end[0], back.bottom + 44, stroke=COL["gnd"], width=1, stroke_dasharray="3 3")
    s.text(bus_end[0] - 4, back.bottom + 60, "GND bus: bare wire along the bottom row", size=12.5, weight="bold",
           fill=COL["gnd"])

    # --- right column: detail, notes, legend ------------------------------------
    switch_detail(s, 860, 112)
    notes = [
        "① The middle switch sits at the strip's centre, the others 10 holes",
        "    (25.4 mm) either side, the same spacing as the caps.",
        "② Push each switch flat onto the board; bend the legs in slightly to",
        "    fit the grid. Trim the legs to 2 mm under the board after soldering.",
        "③ Drill out the 15th hole either side of the centre, on the middle",
        "    row (the second hole in from each end), to 2.7 mm for the M2.5",
        "    screws into the bezel's inserts.",
        "④ Signal: each switch's top-left leg (front view), insulated wire to",
        "    its hole above BACK. Ground: the diagonally opposite leg, to the bus.",
        "⑤ The lead leaves at the left end (front view), to its inline plug",
        "    beside the adapter board. Keep the wires clear of the screw holes.",
        "The buttons pull D0, D1 and D2 (GPIO1–3) to ground. These are RTC",
        "pins, so any press wakes the display from deep sleep.",
    ]
    s.note_box(860, 400, 500, "Notes", notes, size=12.5, lh=19)
    s.legend(860, 700, keys=["gnd", "btn"], title="Colour code", col_w=300)
    s.text(W - 40, H - 18, "Regenerate: python3 hardware/diagrams/make_diagrams.py button-board", size=12,
           anchor="end", fill=COL["text2"])
    return s.render()


if __name__ == "__main__":
    print(build())
