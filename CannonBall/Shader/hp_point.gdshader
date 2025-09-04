shader_type canvas_item;

uniform vec4 inner_color: source_color;
uniform vec4 outter_color: source_color;
uniform float inner_ratio: hint_range(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist = UV.y / 2.0;
	if ((UV.x > 0.5 - dist) && (UV.x < 0.5 + dist)){

		float inner_y_start = 0.5 - 0.5 * inner_ratio;
		float inner_y_end = 0.5 + 0.5 * inner_ratio;
		float t = (UV.y - inner_y_start) / (inner_y_end - inner_y_start);
		if ((t < 0.0) || (t > 1.0))
			t = 0.0;
		else
			t = clamp((UV.y - inner_y_start) / (inner_y_end - inner_y_start), 0, 1.0);
		float inner_dist = t / 2.0 * inner_ratio;
		if ((UV.x > 0.5 - inner_dist) && (UV.x < 0.5 + inner_dist)) {
			COLOR = inner_color;
		}
		else {
			COLOR = outter_color;
		}
	}
	else {
		COLOR = vec4(0, 0, 0, 0);
	}
}