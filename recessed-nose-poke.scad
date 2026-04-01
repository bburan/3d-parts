include <components.scad>

difference() {
    union() {
        face_plate(poke_r + poke_wall / 2);
        // Use 90-degree bevel for flush mounting
        translate([0, 0, poke_h]) 
            rotate([0, 180, 0])
            nose_poke();
    }
}