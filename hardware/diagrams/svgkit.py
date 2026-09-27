"""Small SVG toolkit shared by the brwr-trmnl diagram generators.

Pure standard library. Every drawing gets a solid white background and dark
text so it reads the same in GitHub's light and dark themes.
"""

from __future__ import annotations

import math
from html import escape

FONT = 'system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif'

# Colour code shared by every diagram.
COL = {
    "vbat": "#c62828",    # battery / VBAT_SYS
    "v5": "#ef6c00",      # 5 V (5V_EPD)
    "gnd": "#263238",     # ground
    "spi": "#1565c0",     # SPI
    "ctl": "#6a1b9a",     # control: EPD_EN, EPD_RST, EPD_HRDY
    "btn": "#2e7d32",     # buttons
    "sense": "#00838f",   # battery sense
    "coax": "#757575",    # antenna coax (dashed)
    "ffc": "#9e9e9e",     # panel FFC / flex outline
    "text": "#1a1a1a",
    "text2": "#4a4a4a",
    "line": "#212121",
    "block": "#f6f7f9",
    "blockline": "#b0b7c3",
    "note": "#fff8e1",
    "noteline": "#f9a825",
}

# Pale tints used behind net-label text.
TINT = {
    "vbat": "#ffebee", "v5": "#fff3e0", "gnd": "#eceff1", "spi": "#e3f2fd",
    "ctl": "#f3e5f5", "btn": "#e8f5e9", "sense": "#e0f7fa", "coax": "#f5f5f5",
}

LEGEND = [
    ("vbat", "Battery / VBAT_SYS (3.0–4.2 V)", None),
    ("v5", "5V_EPD (5.2 V, panel supply)", None),
    ("gnd", "GND", None),
    ("spi", "SPI: SCK, MOSI, MISO, CS", None),
    ("ctl", "Control: EPD_EN, EPD_RST, EPD_HRDY", None),
    ("btn", "Buttons: BACK, REFRESH, NEXT", None),
    ("sense", "BATT_SENSE (divider)", None),
    ("coax", "Antenna coax (U.FL)", "6 4"),
]

# Helvetica/Arial advance widths (1/1000 em) for printable ASCII.
_W = [278, 278, 355, 556, 556, 889, 667, 191, 333, 333, 389, 584, 278, 333, 278, 278,
      556, 556, 556, 556, 556, 556, 556, 556, 556, 556, 278, 278, 584, 584, 584, 556,
      1015, 667, 667, 722, 722, 667, 611, 778, 722, 278, 500, 667, 556, 833, 722, 778,
      667, 778, 722, 667, 611, 722, 667, 944, 667, 667, 611, 278, 278, 278, 469, 556,
      333, 556, 556, 500, 556, 556, 278, 556, 556, 222, 222, 500, 222, 833, 556, 556,
      556, 556, 333, 500, 278, 556, 500, 722, 500, 500, 500, 334, 260, 334, 584]
_WX = {"Ω": 768, "µ": 556, "≥": 549, "—": 1000, "–": 556, "×": 584, "Ø": 778, "±": 584,
       "°": 400, "″": 400, "→": 1000, "←": 1000, "↑": 1000, "↓": 1000, "·": 278, "⚠": 1000,
       "≈": 584, "…": 1000, "−": 584, "‘": 222, "’": 222, "“": 333, "”": 333, "é": 556}


def text_w(s: str, size: float, bold: bool = False) -> float:
    """Conservative text width: Arial metrics scaled up to cover wider system fonts."""
    total = 0
    for ch in s:
        o = ord(ch)
        total += _W[o - 32] if 32 <= o < 127 else _WX.get(ch, 700)
    return total / 1000.0 * size * (1.16 if bold else 1.10)


def f(v: float) -> str:
    """Format a number compactly."""
    if abs(v - round(v)) < 1e-6:
        return str(int(round(v)))
    return f"{v:.2f}".rstrip("0").rstrip(".")


class Svg:
    def __init__(self, w: int, h: int, title: str, desc: str = ""):
        self.w, self.h = w, h
        self.title, self.desc = title, desc
        self.defs: list[str] = []
        self.items: list[str] = []

    # -- raw ---------------------------------------------------------------
    def add(self, s: str) -> None:
        self.items.append(s)

    def group(self, inner: list[str], **attrs) -> None:
        a = "".join(f' {k.replace("_", "-")}="{v}"' for k, v in attrs.items())
        self.items.append(f"<g{a}>" + "".join(inner) + "</g>")

    # -- primitives -------------------------------------------------------
    @staticmethod
    def _attrs(d: dict) -> str:
        out = []
        for k, v in d.items():
            if v is None:
                continue
            k = k.rstrip("_").replace("_", "-")
            out.append(f' {k}="{f(v) if isinstance(v, (int, float)) else v}"')
        return "".join(out)

    def line(self, x1, y1, x2, y2, stroke=COL["line"], width=1.5, **kw):
        self.add(f'<line x1="{f(x1)}" y1="{f(y1)}" x2="{f(x2)}" y2="{f(y2)}"'
                 f' stroke="{stroke}" stroke-width="{f(width)}"{self._attrs(kw)}/>')

    def poly(self, pts, stroke=COL["line"], width=1.5, fill="none", **kw):
        p = " ".join(f"{f(x)},{f(y)}" for x, y in pts)
        self.add(f'<polyline points="{p}" fill="{fill}" stroke="{stroke}" stroke-width="{f(width)}"'
                 f' stroke-linejoin="round" stroke-linecap="round"{self._attrs(kw)}/>')

    def polygon(self, pts, fill="none", stroke=COL["line"], width=1.5, **kw):
        p = " ".join(f"{f(x)},{f(y)}" for x, y in pts)
        self.add(f'<polygon points="{p}" fill="{fill}" stroke="{stroke}" stroke-width="{f(width)}"'
                 f' stroke-linejoin="round"{self._attrs(kw)}/>')

    def path(self, d, stroke=COL["line"], width=1.5, fill="none", **kw):
        self.add(f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{f(width)}"'
                 f' stroke-linejoin="round" stroke-linecap="round"{self._attrs(kw)}/>')

    def rect(self, x, y, w, h, fill="none", stroke=COL["line"], width=1.5, rx=0, **kw):
        self.add(f'<rect x="{f(x)}" y="{f(y)}" width="{f(w)}" height="{f(h)}" rx="{f(rx)}"'
                 f' fill="{fill}" stroke="{stroke}" stroke-width="{f(width)}"{self._attrs(kw)}/>')

    def circle(self, cx, cy, r, fill="none", stroke=COL["line"], width=1.5, **kw):
        self.add(f'<circle cx="{f(cx)}" cy="{f(cy)}" r="{f(r)}" fill="{fill}" stroke="{stroke}"'
                 f' stroke-width="{f(width)}"{self._attrs(kw)}/>')

    def dot(self, x, y, color, r=4):
        self.circle(x, y, r, fill=color, stroke="none", width=0)

    def text(self, x, y, s, size=13, anchor="start", weight="normal", fill=COL["text"],
             italic=False, rotate=None, halo=False, family=None, **kw):
        tr = f' transform="rotate({f(rotate)} {f(x)} {f(y)})"' if rotate else ""
        st = ' font-style="italic"' if italic else ""
        fam = f' font-family="{escape(family, quote=True)}"' if family else ""
        halo_attr = (' paint-order="stroke" stroke="#ffffff" stroke-width="4" stroke-linejoin="round"'
                     if halo else "")
        self.add(f'<text x="{f(x)}" y="{f(y)}" font-size="{f(size)}" text-anchor="{anchor}"'
                 f' font-weight="{weight}" fill="{fill}"{st}{tr}{fam}{halo_attr}{self._attrs(kw)}>'
                 f"{escape(s)}</text>")

    def lines(self, x, y, rows, size=13, lh=None, **kw):
        """Several lines of text; rows may be str or (str, dict(overrides))."""
        lh = lh or size * 1.35
        for i, r in enumerate(rows):
            if isinstance(r, tuple):
                s, o = r
                self.text(x, y + i * lh, s, **{**dict(size=size), **kw, **o})
            else:
                self.text(x, y + i * lh, r, size=size, **kw)
        return y + (len(rows) - 1) * lh

    # -- composite --------------------------------------------------------
    def label_box(self, x, y, s, key, size=12, anchor="middle", bold=True, pad=5, h=None):
        """Net label: pale tint box with a coloured border and dark text. (x, y) is the box centre
        (anchor middle), left edge (start) or right edge (end)."""
        w = text_w(s, size, bold) + 2 * pad
        h = h or size + 8
        x0 = x - w / 2 if anchor == "middle" else (x if anchor == "start" else x - w)
        self.rect(x0, y - h / 2, w, h, fill=TINT.get(key, "#fff"), stroke=COL[key], width=1.4, rx=3)
        self.text(x0 + w / 2, y + size * 0.36, s, size=size, anchor="middle",
                  weight="bold" if bold else "normal")
        return x0, x0 + w

    def dimension(self, x1, y1, x2, y2, label, off=0, size=12, color="#555555", text_side=1):
        """Linear dimension with arrowheads; horizontal or vertical."""
        horiz = abs(y2 - y1) < abs(x2 - x1)
        a = 7
        if horiz:
            y = y1 + off
            self.line(x1, y, x2, y, stroke=color, width=1)
            self.polygon([(x1, y), (x1 + a, y - 3), (x1 + a, y + 3)], fill=color, stroke="none", width=0)
            self.polygon([(x2, y), (x2 - a, y - 3), (x2 - a, y + 3)], fill=color, stroke="none", width=0)
            ty = y - 5 if text_side > 0 else y + size + 2
            self.text((x1 + x2) / 2, ty, label, size=size, anchor="middle", fill=COL["text2"], halo=True)
        else:
            x = x1 + off
            self.line(x, y1, x, y2, stroke=color, width=1)
            self.polygon([(x, y1), (x - 3, y1 + a), (x + 3, y1 + a)], fill=color, stroke="none", width=0)
            self.polygon([(x, y2), (x - 3, y2 - a), (x + 3, y2 - a)], fill=color, stroke="none", width=0)
            self.text(x + (6 if text_side > 0 else -6), (y1 + y2) / 2 + size * 0.35, label, size=size,
                      anchor="start" if text_side > 0 else "end", fill=COL["text2"], halo=True)

    def legend(self, x, y, keys=None, title="Colour code", cols=1, col_w=300, size=12.5, extra=None):
        """Legend box. Returns (w, h)."""
        entries = [e for e in LEGEND if keys is None or e[0] in keys]
        extra = extra or []
        rows = math.ceil((len(entries) + len(extra)) / cols)
        lh = 22
        w = cols * col_w + 24
        h = 40 + rows * lh
        self.rect(x, y, w, h, fill="#ffffff", stroke=COL["blockline"], width=1.2, rx=6)
        self.text(x + 12, y + 22, title, size=13, weight="bold")
        for i, (k, label, dash) in enumerate(entries):
            cx = x + 12 + (i // rows) * col_w
            cy = y + 42 + (i % rows) * lh
            self.line(cx, cy - 4, cx + 36, cy - 4, stroke=COL[k], width=4 if k in ("vbat", "v5", "gnd") else 3,
                      stroke_dasharray=dash, stroke_linecap="butt")
            self.text(cx + 46, cy, label, size=size)
        for j, (sym, label) in enumerate(extra):
            i = len(entries) + j
            cx = x + 12 + (i // rows) * col_w
            cy = y + 42 + (i % rows) * lh
            sym(self, cx, cy - 4)
            self.text(cx + 46, cy, label, size=size)
        return w, h

    def note_box(self, x, y, w, title, rows, size=12.5, lh=18, numbered=True):
        h = 34 + len(rows) * lh + 6
        self.rect(x, y, w, h, fill=COL["note"], stroke=COL["noteline"], width=1.2, rx=6)
        self.text(x + 12, y + 22, title, size=13, weight="bold")
        for i, r in enumerate(rows):
            yy = y + 42 + i * lh
            if numbered and not r.startswith("  "):
                pass
            self.text(x + 14, yy, r, size=size)
        return h

    # -- output -------------------------------------------------------------
    def render(self) -> str:
        head = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}" height="{self.h}"'
                f' viewBox="0 0 {self.w} {self.h}" font-family="{escape(FONT, quote=True)}"'
                f' role="img" aria-labelledby="t d">\n'
                f'<title id="t">{escape(self.title)}</title>\n<desc id="d">{escape(self.desc)}</desc>\n')
        defs = "<defs>" + "".join(self.defs) + "</defs>\n" if self.defs else ""
        bg = f'<rect x="0" y="0" width="{self.w}" height="{self.h}" fill="#ffffff"/>\n'
        return head + defs + bg + "\n".join(self.items) + "\n</svg>\n"


def ground(s: Svg, x, y, color=COL["gnd"], stem=10):
    """Ground symbol hanging below (x, y)."""
    s.line(x, y, x, y + stem, stroke=color, width=1.8)
    for i, hw in enumerate((10, 6.5, 3)):
        yy = y + stem + i * 4
        s.line(x - hw, yy, x + hw, yy, stroke=color, width=1.8)


def circled(s: Svg, x, y, n, r=9, color="#8d6e00"):
    """Small circled note number."""
    s.circle(x, y, r, fill="#fff8e1", stroke=color, width=1.3)
    s.text(x, y + 4.2, str(n), size=11.5, anchor="middle", weight="bold", fill=COL["text"])
