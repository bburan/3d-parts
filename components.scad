// --- GLOBAL SETTINGS ---
$fn = 100; // Increased for a much smoother curve
eps = 0.01;

// --- SENSOR PARAMETERS ---
ir_base_w = 7.08;
ir_base_d = 3.7;
ir_slot_w = 5.58;
ir_slot_h = 6.5;
ir_depth  = 22.5; // Vertical length of the sensor housing internal

ir_hole_r   = 0.79;
ir_screw_r  = 1.0;
ir_offset_z = 1.72; // Distance from TOP of sensor to the IR beam center
wall_thick  = 0.75;

// --- HOUSING/POKE PARAMETERS ---
poke_h      = 30; // FIXED: Total height of the assembly
poke_r      = 15 / 2;
poke_wall   = 6;
tap_drill_r = 5.1 / 2;

// The radius of our "rounding" is exactly half the wall thickness
rounding_r = poke_wall / 2;

// Plate
plate_t     = 2;
plate_r     = 30;

// Bars/Clamps
bar_spacing = 16.5; // Center-to-center distance
bar_gap     = 40;   // Vertical gap between bars
bar_d       = 6.35; // Internal diameter for the rod
bar_h       = 10;   // Height of the clamp
bar_wall    = 1.5;  // Wall thickness of the clamp

// --- SENSOR CONFIGURATION ---
sensor_configs = [
    [20,   0],   // Beam is ~11.7mm from the top
    [22.5, 60],  // Beam is ~9.2mm from the top
    [25,   120]  // Beam is ~6.7mm from the top
];

// --- CALCULATED DIMENSIONS ---
housing_w = ir_base_w + (wall_thick * 2);
housing_d = ir_base_d + (wall_thick * 2);

// --- MODULES ---
module sensor_cutout(depth) {
    translate([-ir_base_w/2, 0, 0]) {
        cube([ir_base_w, ir_base_d, depth - ir_slot_h + eps]);
        translate([(ir_base_w - ir_slot_w)/2, 0, depth - ir_slot_h])
            cube([ir_slot_w, ir_base_d, ir_slot_h + eps]);
        
        for(y_off = [0, ir_base_d]) {
            r_val = (y_off == 0) ? ir_hole_r : ir_screw_r;
            translate([ir_base_w/2, y_off, depth - ir_offset_z])
                rotate([90, 0, 0]) cylinder(h = 10, r = r_val, center = true);
        }
    }
}

module sensor_block(depth) {
    translate([-housing_w/2, 0, 0])
        cube([housing_w, housing_d, depth + (wall_thick * 2)]);
}

module place_opposing_pair(angle) {
    for (a = [0, 180]) rotate([0, 0, angle + a]) children();
}

// --- MAIN ASSEMBLY WRAPPED IN A MODULE ---
module nose_poke() {
    difference() {
        // 1. ADDITIVE GEOMETRY
        union() {
            // Main Poke Body (Cylinder + Semicircle Torus)
            union() {
                // Lower body
                difference() {
                    cylinder(h = poke_h - rounding_r, r = poke_r + poke_wall);
                    translate([0, 0, -eps]) 
                        cylinder(h = poke_h, r = poke_r);
                }
                
                // The Rounded Rim
                translate([0, 0, poke_h - rounding_r])
                rotate_extrude()
                translate([poke_r + rounding_r, 0, 0])
                intersection() {
                    circle(r = rounding_r);
                    translate([-rounding_r, 0]) 
                        square([rounding_r * 2, rounding_r]);
                }
            }
            
            // Bottom Plate
            cylinder(h = poke_wall, r = poke_r + poke_wall);
            
            // Housing Blocks
            for (config = sensor_configs) {
                depth = config[0];
                angle = config[1];
                place_opposing_pair(angle)
                    translate([0, poke_r, 0]) sensor_block(depth);
            }
        }

        // 2. SUBTRACTIVE GEOMETRY
        
        // Bottom Plate Tap Hole
        translate([0, 0, -eps]) 
            cylinder(h = poke_wall + (eps * 2), r = tap_drill_r);
            
        // Sensor Cutouts
        for (config = sensor_configs) {
            depth = config[0];
            angle = config[1];
            place_opposing_pair(angle)
                translate([0, poke_r + wall_thick, -eps]) sensor_cutout(depth);
        }
    }
}


// --- MODULES ---
module cage_clamp(id, h, wall) {
    od = id + (wall * 2);
    total_h = h + wall;
    
    rotate([90, 0, 0]) 
    difference() {
        union() {
            cylinder(h = total_h, d = od, center = true);
            translate([0, -od/4, 0])
                cube([od, od/2, total_h], center = true);
        }
        translate([0, 0, wall])
            cylinder(h = h + eps, d = id, center = true);
    }
}

// --- MAIN ASSEMBLY WRAPPED IN A MODULE ---
module face_plate(hole_d) {
    union() {
        color("SlateGray")
        difference() {
            cylinder(h = plate_t, r = plate_r);
            translate([0, 0, -eps]) cylinder(h = plate_t + 2 * eps, r = hole_d);
        }
        
        clamp_offset_z = (bar_d / 2) + bar_wall + plate_t;
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x * bar_spacing/2, y * bar_gap/2, clamp_offset_z])
                rotate([0, 0, (y > 0) ? 180 : 0]) 
                    cage_clamp(bar_d, bar_h, bar_wall);
        }
    }
}