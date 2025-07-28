shader_type canvas_item;

uniform float uv_scale = 1.0;

group_uniforms WAVE_BOTTOM;
uniform vec4 b_color: source_color;
uniform float wave_b_length : hint_range(0.0, 2.0);
uniform float wave_b_height : hint_range(0.01, 0.2);
uniform float wave_b_speed : hint_range(0.0, 10.0);
uniform float wave_b_offset : hint_range(0.0, 500.0);

group_uniforms WAVE_MIDDLE;
uniform vec4 m_color: source_color;
uniform float wave_m_length : hint_range(0.0, 10.0);
uniform float wave_m_height : hint_range(0.0, 0.2);
uniform float wave_m_speed : hint_range(0.0, 10.0);
uniform float wave_m_offset : hint_range(0.0, 5.0);

group_uniforms WAVE_TOP;
uniform vec4 t_color: source_color;
uniform float wave_t_length : hint_range(0.0, 10.0);
uniform float wave_t_height : hint_range(0.0, 0.2);
uniform float wave_t_speed : hint_range(0.0, 10.0);
uniform float wave_t_offset : hint_range(0.0, 5.0);



void vertex() {
	// Called for every vertex the material is visible on.
}

float wave_point(float uv_x, float wave_length, float wave_height, float wave_speed, float wave_offset) {
	return wave_height * (sin(wave_length * uv_x + TIME * wave_speed) + wave_offset);
}

void fragment() {
	vec3 color3 = vec3(COLOR.r, COLOR.g, COLOR.b);
	vec2 uv = UV * uv_scale;
	if (uv.y > wave_point(uv.x, wave_b_length, wave_b_height, wave_b_speed, wave_b_offset)) {
		COLOR = b_color;
	}
	else if (uv.y > wave_point(uv.x, wave_m_length, wave_m_height, wave_m_speed, wave_m_offset)) {
		COLOR = m_color;
	}
	else if (uv.y > wave_point(uv.x, wave_t_length, wave_t_height, wave_t_speed, wave_t_offset)) {
		COLOR = t_color;
	}
	else
	COLOR.a = 0.0;
}
