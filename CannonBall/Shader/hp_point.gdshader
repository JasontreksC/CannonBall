shader_type canvas_item;

uniform vec4 hp_color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist = UV.y / 2.0;
	if ((UV.x < 0.5 - dist) || (UV.x > 0.5 + dist)){
		COLOR = vec4(0, 0, 0, 0);
	}
	else {
		COLOR = hp_color;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
