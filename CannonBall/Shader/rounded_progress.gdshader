shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(0.5, 0.5);

	float dist = distance(uv, center);
	vec4 base_color;

	if (dist <= 0.5 && dist >= 0.4) {
		base_color = vec4(1.0);
	}
	else {
		base_color = vec4(0.0);
	}
	vec2 dir = normalize(uv - center);
	float theta = atan(dir.y, dir.x) + PI / 2.0;
	if (theta < 0.0) {
		theta += 2.0 * PI;
	}

	float progress_deg = 360.0 * progress;
	if (degrees(theta) < progress_deg) {
		base_color = vec4(0.0);
	}

	COLOR = base_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
