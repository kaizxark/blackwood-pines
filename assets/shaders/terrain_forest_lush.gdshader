shader_type spatial;
render_mode cull_back;

// PROJECT PROTO-BREACH: ADVANCED PHOTOREALISTIC ALPINE FOREST TERRAIN SHADER
// Multi-Octave Fractal Noise, Triplanar Cliff Projection, Ecological Moisture & Soil Stratigraphy

uniform vec4 soil_color : source_color = vec4(0.18, 0.12, 0.08, 1.0);       // Rich dark forest loam
uniform vec4 needle_color : source_color = vec4(0.25, 0.15, 0.09, 1.0);     // Dry fallen pine needle bed
uniform vec4 trail_color : source_color = vec4(0.28, 0.20, 0.13, 1.0);      // Packed gravel & worn trail
uniform vec4 moss_color : source_color = vec4(0.13, 0.32, 0.07, 1.0);       // Lush velvety alpine moss
uniform vec4 rock_color : source_color = vec4(0.32, 0.31, 0.30, 1.0);       // Weathered granite bedrock
uniform vec4 rock_crevice_color : source_color = vec4(0.16, 0.15, 0.14, 1.0); // Shadowed rock fissures
uniform vec4 lichen_color : source_color = vec4(0.38, 0.42, 0.24, 1.0);     // Crustose rock lichens
uniform vec4 water_puddle_color : source_color = vec4(0.06, 0.08, 0.07, 1.0); // Wet creek wash / puddles

varying vec3 v_world_pos;
varying vec3 v_world_normal;

// Fast procedural hash
float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

// 2D Smooth Value Noise
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 4-Octave Fractal Brownian Motion (fBm)
float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	for (int i = 0; i < 4; i++) {
		v += amp * noise(p);
		p = rot * p * 2.02 + vec2(1.3, 1.7);
		amp *= 0.5;
	}
	return v;
}

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// 1. Geological Slope Calculation
	// Flat terrain holds loam, needles & moss; steep slopes (>30 deg) expose sheer granite cliffs
	float slope = 1.0 - clamp(v_world_normal.y, 0.0, 1.0);
	float rock_factor = smoothstep(0.28, 0.62, slope);

	// 2. Multi-Scale Procedural Noise (replaces artificial sinusoidal striping)
	vec2 pos_xz = v_world_pos.xz;
	float macro_noise = fbm(pos_xz * 0.04);
	float mid_noise   = fbm(pos_xz * 0.16 + vec2(4.2, 8.7));
	float micro_noise = fbm(pos_xz * 0.85 + vec2(12.1, 3.4));

	// 3. Trail & Human Outpost Mask
	// Natural winding dirt trail leading from Outpost Alpha through the valley
	float path_center_x = sin(v_world_pos.z * 0.028) * 18.0 + cos(v_world_pos.z * 0.065) * 8.0;
	float dist_to_path = abs(v_world_pos.x - path_center_x);
	float path_factor = 1.0 - smoothstep(1.4, 3.6, dist_to_path);

	// Outpost terrace clearing
	float dist_to_outpost = length(v_world_pos.xz - vec2(1.0, 14.0));
	float outpost_factor = 1.0 - smoothstep(10.0, 20.0, dist_to_outpost);
	float ground_worn_factor = clamp(max(path_factor, outpost_factor * 0.85), 0.0, 1.0);

	// 4. Riparian Creek Bed & Stream Wash (Lowest valley drainage)
	float creek_x = path_center_x + sin(v_world_pos.z * 0.05 + 0.8) * 4.5;
	float dist_to_creek = abs(v_world_pos.x - creek_x);
	float creek_factor = 1.0 - smoothstep(1.0, 3.8, dist_to_creek);

	// 5. Triplanar Vertical Cliff Projection
	// Steep rock faces project vertical strata along X & Z to prevent stretching
	vec2 rock_uv_side = vec2(v_world_pos.x * 0.15 + v_world_pos.z * 0.15, v_world_pos.y * 0.35);
	float cliff_strata = fbm(rock_uv_side * 2.0);
	float cliff_fissure = smoothstep(0.35, 0.65, cliff_strata);
	vec3 cliff_rock = mix(rock_crevice_color.rgb, rock_color.rgb, cliff_fissure);
	// Add subtle green/yellow crustose lichen flecks on sunny rock faces
	float lichen_mask = smoothstep(0.55, 0.75, fbm(v_world_pos.xz * 0.25)) * (1.0 - rock_factor * 0.5);
	cliff_rock = mix(cliff_rock, lichen_color.rgb, lichen_mask * 0.45);

	// 6. Forest Floor Soil & Pine Needle Blend
	float needle_mask = smoothstep(0.35, 0.65, macro_noise * 0.6 + mid_noise * 0.4);
	vec3 forest_floor = mix(soil_color.rgb, needle_color.rgb, needle_mask);

	// 7. Velvet Alpine Moss (thrives in moist lowlands, shaded hollows, and north-facing slopes)
	float north_facing = clamp(-v_world_normal.z * 0.5 + 0.5, 0.0, 1.0);
	float moisture = clamp(creek_factor * 0.7 + macro_noise * 0.3 + north_facing * 0.2, 0.0, 1.0);
	float moss_mask = smoothstep(0.32, 0.68, moisture + mid_noise * 0.2) * (1.0 - rock_factor) * (1.0 - ground_worn_factor * 0.85);
	vec3 ground_col = mix(forest_floor, moss_color.rgb, moss_mask * 0.88);

	// 8. Blend Worn Trail & Outpost Dirt/Gravel
	ground_col = mix(ground_col, trail_color.rgb, ground_worn_factor * 0.82);

	// 9. Blend Sheer Rock Outcrops & Cliffs
	ground_col = mix(ground_col, cliff_rock, rock_factor);

	// 10. Water Puddles & Wet Stream Stones
	float wet_zone = creek_factor * 0.8 + path_factor * smoothstep(0.3, 0.7, sin(v_world_pos.z * 0.4) * 0.5 + 0.5) * 0.4;
	wet_zone *= (1.0 - rock_factor);
	float puddle_mask = smoothstep(0.62, 0.82, wet_zone + micro_noise * 0.2);

	// 11. Final Albedo & PBR Properties
	ALBEDO = mix(ground_col, water_puddle_color.rgb, puddle_mask);

	float base_roughness = mix(0.92, 0.72, moss_mask);
	base_roughness = mix(base_roughness, 0.95, rock_factor);
	base_roughness = mix(base_roughness, 0.85, ground_worn_factor);
	ROUGHNESS = mix(base_roughness, 0.05, puddle_mask);
	SPECULAR = mix(0.12, 0.95, puddle_mask);
}
