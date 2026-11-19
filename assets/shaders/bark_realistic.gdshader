shader_type spatial;
render_mode cull_back;

// PROJECT PROTO-BREACH - Procedural Craggy Bark & Moss Shader
// Supports vertical bark fissures, north/upward moss accumulation, and damp base darkening.

uniform vec4 bark_color : source_color = vec4(0.20, 0.13, 0.08, 1.0);
uniform vec4 bark_crevice_color : source_color = vec4(0.10, 0.07, 0.04, 1.0);
uniform vec4 moss_color : source_color = vec4(0.18, 0.35, 0.09, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.88;
uniform float moss_amount : hint_range(0.0, 1.0) = 0.45;
uniform bool is_birch = false;

varying vec3 v_world_pos;
varying vec3 v_world_normal;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	if (is_birch) {
		// Birch bark: chalky white with dark horizontal lenticels and rough dark base
		float lenticel = smoothstep(0.72, 0.95, sin(v_world_pos.y * 18.0 + sin(v_world_pos.x * 2.0) * 1.5) * cos(v_world_pos.z * 10.0));
		float dark_base = clamp((2.5 - VERTEX.y) * 0.4, 0.0, 1.0);
		
		vec3 white_bark = vec3(0.85, 0.84, 0.80);
		vec3 dark_bark = vec3(0.14, 0.12, 0.10);
		
		vec3 final_bark = mix(white_bark, dark_bark, max(lenticel, dark_base * 0.7));
		
		// Upward moss
		float moss = clamp(v_world_normal.y * 1.2 + (-v_world_normal.z) * 0.5, 0.0, 1.0) * moss_amount * 0.6;
		ALBEDO = mix(final_bark, moss_color.rgb, moss);
		ROUGHNESS = mix(0.75, 0.95, moss);
		SPECULAR = 0.18;
	} else {
		// Craggy Pine / Oak bark: deep vertical grooves
		float groove1 = sin(v_world_pos.x * 8.0 + v_world_pos.z * 8.0);
		float groove2 = cos(v_world_pos.y * 4.0 + groove1 * 2.0);
		float fissure = smoothstep(-0.2, 0.4, groove1 * 0.6 + groove2 * 0.4);
		
		vec3 base_bark = mix(bark_crevice_color.rgb, bark_color.rgb, fissure);
		
		// North-facing and upward moss growth
		float moss_growth = clamp((-v_world_normal.z * 1.2) + (v_world_normal.y * 1.5), 0.0, 1.0) * moss_amount;
		moss_growth = smoothstep(0.2, 0.7, moss_growth);
		
		// Damp base darkening near the forest floor
		float damp_base = clamp((1.8 - VERTEX.y) * 0.35, 0.0, 0.5);
		base_bark *= (1.0 - damp_base);
		
		ALBEDO = mix(base_bark, moss_color.rgb, moss_growth);
		ROUGHNESS = mix(roughness, 0.96, moss_growth);
		SPECULAR = 0.12;
	}
}
