include <components.scad>

// --- RENDER TOGGLES ---
//render_standalone_poke = true;
render_mounted_poke = true;

// --- 1. Original Standalone Nose Poke ---
if (render_standalone_poke) {
    nose_poke();
}

// --- 2. Mounted Face Plate Combo ---
if (render_mounted_poke) {
    difference() {
        union() {
            face_plate(poke_r + poke_wall / 2);
            
            // Shift the poke up by the plate thickness so it sits flush on top
            translate([0, 0, poke_h]) 
                rotate([0, 180, 0])
                nose_poke();
        }
    }
}