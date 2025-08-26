shader_type canvas_item;

uniform float waves : hint_range(0.0, 10.0) = 0.75;
uniform float sway_strength : hint_range(0.0, 50.0) = 10.0;
uniform float sway_speed : hint_range(0.0, 10.0) = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;

    // 바닥 기준으로 위쪽일수록 더 많이 흔들림
    float sway = sin(TIME * sway_speed + UV.y * waves) * sway_strength * (1.0 - UV.y);

    uv.x += sway / 100.0;

    COLOR = texture(TEXTURE, uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
