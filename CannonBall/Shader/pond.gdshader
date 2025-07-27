shader_type canvas_item;

uniform sampler2D ground_tex;
uniform int dir: hint_range(-1, 1, 2) ;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = COLOR;
	vec2 uv = UV;
	if (color.a <= 0.9) {
		
		vec4 ground_color = texture(ground_tex, fract(vec2(uv.x * float(dir), uv.y) * 2.0));
		ground_color.rgb = pow(ground_color.rgb, vec3(2.15));
		COLOR = ground_color;
	}
	else if (color.r < 0.05) {
		COLOR.a = 0.0;
	}
	else {
		COLOR = color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
