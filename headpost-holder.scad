// Gerbil Headpost Holder - Hollowed
// Units: mm

/* [Parameters] */
$fn = 100; 
eps = 0.01;

// Base Dimensions (1/2 inch optical post)
base_dia = 12.7; 
base_height = 20;

// Taper Dimensions
taper_height = 20;

// Tip/Head Dimensions
tip_dia = 7;
tip_height = 50;

// Socket Dimensions
socket_side = 3.1;

// Set Screw Dimensions
screw_dia = 2.2606; 
screw_pos_z = 5; // Distance from the top face to screw center

/* [Hollowing Parameters] */
wall_thickness = 1.5; // Outer wall thickness
solid_top_depth = 15; // Leave top solid for socket and screw strength

// Helper calculation
total_height = base_height + taper_height + tip_height;
taper_dia = sqrt(2 * tip_dia^2);

/* [Rendering] */
difference() {
    // Main Body
    union() {
        cylinder(d = base_dia, h = base_height);
        
        translate([0, 0, base_height])
            cylinder(d1 = base_dia, d2 = tip_dia, h = taper_height+taper_dia);
            
        translate([0, 0, total_height / 2])
            //cylinder(tip_height, d = tip_dia, center=true);
            cube([tip_dia, tip_dia, total_height], center=true);
    }

    // SUBTRACTION 1: Square Headpost Socket
    // We position the cube so it starts at the very top and goes down
    translate([0, 0, total_height - (tip_dia / 2)])
        rotate([90, 0, 0]) // Note: See comment below about this rotation
        cube([socket_side, socket_side, tip_dia + eps], center = true);

    // SUBTRACTION 2: Set Screw Hole
    translate([0, 0, total_height - (tip_dia / 2)])
        rotate([0, 90, 0])
            cylinder(d = screw_dia, h = tip_dia, center = false);
            
    // SUBTRACTION 3: Hollowing Void
    // Leaves bottom open to allow uncured resin/powder to escape
    /*
    translate([0, 0, -0.1])
    union() {
        // Hollow base
        cylinder(d = base_dia - 2 * wall_thickness, h = base_height + 0.2);
        
        // Hollow taper
        translate([0, 0, base_height])
            cylinder(d1 = base_dia - 2 * wall_thickness, d2 = tip_dia - 2 * wall_thickness, h = taper_height + 0.1);
            
        // Hollow tip (stops before the solid top region)
        translate([0, 0, base_height + taper_height])
            cylinder(d = tip_dia - 2 * wall_thickness, h = tip_height - solid_top_depth);
    }
    */

}