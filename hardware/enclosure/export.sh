#!/usr/bin/env bash
# Render the brwr-trmnl enclosure: printable STLs and preview PNGs.
#
#   ./export.sh                      # everything
#   OPENSCAD=/path/to/openscad ./export.sh
#
# Writes
#   hardware/enclosure/stl/{bezel,back,button_caps,stand}.stl  (print orientation)
#   docs/images/enclosure-{front,back,exploded,inside}.png     (1600 x 1200)
#
# Fails if OpenSCAD reports any warning or error (design-rule asserts, CGAL
# or "not a valid 2-manifold" messages). PNG export needs a display; without
# one the script runs OpenSCAD under xvfb-run.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scad="$here/brwr-trmnl.scad"
stl_dir="$here/stl"
img_dir="$(cd "$here/../.." && pwd)/docs/images"
openscad="${OPENSCAD:-openscad}"
parts=(bezel back button_caps stand)

mkdir -p "$stl_dir" "$img_dir"
logs="$(mktemp -d)"
trap 'rm -rf "$logs"' EXIT

display=()
if [[ -z "${DISPLAY:-}" ]]; then
  command -v xvfb-run >/dev/null || { echo "PNG export needs a display or xvfb-run" >&2; exit 1; }
  display=(xvfb-run -a)
fi

check_log() {  # name log: fail on any OpenSCAD warning or error
  if grep -Eiq 'warning|error|manifold' "$2"; then
    echo "!! $1:" >&2
    grep -Ei 'warning|error|manifold' "$2" >&2
    return 1
  fi
}

# ---- STLs (CGAL, about a minute; the parts render in parallel) ----------
echo "Rendering STLs into $stl_dir"
pids=()
for part in "${parts[@]}"; do
  "$openscad" -o "$stl_dir/$part.stl" --export-format binstl -D "part=\"$part\"" "$scad" \
    > "$logs/$part.log" 2>&1 &
  pids+=("$!")
done
failed=0
for i in "${!parts[@]}"; do
  if ! wait "${pids[$i]}"; then
    echo "!! ${parts[$i]}: OpenSCAD failed" >&2
    tail -n 5 "$logs/${parts[$i]}.log" >&2
    failed=1
  fi
  check_log "${parts[$i]}" "$logs/${parts[$i]}.log" || failed=1
done
(( failed == 0 )) || exit 1

# design-rule report (the asserts passed, or the renders above would have failed)
grep '^ECHO' "$logs/bezel.log" | sed 's/^ECHO: "//; s/"$//'

# ---- PNGs (OpenCSG preview of the STLs just written) --------------------
echo "Rendering PNGs into $img_dir"
render_png() {  # name part camera [extra openscad args]
  local name=$1 part=$2 camera=$3
  shift 3
  ${display[@]+"${display[@]}"} "$openscad" -o "$img_dir/enclosure-$name.png" \
    --imgsize=1600,1200 --colorscheme=Tomorrow --projection=p --camera="$camera" \
    -D "part=\"$part\"" -D use_stl=true -D upright=true "$@" "$scad" \
    > "$logs/png-$name.log" 2>&1
  check_log "enclosure-$name.png" "$logs/png-$name.log"
}
#          name     part      camera: target x,y,z, rotation x,y,z, distance
render_png front    assembly  0,0,0,74,0,28,670
render_png back     assembly  0,0,0,70,0,212,700
render_png exploded exploded  0,-70,5,55,0,58,900
render_png inside   inside    0,0,0,82,0,196,660

# ---- optional: size, volume and mass estimate (python3 with numpy) -------
if command -v python3 >/dev/null && python3 -c 'import numpy' 2>/dev/null; then
  python3 - "$stl_dir" "${parts[@]}" <<'PY'
import sys, struct, numpy as np
# PETG 1.27 g/cm3; 1.2 mm solid shell on every surface (3-4 walls, 4-5
# top/bottom layers at 0.2 mm), 20 % infill inside the shell
RHO, SHELL, INFILL = 1.27, 0.12, 0.20
d = sys.argv[1]
print(f"{'part':12s} {'X x Y x Z (mm, as printed)':28s} {'volume':>9s} {'mass':>7s}")
for p in sys.argv[2:]:
    raw = open(f"{d}/{p}.stl", "rb").read()
    n = struct.unpack("<I", raw[80:84])[0]
    t = np.frombuffer(raw[84:84 + 50 * n], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]))
    v = t["v"].reshape(-1, 3, 3).astype(float) / 10.0          # cm
    vol = np.einsum("ij,ij->i", v[:, 0], np.cross(v[:, 1], v[:, 2])).sum() / 6
    area = 0.5 * np.linalg.norm(np.cross(v[:, 1] - v[:, 0], v[:, 2] - v[:, 0]), axis=1).sum()
    shell = min(vol, area * SHELL)
    mass = RHO * (shell + INFILL * (vol - shell))
    size = (v.reshape(-1, 3).max(0) - v.reshape(-1, 3).min(0)) * 10
    print(f"{p:12s} {' x '.join(f'{s:.1f}' for s in size):28s} {vol:7.1f}cm3 {mass:5.0f} g")
PY
fi
echo "Done."
