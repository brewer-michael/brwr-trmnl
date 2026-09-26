"""schematic.svg: logical schematic of brwr-trmnl v1."""

from __future__ import annotations

from svgkit import COL, Svg, circled, ground, text_w

W, H = 1400, 1045
PIN = 20  # pin stub length


# --------------------------------------------------------------------------- symbols
def block(s: Svg, x, y, w, h, title):
    s.rect(x, y, w, h, fill=COL["block"], stroke=COL["blockline"], width=1.2, rx=8)
    s.text(x + 14, y + 22, title, size=13, weight="bold", fill="#37474f", letter_spacing="1.5")


def resistor_v(s: Svg, x, y1, y2, color, body=46):
    """Vertical IEC resistor between y1 and y2 (wire ends)."""
    m = (y1 + y2) / 2
    s.line(x, y1, x, m - body / 2, stroke=color, width=2)
    s.line(x, m + body / 2, x, y2, stroke=color, width=2)
    s.rect(x - 7, m - body / 2, 14, body, fill="#ffffff", stroke=COL["line"], width=1.6)


def resistor_h(s: Svg, x1, x2, y, color, body=44):
    m = (x1 + x2) / 2
    s.line(x1, y, m - body / 2, y, stroke=color, width=2)
    s.line(m + body / 2, y, x2, y, stroke=color, width=2)
    s.rect(m - body / 2, y - 7, body, 14, fill="#ffffff", stroke=COL["line"], width=1.6)


def cap_v(s: Svg, x, y1, y2, color, polar=False):
    """Vertical capacitor between y1 (top wire end) and y2 (bottom wire end)."""
    m = (y1 + y2) / 2
    g = 4
    s.line(x, y1, x, m - g, stroke=color, width=2)
    s.line(x, m + g, x, y2, stroke=COL["gnd"], width=2)
    s.line(x - 13, m - g, x + 13, m - g, stroke=COL["line"], width=2.4)
    if polar:
        s.path(f"M {x - 13} {m + g + 5} Q {x} {m + g - 3} {x + 13} {m + g + 5}", stroke=COL["line"], width=2.4)
        s.text(x - 20, m - g - 3, "+", size=13, anchor="middle", weight="bold")
    else:
        s.line(x - 13, m + g, x + 13, m + g, stroke=COL["line"], width=2.4)


def battery_v(s: Svg, x, ytop, ybot):
    """Two-cell battery symbol, + at the top."""
    m = (ytop + ybot) / 2
    plates = [(m - 15, 16, 1.8), (m - 9, 8, 4), (m + 3, 16, 1.8), (m + 9, 8, 4)]
    s.line(x, ytop, x, m - 15, stroke=COL["vbat"], width=2)
    s.line(x, m + 9, x, ybot, stroke=COL["gnd"], width=2)
    for yy, hw, wd in plates:
        s.line(x - hw, yy, x + hw, yy, stroke=COL["line"], width=wd)
    s.line(x, m - 9, x, m + 3, stroke=COL["line"], width=1, stroke_dasharray="2 2")
    s.text(x + 22, m - 13, "+", size=14, anchor="middle", weight="bold")


def switch_spst(s: Svg, x1, x2, y, color):
    """Slide/toggle switch between x1 and x2 on a horizontal wire."""
    s.circle(x1, y, 3.2, fill="#ffffff", stroke=COL["line"], width=1.6)
    s.circle(x2, y, 3.2, fill="#ffffff", stroke=COL["line"], width=1.6)
    s.line(x1 + 2, y - 2, x2 - 2, y - 16, stroke=COL["line"], width=2)


def pushbutton(s: Svg, x1, x2, y):
    """Normally open push button between x1 and x2 on a horizontal line."""
    s.circle(x1, y, 3, fill="#ffffff", stroke=COL["line"], width=1.6)
    s.circle(x2, y, 3, fill="#ffffff", stroke=COL["line"], width=1.6)
    s.line(x1 - 3, y - 9, x2 + 3, y - 9, stroke=COL["line"], width=2)
    m = (x1 + x2) / 2
    s.line(m, y - 9, m, y - 19, stroke=COL["line"], width=1.6)
    s.line(m - 7, y - 19, m + 7, y - 19, stroke=COL["line"], width=2)


def antenna(s: Svg, x, y):
    """Antenna symbol whose feed point is at (x, y); radiates upward."""
    s.line(x, y, x, y - 22, stroke=COL["line"], width=1.8)
    s.poly([(x - 11, y - 34), (x, y - 20), (x + 11, y - 34)], stroke=COL["line"], width=1.8)
    s.line(x, y - 22, x, y - 34, stroke=COL["line"], width=1.8)


def nc_mark(s: Svg, x, y):
    for dx in (-1, 1):
        s.line(x - 5, y - 5 * dx, x + 5, y + 5 * dx, stroke="#b71c1c", width=1.8)


def module(s: Svg, x, y, w, h, title_rows, pins, title_dy=0):
    """Module box; pins: (side, pos, name, color). pos is absolute y (left/right) or x (top/bottom).
    Returns dict name -> (x, y) of the pin's outer end."""
    s.rect(x, y, w, h, fill="#ffffff", stroke=COL["line"], width=2, rx=4)
    ends = {}
    for side, pos, name, color in pins:
        rows = name.split("\n")
        if side == "L":
            s.line(x - PIN, pos, x, pos, stroke=color, width=2)
            ends[rows[0]] = (x - PIN, pos)
            s.text(x + 7, pos + 4.5, rows[0], size=12)
            if len(rows) > 1:
                s.text(x + 7 + text_w(rows[0], 12) + 2, pos + 4.5, rows[1], size=11, fill=COL["text2"])
        elif side == "R":
            s.line(x + w, pos, x + w + PIN, pos, stroke=color, width=2)
            ends[rows[0]] = (x + w + PIN, pos)
            if len(rows) > 1:
                s.text(x + w - 7, pos + 4.5, rows[1], size=11, anchor="end", fill=COL["text2"])
                s.text(x + w - 7 - text_w(rows[1], 11) - 3, pos + 4.5, rows[0], size=12, anchor="end")
            else:
                s.text(x + w - 7, pos + 4.5, rows[0], size=12, anchor="end")
        elif side == "T":
            s.line(pos, y - PIN, pos, y, stroke=color, width=2)
            ends[rows[0]] = (pos, y - PIN)
            for i, r in enumerate(rows):
                s.text(pos, y + 17 + i * 13, r, size=12 if i == 0 else 11, anchor="middle",
                       fill=COL["text"] if i == 0 else COL["text2"])
        elif side == "B":
            s.line(pos, y + h, pos, y + h + PIN, stroke=color, width=2)
            ends[rows[0]] = (pos, y + h + PIN)
            for i, r in enumerate(reversed(rows)):
                s.text(pos, y + h - 8 - i * 13, r, size=12 if i == len(rows) - 1 else 11, anchor="middle",
                       fill=COL["text"] if i == len(rows) - 1 else COL["text2"])
    cx = x + w / 2
    ty = y + h / 2 - (len(title_rows) - 1) * 8 + title_dy
    for i, r in enumerate(title_rows):
        big = i == 0
        s.text(cx, ty + i * 17, r, size=15 if big else 12.5, anchor="middle", weight="bold" if big else "normal",
               fill=COL["text"] if big else COL["text2"])
    return ends


# --------------------------------------------------------------------------- drawing
def build() -> str:
    s = Svg(W, H, "brwr-trmnl v1 schematic",
            "Logical schematic: LiPo, TP4056 charger, optional switch, VBAT_SYS, battery-sense divider, "
            "XIAO ESP32-S3, MiniBoost 5 V booster switched by EPD_EN, IT8951 e-paper HAT on SPI, three buttons.")

    # ---- blocks
    block(s, 20, 20, 1360, 300, "POWER")
    block(s, 20, 340, 540, 230, "SENSE")
    block(s, 20, 590, 540, 205, "BUTTONS")
    block(s, 580, 340, 400, 455, "MCU")
    block(s, 1000, 340, 380, 455, "DISPLAY")

    RAIL = 120

    # ---- BT1
    bx = 132
    battery_v(s, bx, RAIL, 210)
    s.line(bx, RAIL, 180, RAIL, stroke=COL["vbat"], width=2.4)
    s.line(bx, 210, 180, 210, stroke=COL["gnd"], width=2.4)
    s.lines(36, 136, [("BT1", dict(weight="bold", size=13)), "LiPo 3.7 V", "5000 mAh", "JST-PH"], size=12, lh=16)
    circled(s, 116, 244, 4)
    s.lines(36, 272, ["Check polarity with a meter:", "JST-PH polarity is not standard."], size=12, lh=16,
            fill=COL["text2"])

    # ---- U4 charger
    u4 = module(s, 200, 90, 130, 150, ["U4", "TP4056", "+ DW01A"],
                [("L", RAIL, "B+", COL["vbat"]), ("L", 210, "B−", COL["gnd"]),
                 ("R", RAIL, "OUT+", COL["vbat"]), ("R", 210, "OUT−", COL["gnd"])])
    # USB-C charge input
    s.line(265, 72, 265, 90, stroke=COL["line"], width=1.6)
    s.rect(247, 60, 36, 12, fill="#eceff1", stroke=COL["line"], width=1.4, rx=5)
    s.text(292, 70, "USB-C: charging, 1 A", size=12, fill=COL["text2"])
    s.text(188, RAIL - 6, "BAT+", size=11, anchor="end", fill=COL["text2"])
    s.text(188, 210 - 6, "BAT−", size=11, anchor="end", fill=COL["text2"])
    # OUT- to ground
    s.line(350, 210, 372, 210, stroke=COL["gnd"], width=2.4)
    ground(s, 372, 210)

    # ---- SW4 and the VBAT_SYS rail
    s.line(350, RAIL, 368, RAIL, stroke=COL["vbat"], width=2.4)
    switch_spst(s, 372, 408, RAIL, COL["vbat"])
    s.lines(390, 150, [("SW4", dict(weight="bold")), "optional", "power switch"], size=12, lh=15, anchor="middle")
    x_u3vin = 840
    s.line(412, RAIL, x_u3vin, RAIL, stroke=COL["vbat"], width=3)
    s.label_box(545, RAIL - 18, "VBAT_SYS", "vbat", size=12.5)
    X_R1, X_BATP, X_C3 = 440, 670, 740
    for xx in (X_R1, X_BATP, X_C3):
        s.dot(xx, RAIL, COL["vbat"], 4.5)
    # C3 bulk cap at the booster input
    cap_v(s, X_C3, RAIL, 190, COL["vbat"], polar=True)
    ground(s, X_C3, 190)
    s.lines(X_C3 + 20, 152, [("C3 470 µF", dict(weight="bold")), "6.3 V low-ESR"], size=12, lh=15)

    # ---- U3 MiniBoost
    X_EN = 880
    u3 = module(s, 860, 90, 170, 120, ["U3 MiniBoost", "5 V 1 A · TPS61023"],
                [("L", RAIL, "VIN", COL["vbat"]), ("R", RAIL, "VOUT", COL["v5"]),
                 ("B", X_EN, "EN", COL["ctl"]), ("B", 990, "GND", COL["gnd"])], title_dy=10)
    ground(s, 990, 230)
    s.text(945, 82, "EN: 100 kΩ pull-up to VIN on board", size=11.5, anchor="middle", fill=COL["text2"])
    # R4 pull-down on EN
    s.line(X_EN, 230, X_EN, 400, stroke=COL["ctl"], width=2)
    s.polygon([(X_EN, 232), (X_EN - 4, 241), (X_EN + 4, 241)], fill=COL["ctl"], stroke="none", width=0)
    s.dot(X_EN, 268, COL["ctl"], 4)
    resistor_h(s, 790, X_EN, 268, COL["ctl"])
    ground(s, 790, 268)
    s.text(835, 253, "R4 4.7 kΩ", size=12, anchor="middle", weight="bold")
    circled(s, 900, 253, 2)
    s.label_box(X_EN + 10, 300, "EPD_EN", "ctl", anchor="start", size=12)

    # ---- 5V_EPD to the HAT
    X5 = 1170
    s.line(1050, RAIL, X5, RAIL, stroke=COL["v5"], width=3)
    s.line(X5, RAIL, X5, 430, stroke=COL["v5"], width=3)
    s.label_box(1110, RAIL - 18, "5V_EPD", "v5", size=12.5)
    s.text(1110, RAIL + 22, "5.2 V, off in sleep", size=11.5, anchor="middle", fill=COL["text2"])
    s.dot(X5, 372, COL["v5"], 4.5)
    s.line(1060, 372, X5, 372, stroke=COL["v5"], width=2.4)
    cap_v(s, 1060, 372, 420, COL["v5"], polar=True)
    ground(s, 1060, 420)
    s.lines(1078, 396, [("C2 220 µF", dict(weight="bold")), "10 V low-ESR"], size=12, lh=15)

    # ---- U1 XIAO ESP32-S3
    ys = dict(MISO=480, MOSI=520, SCK=560, CS=600, RST=640, HRDY=680)
    u1 = module(s, 640, 420, 260, 320, ["U1", "Seeed XIAO", "ESP32-S3", "USB-C: flash, logs"],
                [("T", X_BATP, "BAT+\npad", COL["vbat"]), ("T", 770, "U.FL", COL["coax"]),
                 ("T", X_EN, "D5\nGPIO6", COL["ctl"]),
                 ("L", 470, "D3\nGPIO4", COL["sense"]),
                 ("L", 620, "D0\nGPIO1", COL["btn"]), ("L", 665, "D1\nGPIO2", COL["btn"]),
                 ("L", 710, "D2\nGPIO3", COL["btn"]),
                 ("R", ys["MISO"], "D9\nGPIO8", COL["spi"]), ("R", ys["MOSI"], "D10\nGPIO9", COL["spi"]),
                 ("R", ys["SCK"], "D8\nGPIO7", COL["spi"]), ("R", ys["CS"], "D4\nGPIO5", COL["spi"]),
                 ("R", ys["RST"], "D6\nGPIO43", COL["ctl"]), ("R", ys["HRDY"], "D7\nGPIO44", COL["ctl"]),
                 ("B", 680, "GND", COL["gnd"]), ("B", 740, "BAT−\npad", COL["gnd"]),
                 ("B", 810, "5V", "#9e9e9e"), ("B", 865, "3V3", "#9e9e9e")])
    s.line(X_BATP, RAIL, X_BATP, 400, stroke=COL["vbat"], width=2.4)
    ground(s, 680, 760)
    ground(s, 740, 760)
    nc_mark(s, 810, 760)
    nc_mark(s, 865, 760)
    s.text(838, 786, "not connected", size=11.5, anchor="middle", fill=COL["text2"])
    # antenna
    s.line(770, 400, 770, 386, stroke=COL["coax"], width=2.2, stroke_dasharray="5 3")
    antenna(s, 770, 386)
    s.lines(756, 366, [("ANT1", dict(weight="bold")), "2.4 GHz FPC"], size=12, lh=15, anchor="end")

    # ---- U2 HAT
    u2 = module(s, 1110, 450, 150, 270, ["U2", "IT8951", "Driver HAT (B)", "DIP: SPI"],
                [("T", X5, "5V", COL["v5"])] +
                [("L", ys[k], k, COL["spi"] if k in ("MISO", "MOSI", "SCK", "CS") else COL["ctl"]) for k in ys] +
                [("B", X5, "GND", COL["gnd"])])
    ground(s, X5, 740)
    circled(s, 1245, 700, 3)
    # FFC + panel
    s.rect(1260, 572, 26, 16, fill="#fafafa", stroke=COL["ffc"], width=1.4)
    for i in range(5):
        s.line(1263 + i * 5, 575, 1263 + i * 5, 585, stroke="#bdbdbd", width=1)
    s.rect(1286, 470, 84, 220, fill="#eceff1", stroke=COL["line"], width=1.6, rx=3)
    s.lines(1328, 520, [("10.3″", dict(weight="bold")), ("panel", dict(weight="bold")), "1872 × 1404",
                        "", "adapter +", "40-pin FFC"], size=11.5, lh=16, anchor="middle")

    # ---- SPI / control wires U1 <-> U2
    x1, x2 = 920, 1090
    for k, y in ys.items():
        col = COL["spi"] if k in ("MISO", "MOSI", "SCK", "CS") else COL["ctl"]
        if k == "RST":
            s.line(x1, y, 936, y, stroke=col, width=2)
            resistor_h(s, 936, 984, y, col, body=36)
            s.line(984, y, x2, y, stroke=col, width=2)
        else:
            s.line(x1, y, x2, y, stroke=col, width=2)
        name = {"RST": "EPD_RST", "HRDY": "EPD_HRDY"}.get(k, k)
        s.label_box(1044, y, name, "spi" if col == COL["spi"] else "ctl", size=11.5)
    s.text(960, ys["RST"] + 25, "R3 1 kΩ", size=12, anchor="middle", weight="bold")
    circled(s, 960, ys["RST"] - 22, 1)
    # direction arrows at the receiving end
    for k, y in ys.items():
        col = COL["spi"] if k in ("MISO", "MOSI", "SCK", "CS") else COL["ctl"]
        if k in ("MISO", "HRDY"):
            s.polygon([(921, y), (930, y - 4.5), (930, y + 4.5)], fill=col, stroke="none", width=0)
        else:
            s.polygon([(1089, y), (1080, y - 4.5), (1080, y + 4.5)], fill=col, stroke="none", width=0)

    # ---- SENSE
    X_NODE, Y_NODE = X_R1, 470
    s.line(X_R1, RAIL, X_R1, 368, stroke=COL["vbat"], width=2)
    resistor_v(s, X_R1, 368, Y_NODE, COL["vbat"])
    s.line(X_R1, 437, X_R1, Y_NODE, stroke=COL["sense"], width=2)
    s.dot(X_NODE, Y_NODE, COL["sense"], 4.5)
    s.line(X_NODE, Y_NODE, 620, Y_NODE, stroke=COL["sense"], width=2)
    resistor_v(s, X_R1, Y_NODE, 530, COL["sense"])
    s.line(X_R1, 519, X_R1, 530, stroke=COL["gnd"], width=2)
    ground(s, X_R1, 530)
    s.lines(X_R1 + 14, 404, [("R1 220 kΩ", dict(weight="bold")), "1 %"], size=12, lh=15)
    s.lines(X_R1 + 14, 500, [("R2 220 kΩ", dict(weight="bold")), "1 %"], size=12, lh=15)
    s.line(360, Y_NODE, X_NODE, Y_NODE, stroke=COL["sense"], width=2)
    s.dot(360, Y_NODE, COL["sense"], 0.1)
    cap_v(s, 360, Y_NODE, 520, COL["sense"])
    ground(s, 360, 520)
    s.lines(344, 492, [("C1", dict(weight="bold")), "100 nF"], size=12, lh=15, anchor="end")
    s.label_box(528, Y_NODE - 16, "BATT_SENSE", "sense", size=11.5)
    s.lines(36, 380, ["VBAT_SYS ÷ 2 into the ADC", "(4.2 V reads as 2.1 V)"], size=12, lh=16,
            fill=COL["text2"])

    # ---- BUTTONS
    xg = 300
    rows = [("D0", 620, "SW1", "BACK", "BTN_BACK"), ("D1", 665, "SW2", "REFRESH", "BTN_REFRESH"),
            ("D2", 710, "SW3", "NEXT", "BTN_NEXT")]
    for pin, y, ref, name, net in rows:
        s.line(xg, y, 380, y, stroke=COL["gnd"], width=2)
        pushbutton(s, 383, 423, y)
        s.line(426, y, 620, y, stroke=COL["btn"], width=2)
        s.text(403 - 30, y - 12, ref, size=12, anchor="end", weight="bold")
        s.text(403 + 30, y - 12, name, size=12, anchor="start")
        s.label_box(540, y, net, "btn", size=11.5)
        s.dot(xg, y, COL["gnd"], 4)
    s.line(xg, 620, xg, 740, stroke=COL["gnd"], width=2)
    ground(s, xg, 740)
    s.lines(36, 628, ["Internal pull-ups,", "no resistors.", "Common side", "to GND."], size=12, lh=16,
            fill=COL["text2"])
    s.text(36, 780, "On the button board, via J3 (carrier) and a 4-wire lead.", size=11.5, fill=COL["text2"])

    # ---- notes, legend, title block
    notes = [
        "① RST series 1 kΩ: GPIO43 is UART0 TX during boot, before the HAT is powered.",
        "② R4 keeps the booster off until firmware enables it (MiniBoost EN has a",
        "    100 kΩ pull-up to VIN; with EN low, VOUT is disconnected from VIN).",
        "③ HAT DIP switches: SPI. The HAT drives the panel through the kit's adapter board.",
        "④ Check BT1 polarity with a meter before plugging it into J1.",
        "⑤ U4 B− is the battery side of the protection FETs: not GND.",
        "U2 connects through J2 (1×8 on the carrier) and the kit's PH2.0 8-pin cable.",
        "U1 USB-C: firmware and logs. U4 USB-C: charging. U1 5V and 3V3: not connected.",
    ]
    s.rect(20, 815, 660, 210, fill=COL["note"], stroke=COL["noteline"], width=1.2, rx=8)
    s.text(34, 840, "Notes", size=13, weight="bold")
    for i, r in enumerate(notes):
        ind = 20 if r.startswith("    ") else 0
        s.text(34 + ind, 866 + i * 20, r.strip(), size=12.5)
    circled(s, 160, 230, 5)

    s.legend(700, 815, title="Colour code", col_w=330, size=12.5)

    tb_x, tb_y, tb_w, tb_h = 1060, 815, 320, 210
    s.rect(tb_x, tb_y, tb_w, tb_h, fill="#ffffff", stroke=COL["line"], width=1.6, rx=4)
    s.text(tb_x + 14, tb_y + 34, "brwr-trmnl v1 — schematic", size=17, weight="bold")
    rows = [("Date", "2026-09-26"), ("Licence", "GPL-3.0"), ("Sheet", "1 of 1"),
            ("Source", "hardware/diagrams/")]
    for i, (k, v) in enumerate(rows):
        yy = tb_y + 58 + i * 30
        s.line(tb_x, yy, tb_x + tb_w, yy, stroke="#cfd8dc", width=1)
        s.text(tb_x + 14, yy + 20, k, size=12, fill=COL["text2"])
        s.text(tb_x + 90, yy + 20, v, size=13, weight="bold")
    s.text(tb_x + 14, tb_y + tb_h - 12, "Regenerate: python3 make_diagrams.py", size=11.5, fill=COL["text2"])
    return s.render()
