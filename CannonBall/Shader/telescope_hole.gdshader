shader_type canvas_item;

uniform vec2 hole_center = vec2(0.5, 0.5); // 중앙 (0~1 기준)
uniform float hole_radius = 0.4;           // 0~1 기준 상대 거
uniform float thickness = 0.02;  // 십자가 선 두께 (0~1)

uniform vec4 cross_color = vec4(1.0, 1.0, 1.0, 1.0);  // 십자가 색
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 1); // 배경색
uniform vec4 transparency_color : source_color = vec4(0.0, 0.0, 0.0, 0); // 투명색

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	float horizontal = step(0.5 - thickness / 2.0, uv.y) * step(uv.y, 0.5 + thickness / 2.0);
    float vertical = step(0.5 - thickness / 2.0, uv.x) * step(uv.x, 0.5 + thickness / 2.0);
	float cross_ = max(horizontal, vertical);

    float dist = distance(uv, hole_center);

    if (dist < hole_radius) {
		COLOR = mix(transparency_color, cross_color, cross_);
    }
	else {
        COLOR = bg_color;
    }
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
