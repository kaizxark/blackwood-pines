shader_type spatial;
render_mode cull_back;

// PROJECT PROTO-BREACH - Ultra-Realistic Forest Terrain Shader
// Procedural multi-biome splatting: damp loam, packed forest trail, velvety moss, exposed rock, and wet puddles.

uniform vec4 soil_color : source_color = vec4(0.18, 0.12, 0.08, 1.0);
uniform vec4 trail_color : source_color = vec4(0.24, 0.16, 0.10, 1.0);
uniform vec4 moss_color : source_color = vec4(0.16, 0.32, 0.09, 1.0);
uniform vec4 rock_color : source_color = vec4(0.28, 0.29, 0.30, 1.0);
uniform vec4 puddle_color : source_color = vec4(0.06, 0.08, 0.07, 1.0);

varying vec3 v_world_pos;
varying vec3 v_world_normal;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// Slope mask (steep slopes expose rock/gravel, flat areas hold lush moss & loam)
	float slope = 1.0 - clamp(v_world_normal.y, 0.0, 1.0);
	float rock_factor = smoothstep(0.35, 0.65, slope);

	// Multi-frequency organic procedural noise
	float n1 = sin(v_world_pos.x * 0.45 + v_world_pos.z * 0.38);
	float n2 = cos(v_world_pos.x * 0.95 - v_world_pos.z * 0.85);
	float n3 = sin(v_world_pos.x * 2.2 + v_world_pos.z * 2.7) * 0.5;
	float micro_noise = n1 * 0.5 + n2 * 0.35 + n3 * 0.15;

	// Forest Trail mask (winding path along Z with gentle curve)
	float path_center_x = sin(v_world_pos.z * 0.045) * 12.0 + cos(v_world_pos.z * 0.09) * 4.0;
	float dist_to_path = abs(v_world_pos.x - path_center_x);
	float path_factor = 1.0 - smoothstep(1.5, 3.8, dist_to_path);

	// Moss distribution (thrives in moist flat/gentle slopes, shaded regions)
	float moss_noise = sin(v_world_pos.x * 0.18) * cos(v_world_pos.z * 0.22) * 0.5 + 0.5;
	float moss_factor = smoothstep(0.35, 0.7, moss_noise + micro_noise * 0.25) * (1.0 - rock_factor) * (1.0 - path_factor * 0.8);

	// Base blend between soil and moss
	vec3 ground_col = mix(soil_color.rgb, moss_color.rgb, moss_factor * 0.85);

	// Blend in trail dirt / packed needles
	ground_col = mix(ground_col, trail_color.rgb, path_factor * 0.85);

	// Blend in steep rocky outcrops
	ground_col = mix(ground_col, rock_color.rgb, rock_factor);

	// Rain puddles (collect in subtle path ruts and low terrain pockets)
	float puddle_zone = path_factor * smoothstep(0.2, 0.8, sin(v_world_pos.z * 0.35) * 0.5 + 0.5);
	float puddle_mask = clamp((puddle_zone * 0.85 + micro_noise * 0.15) * (1.0 - rock_factor), 0.0, 1.0);
	puddle_mask = smoothstep(0.68, 0.85, puddle_mask);

	// Micro-pebbles / needle specks
	float speck = smoothstep(0.75, 0.9, sin(v_world_pos.x * 25.0) * cos(v_world_pos.z * 25.0));
	ground_col += vec3(speck * 0.04);

	ALBEDO = mix(ground_col, puddle_color.rgb, puddle_mask);
	
	// PBR Roughness & Specular (puddles are glassy and catch golden sunlight)
	float base_roughness = mix(0.92, 0.78, moss_factor);
	base_roughness = mix(base_roughness, 0.95, rock_factor);
	ROUGHNESS = mix(base_roughness, 0.04, puddle_mask);
	SPECULAR = mix(0.15, 0.95, puddle_mask);
}

// Triplanar projection blends mossy forest floor on flat terrain and granite on steep slopes
