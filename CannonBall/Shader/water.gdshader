shader_type canvas_item;

uniform float uv_scale = 1.0;
uniform float poisoned : hint_range(0.0, 1.0, 0.0);

group_uniforms WAVE_BOTTOM;
uniform vec4 b_clean_color: source_color;
uniform vec4 b_poisoned_color: source_color;
uniform float wave_b_length : hint_range(0.0, 2.0);
uniform float wave_b_height : hint_range(0.01, 0.2);
uniform float wave_b_speed : hint_range(0.0, 10.0);
uniform float wave_b_offset : hint_range(0.0, 500.0);

group_uniforms WAVE_MIDDLE;
uniform vec4 m_clean_color: source_color;
uniform vec4 m_poisoned_color: source_color;
uniform float wave_m_length : hint_range(0.0, 10.0);
uniform float wave_m_height : hint_range(0.0, 0.2);
uniform float wave_m_speed : hint_range(0.0, 10.0);
uniform float wave_m_offset : hint_range(0.0, 5.0);

group_uniforms WAVE_TOP;
uniform vec4 t_clean_color: source_color;
uniform vec4 t_poisoned_color: source_color;
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
    
    // 각 웨이브의 y값 계산
    float wave_bottom = wave_point(uv.x, wave_b_length, wave_b_height, wave_b_speed, wave_b_offset);
    float wave_middle = wave_point(uv.x, wave_m_length, wave_m_height, wave_m_speed, wave_m_offset);
    float wave_top = wave_point(uv.x, wave_t_length, wave_t_height, wave_t_speed, wave_t_offset);
    
    // 블렌딩을 위한 스무딩 계수
    float blend_amount = 0.1; // 블렌딩 강도 조절
    
	// 청정 상태 <-> 독성화 상태 색 보간
	vec4 b_color = mix(b_clean_color, b_poisoned_color, poisoned);
	vec4 m_color = mix(m_clean_color, m_poisoned_color, poisoned);
	vec4 t_color = mix(t_clean_color, t_poisoned_color, poisoned);
	
    // 색상 블렌딩
    vec4 final_color;
    
    if (uv.y > wave_bottom) {
        float t = smoothstep(wave_bottom, wave_bottom + blend_amount, uv.y);
        final_color = mix(m_color, b_color, t);
    }
    else if (uv.y > wave_middle) {
        float t = smoothstep(wave_middle, wave_middle + blend_amount, uv.y);
        final_color = mix(t_color, m_color, t);
    }
    else if (uv.y > wave_top) {
        float t = smoothstep(wave_top, wave_top + blend_amount, uv.y);
        final_color = mix(vec4(0.0), t_color, t);
    }
    else {
        final_color = vec4(0.0, 0.0, 0.0, 0.0);
    }
    
    COLOR = final_color;
}