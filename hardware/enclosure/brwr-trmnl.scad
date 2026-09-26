// =====================================================================
// brwr-trmnl enclosure: 10.3" e-paper Home Assistant display
// =====================================================================
// A two-part printed frame (bezel + back cover) that hangs on a fridge
// door with four rubber-coated pot magnets, on a wall with two keyholes,
// or leans into a small printed desk stand.
//
// Coordinates (front view, looking at the display): origin at the centre
// of the outline, +X right, +Y up, +Z toward the viewer. Z = 0 is the
// back face of the back cover (the face that touches the fridge); the
// front face of the bezel is at Z = depth. All dimensions are mm.
//
// Printable parts: bezel, back, button_caps, stand (render them with
// ./export.sh). Views: assembly, exploded, inside (back cover removed),
// fit_check (module envelopes in a see-through enclosure) and clash
// (intersections between parts and modules; empty when everything fits).
//
// OpenSCAD 2021.01 or newer. Open the Customizer to change parameters.
// =====================================================================

/* [Part] */
// What to render
part = "assembly"; // [assembly, exploded, inside, fit_check, clash, bezel, back, button_caps, stand]

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
pocket_relief_d = 2.0;   // mm, relief holes in the pocket corners for the glass corners (design)
gasket_t = 0.5;          // mm, foam gasket on the window lip (spec)
back_foam_t = 1.0;       // mm, foam strips between the ribs and the panel (spec)
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
depth = 25;              // mm, total depth incl. back cover (spec ~22; 25 so the 21 mm antenna fits the top wall)
border_top = 6;          // mm, panel top edge to outer top edge (spec ~6)
corner_r = 6;            // mm, outline corner radius (spec ~6)
wall_t = 2.5;            // mm, side walls (spec)
front_t = 2.0;           // mm, front face (spec)
back_t = 2.0;            // mm, back cover plate (spec)
front_chamfer = 1.5;     // mm, 45 deg chamfer on the front outer edge (design)
back_chamfer = 1.0;      // mm, 45 deg chamfer on the back outer edge (design)
seam_chamfer = 0.5;      // mm, V-groove where bezel and back cover meet (design)
window_chamfer = 1.5;    // mm, 45 deg chamfer on the window's front edge (spec: 45 deg)
window_land = 0.5;       // mm, straight land behind the window chamfer (design)
window_r = 1.0;          // mm, window corner radius (design)
lip_t = 1.2;             // mm, locating lip on the back cover, inside the walls (design)
lip_h = 2.0;             // mm, locating lip height (design)
lip_clear = 0.25;        // mm, lip to wall clearance (design)
bed_size = [250, 210];   // mm, printer bed the bezel must fit (Prusa MK4; 220 x 220 is too small)
print_gap = 4;           // mm, spacing between caps on the bed (design)

/* [Driver board: Waveshare e-Paper IT8951 Driver HAT (B)] */
drv_size = [65, 56.5];   // mm, RPi HAT footprint, long x short edge (Waveshare)
drv_pos = [-73, 0];      // mm, board centre; the short FFC edge faces +X (spec)
drv_pcb_t = 1.6;         // mm (Waveshare)
drv_hole_inset = 3.5;    // mm, M2.5 hole centres from the edges, 58 x 49 pattern (Waveshare)
drv_hole_d = 2.75;       // mm, M2.5 mounting holes (Waveshare)
drv_header_h = 8.5;      // mm, 2x20 female header below the PCB, faces the back cover (spec)
drv_header_clear = 1.0;  // mm, minimum gap between the header and the back cover (design)
drv_header_size = [50.8, 5.1]; // mm, 2x20 header body at 2.54 mm pitch (standard)
drv_header_side = 1;     // [-1, 1] header along the +Y (1) or -Y (-1) long edge (assumed)
drv_comp_h = 3.0;        // mm, tallest part on the panel side (estimate: 2.0 mm FFC socket, USB)
drv_air_min = 1.5;       // mm, minimum air gap from components to the panel (spec)
drv_standoff_h = 10;     // mm, back cover inner face to PCB underside (spec ~10)
drv_standoff_d = 6;      // mm, standoff diameter (design)
drv_ffc_socket = [5, 30, 2.0]; // mm, FFC socket envelope on the +X edge, X x Y x Z (estimate)

/* [Carrier board: XIAO ESP32-S3 + MiniBoost + TP4056] */
car_size = [70, 35];     // mm, protoboard W x H (spec)
car_pcb_t = 1.6;         // mm, protoboard thickness
car_comp_h = 9;          // mm, tallest part above the board (spec)
car_solder_h = 2;        // mm, solder joints below the board (spec)
car_air_min = 1.0;       // mm, minimum gap from the tallest part to the panel (design)
car_standoff_h = 4;      // mm, back cover inner face to PCB underside (design: 2 mm joints + margin)
car_boss_d = 6.5;        // mm, screw boss diameter (design)
car_clear = 0.4;         // mm, board to tray rim, per side (design)
car_tray_wall = 1.2;     // mm, tray rim thickness (design)
car_tray_rim = 1.0;      // mm, rim height above the PCB underside (design)
car_screws = [[-30, 30], [30, 4]]; // mm, M2.5 screws as [X, height above the board's bottom edge] (spec -30/+30; right one moved, see README)
car_wire_gap = [-33, 8]; // mm, gap in the tray rim for incoming wires, [X centre, width] (design)
usb_x = [-8, 22];        // mm, USB-C centres: XIAO, charger (spec)
usb_size = [9, 3.4];     // mm, USB-C receptacle opening W x H (spec)
usb_overhang = 1.5;      // mm, connector beyond the board's top edge (spec)
usb_len = 7.4;           // mm, receptacle length (typical USB-C)
usb_zc = 3.0;            // mm, connector centre above the board surface (spec)
usb_slot = [12.5, 6.5];  // mm, plug slot in the top wall, W x H (spec)
usb_slot_r = 2.0;        // mm, slot corner radius (design)
usb_label = ["USB", "CHARGE"]; // labels above the slots (spec)
label_size = 3.2;        // mm, label text size (design)
label_depth = 0.4;       // mm, label engraving depth (spec)
label_stagger = 0.3;     // mm, baseline offset between labels (mesh hygiene, invisible)
xiao_size = [17.8, 21];  // mm, XIAO ESP32-S3, X x Y (Seeed)
xiao_t = 1.0;            // mm, XIAO PCB (Seeed)
ufl_from_top = 20;       // mm, U.FL connector below the carrier's top edge (spec)
ufl_plug_h = 2.0;        // mm, U.FL plug above the XIAO PCB (estimate)

/* [Wi-Fi antenna] */
ant_x = [38, 80];        // mm, X range on the inside of the top wall (spec)
ant_h = 21;              // mm, reservation along Z (spec 42 x 21; Seeed A-02 FPC is 40 x 20)
ant_recess = 0.6;        // mm, recess in the top wall (spec)
ant_t = 0.3;             // mm, FPC and adhesive thickness (estimate)
ant_rim_keep = 1.0;      // mm, pocket rim kept in front of the antenna (design)
ant_feed_dx = 3;         // mm, coax exit from the antenna's -X end (estimate)
ant_metal_keepout = 10;  // mm, nothing metallic closer than this (spec)
coax_d = 1.13;           // mm, antenna coax (spec)
coax_len = 80;           // mm, antenna coax (spec)
coax_notch = 3;          // mm, notch width and depth in ribs for the coax (spec)

/* [Battery: LiPo pouch] */
bat_size = [100, 60, 6]; // mm, L x W x T in landscape: 6060100 5000 mAh (spec); 105080: [80, 50, 10]
bat_pos = [56, 0];       // mm, cell centre (spec)
bat_clear = 1.0;         // mm per side (spec)
bat_wall_h = 2.5;        // mm, cradle wall height (spec)
bat_wall_t = 1.2;        // mm, cradle wall thickness (design)
bat_foam_t = 1.0;        // mm, foam pad under the cell (spec)
bat_lead_slot = 20;      // mm, slot in the cradle's -X wall for the lead (design)
bat_air_min = 1.0;       // mm, minimum gap from the cell to the panel side ribs (design)

/* [Front buttons] */
btn_x = [-26, 0, 26];    // mm, button centres (spec)
btn_y = -89;             // mm, button centres (design: below the flex relief, strip clears the bottom wall)
sw_size = 12;            // mm, 12 x 12 tactile switch body (spec)
sw_h = 7.3;              // mm, switch height incl. plunger (spec)
sw_body_h = 3.5;         // mm, body without plunger (typical 12 x 12 x 7.3 switch)
sw_plunger_d = 7;        // mm (spec)
strip_clear = 0.3;       // mm, strip to bottom wall (design)
strip_size = [84, 20];   // mm, protoboard strip W x H (spec)
strip_t = 1.6;           // mm, protoboard thickness
strip_solder_h = 2;      // mm, joints behind the strip (design)
strip_screw_x = [-38, 38]; // mm, M2.5 insert bosses on the bezel (spec)
strip_boss_d = 6;        // mm (design)
cap_d = 11;              // mm, cap face and stem (spec)
cap_hole_d = 11.4;       // mm, hole in the front face (spec)
cap_proud = 0.5;         // mm, cap face in front of the bezel face (spec 0 to 0.5)
cap_flange_d = 13.4;     // mm, retaining flange behind the front face (design)
cap_flange_t = 0.8;      // mm, flange cylinder behind its 45 deg cone (design)
cap_preload = -0.2;      // mm, plunger pre-travel at rest; negative = free gap above the plunger (lead: -0.2)
sw_travel = 0.25;        // mm, switch travel to the click (Omron B3F type 12 x 12)
cap_gap_max = 0.5;       // mm, largest free gap allowed before the cap feels loose (design)
sleeve_od = 14.6;        // mm, guide sleeve behind the front face (design)
sleeve_len = 2.0;        // mm, guide sleeve length incl. the conical seat (design)
key_size = [1.2, 1.0];   // mm, anti-rotation key on the stem, width x radial height (design)
key_clear = 0.2;         // mm, key to keyway clearance (design)
key_boss_wall = 1.2;     // mm, sleeve wall around the keyway (design)
symbol_depth = 0.6;      // mm, engraved symbol depth (spec)
symbol_size = 5.0;       // mm, symbol size (design)

/* [Magnets: supermagnete ITNG-22] */
mag_d = 22;              // mm, rubber-coated pot magnet (supermagnete ITNG-22)
mag_h = 6.0;             // mm, height incl. rubber (ITNG-22)
mag_pos = [[-90, 65], [90, 65], [-90, -65], [90, -65]]; // mm, centres; count = number of entries (lead: +-90/+-65; no 5th/6th spot meets the rules)
mag_proud = 0.5;         // mm, rubber face in front of the back surface (spec)
mag_clear = 0.3;         // mm, pocket diametral clearance (design)
mag_wall = 2.0;          // mm, radial wall around the pocket (design)
mag_floor = 2.0;         // mm, back wall between the pocket and the screw head (design)
mag_screw_len = 6;       // mm, M4 x 6 A2 screw from inside (spec)
mag_screw_d = 4.0;       // mm, M4 (spec)
mag_screw_hole = 4.3;    // mm (spec)
mag_screw_head = [8, 2.8]; // mm, M4 pan/button head D x H (ISO 7045 / 7380, clearance only)
mag_tool_clear = 3;      // mm, free space around the screw head for the screwdriver (design)
mag_thread_depth = 5.0;  // mm, usable thread depth from the magnet's back (spec: through thread)
mag_min_engage = 3.0;    // mm, minimum thread engagement (>= 4 threads at 0.7 pitch)
mag_face_skin = 1.0;     // mm, minimum between the screw tip and the magnet's front face (design)
mag_keep_board = 36;     // mm, magnet centre to driver/carrier board edge, >= 25 mm from the magnet's edge (lead: < 5 mT)
mag_keep_ant = 35;       // mm, magnet centre to antenna reservation (spec rule)

/* [Screws and inserts] */
m3_insert = [4.0, 5.0];  // mm, M3 heat-set insert hole D x depth (spec)
m3_clear_d = 3.4;        // mm, M3 clearance hole (ISO 273 medium)
m3_csk_d = 6.8;          // mm, countersink for M3 flat head (ISO 10642 / DIN 7991)
m3_screw_len = 8;        // mm, M3 x 8 countersunk (spec)
m3_tip_clear = 0.5;      // mm, clearance beyond the screw tip (design)
m3_boss_d = 7.2;         // mm (design)
m3_boss_inset = 5.8;     // mm, boss centre from the outer edge (design)
m3_side_y = 40;          // mm, Y of the two side-wall bosses (design)
m3_bottom_x = 60;        // mm, |X| of the two bottom-wall bosses (design)
boss_floor = 1.0;        // mm, solid end beyond blind holes (design)
m25_insert = [3.6, 4.2]; // mm, M2.5 heat-set insert hole D x depth (typical 4 mm insert)
m25_clear_d = 2.9;       // mm, M2.5 clearance hole (ISO 273 medium)
m25_head_h = 2.0;        // mm, M2.5 pan head height (ISO 7045, for the antenna metal check)

/* [Panel support ribs] */
rib_t = 1.6;             // mm, rib web thickness (design)
rib_pad = 4.0;           // mm, rib top pad for the foam strips (design)
rib_pad_t = 0.8;         // mm, pad thickness above the 45 deg flare (design)
rib_inset = 0.55;        // mm, perimeter rib centre inside the panel edge (design: keeps 1 mm to the battery)
rib_mid_y = [36, -35];   // mm, Y of the two horizontal interior ribs (design)
rib_mid_x = [-45, 45];   // mm, X of the two vertical ribs in the upper corners (design)
rib_gap_ffc = [-60, -10]; // mm, X range left open in the lower interior rib for the FFC and wires (design)
rib_gap_wire = 10;       // mm, gap in the upper interior rib where the wires pass (design)
rib_keep = 1.0;          // mm, rib clearance around bosses and modules (design)

/* [Wire route] */
wire_x = -34;            // mm, button wires run up the back cover here, between driver and battery (spec)
wire_ties_y = [-90, -25, 15, 52]; // mm, zip-tie points (design: none inside the FPC zone)
tie_size = [8, 5, 4];    // mm, tie block X x Y x Z (design)
tie_slot = [3.2, 1.8];   // mm, tunnel for a 2.5 mm zip tie, Y x Z (design)

/* [Wall hanging and desk stand] */
keyholes = true;         // two keyholes in the back cover
keyhole_pos = [[-60, 56], [60, 56]]; // mm, head-hole centres; the screw rests keyhole_travel higher (design)
keyhole_head_d = 8.5;    // mm, for screw heads up to 8 mm (design)
keyhole_slot_w = 4.2;    // mm, for 4 mm screws (design)
keyhole_travel = 10;     // mm (design)
keyhole_cavity_h = 3.5;  // mm, head pocket behind the plate (design)
keyhole_wall = 1.6;      // mm (design)
keyhole_roof = 1.2;      // mm (design)
keyhole_track_clear = 0.3; // mm, head pocket wider than the head hole (design)
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
logo_pos = [0, -88];     // mm, centre, front-view coordinates (design)
text_font = "Liberation Sans:style=Bold"; // any installed font

/* [Rendering] */
use_stl = false;         // import stl/bezel.stl and stl/back.stl instead of rebuilding them (fast previews)
upright = false;         // stand the scene up (+Y becomes +Z) for PNG cameras
explode_gap = 60;        // mm, layer spacing in the exploded view
show_labels = true;      // module names in the inside and fit_check views
layer_h = 0.2;           // mm, print layer height (for the bridged screw holes)
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

// illustration only (renders and fit check), not used for printed geometry
sym_tri_base = 0.4;      // triangle symbol: base position, fraction of symbol_size
sym_dot = 0.8;           // circle symbol: diameter, fraction of symbol_size
drv_chip = [14, 14, 1.4];            // mm, IT8951 package on the driver HAT
car_modules = [                      // [X centre, Y below top edge, size, colour]
  [usb_x[1], 13, [17, 26, 1.2], "#2c6e4f"],     // TP4056 USB-C charger module
  [-24.5, 25, [11.5, 18, 3], "#26282b"],        // MiniBoost 5 V
  [-11, 27, [11, 8, 8], "#2d4f8a"]];            // 220 uF capacitor lying down
xiao_shield = [12, 11, 2.2];         // mm, XIAO RF shield can
fpc_fold_h = 18;                     // mm, folded flex visible behind the panel
fpc_adapter_x = -25;                 // mm, adapter board centre X in the flex zone
mock_margin = 8;                     // mm, screen mock inset from the window
mock_ink = [                         // [x, y, w, h] as fractions of the mock area, dark
  [0, 0.86, 0.42, 0.07], [0.83, 0.86, 0.17, 0.07], [0, 0.40, 0.36, 0.33]];
mock_grey = [                        // same, mid grey
  [0.40, 0.66, 0.60, 0.07], [0.40, 0.54, 0.48, 0.07], [0.40, 0.42, 0.54, 0.07],
  [0, 0, 0.32, 0.27], [0.34, 0, 0.32, 0.27], [0.68, 0, 0.32, 0.27]];
explode_z = [-0.6, 0, 1.0, 1.0, 1.6, 2.3];   // x explode_gap: magnets, back, panel, strip, caps, bezel
img_label = 5;                       // mm, text size of module labels
ring_w = 0.8;                        // mm, width of the magnet keep-out rings

// ---- Z levels --------------------------------------------------------
z_in = back_t;                                   // back cover inner face = bezel back edge
z_lip = depth - front_t;                         // back face of the front plate (window lip)
z_panel_front = z_lip - gasket_t;
z_panel_back = z_panel_front - panel_t;
z_pocket = z_lip - pocket_depth;                 // pocket floor, seen from behind
z_rib_top = z_panel_back - (back_foam_t - back_foam_squeeze);

// ---- outline and panel -----------------------------------------------
in_w = outer_w - 2 * wall_t;
in_h = outer_h - 2 * wall_t;
panel_top = outer_h / 2 - border_top;
panel_bot = panel_top - panel_h;
panel_c = [0, (panel_top + panel_bot) / 2];
pocket_size = [panel_w + 2 * pocket_clear, panel_h + 2 * pocket_clear];
pocket_top = panel_top + pocket_clear;
pocket_bot = panel_bot - pocket_clear;
win_size = [panel_w - 2 * border_side, panel_h - border_side - border_bottom];
win_c = [0, (panel_top - border_side + panel_bot + border_bottom) / 2];
chin_h = panel_bot + outer_h / 2;

// ---- driver board ----------------------------------------------------
z_drv_pcb = z_in + drv_standoff_h;
z_drv_top = z_drv_pcb + drv_pcb_t + drv_comp_h;
drv_lo = drv_pos - drv_size / 2;
drv_hi = drv_pos + drv_size / 2;
drv_holes = [for (sx = [-1, 1], sy = [-1, 1])
  drv_pos + [sx * (drv_size[0] / 2 - drv_hole_inset), sy * (drv_size[1] / 2 - drv_hole_inset)]];
drv_header_y = drv_pos[1] + drv_header_side * (drv_size[1] / 2 - drv_hole_inset);

// ---- carrier board ---------------------------------------------------
car_top = in_h / 2;                              // top edge against the top wall
car_lo = [-car_size[0] / 2, car_top - car_size[1]];
car_hi = [car_size[0] / 2, car_top];
z_car_pcb = z_in + car_standoff_h;
z_car_top = z_car_pcb + car_pcb_t;
z_usb = z_car_top + usb_zc;
car_screw_pos = [for (s = car_screws) [s[0], car_lo[1] + s[1]]];
car_tray_x = car_size[0] / 2 + car_clear + car_tray_wall;
ufl_pos = [usb_x[0], car_top - ufl_from_top];
z_ufl = z_car_top + xiao_t + ufl_plug_h;

z_label = (z_usb + usb_slot[1] / 2 + depth - front_chamfer) / 2;   // USB labels, between slot and chamfer

// ---- antenna ---------------------------------------------------------
z_ant = [z_lip - ant_h, z_lip];                  // front edge on the front plate
ant_lo = [ant_x[0], in_h / 2 + ant_recess - ant_t, z_ant[0]];   // the FPC itself, on the recess floor
ant_hi = [ant_x[1], in_h / 2 + ant_recess, z_ant[1]];
ant_res_lo = [ant_x[0], in_h / 2, z_ant[0]];                       // reservation: the whole recess,
ant_res_hi = ant_hi;                                               // measured from the wall's inner face
coax_path = [
  [ant_x[0] + ant_feed_dx, in_h / 2 + ant_recess - ant_t - coax_d / 2, (z_ant[0] + z_ant[1]) / 2],
  [ant_x[0] - coax_notch, in_h / 2 - coax_notch, z_car_top + car_comp_h + coax_notch / 2],   // over the carrier
  [ufl_pos[0], ufl_pos[1], z_ufl]];

// ---- battery ---------------------------------------------------------
bat_in = [bat_size[0] + 2 * bat_clear, bat_size[1] + 2 * bat_clear];
bat_out = bat_in + 2 * [bat_wall_t, bat_wall_t];
z_bat = [z_in + bat_foam_t, z_in + bat_foam_t + bat_size[2]];

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

// ---- magnets ---------------------------------------------------------
mag_pocket_d = mag_d + mag_clear;
mag_boss_d = mag_pocket_d + 2 * mag_wall;
z_mag_seat = mag_h - mag_proud;                  // pocket floor = magnet back face
z_mag_boss = z_mag_seat + mag_floor;             // screw head seat
mag_engage = mag_screw_len - mag_floor;          // thread length inside the magnet
z_screw_tip = z_mag_boss - mag_screw_len;

// ---- M3 bosses (bezel) ------------------------------------------------
m3_cx = outer_w / 2 - m3_boss_inset;
m3_cy = outer_h / 2 - m3_boss_inset;
m3_pos = [
  [-m3_cx, m3_cy], [m3_cx, m3_cy], [-m3_cx, -m3_cy], [m3_cx, -m3_cy],   // corners
  [-m3_cx, m3_side_y], [m3_cx, m3_side_y],                              // side walls
  [-m3_bottom_x, -m3_cy], [m3_bottom_x, -m3_cy]];                      // bottom wall
z_m3_hole = m3_screw_len + m3_tip_clear;
z_m3_boss = z_m3_hole + boss_floor;

// ---- ribs --------------------------------------------------------------
rib_px = panel_w / 2 - rib_inset;
rib_ty = panel_top - rib_inset;
rib_by = panel_bot + rib_inset;
rib_car_x = car_tray_x + rib_keep;
rib_fpc_x = fpc_zone[0] / 2 + rib_keep;
rib_segments = [
  [[-rib_px, rib_by], [-rib_px, rib_ty]],                  // left edge
  [[rib_px, rib_by], [rib_px, rib_ty]],                    // right edge (outer wall of the battery cradle)
  [[-rib_px, rib_ty], [-rib_car_x, rib_ty]],               // top edge, left of the carrier
  [[rib_car_x, rib_ty], [rib_px, rib_ty]],                 // top edge, right of the carrier
  [[-rib_px, rib_by], [-rib_fpc_x, rib_by]],               // bottom edge, left of the flex
  [[rib_fpc_x, rib_by], [rib_px, rib_by]],                 // bottom edge, right of the flex
  [[-rib_px, rib_mid_y[0]], [rib_px, rib_mid_y[0]]],       // above driver board and battery
  [[-rib_px, rib_mid_y[1]], [rib_px, rib_mid_y[1]]],       // below driver board and battery
  [[rib_mid_x[0], rib_mid_y[0]], [rib_mid_x[0], rib_ty]],  // upper left
  [[rib_mid_x[1], rib_mid_y[0]], [rib_mid_x[1], rib_ty]]]; // upper right
coax_notch_x = rib_car_x + coax_notch;                    // where the coax crosses the top rib

// ---- colours -------------------------------------------------------------
c_bezel = "#34383d";
c_back = "#6f7882";
c_cap = "#e7e3db";
c_panel = "#dedcd4";
c_ink = "#3e3f42";
c_ink2 = "#9d9a92";
c_magnet = "#161616";
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
  else if (part == "bezel") bezel_print();
  else if (part == "back") back_print();
  else if (part == "button_caps") caps_print();
  else if (part == "stand") stand();
  else assert(false, str("unknown part: ", part));
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

module chamfered_body(z0, z1, c_bot, c_top) {
  // outline prism with 45 deg chamfers on its bottom and top outer edges
  hull() {
    slab(c_bot, z0, z0 + eps);
    slab(0, z0 + c_bot, z1 - c_top);
    slab(c_top, z1 - eps, z1);
  }
}

module box(lo, hi) {
  translate(lo) cube(hi - lo);
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

module label(txt, size, h = 2 * eps) {
  // flat text, readable from the front (+Z)
  linear_extrude(h) text(txt, size = size, font = text_font, halign = "center", valign = "center");
}

// =====================================================================
// Bezel: front face, window, panel pocket, walls, bosses
// =====================================================================
module bezel() {
  difference() {
    union() {
      bezel_shell();
      pocket_rim();
      button_sleeves();
      strip_bosses();
      m3_bosses();
    }
    window_cut();
    pocket_cut();
    flex_relief_cut();
    antenna_cuts();
    button_bores();
    strip_insert_holes();
    m3_insert_holes();
    usb_notches();
    usb_labels();
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
  translate(panel_c) {
    square(pocket_size, center = true);
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx * pocket_size[0] / 2, sy * pocket_size[1] / 2]) circle(d = pocket_relief_d);
  }
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

module antenna_cuts() {
  // 0.6 mm recess on the inside of the top wall, and the pocket rim cut back in front of it
  box([ant_x[0], in_h / 2 - eps, z_ant[0] - eps], [ant_x[1], in_h / 2 + ant_recess, z_ant[1]]);
  box([ant_x[0] - rib_keep, pocket_top + ant_rim_keep, z_pocket - eps], [ant_x[1] + rib_keep, in_h / 2, z_lip]);
}

module button_sleeves() {
  for (x = btn_x) translate([x, btn_y, z_sleeve_end]) {
    cylinder(d = sleeve_od, h = sleeve_len + eps, $fn = fn_button);
    // local thickening around the keyway (at -Y)
    translate([-(key_size[0] / 2 + key_clear + key_boss_wall), -(keyway_r() + key_boss_wall), 0])
      cube([key_size[0] + 2 * (key_clear + key_boss_wall), keyway_r() + key_boss_wall - cap_hole_d / 2 + key_boss_wall, sleeve_len + eps]);
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

module wall_ring_2d() {
  difference() { outline(0); outline(wall_t); }
}

module m3_anchor_2d(p) {
  // the piece of wall a boss hangs from
  intersection() { wall_ring_2d(); translate(p) square(m3_boss_d, center = true); }
}

module m3_boss_2d(p) {
  // footprint of a boss and its gusset (used for clearances on the back cover)
  hull() { translate(p) circle(d = m3_boss_d); m3_anchor_2d(p); }
}

module m3_bosses() {
  // insert boss hanging from the wall, with a 45 deg gusset so it prints face-down
  for (p = m3_pos) hull() {
    translate([p[0], p[1], z_in]) cylinder(d = m3_boss_d, h = z_m3_boss - z_in);
    translate([0, 0, z_in]) linear_extrude(z_m3_boss - z_in + m3_boss_d) m3_anchor_2d(p);
  }
}

module m3_insert_holes() {
  for (p = m3_pos) translate([p[0], p[1], z_in - eps]) {
    cylinder(d = m3_insert[0], h = m3_insert[1] + eps);
    cylinder(d = m3_clear_d, h = z_m3_hole - z_in + eps);
  }
}

module usb_slot_2d(x, grow = 0) {
  translate([x, z_usb]) offset(r = grow) rrect(usb_slot, usb_slot_r);
}

module usb_notches() {
  // slot for each plug, open toward the back edge so the carrier can drop in
  // with the back cover; the back cover's tongue closes the lower half
  for (x = usb_x) through_top_wall() {
    usb_slot_2d(x);
    translate([x - usb_slot[0] / 2, z_in - cut_over]) square([usb_slot[0], z_usb - z_in + cut_over]);
  }
}

module usb_labels() {
  // engraved in the top wall, read from above with the front toward you
  // (each label on its own baseline: collinear baselines across labels make
  //  the exporter emit zero-area triangles)
  for (i = [0 : len(usb_x) - 1])
    translate([usb_x[i], outer_h / 2 - label_depth, z_label + i * label_stagger]) rotate([-90, 0, 0])
      linear_extrude(label_depth + cut_over)
        text(usb_label[i], size = label_size, font = text_font, halign = "center", valign = "center");
}

// =====================================================================
// Back cover: plate, magnet pockets, standoffs, cradle, tray, ribs
// =====================================================================
module back_cover() {
  difference() {
    union() {
      chamfered_body(0, back_t, back_chamfer, seam_chamfer);
      locating_lip();
      usb_tongues();
      driver_standoffs();
      carrier_tray();
      battery_cradle();
      magnet_bosses();
      if (keyholes) keyhole_housings();
      wire_ties();
      ribs();
    }
    magnet_pockets();
    m3_screw_holes();
    driver_insert_holes();
    carrier_insert_holes();
    if (keyholes) keyhole_cuts();
    back_logo();
  }
}

module locating_lip() {
  translate([0, 0, back_t - eps]) linear_extrude(lip_h + eps)
    difference() {
      outline(wall_t + lip_clear);
      outline(wall_t + lip_clear + lip_t);
      for (p = m3_pos) offset(delta = lip_clear) m3_boss_2d(p);
      // the carrier and the antenna sit against the top wall
      translate([-rib_car_x, in_h / 2 - 2 * lip_t - wall_t]) square([rib_car_x + ant_x[1] + rib_keep, 3 * wall_t]);
    }
}

module usb_tongues() {
  // fills the lower half of each USB notch in the bezel's top wall
  for (x = usb_x) through_top_wall(in_h / 2 + lip_clear, outer_h / 2)
    difference() {
      translate([x - usb_slot[0] / 2 + lip_clear, back_t - seam_chamfer])
        square([usb_slot[0] - 2 * lip_clear, z_usb - back_t + seam_chamfer]);
      usb_slot_2d(x, lip_clear);
    }
}

module driver_standoffs() {
  for (h = drv_holes) translate([h[0], h[1], back_t - eps])
    cylinder(d = drv_standoff_d, h = drv_standoff_h + eps);
}

module driver_insert_holes() {
  for (h = drv_holes) translate([h[0], h[1], z_drv_pcb - m25_insert[1]])
    cylinder(d = m25_insert[0], h = m25_insert[1] + eps);
}

module carrier_tray() {
  for (p = car_screw_pos) translate([p[0], p[1], back_t - eps])
    cylinder(d = car_boss_d, h = car_standoff_h + eps);
  // rim on the left, right and bottom edges; the top edge rests against the top wall
  translate([0, 0, back_t - eps]) linear_extrude(car_standoff_h + car_tray_rim + eps)
    difference() {
      translate([-car_tray_x, car_lo[1] - car_clear - car_tray_wall])
        square([2 * car_tray_x, car_size[1] + car_clear + car_tray_wall - lip_clear]);
      translate([-car_tray_x + car_tray_wall, car_lo[1] - car_clear])
        square([2 * (car_tray_x - car_tray_wall), car_size[1] + car_clear + cut_over]);
      translate([car_wire_gap[0] - car_wire_gap[1] / 2, car_lo[1] - car_clear - car_tray_wall - eps])
        square([car_wire_gap[1], car_tray_wall + 2 * eps]);
    }
}

module carrier_insert_holes() {
  for (p = car_screw_pos) translate([p[0], p[1], z_car_pcb - m25_insert[1]])
    cylinder(d = m25_insert[0], h = m25_insert[1] + eps);
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

module magnet_bosses() {
  for (p = mag_pos) translate([p[0], p[1], back_t - eps])
    cylinder(d = mag_boss_d, h = z_mag_boss - back_t + eps);
}

module magnet_pockets() {
  // pocket open to the outside; the screw hole is bridged in two layers
  // (slot, then square) so the pocket ceiling prints without supports
  for (p = mag_pos) translate([p[0], p[1], 0]) {
    translate([0, 0, -eps]) cylinder(d = mag_pocket_d, h = z_mag_seat + eps);
    translate([0, 0, z_mag_seat - eps]) {
      translate([-mag_pocket_d / 2, -mag_screw_hole / 2, 0]) cube([mag_pocket_d, mag_screw_hole, layer_h + eps]);
      translate([-mag_screw_hole / 2, -mag_screw_hole / 2, 0]) cube([mag_screw_hole, mag_screw_hole, 2 * layer_h + eps]);
      cylinder(d = mag_screw_hole, h = mag_floor + 2 * eps);
    }
  }
}

module m3_screw_holes() {
  // countersunk from the outside (90 deg); cone and hole share one segment count
  for (p = m3_pos) translate([p[0], p[1], 0]) {
    translate([0, 0, -cut_over]) cylinder(d = m3_clear_d, h = back_t + lip_h + 2 * cut_over, $fn = fn_screw);
    cylinder(d1 = m3_csk_d, d2 = m3_clear_d, h = (m3_csk_d - m3_clear_d) / 2, $fn = fn_screw);
  }
}

module keyhole_2d() {
  circle(d = keyhole_head_d);
  hull() { circle(d = keyhole_slot_w); translate([0, keyhole_travel]) circle(d = keyhole_slot_w); }
}

module keyhole_track_2d() {
  // head pocket behind the plate, a little wider than the keyhole
  hull() for (y = [0, keyhole_travel]) translate([0, y]) circle(d = keyhole_head_d + 2 * keyhole_track_clear);
}

module keyhole_housings() {
  for (p = keyhole_pos) translate([p[0], p[1], back_t - eps])
    linear_extrude(keyhole_cavity_h + keyhole_roof + eps) offset(r = keyhole_wall) keyhole_track_2d();
}

module keyhole_cuts() {
  for (p = keyhole_pos) translate([p[0], p[1], 0]) {
    translate([0, 0, -eps]) linear_extrude(back_t + 2 * eps) keyhole_2d();
    translate([0, 0, back_t - eps]) linear_extrude(keyhole_cavity_h + eps) keyhole_track_2d();
  }
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
  // ribs may merge with a magnet boss, but keep the screw head reachable
  for (p = mag_pos) translate([p[0], p[1], -cut_over]) cylinder(r = mag_screw_head[0] / 2 + mag_tool_clear, h = h);
  if (keyholes) for (p = keyhole_pos) translate([p[0], p[1], -cut_over]) linear_extrude(h)
    offset(r = keyhole_wall + rib_keep) keyhole_track_2d();
  // flex zone and relief (nothing but foam there)
  box([-fpc_zone[0] / 2 - rib_keep, pocket_bot - fpc_relief_d, -cut_over],
      [fpc_zone[0] / 2 + rib_keep, panel_bot + fpc_zone[1] + rib_keep, depth + cut_over]);
  // carrier tray, driver board, battery (up to the cell top)
  box([-rib_car_x, car_lo[1] - car_clear - car_tray_wall - rib_keep, -cut_over], [rib_car_x, outer_h, depth + cut_over]);
  box([drv_lo[0] - rib_keep, drv_lo[1] - rib_keep, -cut_over], [drv_hi[0] + rib_keep, drv_hi[1] + rib_keep, z_drv_top + drv_air_min]);
  translate([bat_pos[0], bat_pos[1], -cut_over]) linear_extrude(z_bat[1] + cut_over + rib_keep) rrect(bat_in, bat_clear);
  // wire and FFC passages, coax notch
  box([wire_x - rib_gap_wire / 2, rib_mid_y[0] - rib_pad, -cut_over], [wire_x + rib_gap_wire / 2, rib_mid_y[0] + rib_pad, depth + cut_over]);
  box([rib_gap_ffc[0], rib_mid_y[1] - rib_pad, -cut_over], [rib_gap_ffc[1], rib_mid_y[1] + rib_pad, depth + cut_over]);
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
  u = [-sin(stand_tilt), cos(stand_tilt)];        // up along the back rest
  v = [cos(stand_tilt), sin(stand_tilt)];         // forward along the seat
  s0 = [0, stand_seat_h];                         // seat, back corner
  s1 = s0 + (depth + stand_clear) * v;            // seat, front corner
  s2 = s1 + stand_lip_h * u;
  s3 = s2 + stand_t * v;
  s4 = s1 + stand_t * v;
  f = [s4[0] + s4[1], 0];                         // 45 deg down to the table
  r0 = s0 + stand_rest_h * u;
  r1 = r0 - stand_t * v;
  k = r1 - ((r1[1] - stand_brace_h) / cos(stand_tilt)) * u;
  b = [-stand_foot, 0];
  color(c_stand) translate([-stand_w / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(stand_w)
    polygon([b, f, s4, s3, s2, s1, s0, r0, r1, k]);
}

// =====================================================================
// Print layouts (STL orientation)
// =====================================================================
module bezel_print() { translate([0, 0, depth]) rotate([0, 180, 0]) bezel(); }
module back_print() { back_cover(); }
module caps_print() {
  for (i = [0 : len(btn_x) - 1]) translate([(i - 1) * (cap_flange_d + print_gap), 0, cap_len])
    rotate([180, 0, 0]) cap_local(i);
}

// Parts in assembled position, optionally from pre-rendered STLs
module bezel_part() {
  if (use_stl) rotate([0, 180, 0]) translate([0, 0, -depth]) import("stl/bezel.stl");
  else bezel();
}
module back_part() {
  if (use_stl) import("stl/back.stl"); else back_cover();
}

// =====================================================================
// Bought parts and module envelopes (assembled position)
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

module driver_model() {
  translate([drv_pos[0], drv_pos[1], z_drv_pcb]) {
    color(c_drv) difference() {
      translate(-drv_size / 2) cube([drv_size[0], drv_size[1], drv_pcb_t]);
      for (h = drv_holes) translate([h[0] - drv_pos[0], h[1] - drv_pos[1], -cut_over])
        cylinder(d = drv_hole_d, h = drv_pcb_t + 2 * cut_over);
    }
    color(c_switch) translate([-drv_header_size[0] / 2, drv_header_y - drv_pos[1] - drv_header_size[1] / 2, -drv_header_h])
      cube([drv_header_size[0], drv_header_size[1], drv_header_h]);
    color(c_switch) translate([-drv_chip[0] / 2, -drv_chip[1] / 2, drv_pcb_t]) cube(drv_chip);
    color(c_metal) translate([drv_size[0] / 2 - drv_ffc_socket[0], -drv_ffc_socket[1] / 2, drv_pcb_t])
      cube(drv_ffc_socket);
  }
}

module sbox(lo, hi, s) {
  // box shrunk by s on every side (s = 0: exact envelope)
  box(lo + [s, s, s], hi - [s, s, s]);
}

module driver_env(s = 0) {
  sbox([drv_lo[0], drv_lo[1], z_drv_pcb], [drv_hi[0], drv_hi[1], z_drv_top], s);
  sbox([drv_pos[0] - drv_header_size[0] / 2, drv_header_y - drv_header_size[1] / 2, z_drv_pcb - drv_header_h],
       [drv_pos[0] + drv_header_size[0] / 2, drv_header_y + drv_header_size[1] / 2, z_drv_pcb], s);
}

module carrier_model() {
  color(c_car) box([car_lo[0], car_lo[1], z_car_pcb], [car_hi[0], car_hi[1], z_car_top]);
  // XIAO at the top edge, the other modules where they fit (illustration)
  color(c_switch) translate([usb_x[0] - xiao_size[0] / 2, car_top - xiao_size[1], z_car_top])
    cube([xiao_size[0], xiao_size[1], xiao_t]);
  color(c_metal) translate([usb_x[0] - xiao_shield[0] / 2, car_top - (xiao_size[1] + xiao_shield[1]) / 2, z_car_top + xiao_t])
    cube(xiao_shield);
  for (m = car_modules) color(m[3]) translate([m[0] - m[2][0] / 2, car_top - m[1] - m[2][1] / 2, z_car_top]) cube(m[2]);
  color(c_metal) for (x = usb_x) usb_receptacle(x);
  color(c_metal) translate([ufl_pos[0], ufl_pos[1], z_car_top + xiao_t]) cylinder(d = 2 * coax_d, h = ufl_plug_h);
}

module usb_receptacle(x) {
  translate([x, car_top + usb_overhang - usb_len / 2, z_usb]) rotate([90, 0, 0])
    linear_extrude(usb_len, center = true) rrect(usb_size, usb_size[1] / 2 - eps);
}

module carrier_env(s = 0) {
  sbox([car_lo[0], car_lo[1], z_car_pcb], [car_hi[0], car_hi[1], z_car_top + car_comp_h], s);
  difference() {
    sbox([car_lo[0], car_lo[1], z_car_pcb - car_solder_h], [car_hi[0], car_hi[1], z_car_pcb], s);
    // keep solder joints away from the two screw bosses
    for (p = car_screw_pos) translate([p[0], p[1], 0]) cylinder(d = car_boss_d + 2 * car_clear, h = depth);
  }
  for (x = usb_x) sbox([x - usb_size[0] / 2, car_top + usb_overhang - usb_len, z_usb - usb_size[1] / 2],
                       [x + usb_size[0] / 2, car_top + usb_overhang, z_usb + usb_size[1] / 2], s);
}

module battery_model() {
  color(c_foam) translate([bat_pos[0], bat_pos[1], z_in]) linear_extrude(bat_foam_t) rrect([bat_size[0], bat_size[1]], bat_clear);
  color(c_bat) translate([bat_pos[0], bat_pos[1], z_bat[0]]) linear_extrude(bat_size[2]) rrect([bat_size[0], bat_size[1]], bat_clear);
}

module battery_env(s = 0) {
  sbox([bat_pos[0] - bat_size[0] / 2, bat_pos[1] - bat_size[1] / 2, z_in],
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
  color(c_car) box([-strip_size[0] / 2, btn_y - strip_size[1] / 2, z_strip_back], [strip_size[0] / 2, btn_y + strip_size[1] / 2, z_strip_front]);
  for (x = btn_x) translate([x, btn_y, z_strip_front]) {
    color(c_switch) translate([-sw_size / 2, -sw_size / 2, 0]) cube([sw_size, sw_size, sw_body_h]);
    // plunger at its free height, or pressed by the cap if preloaded
    color(c_switch) cylinder(d = sw_plunger_d, h = sw_h - max(cap_preload, 0));
  }
}

module strip_env(s = 0) {
  difference() {
    sbox([-strip_size[0] / 2, btn_y - strip_size[1] / 2, z_strip_back - strip_solder_h],
         [strip_size[0] / 2, btn_y + strip_size[1] / 2, z_strip_front], s);
    // screw heads only behind the two bosses
    for (x = strip_screw_x) translate([x, btn_y, 0]) cylinder(d = strip_boss_d, h = depth);
  }
  for (x = btn_x) sbox([x - sw_size / 2, btn_y - sw_size / 2, z_strip_front], [x + sw_size / 2, btn_y + sw_size / 2, z_strip_front + sw_body_h], s);
}

module magnets_model() {
  for (p = mag_pos) translate([p[0], p[1], 0]) {
    color(c_magnet) translate([0, 0, -mag_proud]) cylinder(d = mag_d, h = mag_h);
    color(c_metal) translate([0, 0, z_screw_tip]) cylinder(d = mag_screw_d, h = mag_screw_len);
    color(c_metal) translate([0, 0, z_mag_boss]) cylinder(d = mag_screw_head[0], h = mag_screw_head[1]);
  }
}

module magnets_env(s = 0) {
  for (p = mag_pos) translate([p[0], p[1], -mag_proud + s]) cylinder(d = mag_d - 2 * s, h = mag_h - 2 * s);
}

module fpc_zone_env(s = 0) {
  sbox([-fpc_zone[0] / 2, panel_bot, z_in], [fpc_zone[0] / 2, panel_bot + fpc_zone[1], z_panel_back], s);
}

module panel_env(s = 0) {
  sbox([panel_c[0] - panel_w / 2, panel_c[1] - panel_h / 2, z_panel_back], [panel_c[0] + panel_w / 2, panel_c[1] + panel_h / 2, z_panel_front], s);
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
}

module caps_inked() {
  // caps with their engraved symbols filled dark, for the renders
  color(c_cap) for (i = [0 : len(btn_x) - 1]) cap(i);
  color(c_ink) for (i = [0 : len(btn_x) - 1])
    translate([btn_x[i], btn_y, z_cap_face - symbol_depth + eps]) linear_extrude(eps) cap_symbol_2d(i);
}

// =====================================================================
// Scenes
// =====================================================================
module scene_assembly() {
  color(c_bezel) bezel_part();
  color(c_back) back_part();
  caps_inked();
  magnets_model();
  internals();
}

module scene_exploded() {
  // layers pulled apart along Z in assembly order, explode_z[i] x explode_gap
  function dz(i) = [0, 0, explode_z[i] * explode_gap];
  translate(dz(0)) magnets_model();
  translate(dz(1)) { color(c_back) back_part(); driver_model(); carrier_model(); battery_model(); }
  translate(dz(2)) { panel_model(); flex_model(); }
  translate(dz(3)) strip_model();
  translate(dz(4)) caps_inked();
  translate(dz(5)) { color(c_bezel) bezel_part(); color(c_ant) box(ant_lo, ant_hi); gasket_model(); }
}

module scene_inside() {
  // back cover removed, seen from behind: where each module sits, with the
  // magnets (on the back cover) as ghosts and their board keep-out circles
  color(c_bezel) bezel_part();
  caps_inked();
  internals();
  color(c_fpc, 0.35) fpc_zone_env();
  color(c_ant, 0.3) antenna_keepout();                       // antenna edge-on from behind: show its zone
  for (p = mag_pos) translate([p[0], p[1], 0]) {
    color(c_magnet, 0.8) translate([0, 0, -mag_proud]) cylinder(d = mag_d, h = mag_h);
    color(c_keepout, 0.5) linear_extrude(ring_w) difference() {
      circle(r = mag_keep_board);
      circle(r = mag_keep_board - ring_w);
    }
  }
  if (show_labels) inside_labels();
}

module inside_labels() {
  // read from behind: mirrored, just behind the back face of each module
  lbl = [
    ["DRIVER HAT", drv_pos, z_drv_pcb],
    ["CARRIER", [0, car_top - car_size[1] / 2], z_car_pcb - car_solder_h],
    ["BATTERY", bat_pos, z_in],
    ["FPC ZONE", [0, panel_bot + fpc_zone[1] / 2], z_in],
    ["ANTENNA", [(ant_x[0] + ant_x[1]) / 2, in_h / 2 - ant_metal_keepout - img_label], z_in],
    ["BUTTONS", [0, btn_y], z_strip_back - strip_solder_h]];
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
  color(c_switch) coax_model();
  color(c_cap) for (i = [0 : len(btn_x) - 1]) cap(i);
  if (show_labels) fit_labels();
  color(c_fpc, 0.4) fpc_zone_env();
  color(c_keepout, 0.15) antenna_keepout();
  color(c_panel, 0.25) panel_env();
  color(c_back, 0.2) back_part();
  color(c_bezel, 0.15) bezel_part();
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
  // everything rendered here is a collision: the result must be empty
  color(c_keepout) {
    intersection() { bezel(); back_cover(); }
    intersection() { union() { bezel(); back_cover(); } all_envelopes(clash_shrink); }
  }
}

module all_envelopes(s = 0) {
  driver_env(s);
  carrier_env(s);
  battery_env(s);
  fpc_zone_env(s);
  sbox(ant_lo, ant_hi, s);
  strip_env(s);
  magnets_env(s);
  panel_env(s);
}

// =====================================================================
// Design rules: asserts and a placement report (see the console)
// =====================================================================
function clampv(x, lo, hi) = min(max(x, lo), hi);
function rect_dist(p, lo, hi) = norm([p[0] - clampv(p[0], lo[0], hi[0]), p[1] - clampv(p[1], lo[1], hi[1])]);
function box_dist(lo1, hi1, lo2, hi2) = norm([for (i = [0 : len(lo1) - 1]) max(0, lo1[i] - hi2[i], lo2[i] - hi1[i])]);
function path_len(p) = len(p) < 2 ? 0 : norm(p[1] - p[0]) + path_len([for (i = [1 : len(p) - 1]) p[i]]);
function r2(x) = round(x * 100) / 100;

module design_checks() {
  ant_lo2 = [ant_res_lo[0], ant_res_lo[1]];
  ant_hi2 = [ant_res_hi[0], ant_res_hi[1]];
  fpc_lo = [-fpc_zone[0] / 2, panel_bot];
  fpc_hi = [fpc_zone[0] / 2, panel_bot + fpc_zone[1]];
  cradle_lo = bat_pos - bat_out / 2;
  cradle_hi = bat_pos + bat_out / 2;

  // enclosure and bed
  assert(outer_w <= bed_size[0] && outer_h <= bed_size[1], str("bezel does not fit the ", bed_size, " mm bed"));
  assert(window_land + window_chamfer <= front_t, "window chamfer deeper than the front face");
  assert(chin_h > 0, "panel does not fit the outline height");

  // driver board clearances
  assert(z_drv_pcb - drv_header_h >= z_in + drv_header_clear, "driver header too close to the back cover");
  assert(z_panel_back - z_drv_top >= drv_air_min, str("driver board air gap ", z_panel_back - z_drv_top, " < ", drv_air_min));
  // carrier
  assert(z_car_top + car_comp_h <= z_panel_back - car_air_min, "carrier components too close to the panel");
  assert(car_standoff_h >= car_solder_h, "carrier solder joints hit the back cover");
  // battery
  assert(z_bat[1] <= z_rib_top - bat_air_min, "battery too thick for the enclosure depth");
  // antenna on the top wall, front edge on the front plate
  assert(z_ant[0] >= z_in - eps, str("antenna (", ant_h, " mm) taller than the inside of the top wall (", z_lip - z_in, " mm): raise depth"));
  assert(path_len(coax_path) <= coax_len, "coax too short for the route to the U.FL");
  // buttons
  assert(btn_y - strip_size[1] / 2 >= -in_h / 2 + strip_clear, "button strip hits the bottom wall");
  assert(btn_y + strip_size[1] / 2 <= panel_bot, "button strip reaches into the flex zone");
  assert(btn_y + cap_flange_d / 2 <= pocket_bot - fpc_relief_d, "cap flange reaches the flex relief");
  assert(z_strip_back - strip_solder_h >= z_in + lip_h, "button strip too deep");
  // caps: a preload must stay below the switch travel, a gap must stay small;
  // either way the flange seat (not the switch) holds the cap in place
  assert(cap_preload < sw_travel, "cap preload would keep the switch pressed");
  assert(-cap_preload <= cap_gap_max, "cap gap too large, the caps will rattle");
  assert(cap_flange_d > cap_hole_d, "cap flange cannot retain the cap");
  assert(z_cap_back - cap_stroke > z_strip_front + sw_body_h, "cap would hit the switch body before the click");
  assert(fpc_bend <= fpc_relief_d, "flex bend does not fit the relief slot");

  // magnet screw: must engage the thread, must not reach the magnet's front face
  assert(mag_engage >= mag_min_engage, str("M4 screw engages only ", mag_engage, " mm"));
  assert(mag_engage <= mag_thread_depth, "M4 screw longer than the magnet's thread");
  assert(mag_screw_len <= mag_floor + mag_h - mag_face_skin,
    str("M4 screw tip ", z_screw_tip + mag_proud, " mm from the magnet face, needs ", mag_face_skin));

  // magnet placement rules
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

  // metal near the antenna (inserts, screws, magnets, USB shells)
  metal = concat(
    [for (p = m3_pos) [[p[0] - m3_insert[0] / 2, p[1] - m3_insert[0] / 2, 0], [p[0] + m3_insert[0] / 2, p[1] + m3_insert[0] / 2, z_m3_hole]]],
    [for (p = car_screw_pos) [[p[0] - m25_insert[0] / 2, p[1] - m25_insert[0] / 2, z_car_pcb - m25_insert[1]],
                              [p[0] + m25_insert[0] / 2, p[1] + m25_insert[0] / 2, z_car_top + m25_head_h]]],
    [for (p = mag_pos) [[p[0] - mag_d / 2, p[1] - mag_d / 2, -mag_proud], [p[0] + mag_d / 2, p[1] + mag_d / 2, z_mag_boss + mag_screw_head[1]]]],
    [for (x = usb_x) [[x - usb_size[0] / 2, car_top + usb_overhang - usb_len, z_usb - usb_size[1] / 2], [x + usb_size[0] / 2, car_top + usb_overhang, z_usb + usb_size[1] / 2]]]);
  metal_d = min([for (m = metal) box_dist(m[0], m[1], ant_res_lo, ant_res_hi)]);
  assert(metal_d >= ant_metal_keepout, str("metal ", metal_d, " mm from the antenna"));

  // placement report (front-view X/Y, Z from the back face)
  echo(str("OUTER W x H x D = ", outer_w, " x ", outer_h, " x ", depth, " mm (caps +", cap_proud,
           ", magnets +", mag_proud, ")"));
  echo(str("PANEL centre ", panel_c, ", window ", r2(win_size[0]), " x ", r2(win_size[1]),
           " at ", [0, r2(win_c[1])], ", chin ", r2(chin_h), " mm"));
  echo(str("DRIVER board centre ", drv_pos, ", ", drv_size[0], " x ", drv_size[1], ", PCB at Z ", z_drv_pcb,
           ", air gap to panel ", r2(z_panel_back - z_drv_top), " mm"));
  echo(str("CARRIER board centre ", [0, car_top - car_size[1] / 2], ", ", car_size[0], " x ", car_size[1],
           ", PCB at Z ", z_car_pcb, ", screws ", car_screw_pos));
  echo(str("USB slots at X ", usb_x, ", centre Z ", z_usb));
  echo(str("ANTENNA X ", ant_x, " on the top wall, Z ", z_ant, ", coax route ", r2(path_len(coax_path)),
           " of ", coax_len, " mm, nearest metal ", r2(metal_d), " mm"));
  echo(str("CARRIER board edge to antenna ", r2(ant_x[0] - car_hi[0]), " mm (protoboard copper, keep it sparse there)"));
  echo(str("BATTERY centre ", bat_pos, ", cell ", bat_size, ", Z ", z_bat));
  echo(str("FPC zone X +-", fpc_zone[0] / 2, ", Y ", r2(panel_bot), " to ", r2(panel_bot + fpc_zone[1])));
  echo(str("BUTTONS at X ", btn_x, ", Y ", btn_y, ", strip Z ", r2(z_strip_back), " to ", r2(z_strip_front),
           "; cap ", cap_preload < 0 ? str(-cap_preload, " mm above the plunger") : str(cap_preload, " mm preload"),
           ", clicks after ", r2(cap_stroke), " mm with the face ", r2(cap_proud - cap_stroke), " mm proud"));
  echo(str("MAGNETS ", mag_pos, ", screw engagement ", mag_engage, " mm, tip ", z_screw_tip + mag_proud,
           " mm behind the magnet face"));
}
