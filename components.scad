// --- GLOBAL SETTINGS ---
$fn = 100; 
eps = 0.01;

// --- SENSOR PARAMETERS ---
ir_base_w = 7.08;
ir_base_d = 3.7;
ir_slot_w = 5.58;
ir_slot_h = 6.5;
ir_depth  = 22.5;

ir_hole_r   = 0.79;
small_tap_drill_r = 1.0; 	// tap hole for small screws
ir_offset_z = 1.72; 		// Offset of sensor hole from top of housing	
housing_wall_thick  = 0.75;			// Minimum wall thickness of IR sensor housing
housing_w = ir_base_w + (housing_wall_thick * 2);
housing_d = ir_base_d + (housing_wall_thick * 2);

// --- HOUSING/POKE PARAMETERS ---
poke_h      = 30;
poke_r      = 15 / 2;
poke_wall   = 6;
tap_drill_r = 5.1 / 2;
rounding_r  = poke_wall / 2;

// Plate
plate_t     = 2;
plate_r     = 30;

// Bars/Clamps
bar_spacing = 16.5;
bar_gap     = 40;   
bar_d       = 6.35;
bar_h       = 10;
bar_wall    = 1.5;

// --- SENSOR CONFIGURATION ---
sensor_configs = [
    [20,   0],   
    [22.5, 60],  
    [25,   120]  
];


// --- MODULES ---

module sensor_cutout(depth) {
    translate([-ir_base_w/2, 0, 0]) {
        cube([ir_base_w, ir_base_d, depth - ir_slot_h + eps]);
        translate([(ir_base_w - ir_slot_w)/2, 0, depth - ir_slot_h])
            cube([ir_slot_w, ir_base_d, ir_slot_h + eps]);
        for(y_off = [0, ir_base_d]) {
            r_val = (y_off == 0) ? ir_hole_r : small_tap_drill_r;
            translate([ir_base_w/2, y_off, depth - ir_offset_z])
                rotate([90, 0, 0]) cylinder(h = 5, r = r_val, center = true);
        }
    }
}

module sensor_block(depth) {
    translate([-housing_w/2, 0, 0])
        cube([housing_w, housing_d, depth + (housing_wall_thick * 2)]);
}

module place_opposing_pair(angle) {
    for (a = [0, 180]) rotate([0, 0, angle + a]) children();
}

module nose_poke() {
    difference() {
        union() {
            // Main Poke Body
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
				translate([-rounding_r, 0]) square([rounding_r * 2, rounding_r]);
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

        // Subtractive Geometry
        translate([0, 0, -eps]) 
            cylinder(h = poke_wall + (eps * 2), r = tap_drill_r);
        for (config = sensor_configs) {
            depth = config[0];
            angle = config[1];
            place_opposing_pair(angle)
                translate([0, poke_r + housing_wall_thick, -eps]) sensor_cutout(depth);
        }
    }
}

module cage_clamp(id, h, wall) {
    od = id + (wall * 2);
    total_h = h + wall;
    
    difference() {
        rotate([90, 0, 0]) 
        difference() {
            union() {
                cylinder(h = total_h, d = od, center = true);
                translate([0, -od/4, 0])
                    cube([od, od/2, total_h], center = true);
            }
			cylinder(h = total_h + eps, d = id, center = true);
        }
		translate([0, -(total_h / 2 - 2 * wall), id/2])
		cylinder(h = wall * 2 + eps, r = small_tap_drill_r, center = true);
    }
}

module face_plate(hole_d) {
    union() {
        // Beveled Cylinder (90 degree rim)
		translate([0, 0, plate_t])
			rotate_extrude()
			hull() {
				rotate([180, 0, 0]) {
					translate([hole_d, 0, 0]) square([plate_r - plate_t - hole_d, plate_t]);
					translate([plate_r - plate_t, 0])
						intersection() {
							circle(r = plate_t);
							square([plate_t, plate_t]);
						}
				}
			}
        
        clamp_offset_z = (bar_d / 2) + bar_wall + plate_t;
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x * bar_spacing/2, y * bar_gap/2, clamp_offset_z])
                rotate([0, 0, (y > 0) ? 180 : 0]) 
                    cage_clamp(bar_d, bar_h, bar_wall);
        }
    }
}
