shader_type spatial;
render_mode blend_add, cull_disabled, unshaded, depth_draw_never;

// Volumetric Sun Shaft Beam Shader
// Simulates cinematic god rays slicing down through the lush canopy gaps.

uniform vec4 ray_color : source_color = vec4(1.0, 0.95, 0.82, 0.14);
uniform float falloff_speed : hint_range(0.0, 5.0) = 1.0;

varying vec3 v_world_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Soft edge fade across UV
	float edge_x = smoothstep(0.0, 0.35, UV.x) * (1.0 - smoothstep(0.65, 1.0, UV.x));
	// Vertical fade: bright near top canopy, softly dissipates toward forest floor
	float fade_y = pow(1.0 - UV.y, 1.4);
	
	// Subtle animated dust shimmer in the ray
	float shimmer = sin(TIME * 1.5 + v_world_pos.x * 2.0 + v_world_pos.y * 3.0) * 0.08 + 0.92;
	
	ALBEDO = ray_color.rgb * shimmer;
	ALPHA = ray_color.a * edge_x * fade_y;
}
