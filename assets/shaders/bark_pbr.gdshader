shader_type spatial;
render_mode cull_back;

// Weathered Pine Bark PBR Shader with north-facing moss growth
uniform vec4 bark_color : source_color = vec4(0.18, 0.12, 0.08, 1.0);
uniform vec4 moss_color : source_color = vec4(0.15, 0.25, 0.08, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.88;
uniform float moss_amount : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	// Vertical furrow variation
	float furrow = sin(UV.y * 35.0) * cos(UV.x * 20.0) * 0.1;
	vec3 base_col = bark_color.rgb * (1.0 + furrow);
	
	// Moss growth on damp north/shady side (negative Z world normal)
	vec3 world_norm = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float moss_factor = clamp(-world_norm.z * 1.2 + furrow * 2.0, 0.0, 1.0) * moss_amount;
	
	ALBEDO = mix(base_col, moss_color.rgb, moss_factor);
	ROUGHNESS = mix(roughness, 0.95, moss_factor);
	SPECULAR = 0.15;
}
