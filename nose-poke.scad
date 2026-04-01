// --- GLOBAL SETTINGS ---
$fn = 64;
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
poke_h      = 30;  // FIXED: Total height of the assembly
poke_r      = 15 / 2;
poke_wall   = 6;
tap_drill_r = 5.1 / 2; 

// --- SENSOR CONFIGURATION ---
// [Internal_Channel_Height, Rotation_Angle]
// "Internal_Channel_Height" is the distance from the base to the top of the sensor.
// Note: Poke Depth (Top to Beam) = poke_h - (Channel_Height - ir_offset_z)
sensor_configs = [
    [20,   0],   // Beam is ~11.7mm from the top
    [22.5, 60],  // Beam is ~9.2mm from the top
    [25,   120],  // Beam is ~6.7mm from the top
    
];

// --- CALCULATED DIMENSIONS ---
housing_w = ir_base_w + (wall_thick * 2);
housing_d = ir_base_d + (wall_thick * 2);

// --- MODULES ---

module sensor_cutout(h_val) {
    translate([-ir_base_w/2, 0, 0]) {
        // Base track (Vertical channel for sensor)
        cube([ir_base_w, ir_base_d, h_val - ir_slot_h + eps]);
        
        // Top slot housing
        translate([(ir_base_w - ir_slot_w)/2, 0, h_val - ir_slot_h])
            cube([ir_slot_w, ir_base_d, ir_slot_h + eps]);
        
        // IR Beam Center (Emitter/Receiver Hole)
        translate([ir_base_w/2, 0, h_val - ir_offset_z])
            rotate([90, 0, 0]) 
                cylinder(h = 10, r = ir_hole_r, center = true);
        
        // Mechanical Support / Screw Hole
        translate([ir_base_w/2, ir_base_d, h_val - ir_offset_z])
            rotate([90, 0, 0]) 
                cylinder(h = 10, r = ir_screw_r, center = true);
    }
}

module sensor_block(h_val) {
    // Adds wall thickness to the height of the internal channel
    translate([-housing_w/2, 0, 0])
        cube([housing_w, housing_d, h_val + (wall_thick * 2)]);
}

// Wrapper to automatically handle opposing pairs
module place_opposing_pair(angle) {
    for (a = [0, 180]) rotate([0, 0, angle + a]) children();
}

// --- MAIN ASSEMBLY ---

difference() {
    // 1. ADDITIVE GEOMETRY
    union() {
        // Main Poke Body
        difference() {
            cylinder(h = poke_h, r = poke_r + poke_wall);
            translate([0, 0, -eps]) 
                cylinder(h = poke_h + (eps * 2), r = poke_r);
        }
        
        // Bottom Plate
        cylinder(h = poke_wall, r = poke_r + poke_wall);

        // Housing Blocks
        for (config = sensor_configs) {
            h_val = config[0];
            angle = config[1];
            place_opposing_pair(angle)
                translate([0, poke_r, 0]) 
                    sensor_block(h_val);
        }
    }

    // 2. SUBTRACTIVE GEOMETRY
    
    // Bottom Plate Tap Hole (1/4"-20)
    translate([0, 0, -eps]) 
        cylinder(h = poke_wall + (eps * 2), r = tap_drill_r);

    // Internal Sensor Cutouts
    for (config = sensor_configs) {
        h_val = config[0];
        angle = config[1];
        place_opposing_pair(angle)
            translate([0, poke_r + wall_thick, -eps]) 
                sensor_cutout(h_val);
    }
}