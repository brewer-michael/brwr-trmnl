#!/usr/bin/env python3
"""Regenerate the brwr-trmnl hardware diagrams in docs/images/.

    python3 hardware/diagrams/make_diagrams.py            # all diagrams
    python3 hardware/diagrams/make_diagrams.py wiring     # just one

Standard library only. The drawings are plain SVG with a white background, so
they read the same in GitHub's light and dark themes.
"""

from __future__ import annotations

import importlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE.parent.parent / "docs" / "images"

# output name -> generator module (each has build() -> str)
DIAGRAMS = {
    "schematic": "schematic",
    "wiring": "wiring",
    "carrier-layout": "carrier",
    "button-board": "button_board",
}


def main(argv: list[str]) -> int:
    sys.path.insert(0, str(HERE))
    wanted = argv or list(DIAGRAMS)
    OUT.mkdir(parents=True, exist_ok=True)
    for name in wanted:
        if name not in DIAGRAMS:
            print(f"unknown diagram {name!r}; choose from {', '.join(DIAGRAMS)}", file=sys.stderr)
            return 2
        svg = importlib.import_module(DIAGRAMS[name]).build()
        path = OUT / f"{name}.svg"
        path.write_text(svg, encoding="utf-8")
        print(f"wrote {path.relative_to(HERE.parent.parent)} ({len(svg) // 1024} KiB)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
