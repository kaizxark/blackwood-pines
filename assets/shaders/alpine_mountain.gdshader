shader_type spatial;
render_mode cull_back;

// PROJECT PROTO-BREACH - Next-Gen Alpine Mountain Peak Shader
// Features: Elevation-based stratigraphy, sheer granite cliffs, upward snow dustings, and atmospheric sun glint.

uniform vec4 rock_base_color : source_color = vec4(0.24, 0.25, 0.27, 1.0);
uniform vec4 rock_dark_color : source_color = vec4(0.14, 0.15, 0.16, 1.0);
uniform vec4 forest_base_color : source_color = vec4(0.12, 0.24, 0.08, 1.0);
uniform vec4 snow_color : source_color = vec4(0.92, 0.95, 0.98, 1.0);

varying vec3 v_world_pos;
varying vec3 v_world_normal;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// 1. Rock Stratigraphy & Fissure Noise
	float fissure = sin(v_world_pos.y * 0.4 + sin(v_world_pos.x * 0.15 + v_world_pos.z * 0.15) * 3.0);
	fissure += cos(v_world_pos.y * 1.2) * 0.4;
	float fissure_mask = smoothstep(-0.3, 0.5, fissure);
	vec3 rock = mix(rock_dark_color.rgb, rock_base_color.rgb, fissure_mask);
	
	// 2. Forest Foothill transition at mountain base (y < 22m)
	float foothill_factor = 1.0 - smoothstep(12.0, 26.0, v_world_pos.y);
	// Steep rock faces at the base don't grow trees
	float slope = 1.0 - clamp(v_world_normal.y, 0.0, 1.0);
	foothill_factor *= (1.0 - smoothstep(0.4, 0.8, slope));
	vec3 surface = mix(rock, forest_base_color.rgb, foothill_factor * 0.85);
	
	// 3. Alpine Snow Caps on high peaks (y > 40m) and upward-facing ledges
	float height_snow = smoothstep(38.0, 65.0, v_world_pos.y);
	float upward_ledge = smoothstep(0.42, 0.75, v_world_normal.y);
	float snow_factor = height_snow * upward_ledge;
	
	// Wind-drift noise on snow edges
	float drift = sin(v_world_pos.x * 0.3 + v_world_pos.z * 0.3) * 0.2;
	snow_factor = smoothstep(0.35, 0.7, snow_factor + drift);
	
	vec3 final_color = mix(surface, snow_color.rgb, snow_factor);
	
	ALBEDO = final_color;
	ROUGHNESS = mix(0.88, 0.45, snow_factor);
	SPECULAR = mix(0.12, 0.65, snow_factor);
}

// Mountain shader elevation strata: Foothills (<22m), Crags (22-55m), Snow (>55m)
