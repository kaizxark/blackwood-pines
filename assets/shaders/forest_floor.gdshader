shader_type spatial;
render_mode cull_back;

// Blackwood Pines Organic Terrain Shader
// Blends damp loam, decaying pine needles, mossy patches, and wet puddle reflections.

uniform vec4 soil_color : source_color = vec4(0.13, 0.10, 0.07, 1.0);
uniform vec4 needle_color : source_color = vec4(0.24, 0.15, 0.08, 1.0);
uniform vec4 moss_color : source_color = vec4(0.14, 0.22, 0.09, 1.0);
uniform vec4 puddle_color : source_color = vec4(0.04, 0.04, 0.05, 1.0);

varying vec3 v_world_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Multi-frequency organic noise based on world position
	float n1 = sin(v_world_pos.x * 0.35 + v_world_pos.z * 0.42);
	float n2 = cos(v_world_pos.x * 0.85 - v_world_pos.z * 0.75);
	float organic_mix = n1 * 0.5 + n2 * 0.5;
	
	// Needle litter vs soil
	vec3 base_terrain = mix(soil_color.rgb, needle_color.rgb, clamp(organic_mix + 0.5, 0.0, 1.0));
	
	// Moss patches in shaded, moist depressions
	float moss_mask = clamp(sin(v_world_pos.x * 0.15) * cos(v_world_pos.z * 0.15) * 2.0, 0.0, 1.0);
	vec3 with_moss = mix(base_terrain, moss_color.rgb, moss_mask * 0.65);
	
	// Wet puddle hollows (depressed areas have low roughness and dark water specular)
	float puddle_mask = clamp(-v_world_pos.y * 3.0 + n1 * 0.4, 0.0, 1.0);
	if (v_world_pos.y < 0.05) {
		puddle_mask = clamp((0.05 - v_world_pos.y) * 8.0, 0.0, 0.9);
	} else {
		puddle_mask = 0.0;
	}
	
	ALBEDO = mix(with_moss, puddle_color.rgb, puddle_mask);
	// Wet puddles have near-zero roughness for sharp moonlit reflections
	ROUGHNESS = mix(0.88, 0.06, puddle_mask);
	SPECULAR = mix(0.12, 0.85, puddle_mask);
}
