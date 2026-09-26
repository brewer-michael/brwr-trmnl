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
# or "not a valid 2-manifold" messages), or if an STL, after merging
# vertices closer than 1e-4 mm the way a slicer does, has an edge not shared
# by exactly two triangles or a degenerate triangle (needs python3). Prints
# sizes and estimated masses. PNG export needs a display; without one the
# script runs OpenSCAD under xvfb-run.
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

# ---- mesh check, size and mass (python3) ---------------------------------
# Slicers merge vertices that are closer than about 1e-4 mm. Every STL is
# checked after the same merge: each edge shared by exactly two triangles
# (once in each direction) and no degenerate triangles, or the export fails.
command -v python3 >/dev/null || { echo "the mesh check needs python3" >&2; exit 1; }
python3 - "$stl_dir" "${parts[@]}" one-piece/bezel one-piece/back <<'PY'
import sys, struct, math
TOL = 1e-4                        # mm, vertex merge distance (as a slicer does)
# PETG 1.27 g/cm3; 1.2 mm solid shell on every surface (3-4 walls, 4-5
# top/bottom layers at 0.2 mm), 20 % infill inside the shell
RHO, SHELL, INFILL = 1.27, 0.12, 0.20

def read_stl(fn):
    raw = open(fn, "rb").read()
    n = struct.unpack_from("<I", raw, 80)[0]
    return [struct.unpack_from("<12f", raw, 84 + 50 * i)[3:] for i in range(n)]

def weld(pts):
    # union-find over points closer than TOL, found through a grid of TOL cells
    parent = list(range(len(pts)))
    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a
    cells = {}
    for i, p in enumerate(pts):
        c = [math.floor(x / TOL) for x in p]
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                for dz in (-1, 0, 1):
                    for j in cells.get((c[0] + dx, c[1] + dy, c[2] + dz), ()):
                        q = pts[j]
                        if (p[0] - q[0]) ** 2 + (p[1] - q[1]) ** 2 + (p[2] - q[2]) ** 2 <= TOL * TOL:
                            ri, rj = find(i), find(j)
                            if ri != rj:
                                parent[ri] = rj
        cells.setdefault(tuple(c), []).append(i)
    return [find(i) for i in range(len(pts))]

def cross(a, b):
    return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])

d, bad = sys.argv[1], 0
print(f"{'part':18s} {'X x Y x Z (mm, as printed)':28s} {'volume':>9s} {'mass':>6s}  mesh (vertices merged within {TOL} mm)")
for part in sys.argv[2:]:
    tris = read_stl(f"{d}/{part}.stl")
    index, pts = {}, []
    for t in tris:
        for k in range(3):
            v = t[3 * k:3 * k + 3]
            if v not in index:
                index[v] = len(pts)
                pts.append(v)
    root = weld(pts)
    merged = len(pts) - len(set(root))
    edges, degenerate, vol, area = {}, 0, 0.0, 0.0
    for t in tris:
        a, b, c = t[0:3], t[3:6], t[6:9]
        ids = [root[index[a]], root[index[b]], root[index[c]]]
        n = cross([b[i] - a[i] for i in range(3)], [c[i] - a[i] for i in range(3)])
        ar = 0.5 * math.sqrt(n[0] ** 2 + n[1] ** 2 + n[2] ** 2)
        area += ar
        vol += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0]) + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6
        if len(set(ids)) < 3 or ar == 0:
            degenerate += 1
        for i in range(3):                        # a slicer keeps these edges too
            e = (ids[i], ids[(i + 1) % 3])
            if e[0] != e[1]:
                edges[e] = edges.get(e, 0) + 1
    und = {}
    for (i, j), k in edges.items():
        und[(min(i, j), max(i, j))] = und.get((min(i, j), max(i, j)), 0) + k
    open_or_shared = sum(1 for k in und.values() if k != 2)
    flipped = sum(1 for k in edges.values() if k > 1)
    problems = open_or_shared + flipped + degenerate
    bad += problems
    vol_cm3, area_cm2 = vol / 1000, area / 100
    shell = min(vol_cm3, area_cm2 * SHELL)
    mass = RHO * (shell + INFILL * (vol_cm3 - shell))
    size = [max(p[i] for p in pts) - min(p[i] for p in pts) for i in range(3)]
    status = "ok" if problems == 0 else (f"{merged} vertices merged, {open_or_shared} edges not shared by two faces, "
                                         f"{flipped} flipped, {degenerate} degenerate triangles")
    print(f"{part:18s} {' x '.join(f'{s:.1f}' for s in size):28s} {vol_cm3:7.1f}cm3 {mass:4.0f} g  {status}")
sys.exit(1 if bad else 0)
PY
echo "Done."
