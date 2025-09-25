shader_type canvas_item;

uniform sampler2D telescope_texture;
uniform float radius: hint_range(0.0, 1.0);
uniform float strength: hint_range(-1.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	vec4 tex_color = texture(telescope_texture, uv);

    float dist = distance(uv, vec2(0.5, 0.5));

    if (dist > radius) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0); // 배경색
    }
	else {
		vec2 centered_uv = UV - vec2(0.5);
		float factor = 1.0 + strength * dist * dist;

   		 // 왜곡된 좌표
		vec2 warped_uv = centered_uv * factor + vec2(0.5);

		COLOR = texture(TEXTURE, warped_uv);
		COLOR.rgb -= 0.25 * dist;
	}
}