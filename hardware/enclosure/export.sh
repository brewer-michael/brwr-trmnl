#!/usr/bin/env bash
# Render the brwr-trmnl enclosure: printable STLs and preview PNGs.
#
#   ./export.sh                      # everything
#   OPENSCAD=/path/to/openscad ./export.sh
#
# Writes
#   hardware/enclosure/stl/{bezel_top,bezel_bottom,bezel_left,bezel_right,back_left,back_right,button_caps,stand}.stl
#       split parts for a 220 x 220 mm bed, in print orientation (the top rail
#       and the chin turned 45 deg)
#   hardware/enclosure/stl/one-piece/{bezel,back}.stl
#       one-piece bezel and back cover for beds of 250 x 210 mm or more
#   docs/images/enclosure-{front,back,exploded,inside}.png   (1600 x 1200)
#   docs/images/enclosure-plates.png                         (print jobs on the bed)
#
# Fails if OpenSCAD reports any warning or error (design-rule asserts, CGAL
# or "not a valid 2-manifold" messages). If python3 with numpy is available
# it also checks every STL for open or non-manifold edges and zero-area
# triangles, and prints sizes and estimated masses. PNG export needs a
# display; without one the script runs OpenSCAD under xvfb-run.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scad="$here/brwr-trmnl.scad"
stl_dir="$here/stl"
img_dir="$(cd "$here/../.." && pwd)/docs/images"
openscad="${OPENSCAD:-openscad}"
parts=(bezel_top bezel_bottom bezel_left bezel_right back_left back_right button_caps stand)
one_piece=(bezel back)
# the one-piece parts are checked against a 250 x 210 bed (3 mm margins)
one_piece_args=(-D split=false -D "bed_size=[250,210]" -D bed_margin=3)

mkdir -p "$stl_dir/one-piece" "$img_dir"
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

# ---- STLs (CGAL, a minute or two; the parts render in parallel) ---------
echo "Rendering STLs into $stl_dir"
jobs_names=()
pids=()
for part in "${parts[@]}"; do
  "$openscad" -o "$stl_dir/$part.stl" --export-format binstl -D "part=\"$part\"" "$scad" \
    > "$logs/$part.log" 2>&1 &
  pids+=("$!"); jobs_names+=("$part")
done
for part in "${one_piece[@]}"; do
  "$openscad" -o "$stl_dir/one-piece/$part.stl" --export-format binstl -D "part=\"$part\"" \
    "${one_piece_args[@]}" "$scad" > "$logs/one-piece-$part.log" 2>&1 &
  pids+=("$!"); jobs_names+=("one-piece-$part")
done
failed=0
for i in "${!pids[@]}"; do
  name="${jobs_names[$i]}"
  if ! wait "${pids[$i]}"; then
    echo "!! $name: OpenSCAD failed" >&2
    tail -n 5 "$logs/$name.log" >&2
    failed=1
  fi
  check_log "$name" "$logs/$name.log" || failed=1
done
(( failed == 0 )) || exit 1

# design-rule report (the asserts passed, or the renders above would have failed)
grep '^ECHO' "$logs/bezel_top.log" | sed 's/^ECHO: "//; s/"$//'

# ---- PNGs (OpenCSG preview of the STLs just written) --------------------
echo "Rendering PNGs into $img_dir"
render_png() {  # name part size projection camera [extra openscad args]
  local name=$1 part=$2 size=$3 projection=$4 camera=$5
  shift 5
  ${display[@]+"${display[@]}"} "$openscad" -o "$img_dir/enclosure-$name.png" \
    --imgsize="$size" --colorscheme=Tomorrow --projection="$projection" --camera="$camera" \
    -D "part=\"$part\"" -D use_stl=true "$@" "$scad" \
    > "$logs/png-$name.log" 2>&1
  check_log "enclosure-$name.png" "$logs/png-$name.log"
}
#          name     part      size        proj  camera: target x,y,z, rotation x,y,z, distance
render_png front    assembly  1600,1200   p     0,0,0,74,0,28,670      -D upright=true
render_png back     assembly  1600,1200   p     0,0,0,70,0,212,700     -D upright=true
render_png exploded exploded  1600,1200   p     -10,-40,-12,55,0,58,930 -D upright=true
render_png inside   inside    1600,1200   p     0,0,0,82,0,196,660     -D upright=true
render_png plates   plates    1600,1700   o     245,-12,0,0,0,0,1450

# ---- optional: mesh check, size and mass (python3 with numpy) -----------
if command -v python3 >/dev/null && python3 -c 'import numpy' 2>/dev/null; then
  python3 - "$stl_dir" "${parts[@]}" one-piece/bezel one-piece/back <<'PY'
import sys, struct, numpy as np
# PETG 1.27 g/cm3; 1.2 mm solid shell on every surface (3-4 walls, 4-5
# top/bottom layers at 0.2 mm), 20 % infill inside the shell
RHO, SHELL, INFILL = 1.27, 0.12, 0.20
d, bad = sys.argv[1], 0
print(f"{'part':18s} {'X x Y x Z (mm, as printed)':28s} {'volume':>9s} {'mass':>6s}  mesh")
for p in sys.argv[2:]:
    raw = open(f"{d}/{p}.stl", "rb").read()
    n = struct.unpack("<I", raw[80:84])[0]
    t = np.frombuffer(raw[84:84 + 50 * n], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]))
    v = t["v"].reshape(-1, 3, 3).astype(float)
    # every edge shared by exactly two triangles, once in each direction
    _, idx = np.unique(v.reshape(-1, 3), axis=0, return_inverse=True)
    idx = idx.reshape(-1, 3)
    e = np.concatenate([idx[:, [0, 1]], idx[:, [1, 2]], idx[:, [2, 0]]])
    _, cnt = np.unique(np.sort(e, axis=1), axis=0, return_counts=True)
    _, dcnt = np.unique(e, axis=0, return_counts=True)
    area = 0.5 * np.linalg.norm(np.cross(v[:, 1] - v[:, 0], v[:, 2] - v[:, 0]), axis=1)
    problems = int((cnt != 2).sum() + (dcnt > 1).sum() + (area == 0).sum())
    bad += problems
    c = v / 10.0                                                  # cm
    vol = np.einsum("ij,ij->i", c[:, 0], np.cross(c[:, 1], c[:, 2])).sum() / 6
    shell = min(vol, area.sum() / 100 * SHELL)
    mass = RHO * (shell + INFILL * (vol - shell))
    size = v.reshape(-1, 3).max(0) - v.reshape(-1, 3).min(0)
    print(f"{p:18s} {' x '.join(f'{s:.1f}' for s in size):28s} {vol:7.1f}cm3 {mass:4.0f} g  "
          + ("ok" if problems == 0 else f"{problems} PROBLEMS"))
sys.exit(1 if bad else 0)
PY
fi
echo "Done."
