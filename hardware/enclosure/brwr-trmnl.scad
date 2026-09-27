// =====================================================================
// brwr-trmnl enclosure: 10.3" e-paper Home Assistant display
// =====================================================================
// A thin printed frame (bezel + back cover, 229 x 204 x 13 mm) that sticks
// to a fridge door with four N52 disc magnets sealed inside the back cover,
// or leans into a small printed desk stand. Steel rods epoxied into
// channels stiffen it and splice the split parts.
//
// Coordinates (front view, looking at the display): origin at the centre
// of the outline, +X right, +Y up, +Z toward the viewer. Z = 0 is the
// back face of the back cover (the face that touches the fridge); the
// front face of the bezel is at Z = depth. All dimensions are mm.
//
// Printable parts (split = true, for a 220 x 220 bed): bezel_top,
// bezel_bottom, bezel_left, bezel_right, back_left, back_right,
// button_caps, stand. One-piece parts for a 250 x 210 bed: bezel, back
// (split = false). Render them all with ./export.sh. Views: assembly,
// exploded, inside (back cover removed), fit_check (module envelopes in a
// see-through enclosure), plates (print jobs on the bed) and clash
// (intersections between parts, modules and rods; empty when all fits).
//
// OpenSCAD 2021.01 or newer. Open the Customizer to change parameters.
// =====================================================================

/* [Part] */
// What to render
part = "assembly"; // [assembly, exploded, inside, fit_check, clash, plates, bezel_top, bezel_bottom, bezel_left, bezel_right, back_left, back_right, button_caps, stand, bezel, back]

/* [Panel: E Ink ED103TC2] */
panel_w = 216.70;        // mm, glass outline width (ED103TC2 spec)
panel_h = 174.41;        // mm, glass outline height (ED103TC2 spec)
panel_t = 0.78;          // mm, panel thickness (ED103TC2 spec)
active_w = 209.66;       // mm, active area width (ED103TC2 spec)
active_h = 157.25;       // mm, active area height (ED103TC2 spec)
border_side = 3.1;       // mm, non-active border to cover left, right and top (spec)
border_bottom = 13.7;    // mm, non-active border to cover at the bottom, FPC side (spec)
pocket_depth = 1.2;      // mm, panel pocket depth (community-measured FrameOS case)
pocket_clear = 0.3;      // mm per side, panel to pocket wall (spec)
pocket_rim_b = 2.0;      // mm, rim below the pocket's bottom edge, outside the flex slot (design)
pocket_relief_d = 1.6;   // mm, relief holes in the pocket corners for the glass corners (design: leaves a web to the rod groove)
gasket_t = 0.5;          // mm, foam gasket on the window lip (spec)
back_foam_t = 1.0;       // mm, foam strips between the ribs and the panel (lead)
back_foam_squeeze = 0.3; // mm, foam compression when the back cover is screwed on (design)

/* [Panel flex (FPC)] */
fpc_w = 141;             // mm, flex width at the panel's bottom edge (spec)
fpc_zone = [144, 40];    // mm, keep-clear zone behind the panel's bottom centre, W x H (spec)
fpc_relief_w = 144;      // mm, relief slot width along the pocket's bottom edge (spec >= 141)
fpc_relief_d = 3.0;      // mm, relief slot depth below the pocket edge (spec >= 3)
fpc_adapter = [30, 15, 4]; // mm, e-Paper Adapter board envelope (estimate, exact size unknown)
fpc_t = 0.3;             // mm, flex thickness incl. stiffener (estimate)
fpc_bend = 1.5;          // mm, how far the 180 deg bend reaches below the panel edge (estimate)

/* [Enclosure] */
outer_w = 229;           // mm, outer width (spec target ~229)
outer_h = 204;           // mm, outer height (spec target ~204)
depth = 13;              // mm, total depth incl. back cover (lead: 13; the charger's USB-C sets the minimum, see the console)
border_top = 6;          // mm, panel top edge to outer top edge (spec ~6)
corner_r = 6;            // mm, outline corner radius (spec ~6)
wall_t = 2.5;            // mm, side walls (spec)
front_t = 1.6;           // mm, front face (lead)
back_t = 1.8;            // mm, back cover plate (lead)
front_chamfer = 1.5;     // mm, 45 deg chamfer on the front outer edge (design)
back_chamfer = 1.0;      // mm, 45 deg chamfer on the back outer edge (design)
seam_chamfer = 0.5;      // mm, V-groove where bezel and back cover meet, and on the rail joints (design)
window_chamfer = 1.1;    // mm, 45 deg chamfer on the window's front edge (spec: 45 deg; land + chamfer = front_t)
window_land = 0.5;       // mm, straight land behind the window chamfer (design)
window_r = 1.0;          // mm, window corner radius (design)
lip_t = 1.2;             // mm, locating lip on the back cover, inside the walls (design)
lip_h = 2.0;             // mm, locating lip height (design)
lip_clear = 0.25;        // mm, lip to wall clearance (design)
print_gap = 4;           // mm, spacing between caps on the bed (design)

/* [Print bed and split] */
bed_size = [220, 220];   // mm, printer bed (FlashForge Adventurer 5M); one-piece parts need [250, 210]
bed_margin = 5;          // mm, strip along the bed edge that is not used (lead)
split = true;            // split bezel and back cover to fit bed_size; false: one-piece bezel and back
bezel_lap = 4;           // mm, rail joints: the inner half of the side wall runs this far past the outer half (design)
rail_angle = 45;         // deg, the top rail and the chin turn on the bed so they fit (lead)
back_split_x = -39;      // mm, back cover seam on its inner face (lead)
scarf_land = 0.4;        // mm, straight land at both ends of the back cover's 45 deg scarf (design)
back_tab_y = [-70, 0, 55]; // mm, alignment tabs across the back cover seam (design: clear of the rods)
back_tab = [2, 8, 0.8];  // mm, tab length past the seam, width, thickness (design)
tab_clear = 0.2;         // mm, tab to pocket clearance (design)
seam_clear_min = 1.5;    // mm, back cover seam and bezel joints to any feature (lead)
tie_seam_min = 4;        // mm, back cover seam to the zip-tie blocks (lead)
rib_seam_clear = 1.5;    // mm, ribs stop this far from the back cover seam (design)
plate_gap = 10;          // mm, gap between parts that share a print job (design)

/* [Driver board: Waveshare e-Paper IT8951 Driver HAT (B)] */
drv_size = [65, 56.5];   // mm, RPi HAT footprint, long x short edge (Waveshare)
drv_pos = [-73, 0];      // mm, board centre; the short FFC edge faces +X (spec)
drv_pcb_t = 1.6;         // mm (Waveshare)
drv_hole_inset = 3.5;    // mm, M2.5 hole centres from the edges, 58 x 49 pattern (Waveshare)
drv_hole_d = 2.75;       // mm, M2.5 mounting holes (Waveshare)
drv_stub_h = 1.0;        // mm, clipped 2x20 header pins left on the back (lead: header removed)
drv_stub_size = [50.8, 5.1]; // mm, where the header was, along the +Y long edge (standard 2x20)
drv_comp_h = 3.0;        // mm, tallest part on the panel side (lead: tall socket and pin headers removed)
drv_air_min = 1.5;       // mm, minimum air gap from components to the panel (spec)
drv_standoff_h = 1.5;    // mm, printed standoffs, back plate to PCB (lead ~1.5, clears the stubs)
drv_standoff_d = 6;      // mm, standoff diameter (design)
drv_screw_len = 8;       // mm, M2.5 x 8 countersunk (ISO 10642) from outside into a nut on the component side
drv_ffc_socket = [5, 30, 2.0]; // mm, FFC socket envelope on the +X edge, X x Y x Z (estimate)

/* [Carrier board: XIAO ESP32-S3 + MiniBoost + TP4056] */
car_size = [70, 35];     // mm, protoboard W x H (spec)
car_pcb_t = 1.6;         // mm, protoboard thickness
car_comp_h = 5.6;        // mm, tallest part above the board: the MiniBoost, 17.8 x 11.3 x 5.6 mm (Adafruit, lead)
car_floor = 0.6;         // mm, back plate left under the board's recess (lead: the thinnest allowed, for the MiniBoost)
car_ledge_h = 1.2;       // mm, ledges that carry the board; room for its solder joints (lead)
car_ledge_w = 1.5;       // mm, ledge width along the board's left and right edges (design)
car_air_min = 1.0;       // mm, minimum gap from the tallest part to the panel or rim (design)
car_boss_d = 6.0;        // mm, screw boss diameter in the recess (design: clears the joints one hole out)
car_clear = 0.4;         // mm, board to tray rim, per side (design)
car_tray_wall = 1.2;     // mm, tray rim thickness (design)
car_tray_rim = 1.0;      // mm, rim height above the PCB underside (design)
car_screws = [[-31.75, 30.85], [31.75, 2.91]]; // mm, M2.5 screws as [X, height above the board's bottom edge]: the middle of the
                         // top-left and bottom-right corner squares of four protoboard holes, where a 2.7 mm drill centres
                         // itself (spec -30/+30; moved onto the carrier layout's hole grid, see README)
car_ledge_notches = [[-33.02, 23.2]]; // mm, joints that land on a ledge, as [X, depth below the board's top edge]: the
                         // MiniBoost's VIN pin (carrier layout hole k0, r8) (design)
car_notch_len = 4;       // mm, ledge cut away along the edge at each such joint: a 2 mm pad and 1 mm either side (design)
car_screw_len = 6;       // mm, M2.5 x 6 countersunk from outside into a nut on the board (design)
car_wire_gap = [-30, 9]; // mm, gap in the tray rim for incoming wires, [X centre, width] (design; edges not in line with the tie blocks)
usb_x = [-7.62, 22];     // mm, USB-C centres: XIAO (on the carrier's hole grid), charger (spec -8, 22)
usb_size = [9, 3.2];     // mm, USB-C receptacle W x H (typical)
usb_overhang = 1.5;      // mm, connector beyond the board's top edge (spec)
usb_len = 7.4;           // mm, receptacle length (typical USB-C)
usb_zc = [2.6, 3.2];     // mm, receptacle centre above the protoboard: XIAO 1.0 + 1.6, charger 1.6 + 1.6 (lead)
usb_slot = [12.5, 6.5];  // mm, plug slot in the top wall, W x H (spec)
usb_slot_r = 2.0;        // mm, slot corner radius (design)
usb_label = ["USB", "CHARGE"]; // labels beside the slots, outer side (spec)
label_size = 3.2;        // mm, label text size (design)
label_depth = 0.4;       // mm, label engraving depth (spec)
label_gap = 2.0;         // mm, slot edge to label (design)
label_stagger = 0.3;     // mm, baseline offset between labels (mesh hygiene, invisible)
xiao_size = [17.8, 21];  // mm, XIAO ESP32-S3, X x Y (Seeed)
xiao_t = 1.0;            // mm, XIAO PCB, soldered flat (lead)
ufl_from_top = 20;       // mm, U.FL connector below the carrier's top edge (spec)
ufl_plug_h = 2.0;        // mm, U.FL plug above the XIAO PCB (estimate)

/* [Wi-Fi antenna: Taoglas FXP831] */
ant_x = [38, 83];        // mm, X range, just inside the top wall (FXP831 is 45 long)
ant_h = 7;               // mm, height along Z (FXP831 45 x 7 x 0.1)
ant_t = 0.2;             // mm, FPC and adhesive thickness (estimate)
// The antenna sticks to a fin on the back cover, so it and the XIAO are on the
// same part and its coax never has to cross between the halves. Standing on
// edge beside the top wall, it faces away from the fridge door as before.
ant_fin_t = 1.2;         // mm, fin thickness (design)
ant_wall_gap = 1.0;      // mm, fin to the top wall's inner face, so it clears the wall as the case closes (design)
ant_top_clear = 0.2;     // mm, fin and antenna top below the bezel's pocket rim (design)
ant_feed_dx = 3;         // mm, coax exit from the antenna's -X end (estimate)
ant_metal_keepout = 10;  // mm, nothing metallic closer than this (spec)
coax_d = 1.37;           // mm, antenna coax (FXP831)
coax_len = 100;          // mm, antenna coax (FXP831)
coax_notch = 4;          // mm, notch width and depth in ribs for the coax (spec 3; 4 for the lower feed on the fin)
coax_z = 7.0;            // mm, coax height where it crosses the carrier (design: between the parts and the panel)

/* [Battery: LiPo pouch] */
bat_size = [100, 60, 6]; // mm, L x W x T in landscape: 6060100 5000 mAh (spec); 105080: [80, 50, 10]
bat_pos = [56, 0];       // mm, cell centre (spec)
bat_clear = 1.0;         // mm per side (spec)
bat_floor = 0.6;         // mm, back plate left under the cell's recess (lead)
bat_foam_t = 0.5;        // mm, foam pad under the cell (lead)
bat_wall_h = 2.5;        // mm, cradle wall height above the plate (design)
bat_wall_t = 1.2;        // mm, cradle wall thickness (design)
bat_lead_slot = 20;      // mm, slot in the cradle's -X wall for the lead (design)
bat_air_min = 1.0;       // mm, minimum gap from the cell to the rib tops and panel (design)

/* [Front buttons: Omron B3F-4000] */
btn_x = [-25.4, 0, 25.4]; // mm, button centres: 10 holes apart on the strip's 2.54 mm grid (spec 26)
btn_y = -89;             // mm, button centres (design: below the flex relief, strip clears the bottom wall)
sw_size = 12;            // mm, 12 x 12 tactile switch body (spec)
sw_h = 4.3;              // mm, height incl. the flat plunger (Omron B3F-4000, lead)
sw_body_h = 3.5;         // mm, body without plunger (B3F-4000, estimate)
sw_plunger_d = 3.5;      // mm, flat plunger (B3F-4000, estimate)
sw_legs = [12.5, 5];     // mm, leg pattern, X x Y (lead)
strip_clear = 0.3;       // mm, strip to bottom wall (design)
strip_size = [84, 20];   // mm, protoboard strip W x H (spec)
strip_t = 1.6;           // mm, protoboard thickness
strip_solder_h = 2.0;    // mm, joints and screw heads behind the strip (design)
strip_joint_clear = 0.3; // mm, joints to the recess floor under the strip (design)
strip_screw_x = [-36.83, 36.83]; // mm, M2.5 insert bosses on the bezel: the strip's holes 14.5 pitches either side of its centre (spec 38)
strip_boss_d = 6;        // mm (design)
btn_plug_pos = [-50, -53]; // mm, the button lead's inline 4-pin JST-PH pair, lying flat on the back cover
                         // beside the adapter board, so the frame and the back cover come apart (design)
btn_plug_size = [11, 16, 6]; // mm, the mated pair with heat-shrink, X x Y x Z (estimate)
cap_d = 11;              // mm, cap face and stem (spec)
cap_hole_d = 11.4;       // mm, hole in the front face (spec)
cap_proud = 0.5;         // mm, cap face in front of the bezel face (spec 0 to 0.5)
cap_flange_d = 13.4;     // mm, retaining flange behind the front face (design)
cap_flange_t = 0.8;      // mm, flange cylinder behind its 45 deg cone (design)
cap_preload = -0.2;      // mm, plunger pre-travel at rest; negative = free gap above the plunger (lead: -0.2)
sw_travel = 0.25;        // mm, switch travel to the click (Omron B3F)
cap_gap_max = 0.5;       // mm, largest free gap allowed before the cap feels loose (design)
sleeve_od = 14.6;        // mm, guide sleeve behind the front face (design)
sleeve_len = 1.2;        // mm, guide sleeve length incl. the conical seat (design: shortened for the thin case)
key_size = [1.2, 1.0];   // mm, anti-rotation key on the stem, width x radial height (design)
key_clear = 0.2;         // mm, key to keyway clearance (design)
key_boss_wall = 1.2;     // mm, sleeve wall around the keyway (design)
symbol_depth = 0.6;      // mm, engraved symbol depth (spec)
symbol_size = 5.0;       // mm, symbol size (design)

/* [Magnets: N52 discs, sealed in] */
mag_d = 20;              // mm, N52 disc magnet (lead)
mag_h = 3;               // mm (lead)
steel_disc = [20, 1.5];  // mm, steel backing disc on each magnet, D x T (lead)
mag_pos = [[-90, 65], [90, 65], [-90, -65], [90, -65]]; // mm, centres; count = number of entries (lead: +-90/+-65)
mag_skin = 0.6;          // mm, back plate left over the magnet on the outside face (lead)
mag_clear = 0.3;         // mm, pocket diametral clearance (design)
mag_wall = 1.6;          // mm, radial wall around the pocket (design)
mag_epoxy = 0.3;         // mm, epoxy over the steel disc (design); the pocket's tube runs on up to the rib tops and carries foam
pad = [25, 1.0];         // mm, self-adhesive rubber pad over each pocket, outside, D x T (lead)
mag_keep_board = 36;     // mm, magnet centre to driver/carrier board edge, >= 25 mm from the magnet's edge (lead: < 5 mT)
mag_keep_ant = 30;       // mm, magnet centre to antenna reservation (design rule: a steady field doesn't affect it; its metal is kept ant_metal_keepout away too)

/* [Steel rods] */
rod_d = 3;               // mm, steel rod (lead)
rod_slot = 3.4;          // mm, channel width (lead)
rod_back_y = [45.5, -35.3]; // mm, back cover rods (lead ~46 / ~-35.5; 45.5 keeps 8 mm to the magnets, -35.3 centres it in its gap)
rod_back_x = 103;        // mm, back cover rods run from -X to +X (design: clear of the side bosses)
rod_back_sink = 1.0;     // mm, back cover rods sit this far into the plate (design)
rod_wall_t = 1.0;        // mm, channel walls on the back cover (design)
rod_skin = 1.0;          // mm, bezel wall left outside the rod grooves (design)
rod_web = 1.0;           // mm, minimum bezel web between a groove and the pocket (design)
rod_legs = [[40, 40], [40, 40], [40, 48], [40, 48]]; // mm, bezel L-rods top-left, top-right, bottom-left, bottom-right: straight length along the top or bottom wall, along the side wall (lead ~40; bottom side legs longer to reach past the joint)
rod_end_clear = 1.0;     // mm, groove longer than its rod at each end (design)
rod_mag_clear = 8;       // mm, rod surface to magnet edge (lead)
recess_floor_min = 0.6;  // mm, thinnest back plate allowed under a recess (lead: battery 0.6)
rod_ant_clear = 10;      // mm, rod to antenna reservation (lead)

/* [Screws and inserts] */
m3_insert = [4.0, 4.0];  // mm, M3 heat-set insert hole D x depth (4 mm long insert)
m3_clear_d = 3.4;        // mm, M3 clearance hole (ISO 273 medium)
m3_csk_d = 6.8;          // mm, countersink for M3 flat head (ISO 10642 / DIN 7991)
m3_screw_len = 6;        // mm, M3 x 6 countersunk (design for the thin case)
m3_tip_clear = 0.5;      // mm, clearance beyond the screw tip (design)
m3_boss_d = 7.2;         // mm (design)
m3_boss_inset = 5.0;     // mm, boss centre from the outer edge (design: keeps the insert below the 45 deg boss caps)
m3_side_y = [40, -40];   // mm, Y of the side-rail bosses, both sides (lead)
m3_bottom_x = 60;        // mm, |X| of the two bottom-wall bosses (lead)
m3_chin_corner = [101.5, -89.5]; // mm, [|X|, Y] of the chin's corner bosses, moved inside the L-rods (design)
m3_top_x = [-60];        // mm, X of the top-rail bosses (design: the rods take the corners; none right: antenna keep-out)
boss_floor = 1.0;        // mm, solid end beyond blind holes (design)
boss_panel_clear = 0.3;  // mm, boss fronts behind the panel's back (design)
m25_insert = [3.6, 4.2]; // mm, M2.5 heat-set insert hole D x depth (typical 4 mm insert)
m25_clear_d = 2.9;       // mm, M2.5 clearance hole (ISO 273 medium)
m25_csk_d = 5.0;         // mm, countersink for M2.5 flat head (ISO 10642)
m25_nut = [5.0, 2.0];    // mm, M2.5 nut across flats x height (ISO 4032)

/* [Panel support ribs] */
rib_t = 1.6;             // mm, rib web thickness (design)
rib_pad = 4.0;           // mm, rib top pad for the foam strips (design)
rib_pad_t = 0.8;         // mm, pad thickness above the 45 deg flare (design)
rib_inset = 2.7;         // mm, perimeter rib centre inside the panel edge (design: pads keep rib_keep from the bezel's rod blocks)
rib_mid_y = 36;          // mm, Y of the horizontal interior rib (design; the lower rod replaces the one at -35)
rib_mid_x = [-45, 45];   // mm, X of the two vertical ribs in the upper corners (design)
rib_gap_wire = 10;       // mm, gap in the interior rib where the wires pass (design)
rib_gap_bat = [7, 12];   // mm, [X centre, width] of the gap in the interior rib for the battery lead and its plug (design)
rib_keep = 1.0;          // mm, rib clearance around bosses, rods and modules (design)

/* [Wire route] */
wire_x = -30;            // mm, button wires run up the back cover here, between driver and battery (lead: >= 4 mm from the back seam)
wire_ties_y = [-25, 15, 52]; // mm, zip-tie points (design: none inside the FPC zone or the strip recess)
tie_size = [8, 5, 4];    // mm, tie block X x Y x Z (design)
tie_slot = [3.2, 1.8];   // mm, tunnel for a 2.5 mm zip tie, Y x Z (design)

/* [Desk stand] */
stand_tilt = 15;         // deg, frame leans back from vertical (spec ~15)
stand_w = 100;           // mm, stand width (design)
stand_t = 4;             // mm, back rest and lip thickness (design)
stand_rest_h = 70;       // mm, back rest length along the frame (design)
stand_lip_h = 5;         // mm, front lip length along the frame (design: below the buttons)
stand_seat_h = 6;        // mm, seat height at the back corner (design)
stand_foot = 50;         // mm, foot length behind the seat (design: keeps the centre of mass inside)
stand_brace_h = 30;      // mm, where the rear brace meets the back rest (design)
stand_clear = 0.6;       // mm, seat width beyond the frame depth (design)

/* [Text] */
logo_text = "brwr-trmnl"; // engraved on the back cover (spec)
logo_size = 7;           // mm (design)
logo_depth = 0.4;        // mm (design)
logo_pos = [0, -58];     // mm, centre, front-view coordinates (design: on full-thickness plate)
text_font = "Liberation Sans:style=Bold"; // any installed font

/* [Rendering] */
use_stl = false;         // import the STLs in stl/ instead of rebuilding them (fast previews)
upright = false;         // stand the scene up (+Y becomes +Z) for PNG cameras
explode_gap = 40;        // mm, layer spacing in the exploded view
explode_side = 30;       // mm, how far split pieces move apart sideways in the exploded view
show_labels = true;      // module names in the inside and fit_check views
show_rods = true;        // steel rods in the assembly views
layer_h = 0.2;           // mm, print layer height
$fa = 4;
$fs = 0.4;

/* [Hidden] */
eps = 0.01;
min_r = 0.1;
corner_segments = 12;    // segments per 90 deg of a rounded rectangle corner
fn_button = 96;          // segments for all coaxial button circles (bore, seat, sleeve, cap)
fn_screw = 32;           // segments for countersinks and their clearance holes
clash_shrink = 0.05;     // mm, envelopes pulled in so parts that only touch do not count as clashes
cut_over = 1;            // mm, how far cutting tools reach past the surface they cut
rod_arc_segments = 24;   // segments of a bezel rod groove's 90 deg bend
boss_cap_reach = 20;     // mm, how far the 45 deg boss caps reach into the pocket outline
face_step = 0.2;         // mm, boss caps and rod blocks stop this far outside the pocket edge (no faces shared with the pocket)
face_stagger = 0.02;     // mm, and each one a little further (features ending on one line make the exporter emit zero-area triangles)

// illustration only (renders and fit check), not used for printed geometry
sym_tri_base = 0.4;      // triangle symbol: base position, fraction of symbol_size
sym_dot = 0.8;           // circle symbol: diameter, fraction of symbol_size
drv_chip = [14, 14, 1.4];            // mm, IT8951 package on the driver HAT
car_modules = [                      // [X centre, Y below top edge, size, colour]
  [usb_x[1], 13, [17, 26, 1.6], "#2c6e4f"],     // TP4056 USB-C charger module, soldered flat
  [-24.5, 25, [11.5, 18, 1.6], "#26282b"],      // MiniBoost 5 V, flat
  [-11, 27, [3.2, 1.6, 1.6], "#8a6d3b"]];       // ceramic capacitor
xiao_shield = [12, 11, 2.2];         // mm, XIAO RF shield can
coax_via = [[36, 90], [5, 82]];      // mm, where the coax runs over the carrier (builder's choice)
fpc_fold_h = 18;                     // mm, folded flex visible behind the panel
fpc_adapter_x = -25;                 // mm, adapter board centre X in the flex zone
mock_margin = 8;                     // mm, screen mock inset from the window
mock_ink = [                         // [x, y, w, h] as fractions of the mock area, dark
  [0, 0.86, 0.42, 0.07], [0.83, 0.86, 0.17, 0.07], [0, 0.40, 0.36, 0.33]];
mock_grey = [                        // same, mid grey
  [0.40, 0.66, 0.60, 0.07], [0.40, 0.54, 0.48, 0.07], [0.40, 0.42, 0.54, 0.07],
  [0, 0, 0.32, 0.27], [0.34, 0, 0.32, 0.27], [0.68, 0, 0.32, 0.27]];
explode_z = [-0.6, 0, 0.5, 1.2, 1.2, 1.8, 2.5];   // x explode_gap: pads, back, magnets, panel, strip, caps, bezel
img_label = 5;                       // mm, text size of module labels
plate_label = 8;                     // mm, text size of part names in the plates view
plate_narrow = 40;                   // mm, parts narrower (or lower) than this get their name turned (or below)
plate_spacing = 50;                  // mm, gap between bed outlines in the plates view
ring_w = 0.8;                        // mm, width of the magnet keep-out rings

// ---- Z levels --------------------------------------------------------
z_in = back_t;                                   // back cover inner face = bezel back edge
z_lip = depth - front_t;                         // back face of the front plate (window lip)
z_panel_front = z_lip - gasket_t;
z_panel_back = z_panel_front - panel_t;
z_pocket = z_lip - pocket_depth;                 // pocket floor, seen from behind
z_rib_top = z_panel_back - (back_foam_t - back_foam_squeeze);
z_boss_cap = z_panel_back - boss_panel_clear;    // boss fronts where they reach under the panel

// ---- outline and panel -----------------------------------------------
in_w = outer_w - 2 * wall_t;
in_h = outer_h - 2 * wall_t;
panel_top = outer_h / 2 - border_top;
panel_bot = panel_top - panel_h;
panel_c = [0, (panel_top + panel_bot) / 2];
pocket_size = [panel_w + 2 * pocket_clear, panel_h + 2 * pocket_clear];
pocket_top = panel_top + pocket_clear;
pocket_bot = panel_bot - pocket_clear;
pocket_edge = panel_c + pocket_size / 2;          // +X and +Y pocket edges, as pocket_rect() computes them
win_size = [panel_w - 2 * border_side, panel_h - border_side - border_bottom];
win_c = [0, (panel_top - border_side + panel_bot + border_bottom) / 2];
win_top = win_c[1] + win_size[1] / 2;            // the rail joints run level with the window's
win_bot = win_c[1] - win_size[1] / 2;            // top and bottom edges
chin_h = panel_bot + outer_h / 2;

// ---- driver board ----------------------------------------------------
z_drv_pcb = z_in + drv_standoff_h;
z_drv_top = z_drv_pcb + drv_pcb_t + drv_comp_h;
drv_lo = drv_pos - drv_size / 2;
drv_hi = drv_pos + drv_size / 2;
drv_holes = [for (sx = [-1, 1], sy = [-1, 1])
  drv_pos + [sx * (drv_size[0] / 2 - drv_hole_inset), sy * (drv_size[1] / 2 - drv_hole_inset)]];
drv_stub_y = drv_pos[1] + drv_size[1] / 2 - drv_hole_inset;   // the old header row
z_drv_nut = z_drv_pcb + drv_pcb_t + m25_nut[1];

// ---- carrier board ---------------------------------------------------
car_top = in_h / 2;                              // top edge against the top wall
car_lo = [-car_size[0] / 2, car_top - car_size[1]];
car_hi = [car_size[0] / 2, car_top];
z_car_pcb = car_floor + car_ledge_h;             // board underside
z_car_top = z_car_pcb + car_pcb_t;
z_usb = [for (z = usb_zc) z_car_top + z];        // receptacle and slot centres
car_screw_pos = [for (s = car_screws) [s[0], car_lo[1] + s[1]]];
car_tray_x = car_size[0] / 2 + car_clear + car_tray_wall;
car_rec_lo = [car_lo[0] - car_clear, car_lo[1] - car_clear];   // recess under the board
car_rec_hi = [car_hi[0] + car_clear, car_top];
ufl_pos = [usb_x[0], car_top - ufl_from_top];
z_ufl = z_car_top + xiao_t + ufl_plug_h;

// ---- antenna ---------------------------------------------------------
z_ant = [z_pocket - ant_top_clear - ant_h, z_pocket - ant_top_clear];   // under the bezel's pocket rim
ant_fin_lo = [ant_x[0], in_h / 2 - ant_wall_gap - ant_fin_t, back_t - eps];
ant_fin_hi = [ant_x[1], in_h / 2 - ant_wall_gap, z_ant[1]];
ant_lo = [ant_x[0], ant_fin_lo[1] - ant_t, z_ant[0]];             // the FPC itself, on the fin's inner face
ant_hi = [ant_x[1], ant_fin_lo[1], z_ant[1]];
ant_res_lo = ant_lo;                                               // reservation: the FPC, the fin and the
ant_res_hi = [ant_x[1], in_h / 2, z_ant[1]];                       // gap to the wall
coax_path = concat(
  [[ant_x[0] + ant_feed_dx, ant_lo[1] - coax_d / 2, (z_ant[0] + z_ant[1]) / 2]],
  [for (v = coax_via) [v[0], v[1], coax_z]],
  [[ufl_pos[0], ufl_pos[1], z_ufl]]);

// ---- battery ---------------------------------------------------------
bat_in = [bat_size[0] + 2 * bat_clear, bat_size[1] + 2 * bat_clear];
bat_out = bat_in + 2 * [bat_wall_t, bat_wall_t];
z_bat = [bat_floor + bat_foam_t, bat_floor + bat_foam_t + bat_size[2]];

// ---- buttons ---------------------------------------------------------
z_sleeve_end = z_lip - sleeve_len;
seat_h = (cap_flange_d - cap_hole_d) / 2;        // 45 deg conical seat
z_cap_face = depth + cap_proud;
z_cap_back = z_sleeve_end - cap_flange_t;
cap_len = z_cap_face - z_cap_back;
z_plunger_top = z_cap_back + cap_preload;        // free (uncompressed) plunger top
cap_stroke = max(-cap_preload, 0) + sw_travel;   // cap travel to the click
z_strip_front = z_plunger_top - sw_h;
z_strip_back = z_strip_front - strip_t;
z_strip_joints = z_strip_back - strip_solder_h;
z_strip_floor = min(z_in, z_strip_joints - strip_joint_clear);   // back plate under the strip
strip_lo = [-strip_size[0] / 2, btn_y - strip_size[1] / 2];
strip_hi = [strip_size[0] / 2, btn_y + strip_size[1] / 2];

// ---- magnets ---------------------------------------------------------
mag_pocket_d = mag_d + mag_clear;
mag_boss_d = mag_pocket_d + 2 * mag_wall;
z_mag = [mag_skin, mag_skin + mag_h];
z_steel = [z_mag[1], z_mag[1] + steel_disc[1]];
z_mag_epoxy = z_steel[1] + mag_epoxy;            // epoxy fill level in the pocket
z_mag_boss = z_rib_top;                          // the pocket's tube carries a foam pad under the panel

function face_off(k) = face_step + k * face_stagger;   // k: boss index, then len(m3_pos) + rod corner index

// ---- M3 bosses (bezel) ------------------------------------------------
m3_cx = outer_w / 2 - m3_boss_inset;
m3_cy = outer_h / 2 - m3_boss_inset;
m3_pos = [
  each [for (y = m3_side_y, s = [-1, 1]) [s * m3_cx, y]],                  // side rails
  [-m3_bottom_x, -m3_cy], [m3_bottom_x, -m3_cy],                          // chin, bottom wall
  [-m3_chin_corner[0], m3_chin_corner[1]], [m3_chin_corner[0], m3_chin_corner[1]],   // chin corners
  each [for (x = m3_top_x) [x, m3_cy]]];                                 // top rail
z_m3_hole = max(z_in + m3_insert[1], m3_screw_len + m3_tip_clear);
z_m3_floor = z_m3_hole + boss_floor;

// ---- ribs --------------------------------------------------------------
rib_px = panel_w / 2 - rib_inset;
rib_ty = panel_top - rib_inset;
rib_by = panel_bot + rib_inset;
rib_car_x = car_tray_x + rib_keep;
rib_segments = [
  [[-rib_px, rib_by], [-rib_px, rib_ty]],                  // left edge (the bottom edge is left to the magnet tubes)
  [[rib_px, rib_by], [rib_px, rib_ty]],                    // right edge
  [[-rib_px, rib_ty], [-rib_car_x, rib_ty]],               // top edge, left of the carrier
  [[rib_car_x, rib_ty], [rib_px, rib_ty]],                 // top edge, right of the carrier
  [[-rib_px, rib_mid_y], [rib_px, rib_mid_y]],             // above driver board and battery
  [[rib_mid_x[0], rib_mid_y], [rib_mid_x[0], rib_ty]],     // upper left
  [[rib_mid_x[1], rib_mid_y], [rib_mid_x[1], rib_ty]]];    // upper right
// the coax crosses the top rib where its first leg crosses rib_ty
coax_notch_x = let(a = coax_path[0], b = coax_path[1]) a[0] + (b[0] - a[0]) * (a[1] - rib_ty) / (a[1] - b[1]);
coax_notch_z = let(a = coax_path[0], b = coax_path[1]) a[2] + (b[2] - a[2]) * (a[1] - rib_ty) / (a[1] - b[1]);

// ---- steel rods ----------------------------------------------------------
rod_cc = [outer_w / 2 - corner_r, outer_h / 2 - corner_r];   // outline corner centre, +X +Y corner
rod_R = corner_r - rod_skin - rod_slot / 2;       // bend radius of the bezel rods (centreline)
rod_sx = rod_cc[0] + rod_R;                       // side legs: centreline |X|
rod_ty = rod_cc[1] + rod_R;                       // top and bottom legs: centreline |Y|
rod_z = [z_lip - rod_slot, z_lip];                // bezel grooves: rod block from rod_z[0], floor at rod_z[1]
rod_zc = z_lip - rod_slot / 2;                    // bezel rods: centreline Z
rod_corners = [[-1, 1], [1, 1], [-1, -1], [1, -1]];   // same order as rod_legs
rod_back_zc = z_in - rod_back_sink + rod_d / 2;   // back cover rods: centreline Z
// straight leg lengths [along the top or bottom wall, along the side wall];
// a rod on the antenna side stops rod_ant_clear short of the antenna
function rod_leg(i) = let(s = rod_corners[i])
  [s[1] > 0 && s[0] * (ant_x[0] + ant_x[1]) > 0 ? min(rod_legs[i][0], rod_cc[0] - max(abs(ant_x[0]), abs(ant_x[1])) - rod_ant_clear)
                                                 : rod_legs[i][0], rod_legs[i][1]];
function rod_len(i) = rod_leg(i)[0] + rod_leg(i)[1] + PI / 2 * rod_R;   // developed length

// ---- split ------------------------------------------------------------
lip_gap_x0 = split ? min(-rib_car_x, back_split_x) : -rib_car_x;   // top lip gap starts here
wall_mid_x = in_w / 2 + wall_t / 2;              // |X| where the wall half-lap changes sides
back_seam_out = back_split_x - (back_t - 2 * scarf_land);   // back cover seam on its outside face
caps_span = len(btn_x) * cap_flange_d + (len(btn_x) - 1) * print_gap;
side_in_x = min(win_size[0] / 2, m3_cx - m3_boss_d / 2);   // inner edge of a side rail
function stand_profile() =
  // desk stand cross-section (u = forward, v = up); the frame sits on s0..s1
  let(u = [-sin(stand_tilt), cos(stand_tilt)], v = [cos(stand_tilt), sin(stand_tilt)],
      s0 = [0, stand_seat_h], s1 = s0 + (depth + pad[1] + stand_clear) * v, s2 = s1 + stand_lip_h * u,
      s3 = s2 + stand_t * v, s4 = s1 + stand_t * v, f = [s4[0] + s4[1], 0],
      r0 = s0 + stand_rest_h * u, r1 = r0 - stand_t * v,
      k = r1 - ((r1[1] - stand_brace_h) / cos(stand_tilt)) * u, b = [-stand_foot, 0])
  [b, f, s4, s3, s2, s1, s0, r0, r1, k];
stand_y = [min([for (p = stand_profile()) p[0]]), max([for (p = stand_profile()) p[0]])];
stand_h = max([for (p = stand_profile()) p[1]]);

// ---- print layout --------------------------------------------------------
function rot2(a, p) = [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a)];
function is_bezel_part(name) = name == "bezel" || name == "bezel_top" || name == "bezel_bottom" ||
                               name == "bezel_left" || name == "bezel_right";
function part_angle(name) = (name == "bezel_top" || name == "bezel_bottom") ? rail_angle : 0;
function box_pts(lo, hi) = [lo, [hi[0], lo[1]], hi, [lo[0], hi[1]]];
function model_footprint(name) =
  // front-view points whose convex hull holds the part's footprint
  let(arcs = rrect_pts([outer_w, outer_h], corner_r))
  name == "bezel_top" ? concat([for (p = arcs) if (p[1] >= win_top) p],
      [[-outer_w / 2, win_top], [outer_w / 2, win_top], [-wall_mid_x, win_top - bezel_lap], [wall_mid_x, win_top - bezel_lap]]) :
  name == "bezel_bottom" ? concat([for (p = arcs) if (p[1] <= win_bot) p],
      [[-outer_w / 2, win_bot], [outer_w / 2, win_bot], [-wall_mid_x, win_bot + bezel_lap], [wall_mid_x, win_bot + bezel_lap]]) :
  name == "bezel_left" ? box_pts([-outer_w / 2, win_bot], [-side_in_x, win_top]) :
  name == "bezel_right" ? box_pts([side_in_x, win_bot], [outer_w / 2, win_top]) :
  name == "back_left" ? box_pts([-outer_w / 2, -outer_h / 2], [back_split_x + back_tab[0], outer_h / 2]) :
  name == "back_right" ? box_pts([back_seam_out, -outer_h / 2], [outer_w / 2, outer_h / 2]) :
  name == "button_caps" ? box_pts([-caps_span / 2, -cap_flange_d / 2], [caps_span / 2, cap_flange_d / 2]) :
  name == "stand" ? box_pts([-stand_w / 2, stand_y[0]], [stand_w / 2, stand_y[1]]) :
  box_pts([-outer_w / 2, -outer_h / 2], [outer_w / 2, outer_h / 2]);          // one-piece bezel and back
// the same points as the part lies in its STL (bezel parts face-down, turned by part_angle)
function print_pts(name) = [for (p = model_footprint(name)) rot2(part_angle(name), is_bezel_part(name) ? [-p[0], p[1]] : p)];
function pts_bbox(pts) = [[min([for (p = pts) p[0]]), min([for (p = pts) p[1]])],
                          [max([for (p = pts) p[0]]), max([for (p = pts) p[1]])]];
function print_bbox(name) = pts_bbox(print_pts(name));
function fp(name) = print_bbox(name)[1] - print_bbox(name)[0];
printed_parts = split ? ["bezel_top", "bezel_bottom", "bezel_left", "bezel_right", "back_left", "back_right", "button_caps", "stand"]
                      : ["bezel", "back", "button_caps", "stand"];
function plate_layout(j) =
  // print jobs on the bed: [part, lower-left corner of its footprint inside the usable area]
  let(u = bed_size - 2 * [bed_margin, bed_margin], g = plate_gap)
  j == 0 ? [["bezel_bottom", (u - fp("bezel_bottom")) / 2], ["button_caps", [u[0] - fp("button_caps")[0], 0]]] :
  j == 1 ? [["bezel_top", (u - fp("bezel_top")) / 2], ["bezel_left", [0, u[1] - fp("bezel_left")[1]]],
            ["bezel_right", [u[0] - fp("bezel_right")[0], 0]]] :
  j == 2 ? [["back_right", (u - fp("back_right")) / 2]] :
  let(w = fp("back_left")[0] + g + fp("stand")[0], x0 = (u[0] - w) / 2)
    [["back_left", [x0, (u[1] - fp("back_left")[1]) / 2]], ["stand", [x0 + fp("back_left")[0] + g, (u[1] - fp("stand")[1]) / 2]]];
plate_titles = ["Print 1: bezel_bottom + button caps", "Print 2: bezel_top + side rails", "Print 3: back_right", "Print 4: back_left + stand"];
function placed_pts(q) = let(bb = print_bbox(q[0])) [for (p = print_pts(q[0])) p - bb[0] + q[1]];
function proj(pts, a) = [for (p = pts) p[0] * cos(a) + p[1] * sin(a)];
function axis_gap(A, B, a) = let(pa = proj(A, a), pb = proj(B, a)) max(min(pb) - max(pa), min(pa) - max(pb));
function sep_gap(A, B) = max([for (a = [0, 45, 90, 135]) axis_gap(A, B, a)]);   // lower bound on the distance

// ---- colours -------------------------------------------------------------
c_bezel = "#34383d";
c_bezel_side = "#484e56";                               // render-only tint so the joints read
c_back = "#6f7882";
c_back_left = "#838d97";                                // render-only tint
c_cap = "#e7e3db";
c_panel = "#dedcd4";
c_ink = "#3e3f42";
c_ink2 = "#9d9a92";
c_magnet = "#b9bdc2";
c_pad = "#161616";
c_rod = "#9aa1a8";
c_drv = "#2c6e4f";
c_car = "#c8a468";
c_bat = "#b8c2cc";
c_ant = "#d08a1e";
c_fpc = "#d9a032";
c_switch = "#26282b";
c_metal = "#a9adb2";
c_foam = "#57595c";
c_stand = "#8f949a";
c_car_env = "#3b6fb6";
c_strip_env = "#8e44ad";
c_keepout = "#c0392b";
c_bed = "#9aa0a6";
c_bed_fill = "#eeeeec";

// =====================================================================
// Top level
// =====================================================================
design_checks();

if (upright) rotate([90, 0, 0]) main(); else main();

module main() {
  if (part == "assembly") scene_assembly();
  else if (part == "exploded") scene_exploded();
  else if (part == "inside") scene_inside();
  else if (part == "fit_check") scene_fit_check();
  else if (part == "clash") scene_clash();
  else if (part == "plates") scene_plates();
  else print_part(part);
}

// =====================================================================
// 2D and 3D helpers
// =====================================================================
function rrect_pts(size, r, n = corner_segments) = [
  // rounded rectangle as explicit points: the same vertex count for every size,
  // so hulls between two of them give clean faces (no sliver triangles)
  for (c = [[1, 1, 0], [-1, 1, 90], [-1, -1, 180], [1, -1, 270]])
    for (i = [0 : n])
      [c[0] * (size[0] / 2 - r) + r * cos(c[2] + 90 * i / n),
       c[1] * (size[1] / 2 - r) + r * sin(c[2] + 90 * i / n)]];

module rrect(size, r) {
  // rounded rectangle centred on the origin
  polygon(rrect_pts(size, max(r, min_r)));
}

module outline(inset = 0) {
  rrect([outer_w - 2 * inset, outer_h - 2 * inset], max(corner_r - inset, min_r));
}

module slab(inset, z0, z1) {
  translate([0, 0, z0]) linear_extrude(z1 - z0) outline(inset);
}

module slab_down(inset, z0, z1) {
  // the same, built down from z1 so its top face lies exactly on z1
  translate([0, 0, z1]) mirror([0, 0, 1]) linear_extrude(z1 - z0) outline(inset);
}

module chamfered_body(z0, z1, c_bot, c_top) {
  // outline prism with 45 deg chamfers on its bottom and top outer edges; its
  // faces lie exactly on z0 and z1, so parts that meet there only touch
  hull() {
    slab(c_bot, z0, z0 + eps);
    slab(0, z0 + c_bot, z1 - c_top);
    slab_down(c_top, z1 - eps, z1);
  }
}

module box(lo, hi) {
  // axis-parallel box with its corners exactly on lo and hi (translate(lo)
  // cube(hi - lo) can miss hi by a rounding step, and faces that should meet
  // then end up a hair apart)
  polyhedron(points = [[lo[0], lo[1], lo[2]], [hi[0], lo[1], lo[2]], [hi[0], hi[1], lo[2]], [lo[0], hi[1], lo[2]],
                       [lo[0], lo[1], hi[2]], [hi[0], lo[1], hi[2]], [hi[0], hi[1], hi[2]], [lo[0], hi[1], hi[2]]],
             faces = [[0, 1, 2, 3], [4, 5, 1, 0], [7, 6, 5, 4], [5, 6, 2, 1], [6, 7, 3, 2], [7, 4, 0, 3]]);
}

module through_top_wall(y0 = in_h / 2 - eps, y1 = outer_h / 2 + eps) {
  // extrude a 2D profile drawn in (X, Z) through the top wall along Y
  translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
}

module rib_profile() {
  // rib cross-section (u across, v = Z): web, 45 deg flare, flat pad for foam
  z2 = z_rib_top - rib_pad_t;
  z1 = z2 - (rib_pad - rib_t) / 2;
  polygon([[-rib_t / 2, z_in - eps], [rib_t / 2, z_in - eps], [rib_t / 2, z1],
           [rib_pad / 2, z2], [rib_pad / 2, z_rib_top], [-rib_pad / 2, z_rib_top],
           [-rib_pad / 2, z2], [-rib_t / 2, z1]]);
}

module rib(a, b) {
  // axis-parallel rib from a to b (2D points)
  if (abs(b[1] - a[1]) < eps)
    translate([min(a[0], b[0]), a[1], 0]) rotate([90, 0, 90])
      linear_extrude(abs(b[0] - a[0])) rib_profile();
  else
    translate([a[0], max(a[1], b[1]), 0]) rotate([90, 0, 0])
      linear_extrude(abs(b[1] - a[1])) rib_profile();
}

module label(txt, size, h = 2 * eps, halign = "center") {
  // flat text, readable from the front (+Z)
  linear_extrude(h) text(txt, size = size, font = text_font, halign = halign, valign = "center");
}

module pocket_rect(shrink = 0) {
  translate(panel_c) square(pocket_size - 2 * [shrink, shrink], center = true);
}

// =====================================================================
// Bezel: front face, window, panel pocket, walls, bosses, rod grooves
// =====================================================================
module bezel() {
  difference() {
    union() {
      bezel_shell();
      pocket_rim();
      button_sleeves();
      strip_bosses();
      m3_bosses();
      rod_blocks();
    }
    window_cut();
    pocket_cut();
    flex_relief_cut();
    button_bores();
    strip_insert_holes();
    m3_insert_holes();
    usb_notches();
    usb_labels();
    rod_grooves();
  }
}

module bezel_shell() {
  difference() {
    chamfered_body(z_in, depth, seam_chamfer, front_chamfer);
    slab(wall_t, z_in - eps, z_lip);
  }
}

module window_cut() {
  // window = panel minus the covered border: a straight land at the back,
  // then a 45 deg chamfer that opens toward the front face
  z_ch = z_lip + window_land;
  translate([win_c[0], win_c[1], z_lip - eps]) linear_extrude(window_land + 2 * eps) rrect(win_size, window_r);
  // the cone ends exactly on the front face, so no facet is cut there
  translate([win_c[0], win_c[1], 0]) hull() {
    translate([0, 0, z_ch]) linear_extrude(eps) rrect(win_size, window_r);
    translate([0, 0, depth]) linear_extrude(eps)
      rrect(win_size + 2 * [1, 1] * window_chamfer, window_r + window_chamfer);
  }
}

module pocket_2d() {
  pocket_rect();
  translate(panel_c) for (sx = [-1, 1], sy = [-1, 1])
    translate([sx * pocket_size[0] / 2, sy * pocket_size[1] / 2]) circle(d = pocket_relief_d);
}

module pocket_rim() {
  // fills the cavity around the pocket (left, right, top) and a narrow rim below
  // it; pocket_cut() then removes the pocket itself (cut once, so no slivers)
  translate([0, 0, z_pocket]) linear_extrude(z_lip - z_pocket + eps)
    intersection() {
      outline(wall_t - eps);
      translate([-outer_w / 2, pocket_bot - pocket_rim_b]) square([outer_w, outer_h]);
    }
}

module pocket_cut() {
  translate([0, 0, z_pocket - eps]) linear_extrude(z_lip - z_pocket + eps) pocket_2d();
}

module flex_relief_cut() {
  // the flex bends 180 deg around the panel's bottom edge: keep this strip clear
  box([-fpc_relief_w / 2, pocket_bot - fpc_relief_d, z_in - eps], [fpc_relief_w / 2, pocket_bot + eps, z_lip]);
}

module antenna_fin() {
  // the antenna sticks to its inner face; the coax leaves its -X end towards the XIAO
  box(ant_fin_lo, ant_fin_hi);
}

module button_sleeves() {
  // sleeve with a local thickening around the keyway (at -Y), as one 2D
  // outline extruded once: a 3D union of the two left near-duplicate
  // vertices on the seat circle in the STL
  for (x = btn_x) translate([x, btn_y, z_sleeve_end]) linear_extrude(sleeve_len + eps) {
    circle(d = sleeve_od, $fn = fn_button);
    translate([-(key_size[0] / 2 + key_clear + key_boss_wall), -(keyway_r() + key_boss_wall)])
      square([key_size[0] + 2 * (key_clear + key_boss_wall), keyway_r() + key_boss_wall - cap_hole_d / 2 + key_boss_wall]);
  }
}

function keyway_r() = cap_d / 2 + key_size[1] + key_clear;

module button_bores() {
  for (x = btn_x) translate([x, btn_y, 0]) {
    translate([0, 0, z_sleeve_end - eps]) cylinder(d = cap_hole_d, h = depth - z_sleeve_end + 2 * eps, $fn = fn_button);
    // 45 deg seat for the cap's conical flange, starting exactly on the sleeve end
    translate([0, 0, z_sleeve_end]) cylinder(d1 = cap_flange_d, d2 = cap_hole_d, h = seat_h, $fn = fn_button);
    // keyway, sleeve only (the front face shows a plain round hole)
    translate([-(key_size[0] / 2 + key_clear), -keyway_r(), z_sleeve_end - eps])
      cube([key_size[0] + 2 * key_clear, keyway_r(), sleeve_len + eps]);
  }
}

module strip_bosses() {
  for (x = strip_screw_x) translate([x, btn_y, z_strip_front])
    cylinder(d = strip_boss_d, h = z_lip - z_strip_front + eps);
}

module strip_insert_holes() {
  for (x = strip_screw_x) translate([x, btn_y, z_strip_front - eps])
    cylinder(d = m25_insert[0], h = m25_insert[1] + eps);
}

module m3_boss_2d(p) {
  // footprint of a bezel boss (used for clearances on the back cover)
  translate(p) circle(d = m3_boss_d);
}

module m3_bosses() {
  // columns from the back edge to the front plate; where one reaches under
  // the panel its front drops at 45 deg from boss_panel_clear behind the
  // panel, so it prints face-down without supports
  for (k = [0 : len(m3_pos) - 1]) difference() {
    translate([m3_pos[k][0], m3_pos[k][1], z_in]) cylinder(d = m3_boss_d, h = z_lip - z_in + eps);
    hull() {
      translate([0, 0, z_boss_cap]) linear_extrude(depth - z_boss_cap) pocket_rect(-face_off(k));
      translate([0, 0, z_boss_cap - boss_cap_reach]) linear_extrude(eps) pocket_rect(boss_cap_reach - face_off(k));
    }
  }
}

module m3_insert_holes() {
  for (p = m3_pos) translate([p[0], p[1], z_in - eps]) {
    cylinder(d = m3_insert[0], h = m3_insert[1] + eps);
    cylinder(d = m3_clear_d, h = z_m3_hole - z_in + eps);
  }
}

module usb_slot_2d(i, grow = 0) {
  translate([usb_x[i], z_usb[i]]) offset(r = grow) rrect(usb_slot, usb_slot_r);
}

module usb_notches() {
  // slot for each plug, open toward the back edge so the carrier can drop in
  // with the back cover; the back cover's tongue closes the lower part
  for (i = [0 : len(usb_x) - 1]) through_top_wall() {
    usb_slot_2d(i);
    translate([usb_x[i] - usb_slot[0] / 2, z_in - cut_over]) square([usb_slot[0], z_usb[i] - z_in + cut_over]);
  }
}

module usb_labels() {
  // engraved in the top wall beside the slots, read from above with the front
  // toward you (each label on its own baseline: collinear baselines across
  // labels make the exporter emit zero-area triangles)
  for (i = [0 : len(usb_x) - 1]) {
    x = usb_x[i] + (i == 0 ? -1 : 1) * (usb_slot[0] / 2 + label_gap);
    translate([x, outer_h / 2 - label_depth, z_usb[i] + i * label_stagger]) rotate([-90, 0, 0])
      linear_extrude(label_depth + cut_over)
        text(usb_label[i], size = label_size, font = text_font, halign = i == 0 ? "right" : "left", valign = "center");
  }
}

// ---- bezel rod grooves: an L-rod in each corner, along the top or bottom
// wall and the side wall, across the rail joint. Canonical shapes are drawn
// for the +X +Y corner and mirrored.
function rod_groove_pts(l) =
  // groove outline around the rod centreline, rod_end_clear longer at both ends
  let(h = rod_slot / 2, n = rod_arc_segments, y_end = rod_cc[1] - l[1] - rod_end_clear, x_end = rod_cc[0] - l[0] - rod_end_clear)
  [[rod_sx + h, y_end],
   for (k = [0 : n]) rod_cc + (rod_R + h) * [cos(90 * k / n), sin(90 * k / n)],
   [x_end, rod_ty + h], [x_end, rod_ty - h],
   for (k = [n : -1 : 0]) rod_cc + (rod_R - h) * [cos(90 * k / n), sin(90 * k / n)],
   [rod_sx - h, y_end]];

module corner_mirror(s) {
  mirror([s[0] < 0 ? 1 : 0, 0, 0]) mirror([0, s[1] < 0 ? 1 : 0, 0]) children();
}

module rod_blocks() {
  // the strip between the pocket (or its line) and the wall, filled from the
  // rod groove's back to the front plate along each rod; the groove is cut
  // into it and into the wall, open toward the back
  for (i = [0 : len(rod_corners) - 1]) corner_mirror(rod_corners[i]) {
    l = rod_leg(i);
    web_end = rod_end_clear + rod_web;
    y0 = rod_cc[1] - l[1] - web_end;
    x0 = rod_cc[0] - l[0] - web_end;
    f = face_off(len(m3_pos) + i);
    // inner edges a little outside the pocket's edges, each block its own offset
    translate([0, 0, rod_z[0]]) linear_extrude(z_lip - rod_z[0] + eps) {
      translate([pocket_edge[0] + f, y0]) square([in_w / 2 + eps - pocket_edge[0] - f, in_h / 2 + eps - y0]);
      translate([x0, pocket_edge[1] + f]) square([in_w / 2 + eps - x0, in_h / 2 + eps - pocket_edge[1] - f]);
    }
  }
}

module rod_grooves() {
  for (i = [0 : len(rod_corners) - 1]) corner_mirror(rod_corners[i])
    translate([0, 0, z_in - cut_over]) linear_extrude(rod_z[1] - z_in + cut_over) polygon(rod_groove_pts(rod_leg(i)));
}

// =====================================================================
// Back cover: plate, recesses, magnet tubes, standoffs, tray, ribs, rods
// =====================================================================
module back_cover() {
  difference() {
    union() {
      difference() {
        union() {
          chamfered_body(0, back_t, back_chamfer, seam_chamfer);
          locating_lip();
          usb_tongues();
          driver_standoffs();
          carrier_tray_rim();
          battery_cradle();
          magnet_bosses();
          rod_channel_walls();
          wire_ties();
          ribs();
          antenna_fin();
        }
        carrier_recess();
        battery_recess();
        strip_recess();
      }
      carrier_ledges();
    }
    magnet_pockets();
    m3_screw_holes();
    csk_holes([for (h = drv_holes) h], z_drv_pcb);
    csk_holes(car_screw_pos, z_car_pcb);
    rod_back_grooves();
    back_logo();
  }
}

module locating_lip() {
  translate([0, 0, back_t - eps]) linear_extrude(lip_h + eps)
    difference() {
      outline(wall_t + lip_clear);
      outline(wall_t + lip_clear + lip_t);
      for (p = m3_pos) offset(delta = lip_clear) m3_boss_2d(p);
      // the carrier and the antenna sit against the top wall (with a split
      // back, the gap starts at the seam so no stub of lip is left), the
      // button strip against the bottom wall
      translate([lip_gap_x0, in_h / 2 - 2 * lip_t - wall_t]) square([ant_x[1] + rib_keep - lip_gap_x0, 3 * wall_t]);
      translate([strip_lo[0] - rib_keep, -outer_h / 2 - eps]) square([strip_size[0] + 2 * rib_keep, 3 * wall_t]);
    }
}

module usb_tongues() {
  // fills the lower part of each USB notch in the bezel's top wall
  for (i = [0 : len(usb_x) - 1]) through_top_wall(in_h / 2 + lip_clear, outer_h / 2)
    difference() {
      translate([usb_x[i] - usb_slot[0] / 2 + lip_clear, back_t - seam_chamfer])
        square([usb_slot[0] - 2 * lip_clear, z_usb[i] - back_t + seam_chamfer]);
      usb_slot_2d(i, lip_clear);
    }
}

module driver_standoffs() {
  for (h = drv_holes) translate([h[0], h[1], back_t - eps])
    cylinder(d = drv_standoff_d, h = drv_standoff_h + eps);
}

module csk_holes(list, z_top) {
  // M2.5 countersunk from the outside (90 deg), through to z_top
  for (p = list) translate([p[0], p[1], 0]) {
    translate([0, 0, -cut_over]) cylinder(d = m25_clear_d, h = z_top + 2 * cut_over, $fn = fn_screw);
    cylinder(d1 = m25_csk_d, d2 = m25_clear_d, h = (m25_csk_d - m25_clear_d) / 2, $fn = fn_screw);
  }
}

module carrier_tray_rim() {
  // rim on the left, right and bottom edges; the top edge rests against the top
  // wall. Built from exact 3D boxes: its inner faces meet the recess and the
  // ledges, and a 2D outline would round them to a different grid
  z0 = back_t - eps;
  z1 = z_car_pcb + car_tray_rim;
  difference() {
    box([-car_tray_x, car_rec_lo[1] - car_tray_wall, z0], [car_tray_x, car_top - lip_clear, z1]);
    box([car_rec_lo[0], car_rec_lo[1], z0 - cut_over], [car_rec_hi[0], car_top + cut_over, z1 + cut_over]);
    box([car_wire_gap[0] - car_wire_gap[1] / 2, car_rec_lo[1] - car_tray_wall - cut_over, z0 - cut_over],
        [car_wire_gap[0] + car_wire_gap[1] / 2, car_rec_lo[1] + eps, z1 + cut_over]);
  }
}

module carrier_recess() {
  // the plate drops to car_floor under the board, for its solder joints
  box([car_rec_lo[0], car_rec_lo[1], car_floor], [car_rec_hi[0], car_rec_hi[1], back_t + eps]);
}

module carrier_ledges() {
  // the board rests on ledges along its left and right edges and on the two screw bosses;
  // a notch in a ledge clears a joint that lands on it (the MiniBoost's VIN pin)
  difference() {
    for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
      box([car_hi[0] - car_ledge_w, car_rec_lo[1], car_floor - eps], [car_rec_hi[0], car_rec_hi[1], z_car_pcb]);
    for (n = car_ledge_notches) {
      y = car_top - n[1];
      x_in = sign(n[0]) * (car_hi[0] - car_ledge_w - cut_over);     // past the ledge's inner face
      x_out = sign(n[0]) * (car_rec_hi[0] + cut_over);               // past the rim side
      box([min(x_in, x_out), y - car_notch_len / 2, car_floor - eps - cut_over],
          [max(x_in, x_out), y + car_notch_len / 2, z_car_pcb + cut_over]);
    }
  }
  for (p = car_screw_pos) translate([p[0], p[1], car_floor - eps]) cylinder(d = car_boss_d, h = z_car_pcb - car_floor + eps);
}

module battery_cradle() {
  translate([0, 0, back_t - eps]) linear_extrude(bat_wall_h + eps)
    difference() {
      translate(bat_pos) rrect(bat_out, bat_wall_t + bat_clear);
      translate(bat_pos) rrect(bat_in, bat_clear);
      translate([bat_pos[0] - bat_out[0] / 2 - eps, bat_pos[1] - bat_lead_slot / 2])
        square([bat_wall_t + 2 * eps, bat_lead_slot]);
    }
}

module battery_recess() {
  translate([bat_pos[0], bat_pos[1], bat_floor]) linear_extrude(back_t - bat_floor + eps) rrect(bat_in, bat_clear);
}

module strip_recess() {
  // room for the switch legs, wire joints and screw heads behind the button strip
  if (z_strip_floor < back_t)
    box([strip_lo[0] - strip_clear, max(strip_lo[1] - strip_clear, -in_h / 2), z_strip_floor],
        [strip_hi[0] + strip_clear, strip_hi[1] + strip_clear, back_t + eps]);
}

module magnet_bosses() {
  // tubes around the magnet pockets, up to the rib tops (they carry foam too)
  for (p = mag_pos) translate([p[0], p[1], back_t - eps])
    cylinder(d = mag_boss_d, h = z_mag_boss - back_t + eps);
}

module magnet_pockets() {
  // open to the inside, mag_skin short of the outside face: magnet, steel
  // disc, then epoxy; nothing metal shows outside
  for (p = mag_pos) translate([p[0], p[1], mag_skin]) cylinder(d = mag_pocket_d, h = z_mag_boss - mag_skin + cut_over);
}

module m3_screw_holes() {
  // countersunk from the outside (90 deg); cone and hole share one segment count
  for (p = m3_pos) translate([p[0], p[1], 0]) {
    translate([0, 0, -cut_over]) cylinder(d = m3_clear_d, h = back_t + lip_h + 2 * cut_over, $fn = fn_screw);
    cylinder(d1 = m3_csk_d, d2 = m3_clear_d, h = (m3_csk_d - m3_clear_d) / 2, $fn = fn_screw);
  }
}

module rod_channel_walls() {
  // two low walls along each back cover rod; the rod lies in a groove
  // rod_back_sink deep in the plate between them
  x1 = rod_back_x + rod_end_clear;
  for (y = rod_back_y, s = [-1, 1])
    box([-x1, y + (s > 0 ? rod_slot / 2 : -rod_slot / 2 - rod_wall_t), back_t - eps],
        [x1, y + (s > 0 ? rod_slot / 2 + rod_wall_t : -rod_slot / 2), back_t - rod_back_sink + rod_d]);
}

module rod_back_grooves() {
  x1 = rod_back_x + rod_end_clear;
  for (y = rod_back_y) box([-x1, y - rod_slot / 2, back_t - rod_back_sink], [x1, y + rod_slot / 2, depth]);
}

module wire_ties() {
  // blocks with a tunnel along X: a zip tie goes through and around the wires
  for (y = wire_ties_y) translate([wire_x, y, back_t - eps]) difference() {
    translate([-tie_size[0] / 2, -tie_size[1] / 2, 0]) cube([tie_size[0], tie_size[1], tie_size[2] + eps]);
    translate([-tie_size[0] / 2 - eps, -tie_slot[0] / 2, -eps]) cube([tie_size[0] + 2 * eps, tie_slot[0], tie_slot[1] + eps]);
  }
}

module back_logo() {
  // engraved in the outside face, mirrored so it reads from behind
  translate([logo_pos[0], logo_pos[1], -eps]) linear_extrude(logo_depth + eps) mirror([1, 0])
    text(logo_text, size = logo_size, font = text_font, halign = "center", valign = "center");
}

module ribs() {
  difference() {
    union() for (s = rib_segments) rib(s[0], s[1]);
    rib_keepouts();
  }
}

module rib_keepouts() {
  h = depth + 2 * cut_over;
  for (p = m3_pos) translate([0, 0, -cut_over]) linear_extrude(h) offset(delta = rib_keep) m3_boss_2d(p);
  // ribs may merge with a magnet tube, but the pocket stays open
  for (p = mag_pos) translate([p[0], p[1], -cut_over]) cylinder(d = mag_pocket_d + 2 * rib_keep, h = h);
  // flex zone and relief (nothing but foam there)
  box([-fpc_zone[0] / 2 - rib_keep, pocket_bot - fpc_relief_d, -cut_over],
      [fpc_zone[0] / 2 + rib_keep, panel_bot + fpc_zone[1] + rib_keep, depth + cut_over]);
  // carrier tray, driver board, battery: in a thin case the ribs stop at the modules
  box([-rib_car_x, car_rec_lo[1] - car_tray_wall - rib_keep, -cut_over], [rib_car_x, outer_h, depth + cut_over]);
  box([drv_lo[0] - rib_keep, drv_lo[1] - rib_keep, -cut_over], [drv_hi[0] + rib_keep, drv_hi[1] + rib_keep, depth + cut_over]);
  translate([bat_pos[0], bat_pos[1], -cut_over]) linear_extrude(h) rrect(bat_in, bat_clear);
  // rods: the channels stay open from above
  for (y = rod_back_y) box([-outer_w, y - rod_slot / 2 - rod_wall_t - rib_keep, -cut_over],
                           [outer_w, y + rod_slot / 2 + rod_wall_t + rib_keep, depth + cut_over]);
  // wire passage; with a split back it runs on to the seam band so no stub is left
  wire_gap_x0 = split ? min(wire_x - rib_gap_wire / 2, back_split_x + rib_seam_clear) : wire_x - rib_gap_wire / 2;
  box([wire_gap_x0, rib_mid_y - rib_pad, -cut_over], [wire_x + rib_gap_wire / 2, rib_mid_y + rib_pad, depth + cut_over]);
  // battery lead, from the cradle's slot up to J1 on the carrier
  box([rib_gap_bat[0] - rib_gap_bat[1] / 2, rib_mid_y - rib_pad, -cut_over],
      [rib_gap_bat[0] + rib_gap_bat[1] / 2, rib_mid_y + rib_pad, depth + cut_over]);
  // ribs end short of the back cover seam
  if (split) box([back_seam_out - rib_seam_clear, -outer_h, -cut_over], [back_split_x + rib_seam_clear, outer_h, depth + cut_over]);
  // coax notch in the top rib
  box([coax_notch_x - coax_notch / 2, rib_ty - rib_pad, z_rib_top - coax_notch], [coax_notch_x + coax_notch / 2, rib_ty + rib_pad, depth + cut_over]);
}

// =====================================================================
// Button caps
// =====================================================================
module cap_symbol_2d(i) {
  // 0: left triangle, 1: circle, 2: right triangle
  s = symbol_size;
  if (i == 1) circle(d = s * sym_dot);
  else mirror([i == 2 ? 1 : 0, 0])
    polygon([[-s / 2, 0], [s * sym_tri_base, s / 2], [s * sym_tri_base, -s / 2]]);
}

module cap_local(i) {
  // cap on its own axis: back face at Z = 0, front face at Z = cap_len
  z_cone = cap_flange_t;                          // widest point of the flange
  difference() {
    union() {
      cylinder(d = cap_flange_d, h = cap_flange_t, $fn = fn_button);
      translate([0, 0, z_cone]) cylinder(d1 = cap_flange_d, d2 = cap_d, h = (cap_flange_d - cap_d) / 2, $fn = fn_button);
      cylinder(d = cap_d, h = cap_len, $fn = fn_button);
      cap_key();
    }
    translate([0, 0, cap_len - symbol_depth]) linear_extrude(symbol_depth + eps) cap_symbol_2d(i);
  }
}

module cap_key() {
  // anti-rotation key at -Y; its front end is chamfered 45 deg for face-down printing
  key_top = z_lip - key_clear - z_cap_back;       // stays inside the sleeve
  embed = key_size[1];                            // how far the key reaches into the stem
  hull() {
    translate([-key_size[0] / 2, -(cap_d / 2 + key_size[1]), 0])
      cube([key_size[0], key_size[1] + embed, key_top - key_size[1]]);
    translate([-key_size[0] / 2, -cap_d / 2, 0]) cube([key_size[0], embed, key_top]);
  }
}

module cap(i) {
  translate([btn_x[i], btn_y, z_cap_back]) cap_local(i);
}

// =====================================================================
// Desk stand: the frame leans back into it at stand_tilt
// =====================================================================
module stand() {
  color(c_stand) translate([-stand_w / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(stand_w)
    polygon(stand_profile());
}

// =====================================================================
// Split for small beds: the bezel in four rails with joints at the window
// corners, the back cover at back_split_x
// =====================================================================
module diamond_2d(g) {
  // square turned 45 deg with exact corners: centred on a surface line it
  // cuts a 90 deg V-groove of depth g
  polygon([[g, 0], [0, g], [-g, 0], [0, -g]]);
}

module hull_pts(pts) {
  // convex hull of 8 points (two diamonds); every corner is an exact number
  hull() polyhedron(points = pts, faces = [[0, 1, 2], [0, 3, 1], [4, 5, 6], [4, 7, 5]]);
}

module joint_grooves() {
  // V-grooves on the four rail joints: across the side border of the front
  // face (starting inside the window opening), over the front chamfer and
  // down the side wall. The three pieces meet exactly on the chamfer's edges
  g = seam_chamfer;
  xw = win_size[0] / 2 - window_r - window_chamfer;   // inside the window opening
  xf = outer_w / 2 - front_chamfer;                    // front face ends, chamfer starts
  xo = outer_w / 2;
  zc = depth - front_chamfer;                          // chamfer ends on the wall
  for (y = [win_top, win_bot], s = [-1, 1]) {
    hull_pts(concat(diamond_yz(s * xw, y, depth, g), diamond_yz(s * xf, y, depth, g)));
    hull_pts(concat(diamond_yz(s * xf, y, depth, g), diamond_xy(s * xo, y, zc, g)));
    hull_pts(concat(diamond_xy(s * xo, y, z_in - cut_over, g), diamond_xy(s * xo, y, zc, g)));
  }
}

// a diamond of half-diagonal g in a plane of constant X (yz) or Z (xy)
function diamond_yz(x, y, z, g) = [[x, y - g, z], [x, y + g, z], [x, y, z - g], [x, y, z + g]];
function diamond_xy(x, y, z, g) = [[x - g, y, z], [x + g, y, z], [x, y - g, z], [x, y + g, z]];

module bezel_finished() {
  // the bezel as printed: one piece, or with the joint grooves when split
  if (split) difference() { bezel(); joint_grooves(); } else bezel();
}

module side_region(s) {
  // side rail s (-1 left, 1 right): everything between the two joints on that
  // side. Outer half of the side wall: cut straight at the window's top and
  // bottom edges. Front plate and inner half: a 45 deg scarf from those lines
  // at the front face, bezel_lap into the rail at the back (a half-lap), so
  // every rail prints face-down without supports
  big = outer_w;
  mirror([s < 0 ? 1 : 0, 0, 0]) {
    rotate([90, 0, 90]) linear_extrude(big) polygon([
      [win_bot, depth + cut_over], [win_bot, depth], [win_bot + bezel_lap, depth - bezel_lap], [win_bot + bezel_lap, -cut_over],
      [win_top - bezel_lap, -cut_over], [win_top - bezel_lap, depth - bezel_lap], [win_top, depth], [win_top, depth + cut_over]]);
    translate([wall_mid_x, win_bot, -cut_over]) cube([big - wall_mid_x, win_top - win_bot, depth + 2 * cut_over]);
  }
}

module lower_half() {
  translate([-outer_w, -outer_h, -cut_over]) cube([2 * outer_w, outer_h + win_c[1], depth + 2 * cut_over]);
}

module bezel_rail(name) {
  if (name == "bezel_left") intersection() { bezel_finished(); side_region(-1); }
  else if (name == "bezel_right") intersection() { bezel_finished(); side_region(1); }
  else difference() {
    if (name == "bezel_bottom") intersection() { bezel_finished(); lower_half(); }
    else difference() { bezel_finished(); lower_half(); }
    side_region(-1);
    side_region(1);
  }
}

module back_left_region() {
  // everything left of the back cover seam: a 45 deg scarf through the plate
  // with short lands (no knife edges), vertical above the plate. At each tab
  // the cut is vertical and back_left keeps a tongue on the bed side
  big = outer_w;
  translate([0, big, 0]) rotate([90, 0, 0]) linear_extrude(2 * big)
    polygon([[-big, -cut_over], [back_seam_out, -cut_over], [back_seam_out, scarf_land],
             [back_split_x, back_t - scarf_land], [back_split_x, depth + cut_over], [-big, depth + cut_over]]);
  for (y = back_tab_y) {
    translate([-big, y - back_tab[1] / 2 - tab_clear, -cut_over])
      cube([big + back_split_x, back_tab[1] + 2 * tab_clear, depth + 2 * cut_over]);
    translate([back_split_x - cut_over, y - back_tab[1] / 2, -cut_over])
      cube([back_tab[0] + cut_over, back_tab[1], back_tab[2] + cut_over]);
  }
}

module back_tab_pockets() {
  // room for back_left's tongues under back_right's plate (bridged roof)
  for (y = back_tab_y) translate([back_split_x - cut_over, y - back_tab[1] / 2 - tab_clear, -cut_over])
    cube([back_tab[0] + tab_clear + cut_over, back_tab[1] + 2 * tab_clear, back_tab[2] + tab_clear + cut_over]);
}

module back_left() { intersection() { back_cover(); back_left_region(); } }
module back_right() { difference() { back_cover(); back_left_region(); back_tab_pockets(); } }

// =====================================================================
// Print layouts (STL orientation)
// =====================================================================
module face_down() { translate([0, 0, depth]) rotate([0, 180, 0]) children(); }
module face_down_inverse() { rotate([0, 180, 0]) translate([0, 0, -depth]) children(); }

module print_part(name) {
  // a printable part in its print orientation (bezel parts face-down, the
  // long rails turned by rail_angle, back cover parts outside face down),
  // from its STL when use_stl is set
  if (use_stl) import(stl_path(name));
  else rotate([0, 0, part_angle(name)]) {
    if (name == "bezel_top" || name == "bezel_bottom" || name == "bezel_left" || name == "bezel_right") face_down() bezel_rail(name);
    else if (name == "back_left") back_left();
    else if (name == "back_right") back_right();
    else if (name == "bezel") face_down() bezel();
    else if (name == "back") back_cover();
    else if (name == "button_caps") caps_print();
    else if (name == "stand") stand();
    else assert(false, str("unknown part: ", name));
  }
}

function stl_path(name) = (name == "bezel" || name == "back") ? str("stl/one-piece/", name, ".stl") : str("stl/", name, ".stl");

module caps_print() {
  for (i = [0 : len(btn_x) - 1]) translate([(i - 1) * (cap_flange_d + print_gap), 0, cap_len])
    rotate([180, 0, 0]) cap_local(i);
}

// Enclosure parts in assembled position (from the STLs when use_stl is set)
module assembled(name) {
  if (is_bezel_part(name)) face_down_inverse() rotate([0, 0, -part_angle(name)]) print_part(name);
  else rotate([0, 0, -part_angle(name)]) print_part(name);
}

module bezel_parts(alpha = 1, shift = 0) {
  // split: top rail and chin in the bezel colour, side rails tinted and moved
  // out by shift (exploded view)
  if (split) {
    color(c_bezel, alpha) { assembled("bezel_top"); assembled("bezel_bottom"); }
    color(c_bezel_side, alpha) {
      translate([-shift, 0, 0]) assembled("bezel_left");
      translate([shift, 0, 0]) assembled("bezel_right");
    }
  } else color(c_bezel, alpha) assembled("bezel");
}

module back_parts(alpha = 1, shift = 0) {
  if (split) {
    color(c_back, alpha) assembled("back_right");
    color(c_back_left, alpha) translate([-shift, 0, 0]) assembled("back_left");
  } else color(c_back, alpha) assembled("back");
}

// =====================================================================
// Bought parts, rods and module envelopes (assembled position)
// =====================================================================
module panel_model() {
  color(c_panel) panel_env();
  translate([win_c[0], win_c[1], z_panel_front]) screen_mock();
}

module mock_tiles(list, area) {
  for (t = list) translate([(t[0] - 0.5) * area[0], (t[1] - 0.5) * area[1], 0])
    cube([t[2] * area[0], t[3] * area[1], 2 * eps]);
}

module screen_mock() {
  // a calm dashboard on the active area, for the renders only
  area = [active_w, active_h] - 2 * [mock_margin, mock_margin];
  color(c_ink) mock_tiles(mock_ink, area);
  color(c_ink2) mock_tiles(mock_grey, area);
}

module gasket_model() {
  color(c_foam) translate([0, 0, z_panel_front]) linear_extrude(gasket_t)
    difference() { translate(panel_c) square([panel_w, panel_h], center = true); translate(win_c) square(win_size, center = true); }
}

module flex_model() {
  // flex bent around the panel's bottom edge, folded flex and adapter board
  color(c_fpc) {
    box([-fpc_w / 2, panel_bot - fpc_bend, z_panel_back - fpc_t], [fpc_w / 2, panel_bot, z_panel_front]);
    box([-fpc_w / 2, panel_bot, z_panel_back - fpc_t], [fpc_w / 2, panel_bot + fpc_fold_h, z_panel_back]);
  }
  color(c_drv) translate([fpc_adapter_x - fpc_adapter[0] / 2, panel_bot + fpc_fold_h - fpc_adapter[1] / 2,
                          z_panel_back - fpc_t - fpc_adapter[2]]) cube(fpc_adapter);
}

module nut(h) {
  // hex nut, across flats m25_nut[0]
  cylinder(d = m25_nut[0] / cos(30), h = h, $fn = 6);
}

module driver_model() {
  translate([drv_pos[0], drv_pos[1], z_drv_pcb]) {
    color(c_drv) difference() {
      translate(-drv_size / 2) cube([drv_size[0], drv_size[1], drv_pcb_t]);
      for (h = drv_holes) translate([h[0] - drv_pos[0], h[1] - drv_pos[1], -cut_over])
        cylinder(d = drv_hole_d, h = drv_pcb_t + 2 * cut_over);
    }
    color(c_metal) translate([-drv_stub_size[0] / 2, drv_stub_y - drv_pos[1] - drv_stub_size[1] / 2, -drv_stub_h])
      cube([drv_stub_size[0], drv_stub_size[1], drv_stub_h]);
    color(c_switch) translate([-drv_chip[0] / 2, -drv_chip[1] / 2, drv_pcb_t]) cube(drv_chip);
    color(c_metal) translate([drv_size[0] / 2 - drv_ffc_socket[0], -drv_ffc_socket[1] / 2, drv_pcb_t])
      cube(drv_ffc_socket);
    color(c_metal) for (h = drv_holes) translate([h[0] - drv_pos[0], h[1] - drv_pos[1], drv_pcb_t]) nut(m25_nut[1]);
  }
}

module sbox(lo, hi, s) {
  // box shrunk by s on every side (s = 0: exact envelope)
  box(lo + [s, s, s], hi - [s, s, s]);
}

module driver_env(s = 0) {
  sbox([drv_lo[0], drv_lo[1], z_drv_pcb], [drv_hi[0], drv_hi[1], z_drv_top], s);
  sbox([drv_pos[0] - drv_stub_size[0] / 2, drv_stub_y - drv_stub_size[1] / 2, z_drv_pcb - drv_stub_h],
       [drv_pos[0] + drv_stub_size[0] / 2, drv_stub_y + drv_stub_size[1] / 2, z_drv_pcb], s);
}

module carrier_model() {
  color(c_car) box([car_lo[0], car_lo[1], z_car_pcb], [car_hi[0], car_hi[1], z_car_top]);
  // XIAO flat at the top edge, the other modules where they fit (illustration)
  color(c_switch) translate([usb_x[0] - xiao_size[0] / 2, car_top - xiao_size[1], z_car_top])
    cube([xiao_size[0], xiao_size[1], xiao_t]);
  color(c_metal) translate([usb_x[0] - xiao_shield[0] / 2, car_top - (xiao_size[1] + xiao_shield[1]) / 2, z_car_top + xiao_t])
    cube(xiao_shield);
  for (m = car_modules) color(m[3]) translate([m[0] - m[2][0] / 2, car_top - m[1] - m[2][1] / 2, z_car_top]) cube(m[2]);
  color(c_metal) for (i = [0 : len(usb_x) - 1]) usb_receptacle(i);
  color(c_metal) translate([ufl_pos[0], ufl_pos[1], z_car_top + xiao_t]) cylinder(d = 2 * coax_d, h = ufl_plug_h);
  color(c_metal) for (p = car_screw_pos) translate([p[0], p[1], z_car_top]) nut(m25_nut[1]);
}

module usb_receptacle(i) {
  translate([usb_x[i], car_top + usb_overhang - usb_len / 2, z_usb[i]]) rotate([90, 0, 0])
    linear_extrude(usb_len, center = true) rrect(usb_size, usb_size[1] / 2 - eps);
}

module carrier_env(s = 0) {
  sbox([car_lo[0], car_lo[1], z_car_pcb], [car_hi[0], car_hi[1], z_car_top + car_comp_h], s);
  // solder joints: not over the ledges, not around the two screw bosses
  difference() {
    sbox([car_lo[0] + car_ledge_w, car_lo[1], z_car_pcb - car_ledge_h], [car_hi[0] - car_ledge_w, car_hi[1], z_car_pcb], s);
    for (p = car_screw_pos) translate([p[0], p[1], 0]) cylinder(d = car_boss_d + 2 * car_clear, h = depth);
  }
  // and the ones in the ledge notches (2 mm pads)
  for (n = car_ledge_notches)
    sbox([n[0] - 1, car_top - n[1] - 1, z_car_pcb - car_ledge_h], [n[0] + 1, car_top - n[1] + 1, z_car_pcb], s);
  for (i = [0 : len(usb_x) - 1])
    sbox([usb_x[i] - usb_size[0] / 2, car_top + usb_overhang - usb_len, z_usb[i] - usb_size[1] / 2],
         [usb_x[i] + usb_size[0] / 2, car_top + usb_overhang, z_usb[i] + usb_size[1] / 2], s);
}

module battery_model() {
  color(c_foam) translate([bat_pos[0], bat_pos[1], bat_floor]) linear_extrude(bat_foam_t) rrect([bat_size[0], bat_size[1]], bat_clear);
  color(c_bat) translate([bat_pos[0], bat_pos[1], z_bat[0]]) linear_extrude(bat_size[2]) rrect([bat_size[0], bat_size[1]], bat_clear);
}

module battery_env(s = 0) {
  sbox([bat_pos[0] - bat_size[0] / 2, bat_pos[1] - bat_size[1] / 2, bat_floor],
       [bat_pos[0] + bat_size[0] / 2, bat_pos[1] + bat_size[1] / 2, z_bat[1]], s);
}

module antenna_model() {
  color(c_ant) box(ant_lo, ant_hi);
  color(c_switch) coax_model();
}

module coax_model() {
  for (i = [0 : len(coax_path) - 2]) hull() {
    translate(coax_path[i]) sphere(d = coax_d);
    translate(coax_path[i + 1]) sphere(d = coax_d);
  }
}

module strip_model() {
  color(c_car) box([strip_lo[0], strip_lo[1], z_strip_back], [strip_hi[0], strip_hi[1], z_strip_front]);
  for (x = btn_x) translate([x, btn_y, z_strip_front]) {
    color(c_switch) translate([-sw_size / 2, -sw_size / 2, 0]) cube([sw_size, sw_size, sw_body_h]);
    // flat plunger at its free height, or pressed by the cap if preloaded
    color(c_metal) cylinder(d = sw_plunger_d, h = sw_h - max(cap_preload, 0));
  }
}

module btn_plug_env(s = 0) {
  sbox([btn_plug_pos[0] - btn_plug_size[0] / 2, btn_plug_pos[1] - btn_plug_size[1] / 2, z_in],
       [btn_plug_pos[0] + btn_plug_size[0] / 2, btn_plug_pos[1] + btn_plug_size[1] / 2, z_in + btn_plug_size[2]], s);
}

module strip_env(s = 0) {
  difference() {
    sbox([strip_lo[0], strip_lo[1], z_strip_joints], [strip_hi[0], strip_hi[1], z_strip_front], s);
    // screw heads only behind the two bosses
    for (x = strip_screw_x) translate([x, btn_y, 0]) cylinder(d = strip_boss_d, h = depth);
  }
  for (x = btn_x) sbox([x - sw_size / 2, btn_y - sw_size / 2, z_strip_front], [x + sw_size / 2, btn_y + sw_size / 2, z_strip_front + sw_body_h], s);
}

module magnets_model() { magnets_at(mag_pos); pads_at(mag_pos); }

module magnets_at(list) {
  // magnet, steel disc and epoxy in the pocket
  for (p = list) translate([p[0], p[1], 0]) {
    color(c_magnet) translate([0, 0, z_mag[0]]) cylinder(d = mag_d, h = mag_h);
    color(c_metal) translate([0, 0, z_steel[0]]) cylinder(d = steel_disc[0], h = steel_disc[1]);
  }
}

module pads_at(list) {
  // rubber pads on the outside face, over the pockets
  color(c_pad) for (p = list) translate([p[0], p[1], -pad[1]]) cylinder(d = pad[0], h = pad[1]);
}

module magnets_env(s = 0) {
  for (p = mag_pos) translate([p[0], p[1], z_mag[0] + s]) cylinder(d = mag_d - 2 * s, h = z_steel[1] - z_mag[0] - 2 * s);
}

module fpc_zone_env(s = 0) {
  sbox([-fpc_zone[0] / 2, panel_bot, z_in], [fpc_zone[0] / 2, panel_bot + fpc_zone[1], z_panel_back], s);
}

module panel_env(s = 0) {
  sbox([panel_c[0] - panel_w / 2, panel_c[1] - panel_h / 2, z_panel_back], [panel_c[0] + panel_w / 2, panel_c[1] + panel_h / 2, z_panel_front], s);
}

module bezel_rods(s = 0) {
  // L-rods in the bezel corners (s > 0: pulled in for the clash check)
  for (i = [0 : len(rod_corners) - 1]) corner_mirror(rod_corners[i]) {
    l = rod_leg(i);
    translate([rod_sx, rod_cc[1] - l[1] + s, rod_zc]) rotate([-90, 0, 0]) cylinder(d = rod_d - 2 * s, h = l[1] - s + eps);
    translate([rod_cc[0] - l[0] + s, rod_ty, rod_zc]) rotate([0, 90, 0]) cylinder(d = rod_d - 2 * s, h = l[0] - s + eps);
    translate([rod_cc[0], rod_cc[1], rod_zc]) rotate_extrude(angle = 90) translate([rod_R, 0]) circle(d = rod_d - 2 * s);
  }
}

module back_rods(s = 0) {
  for (y = rod_back_y) translate([-rod_back_x + s, y, rod_back_zc]) rotate([0, 90, 0])
    cylinder(d = rod_d - 2 * s, h = 2 * (rod_back_x - s));
}

module internals() {
  panel_model();
  gasket_model();
  flex_model();
  driver_model();
  carrier_model();
  battery_model();
  antenna_model();
  strip_model();
  color(c_cap) btn_plug_env();
  if (show_rods) color(c_rod) { bezel_rods(); back_rods(); }
}

module caps_inked() {
  // caps with their engraved symbols filled dark, for the renders
  color(c_cap) for (i = [0 : len(btn_x) - 1]) cap(i);
  color(c_ink) for (i = [0 : len(btn_x) - 1])
    translate([btn_x[i], btn_y, z_cap_face - symbol_depth + eps]) linear_extrude(eps) cap_symbol_2d(i);
}

module all_envelopes(s = 0) {
  driver_env(s);
  carrier_env(s);
  battery_env(s);
  fpc_zone_env(s);
  sbox(ant_lo, ant_hi, s);
  strip_env(s);
  btn_plug_env(s);
  magnets_env(s);
  panel_env(s);
  bezel_rods(s);
  back_rods(s);
}

// =====================================================================
// Scenes
// =====================================================================
module scene_assembly() {
  bezel_parts();
  back_parts();
  caps_inked();
  magnets_model();
  internals();
}

module scene_exploded() {
  // layers pulled apart along Z in assembly order (explode_z[i] x explode_gap):
  // pads, back cover, magnets, panel, strip, caps, bezel. Split pieces also
  // move sideways by explode_side; the rods stay put and show the splices
  side = split ? explode_side : 0;
  dz = [for (e = explode_z) [0, 0, e * explode_gap]];
  translate(dz[0]) for (p = mag_pos) translate([p[0] < back_split_x ? -side : 0, 0, 0]) pads_at([p]);
  translate(dz[1]) {
    back_parts(shift = side);
    translate([-side, 0, 0]) driver_model();
    carrier_model();
    battery_model();
    if (show_rods) color(c_rod) back_rods();
  }
  translate(dz[2]) for (p = mag_pos) translate([p[0] < back_split_x ? -side : 0, 0, 0]) magnets_at([p]);
  translate(dz[3]) { panel_model(); flex_model(); }
  translate(dz[4]) strip_model();
  translate(dz[5]) caps_inked();
  translate(dz[6]) {
    bezel_parts(shift = side);
    antenna_model();
    gasket_model();
    if (show_rods) color(c_rod) bezel_rods();
  }
}

module scene_inside() {
  // back cover removed, seen from behind: where each module sits, with the
  // magnets (in the back cover) as ghosts and their board keep-out circles
  bezel_parts();
  caps_inked();
  internals();
  color(c_fpc, 0.35) fpc_zone_env();
  color(c_ant, 0.3) antenna_keepout();                       // antenna edge-on from behind: show its zone
  for (p = mag_pos) translate([p[0], p[1], 0]) {
    color(c_magnet, 0.8) translate([0, 0, z_mag[0]]) cylinder(d = mag_d, h = z_steel[1] - z_mag[0]);
    color(c_keepout, 0.5) translate([0, 0, z_steel[1]]) linear_extrude(ring_w) difference() {
      circle(r = mag_keep_board);
      circle(r = mag_keep_board - ring_w);
    }
  }
  if (show_labels) inside_labels();
}

module inside_labels() {
  // read from behind: mirrored, just behind the back face of each module
  lbl = [
    ["DRIVER HAT", drv_pos, z_drv_pcb - drv_stub_h],
    ["CARRIER", [0, car_top - car_size[1] / 2], z_car_pcb - car_ledge_h],
    ["BATTERY", bat_pos, bat_floor],
    ["FPC ZONE", [0, panel_bot + fpc_zone[1] / 2], z_in],
    ["ANTENNA", [(ant_x[0] + ant_x[1]) / 2, in_h / 2 - ant_metal_keepout - img_label], z_in],
    ["BUTTONS", [0, btn_y], z_strip_joints]];
  for (l = lbl) color(c_switch) translate([l[1][0], l[1][1], l[2] - 2 * eps]) mirror([1, 0, 0]) label(l[0], img_label);
}

module scene_fit_check() {
  // module envelopes inside a see-through enclosure. OpenCSG depth-tests in
  // draw order, so solid envelopes first, then keep-out volumes, then shells
  color(c_drv) driver_env();
  color(c_car_env) carrier_env();
  color(c_bat) battery_env();
  color(c_ant) box(ant_lo, ant_hi);
  color(c_strip_env) strip_env();
  color(c_magnet) magnets_env();
  color(c_rod) { bezel_rods(); back_rods(); }
  color(c_switch) coax_model();
  color(c_cap) for (i = [0 : len(btn_x) - 1]) cap(i);
  if (show_labels) fit_labels();
  color(c_fpc, 0.4) fpc_zone_env();
  color(c_keepout, 0.15) antenna_keepout();
  color(c_panel, 0.25) panel_env();
  back_parts(alpha = 0.2);
  bezel_parts(alpha = 0.15);
}

module antenna_keepout() {
  // antenna metal keep-out: the reservation grown by ant_metal_keepout, clamped
  // to the inside (a plain box, so translucent previews stay clean)
  grow = [1, 1, 1] * ant_metal_keepout;
  lo = ant_res_lo - grow;
  hi = ant_res_hi + grow;
  box([max(lo[0], -in_w / 2), max(lo[1], -in_h / 2), max(lo[2], z_in) + eps],
      [min(hi[0], in_w / 2), min(hi[1], in_h / 2), min(hi[2], z_lip) - eps]);
}

module fit_labels() {
  lbl = [
    ["DRIVER", drv_pos, z_drv_top],
    ["CARRIER", [0, car_top - car_size[1] / 2], z_car_top + car_comp_h],
    ["BATTERY", bat_pos, z_bat[1]],
    ["FPC", [0, panel_bot + fpc_zone[1] / 2], z_in]];
  for (l = lbl) color(c_switch) translate([l[1][0], l[1][1], l[2] + eps]) label(l[0], img_label);
}

module scene_clash() {
  // everything rendered here is a collision: the result must be empty.
  // The split pieces partition the same solids, so the one-piece shapes
  // (with the joint grooves) stand in for them here. The back cover moves
  // clash_shrink back, so the faces that only touch at the seam do not count
  color(c_keepout) {
    intersection() { bezel_finished(); translate([0, 0, -clash_shrink]) back_cover(); }
    intersection() { union() { bezel_finished(); back_cover(); } all_envelopes(clash_shrink); }
  }
}

module scene_plates() {
  // one bed outline per print job (two by two), parts in print orientation, labelled
  u = bed_size - 2 * [bed_margin, bed_margin];
  top = max(depth, stand_h) + cut_over;           // labels float above the tallest part
  for (j = [0 : len(plate_titles) - 1])
    translate([(j % 2) * (bed_size[0] + plate_spacing), -floor(j / 2) * (bed_size[1] + plate_spacing), 0]) {
      color(c_bed_fill) translate([0, 0, -2 * cut_over]) cube([bed_size[0], bed_size[1], cut_over]);
      color(c_bed) linear_extrude(2 * eps) difference() {
        square(bed_size);
        translate([1, 1]) square(bed_size - [2, 2]);
      }
      color(c_bed, 0.5) linear_extrude(2 * eps) difference() {
        translate([bed_margin, bed_margin]) square(u);
        translate([bed_margin + 0.5, bed_margin + 0.5]) square(u - [1, 1]);
      }
      color(c_switch) translate([bed_size[0] / 2, bed_size[1] + plate_gap, 0]) label(plate_titles[j], plate_label * 1.3);
      for (q = plate_layout(j)) {
        bb = print_bbox(q[0]);
        at = [bed_margin, bed_margin] + q[1];
        color(plate_colour(q[0])) translate([at[0] - bb[0][0], at[1] - bb[0][1], 0]) print_part(q[0]);
        // names run along the rails, along narrow parts, and under small ones
        f = fp(q[0]);
        a = part_angle(q[0]) != 0 ? part_angle(q[0]) : f[0] < plate_narrow ? 90 : 0;
        small = f[1] < plate_narrow && part_angle(q[0]) == 0;
        color(c_keepout) translate([at[0] + f[0] / 2, small ? at[1] - plate_label : at[1] + f[1] / 2, top])
          rotate([0, 0, a]) label(q[0], plate_label);
      }
    }
}

function plate_colour(name) =
  name == "bezel_top" || name == "bezel_bottom" ? c_bezel : name == "bezel_left" || name == "bezel_right" ? c_bezel_side :
  name == "back_left" ? c_back_left : name == "back_right" ? c_back :
  name == "button_caps" ? c_cap : c_stand;

// =====================================================================
// Design rules: asserts and a placement report (see the console)
// =====================================================================
function clampv(x, lo, hi) = min(max(x, lo), hi);
function rect_dist(p, lo, hi) = norm([p[0] - clampv(p[0], lo[0], hi[0]), p[1] - clampv(p[1], lo[1], hi[1])]);
function box_dist(lo1, hi1, lo2, hi2) = norm([for (i = [0 : len(lo1) - 1]) max(0, lo1[i] - hi2[i], lo2[i] - hi1[i])]);
function path_len(p) = len(p) < 2 ? 0 : norm(p[1] - p[0]) + path_len([for (i = [1 : len(p) - 1]) p[i]]);
function r2(x) = round(x * 100) / 100;
function seg_dist(p, a, b) = let(ab = b - a, t = clampv((p - a) * ab / (ab * ab), 0, 1)) norm(p - (a + t * ab));
function gap1d(a, b) = max(0, b[0] - a[1], a[0] - b[1]);   // distance between intervals a and b
function mirror_box(s, b) = [[s[0] < 0 ? -b[1][0] : b[0][0], s[1] < 0 ? -b[1][1] : b[0][1], b[0][2]],
                             [s[0] < 0 ? -b[0][0] : b[1][0], s[1] < 0 ? -b[0][1] : b[1][1], b[1][2]]];
// bounding boxes of the rods (legs exact, bends as their whole corner box)
function bezel_rod_boxes(i) = let(l = rod_leg(i), s = rod_corners[i], z = [rod_zc - rod_d / 2, rod_zc + rod_d / 2]) [
  mirror_box(s, [[rod_sx - rod_d / 2, rod_cc[1] - l[1], z[0]], [rod_sx + rod_d / 2, rod_cc[1], z[1]]]),
  mirror_box(s, [[rod_cc[0] - l[0], rod_ty - rod_d / 2, z[0]], [rod_cc[0], rod_ty + rod_d / 2, z[1]]]),
  mirror_box(s, [[rod_cc[0], rod_cc[1], z[0]], [rod_sx + rod_d / 2, rod_ty + rod_d / 2, z[1]]])];
rod_boxes = concat(
  [for (i = [0 : len(rod_corners) - 1]) each bezel_rod_boxes(i)],
  [for (y = rod_back_y) [[-rod_back_x, y - rod_d / 2, rod_back_zc - rod_d / 2], [rod_back_x, y + rod_d / 2, rod_back_zc + rod_d / 2]]]);
// how far a boss's insert hole reaches into the pocket outline (0 if it stays outside)
function hole_reach(p, f) = let(r = m3_insert[0] / 2, lo = panel_c - pocket_size / 2 - [1, 1] * f, hi = panel_c + pocket_size / 2 + [1, 1] * f)
  max(0, min(p[0] + r - lo[0], hi[0] - p[0] + r, p[1] + r - lo[1], hi[1] - p[1] + r));
stack_front = front_t + gasket_t + panel_t;      // front face to the panel's back
foam_gap = back_foam_t - back_foam_squeeze;      // rib tops to the panel's back
corner_names = ["top-left", "top-right", "bottom-left", "bottom-right"];

module design_checks() {
  ant_lo2 = [ant_res_lo[0], ant_res_lo[1]];
  ant_hi2 = [ant_res_hi[0], ant_res_hi[1]];
  fpc_lo = [-fpc_zone[0] / 2, panel_bot];
  fpc_hi = [fpc_zone[0] / 2, panel_bot + fpc_zone[1]];
  cradle_lo = bat_pos - bat_out / 2;
  cradle_hi = bat_pos + bat_out / 2;

  // print bed: every printed part of this configuration, in its print
  // orientation (turned 90 deg if that helps), inside the bed margins
  usable = bed_size - 2 * [bed_margin, bed_margin];
  for (n = printed_parts) {
    f = fp(n);
    echo(str("PART ", n, " footprint ", r2(f[0]), " x ", r2(f[1]), " mm", part_angle(n) != 0 ? str(" (turned ", part_angle(n), " deg)") : ""));
    assert((f[0] <= usable[0] && f[1] <= usable[1]) || (f[1] <= usable[0] && f[0] <= usable[1]),
      str(n, " (", r2(f[0]), " x ", r2(f[1]), " mm) does not fit a ", bed_size, " mm bed with ", bed_margin,
          " mm margins", split ? "" : "; one-piece parts need a 250 x 210 bed, or set split = true"));
  }
  if (split) {
    for (j = [0 : len(plate_titles) - 1]) {
      jobs = plate_layout(j);
      for (q = jobs)
        assert(q[1][0] >= -eps && q[1][1] >= -eps && q[1][0] + fp(q[0])[0] <= usable[0] + eps && q[1][1] + fp(q[0])[1] <= usable[1] + eps,
          str(q[0], " does not fit print job ", j + 1));
      for (a = [0 : len(jobs) - 1], b = [0 : len(jobs) - 1]) if (a < b) {
        g = sep_gap(placed_pts(jobs[a]), placed_pts(jobs[b]));
        echo(str("PLATE ", j + 1, ": ", jobs[a][0], " to ", jobs[b][0], " at least ", r2(g), " mm"));
        assert(g >= plate_gap - eps, str(jobs[a][0], " and ", jobs[b][0], " are closer than plate_gap on print job ", j + 1));
      }
    }
    assert(bezel_lap >= front_t, "rail half-lap shorter than the front face: the lap would overhang");
    split_checks();
  }
  assert(window_land + window_chamfer <= front_t + eps, "window chamfer deeper than the front face");
  assert(chin_h > 0, "panel does not fit the outline height");

  // ---- depth: every stack that has to fit between the plates ----------
  reach = max([for (k = [0 : len(m3_pos) - 1]) hole_reach(m3_pos[k], face_off(k))]);
  need = [
    ["carrier: board on its ledges, tallest part (the MiniBoost), air", z_car_top + car_comp_h + car_air_min + stack_front],
    ["driver HAT: standoffs, board, 3 mm parts, air", z_drv_top + drv_air_min + stack_front],
    ["driver HAT: screw tips, air", drv_screw_len + drv_air_min + stack_front],
    ["battery: floor, foam, cell, air to the rib tops", z_bat[1] + bat_air_min + foam_gap + stack_front],
    ["buttons: cap, gap, switch, strip, joints, recess floor", depth - (z_strip_joints - strip_joint_clear) + recess_floor_min],
    ["USB slots below the front chamfer", max([for (z = z_usb) z + usb_slot[1] / 2]) + front_chamfer],
    ["antenna on its fin, under the pocket rim", z_in + ant_h + ant_top_clear + front_t + pocket_depth],
    ["M3 inserts under the 45 deg boss caps", z_m3_floor + reach + boss_panel_clear + stack_front],
    ["magnet pockets under the rib tops", z_mag_epoxy + foam_gap + stack_front],
    ["bezel rod grooves", z_in + rod_slot + front_t]];
  min_depth = max([for (n = need) n[1]]);
  for (n = need) echo(str("DEPTH needs ", r2(n[1]), " mm: ", n[0]));
  echo(str("DEPTH ", depth, " mm; the smallest that closes is ", r2(min_depth), " mm"));
  assert(depth >= min_depth - eps, str("depth ", depth, " mm does not close; it needs ", r2(min_depth), " mm (see the DEPTH lines)"));

  // driver board
  assert(drv_standoff_h > drv_stub_h, "HAT standoffs do not clear the clipped header pins");
  assert(m25_nut[1] <= drv_comp_h, "HAT nuts taller than the component zone");
  assert(drv_screw_len >= z_drv_pcb + drv_pcb_t + m25_nut[1], "HAT screws too short for the nuts");
  // carrier
  assert(car_floor >= recess_floor_min, "carrier recess floor too thin");
  assert(car_screw_len >= z_car_top + m25_nut[1], "carrier screws too short for the nuts");
  assert((m25_csk_d - m25_clear_d) / 2 <= min(back_t, z_car_pcb), "M2.5 countersink deeper than the plate");
  // battery
  assert(bat_floor >= recess_floor_min, "battery recess floor too thin");
  // antenna and coax
  assert(z_ant[0] >= z_in - eps, str("antenna (", ant_h, " mm) taller than the space under the pocket rim (", z_pocket - ant_top_clear - z_in, " mm)"));
  assert(ant_lo[1] >= pocket_top + 0.5, "antenna fin too close to the panel pocket");
  assert(path_len(coax_path) <= coax_len, "coax too short for the route to the U.FL");
  assert(coax_z + coax_d / 2 <= z_panel_back - car_air_min, "coax too close to the panel");
  assert(coax_z - coax_d / 2 >= z_car_top + max([for (m = car_modules) m[2][2]]), "coax on the carrier's modules");
  assert(coax_notch_z - coax_d / 2 >= z_rib_top - coax_notch, "coax notch in the top rib too shallow");
  // buttons
  assert(btn_y - strip_size[1] / 2 >= -in_h / 2 + strip_clear, "button strip hits the bottom wall");
  assert(btn_y + strip_size[1] / 2 <= panel_bot, "button strip reaches into the flex zone");
  assert(btn_y + cap_flange_d / 2 <= pocket_bot - fpc_relief_d, "cap flange reaches the flex relief");
  assert(sleeve_len >= seat_h, "sleeve shorter than the cap seat");
  assert(z_strip_floor >= recess_floor_min - eps, str("strip recess floor ", r2(z_strip_floor), " mm is too thin"));
  // the button lead's inline plug lies under the panel and its folded flex, beside the adapter board
  plug_lo = [btn_plug_pos[0] - btn_plug_size[0] / 2, btn_plug_pos[1] - btn_plug_size[1] / 2, z_in];
  plug_hi = [btn_plug_pos[0] + btn_plug_size[0] / 2, btn_plug_pos[1] + btn_plug_size[1] / 2, z_in + btn_plug_size[2]];
  adapter_lo = [fpc_adapter_x - fpc_adapter[0] / 2, panel_bot + fpc_fold_h - fpc_adapter[1] / 2, z_panel_back - fpc_t - fpc_adapter[2]];
  adapter_hi = [fpc_adapter_x + fpc_adapter[0] / 2, panel_bot + fpc_fold_h + fpc_adapter[1] / 2, z_panel_back - fpc_t];
  assert(plug_hi[2] + car_air_min <= z_panel_back - fpc_t, "button plug too tall for the space under the folded flex");
  assert(box_dist(plug_lo, plug_hi, adapter_lo, adapter_hi) >= 2 + eps, "button plug within 2 mm of the adapter board");
  // caps: a preload must stay below the switch travel, a gap must stay small;
  // either way the flange seat (not the switch) holds the cap in place
  assert(cap_preload < sw_travel, "cap preload would keep the switch pressed");
  assert(-cap_preload <= cap_gap_max, "cap gap too large, the caps will rattle");
  assert(cap_flange_d > cap_hole_d, "cap flange cannot retain the cap");
  assert(z_cap_back - cap_stroke > z_strip_front + sw_body_h, "cap would hit the switch body before the click");
  assert(fpc_bend <= fpc_relief_d, "flex bend does not fit the relief slot");
  // screws
  assert((m3_csk_d - m3_clear_d) / 2 <= back_t, "M3 countersink deeper than the back plate");
  for (k = [0 : len(m3_pos) - 1]) assert(z_boss_cap - hole_reach(m3_pos[k], face_off(k)) >= z_m3_floor - eps,
    str("M3 boss ", m3_pos[k], ": insert breaks through its 45 deg cap"));
  assert(outer_w / 2 - corner_r + rod_R - rod_slot / 2 - pocket_edge[0] - face_off(len(m3_pos) + len(rod_corners) - 1) >= rod_web - eps,
    "rod groove web to the pocket too thin");

  // magnets: sealed pocket, placement rules
  assert(mag_skin > 0 && z_mag_epoxy <= z_mag_boss, "magnet pocket does not hold magnet, disc and epoxy");
  for (p = mag_pos) {
    d_drv = rect_dist(p, drv_lo, drv_hi);
    d_car = rect_dist(p, car_lo, car_hi);
    d_ant = rect_dist(p, ant_lo2, ant_hi2);
    d_fpc = rect_dist(p, fpc_lo, fpc_hi);
    d_bat = rect_dist(p, cradle_lo, cradle_hi);
    echo(str("MAGNET at ", p, ": to driver board ", r2(d_drv), " mm, carrier ", r2(d_car),
             " mm, antenna ", r2(d_ant), " mm, FPC zone ", r2(d_fpc), " mm, battery cradle ", r2(d_bat), " mm"));
    assert(d_drv >= mag_keep_board, str("magnet ", p, " only ", d_drv, " mm from the driver board"));
    assert(d_car >= mag_keep_board, str("magnet ", p, " only ", d_car, " mm from the carrier board"));
    assert(d_ant >= mag_keep_ant, str("magnet ", p, " only ", d_ant, " mm from the antenna"));
    assert(d_fpc >= mag_boss_d / 2 + rib_keep, str("magnet ", p, " overlaps the FPC zone"));
    assert(d_bat >= mag_boss_d / 2 + rib_keep, str("magnet ", p, " overlaps the battery cradle"));
    assert(abs(p[0]) + mag_boss_d / 2 <= in_w / 2 - lip_t - lip_clear && abs(p[1]) + mag_boss_d / 2 <= in_h / 2 - lip_t - lip_clear,
      str("magnet ", p, " too close to the wall"));
  }

  // steel rods: away from the magnets, the antenna and the flex zone
  d_rm = min([for (b = rod_boxes, m = mag_pos) rect_dist(m, [b[0][0], b[0][1]], [b[1][0], b[1][1]]) - mag_d / 2]);
  d_ra = min([for (b = rod_boxes) box_dist(b[0], b[1], ant_res_lo, ant_res_hi)]);
  d_rf = min([for (b = rod_boxes) box_dist(b[0], b[1], [fpc_lo[0], fpc_lo[1], z_in], [fpc_hi[0], fpc_hi[1], z_panel_back])]);
  echo(str("RODS: nearest magnet edge ", r2(d_rm), " mm, antenna ", r2(d_ra), " mm, flex zone ", r2(d_rf), " mm"));
  assert(d_rm >= rod_mag_clear - eps, str("a rod is only ", d_rm, " mm from a magnet"));
  assert(d_ra >= rod_ant_clear - eps, str("a rod is only ", d_ra, " mm from the antenna"));
  assert(d_rf > 0, "a rod runs through the flex zone");
  for (i = [0 : len(rod_corners) - 1]) let(l = rod_leg(i))
    echo(str("CUT bezel rod ", corner_names[i], ": L-shape, ", r2(l[0]), " mm along the ", rod_corners[i][1] > 0 ? "top" : "bottom",
             " wall + ", r2(l[1]), " mm along the side wall (straight parts), bend ", r2(rod_R), " mm centre radius (",
             r2(rod_R - rod_d / 2), " inside), cut ", r2(rod_len(i)), " mm"));
  for (y = rod_back_y) echo(str("CUT back rod at Y ", y, ": straight, ", 2 * rod_back_x, " mm, X -", rod_back_x, " to ", rod_back_x));

  // metal near the antenna (inserts, nuts, magnets and discs, USB shells; rods above)
  metal = concat(
    [for (p = m3_pos) [[p[0] - m3_insert[0] / 2, p[1] - m3_insert[0] / 2, 0], [p[0] + m3_insert[0] / 2, p[1] + m3_insert[0] / 2, z_m3_hole]]],
    [for (p = car_screw_pos) [[p[0] - m25_nut[0], p[1] - m25_nut[0], 0], [p[0] + m25_nut[0], p[1] + m25_nut[0], z_car_top + m25_nut[1]]]],
    [for (p = mag_pos) [[p[0] - mag_d / 2, p[1] - mag_d / 2, z_mag[0]], [p[0] + mag_d / 2, p[1] + mag_d / 2, z_steel[1]]]],
    [for (i = [0 : len(usb_x) - 1]) [[usb_x[i] - usb_size[0] / 2, car_top + usb_overhang - usb_len, z_usb[i] - usb_size[1] / 2],
                                     [usb_x[i] + usb_size[0] / 2, car_top + usb_overhang, z_usb[i] + usb_size[1] / 2]]]);
  metal_d = min([for (m = metal) box_dist(m[0], m[1], ant_res_lo, ant_res_hi)]);
  assert(metal_d >= ant_metal_keepout, str("metal ", metal_d, " mm from the antenna"));

  // placement report (front-view X/Y, Z from the back face)
  echo(str("OUTER W x H x D = ", outer_w, " x ", outer_h, " x ", depth, " mm (caps +", cap_proud, ", rubber pads +", pad[1], ")"));
  echo(str("PANEL centre ", panel_c, ", window ", r2(win_size[0]), " x ", r2(win_size[1]),
           " at ", [0, r2(win_c[1])], ", chin ", r2(chin_h), " mm; rail joints at Y ", r2(win_top), " and ", r2(win_bot)));
  echo(str("STACK panel: front plate ", r2(z_lip), "-", depth, ", gasket ", r2(z_panel_front), "-", r2(z_lip), ", panel ",
           r2(z_panel_back), "-", r2(z_panel_front), ", rib tops ", r2(z_rib_top), " (+", foam_gap, " foam)"));
  echo(str("STACK carrier: floor 0-", car_floor, ", joints ", car_floor, "-", r2(z_car_pcb), ", board ", r2(z_car_pcb), "-", r2(z_car_top),
           ", parts to ", r2(z_car_top + car_comp_h), ", panel back ", r2(z_panel_back), " (air ", r2(z_panel_back - z_car_top - car_comp_h), ")"));
  echo(str("STACK driver HAT: plate 0-", back_t, ", stubs ", r2(z_drv_pcb - drv_stub_h), "-", r2(z_drv_pcb), ", board ", r2(z_drv_pcb), "-",
           r2(z_drv_pcb + drv_pcb_t), ", parts and nuts to ", r2(z_drv_top), ", screw tips ", drv_screw_len, ", panel back ",
           r2(z_panel_back), " (air ", r2(z_panel_back - z_drv_top), ")"));
  echo(str("STACK battery: floor 0-", bat_floor, ", foam ", bat_floor, "-", r2(z_bat[0]), ", cell ", r2(z_bat[0]), "-", r2(z_bat[1]),
           ", rib tops ", r2(z_rib_top), " (air ", r2(z_rib_top - z_bat[1]), ")"));
  echo(str("STACK buttons: recess floor 0-", r2(z_strip_floor), ", joints ", r2(z_strip_joints), "-", r2(z_strip_back), ", strip ",
           r2(z_strip_back), "-", r2(z_strip_front), ", switch body to ", r2(z_strip_front + sw_body_h), ", plunger to ",
           r2(z_plunger_top), ", gap ", -cap_preload, ", cap ", r2(z_cap_back), "-", r2(z_cap_face), ", sleeve ", r2(z_sleeve_end), "-", r2(z_lip),
           "; clicks after ", r2(cap_stroke), " mm with the face ", r2(cap_proud - cap_stroke), " mm proud"));
  echo(str("BUTTON PLUG at ", btn_plug_pos, ", ", btn_plug_size[0], " x ", btn_plug_size[1], " x ", btn_plug_size[2], " mm on the back cover (",
           r2(plug_lo[2]), "-", r2(plug_hi[2]), "): adapter board ", r2(box_dist(plug_lo, plug_hi, adapter_lo, adapter_hi)),
           " mm, folded flex ", r2(z_panel_back - fpc_t - plug_hi[2]), " mm above"));
  echo(str("STACK magnets: skin 0-", mag_skin, ", magnet ", r2(z_mag[0]), "-", r2(z_mag[1]), ", steel ", r2(z_steel[0]), "-", r2(z_steel[1]),
           ", epoxy to ", r2(z_mag_epoxy), ", tube to ", r2(z_mag_boss), "; rubber pad -", pad[1], "-0"));
  echo(str("STACK USB slots: XIAO centre ", r2(z_usb[0]), " (slot ", r2(z_usb[0] - usb_slot[1] / 2), "-", r2(z_usb[0] + usb_slot[1] / 2),
           "), charger centre ", r2(z_usb[1]), " (slot ", r2(z_usb[1] - usb_slot[1] / 2), "-", r2(z_usb[1] + usb_slot[1] / 2),
           "), front chamfer from ", depth - front_chamfer));
  echo(str("STACK antenna: ", r2(z_ant[0]), "-", r2(z_ant[1]), " on a fin on the back cover, ", r2(ant_wall_gap + ant_fin_t + ant_t),
           " mm inside the top wall, X ", ant_x,
           "; coax route ", r2(path_len(coax_path)), " of ", coax_len, " mm, nearest metal ", r2(metal_d), " mm"));
  echo(str("STACK rods: bezel rods ", r2(rod_zc - rod_d / 2), "-", r2(rod_zc + rod_d / 2), " in grooves ", r2(rod_z[0]), "-", r2(rod_z[1]),
           ", back rods ", r2(rod_back_zc - rod_d / 2), "-", r2(rod_back_zc + rod_d / 2), " at Y ", rod_back_y));
  echo(str("DRIVER board centre ", drv_pos, ", ", drv_size[0], " x ", drv_size[1], ", M2.5 x ", drv_screw_len,
           " countersunk from outside at ", drv_holes));
  echo(str("CARRIER board centre ", [0, car_top - car_size[1] / 2], ", ", car_size[0], " x ", car_size[1], ", M2.5 x ",
           car_screw_len, " countersunk at ", car_screw_pos));
  echo(str("M3 bosses (", len(m3_pos), "): ", m3_pos));
  echo(str("MAGNETS ", mag_pos, ": N52 ", mag_d, " x ", mag_h, " + steel ", steel_disc[0], " x ", steel_disc[1], ", ", mag_skin, " mm skin"));
  echo(str("CARRIER board edge to antenna ", r2(ant_x[0] - car_hi[0]), " mm (protoboard copper, keep it sparse there)"));
  echo(str("FPC zone X +-", fpc_zone[0] / 2, ", Y ", r2(panel_bot), " to ", r2(panel_bot + fpc_zone[1])));
  boss_report();
}

module boss_report() {
  // clearances around the bezel bosses that moved or are new in the thin case
  rc = bat_wall_t + bat_clear;
  r = m3_boss_d / 2;
  for (p = m3_pos) if (p[1] != -m3_cy || abs(p[0]) != m3_bottom_x) {
    d_bat = rect_dist(p, bat_pos - bat_out / 2 + [rc, rc], bat_pos + bat_out / 2 - [rc, rc]) - rc - r;
    d_mag = min([for (m = mag_pos) norm(p - m)]) - mag_boss_d / 2 - r;
    d_hat = min([for (h = drv_holes) norm(p - h)]) - drv_standoff_d / 2 - r;
    d_rib = min([for (s = rib_segments) seg_dist(p, s[0], s[1])]) - rib_pad / 2 - r;
    d_fpc = rect_dist(p, [-fpc_zone[0] / 2, panel_bot], [fpc_zone[0] / 2, panel_bot + fpc_zone[1]]) - r;
    d_rod = min([for (b = rod_boxes) rect_dist(p, [b[0][0], b[0][1]], [b[1][0], b[1][1]])]) - r;
    echo(str("BOSS ", p, ": battery cradle ", r2(d_bat), ", magnet tube ", r2(d_mag), ", HAT standoff ", r2(d_hat),
             ", rib pad ", r2(d_rib), d_rib < rib_keep ? " (rib cut back to rib_keep)" : "", ", flex zone ", r2(d_fpc), ", rod ", r2(d_rod), " mm"));
  }
}

module split_checks() {
  // back cover seam: features stand on the plate, where the seam is vertical
  // at back_split_x; the scarf below them runs back to back_seam_out
  seam = [back_seam_out, back_split_x];
  near_hole = max([for (h = drv_holes) h[0]]);
  back_items = [
    ["HAT standoffs", [near_hole - drv_standoff_d / 2, near_hole + drv_standoff_d / 2]],
    ["HAT board edge", [drv_lo[0], drv_hi[0]]],
    ["carrier tray rim", [-car_tray_x, car_tray_x]],
    ["vertical rib", [rib_mid_x[0] - rib_pad / 2, rib_mid_x[0] + rib_pad / 2]],
    ["M3 bosses at X -60", [-m3_bottom_x - m3_boss_d / 2, -m3_bottom_x + m3_boss_d / 2]],
    ["left magnet tubes", [mag_pos[0][0] - mag_boss_d / 2, mag_pos[0][0] + mag_boss_d / 2]]];
  for (it = back_items) {
    d = gap1d(it[1], [back_split_x, back_split_x]);
    echo(str("BACK SEAM X ", back_split_x, " to ", it[0], ": ", r2(d), " mm"));
    assert(d >= seam_clear_min, str(it[0], " only ", d, " mm from the back cover seam"));
  }
  d_csk = gap1d([near_hole - m25_csk_d / 2, near_hole + m25_csk_d / 2], [back_seam_out, back_seam_out]);
  echo(str("BACK SEAM outside face X ", r2(back_seam_out), " to the HAT countersinks: ", r2(d_csk), " mm"));
  assert(d_csk >= seam_clear_min, "HAT countersinks too close to the back cover seam");
  d_tie = gap1d([wire_x - tie_size[0] / 2, wire_x + tie_size[0] / 2], seam);
  echo(str("BACK SEAM to tie blocks: ", r2(d_tie), " mm; rib ends ", rib_seam_clear, " mm; both rods cross it"));
  assert(d_tie >= tie_seam_min, str("tie blocks only ", d_tie, " mm from the back cover seam"));
  // tabs and their pockets stay clear of the tray, standoffs, ties and rod channels
  for (y = back_tab_y) {
    lo = [back_split_x, y - back_tab[1] / 2 - tab_clear, 0];
    hi = [back_split_x + back_tab[0] + tab_clear, y + back_tab[1] / 2 + tab_clear, 1];
    d = min(concat(
      [box_dist(lo, hi, [-car_tray_x, car_rec_lo[1] - car_tray_wall, 0], [car_tray_x, car_top, 1])],
      [for (h = drv_holes) box_dist(lo, hi, [h[0] - drv_standoff_d / 2, h[1] - drv_standoff_d / 2, 0],
                                            [h[0] + drv_standoff_d / 2, h[1] + drv_standoff_d / 2, 1])],
      [for (t = wire_ties_y) box_dist(lo, hi, [wire_x - tie_size[0] / 2, t - tie_size[1] / 2, 0],
                                              [wire_x + tie_size[0] / 2, t + tie_size[1] / 2, 1])],
      [for (r = rod_back_y) box_dist(lo, hi, [-outer_w, r - rod_slot / 2 - rod_wall_t, 0], [outer_w, r + rod_slot / 2 + rod_wall_t, 1])]));
    echo(str("BACK TAB at Y ", y, ": ", r2(d), " mm to the nearest feature"));
    assert(d >= seam_clear_min, str("back cover tab at Y ", y, " only ", d, " mm from a feature"));
  }
  // bezel rail joints: where they cut material (the side border and wall),
  // nothing else may come close; the rods are meant to cross them
  jx = [win_size[0] / 2 - window_r - window_chamfer, outer_w / 2];
  bands = [[win_top - bezel_lap, win_top], [win_bot, win_bot + bezel_lap]];
  items = concat(
    [for (p = m3_pos) [str("M3 boss ", p), p - [1, 1] * m3_boss_d / 2, p + [1, 1] * m3_boss_d / 2]],
    [for (sx = [-1, 1], y = [pocket_top, pocket_bot]) ["pocket corner relief", [sx * pocket_edge[0], y] - [1, 1] * pocket_relief_d / 2,
                                                                                  [sx * pocket_edge[0], y] + [1, 1] * pocket_relief_d / 2]],
    [for (x = btn_x) ["button sleeve", [x, btn_y] - [1, 1] * sleeve_od / 2, [x, btn_y] + [1, 1] * sleeve_od / 2]],
    [["flex relief", [-fpc_relief_w / 2, pocket_bot - fpc_relief_d], [fpc_relief_w / 2, pocket_bot]]]);
  d_joint = min([for (it = items, s = [-1, 1], b = bands)
    box_dist([it[1][0], it[1][1], 0], [it[2][0], it[2][1], 0],
                                                  [s > 0 ? jx[0] : -jx[1], b[0], 0], [s > 0 ? jx[1] : -jx[0], b[1], 0])]);
  for (it = items, s = [-1, 1], b = bands) {
    d = box_dist([it[1][0], it[1][1], 0], [it[2][0], it[2][1], 0], [s > 0 ? jx[0] : -jx[1], b[0], 0], [s > 0 ? jx[1] : -jx[0], b[1], 0]);
    assert(d >= seam_clear_min, str(it[0], " only ", d, " mm from a rail joint"));
  }
  echo(str("RAIL JOINTS at Y ", r2(win_top), " and ", r2(win_bot), " (half-lap ", bezel_lap, " mm): nearest feature ", r2(d_joint), " mm"));
}
