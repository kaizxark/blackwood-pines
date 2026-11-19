shader_type spatial;
render_mode cull_back;

// PROJECT PROTO-BREACH - NEXT-GEN ALPINE MOUNTAIN CIRQUE SHADER
// Features: 360-Degree Continuous Panorama, Stratified Granite Crags, Upward Snow Drift, Aerial Perspective

uniform vec4 rock_base_color : source_color = vec4(0.30, 0.31, 0.33, 1.0);
uniform vec4 rock_dark_color : source_color = vec4(0.14, 0.15, 0.17, 1.0);
uniform vec4 forest_base_color : source_color = vec4(0.09, 0.20, 0.06, 1.0);
uniform vec4 snow_color : source_color = vec4(0.93, 0.96, 0.99, 1.0);
uniform vec4 haze_color : source_color = vec4(0.62, 0.72, 0.82, 1.0);

varying vec3 v_world_pos;
varying vec3 v_world_normal;

// Fast procedural hash
float hash(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
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

// 3-Octave fBm
float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 3; i++) {
		v += amp * noise(p);
		p = p * 2.15 + vec2(1.7, 9.2);
		amp *= 0.5;
	}
	return v;
}

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// 1. Rock Stratigraphy & Geological Jointing
	vec2 rock_uv = vec2(v_world_pos.x * 0.02 + v_world_pos.z * 0.02, v_world_pos.y * 0.08);
	float fissure = fbm(rock_uv * 3.0);
	float fissure_mask = smoothstep(0.35, 0.65, fissure);
	vec3 rock = mix(rock_dark_color.rgb, rock_base_color.rgb, fissure_mask);

	// 2. Mountain Base Forest Blending (Elevation < 28m)
	// Dark alpine evergreen tree-line at the foot of the peaks
	float foothill_factor = 1.0 - smoothstep(14.0, 32.0, v_world_pos.y);
	float slope = 1.0 - clamp(v_world_normal.y, 0.0, 1.0);
	foothill_factor *= (1.0 - smoothstep(0.45, 0.85, slope));
	vec3 surface = mix(rock, forest_base_color.rgb, foothill_factor * 0.88);

	// 3. Glaciated Alpine Snow Caps (Elevation > 48m & Upward Ledges)
	float height_snow = smoothstep(44.0, 72.0, v_world_pos.y);
	float upward_ledge = smoothstep(0.32, 0.68, v_world_normal.y);
	float snow_factor = height_snow * upward_ledge;

	// Wind-drift noise on ridges
	float drift = fbm(v_world_pos.xz * 0.1) * 0.25;
	snow_factor = smoothstep(0.28, 0.65, snow_factor + drift);

	vec3 mountain_color = mix(surface, snow_color.rgb, snow_factor);

	// 4. Atmospheric Aerial Perspective (Distance Haze)
	// Peaks further away naturally take on the atmospheric sky hue
	float dist = length(v_world_pos.xz);
	float haze_factor = smoothstep(140.0, 290.0, dist) * 0.45;
	mountain_color = mix(mountain_color, haze_color.rgb, haze_factor);

	ALBEDO = mountain_color;
	ROUGHNESS = mix(0.90, 0.40, snow_factor);
	SPECULAR = mix(0.12, 0.65, snow_factor);
}
