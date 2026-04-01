// --- GLOBAL SETTINGS ---
$fn = 100;
eps = 0.01;

// --- PARAMETERS ---
// Plate
plate_t     = 2;
plate_r     = 30;

// Bars/Clamps
bar_spacing = 16.5; // Center-to-center distance
bar_gap     = 30; // vertical gap between bars
bar_d       = 6.35; // Internal diameter for the rod
bar_h       = 10;   // Height of the clamp
bar_wall    = 1.5;  // Wall thickness of the clamp (renamed from bar_t for clarity)

// --- MODULES ---

module cage_clamp(id, h, wall) {
    od = id + (wall * 2); // Outer diameter
    total_h = h + wall;   // Total length of the housing
    
    // Rotate to lie parallel to the plate surface
    rotate([90, 0, 0]) 
    difference() {
        // 1. OUTER BODY
        union() {
            // Main cylinder
            cylinder(h = total_h, d = od, center = true);
            
            // Connecting block to merge with the plate
            // Positioned to provide a flat mounting base
            translate([0, -od/4, 0])
                cube([od, od/2, total_h], center = true);
        }
        
        // 2. INTERNAL HOLE (The rod path)
        // Made slightly longer than the body to ensure a clean cut
        translate([0, 0, wall])
            cylinder(h = h + eps, d = id, center = true);
    }
}

// --- MAIN ASSEMBLY ---

// 1. The Base Plate
color("SlateGray")
cylinder(h = plate_t, r = plate_r);

// 2. The Clamps
// We use a loop to mirror the clamps across the X and Y axes automatically
clamp_offset_z = (bar_d / 2) + bar_wall + plate_t;

for (x = [-1, 1], y = [-1, 1]) {
    translate([x * bar_spacing/2, y * bar_gap/2, clamp_offset_z])
        // Rotate the top clamps 180 so the "flat" side faces inward
        rotate([0, 0, (y > 0) ? 180 : 0]) 
            cage_clamp(bar_d, bar_h, bar_wall);
}