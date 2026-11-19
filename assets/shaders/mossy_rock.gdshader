shader_type spatial;
render_mode cull_back;

// Glacial Granite Boulder Shader with velvety moss caps and lichen spots

uniform vec4 rock_color : source_color = vec4(0.32, 0.33, 0.34, 1.0);
uniform vec4 rock_dark_color : source_color = vec4(0.18, 0.19, 0.20, 1.0);
uniform vec4 moss_color : source_color = vec4(0.17, 0.34, 0.09, 1.0);
uniform vec4 lichen_color : source_color = vec4(0.48, 0.52, 0.38, 1.0);

varying vec3 v_world_pos;
varying vec3 v_world_normal;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// Surface variation noise
	float n = sin(v_world_pos.x * 2.5 + v_world_pos.z * 2.5) * cos(v_world_pos.y * 3.0);
	vec3 base_stone = mix(rock_dark_color.rgb, rock_color.rgb, n * 0.5 + 0.5);
	
	// Lichen patches
	float lichen_mask = smoothstep(0.6, 0.85, sin(v_world_pos.x * 6.0) * cos(v_world_pos.z * 6.0));
	base_stone = mix(base_stone, lichen_color.rgb, lichen_mask * 0.6);
	
	// Top-surface moss coat
	float moss_mask = smoothstep(0.4, 0.75, v_world_normal.y + n * 0.25);
	vec3 final_color = mix(base_stone, moss_color.rgb, moss_mask * 0.85);

	ALBEDO = final_color;
	ROUGHNESS = mix(0.85, 0.98, moss_mask);
	SPECULAR = 0.15;
}
