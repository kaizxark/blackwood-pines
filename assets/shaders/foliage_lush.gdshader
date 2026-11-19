shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

// PROJECT PROTO-BREACH - Next-Gen Lush Forest Foliage Shader
// Features: Multi-frequency wind physics, dual-tone leaf shading, subsurface light transmission, and organic hue variation.

uniform vec4 leaf_top_color : source_color = vec4(0.12, 0.32, 0.08, 1.0);
uniform vec4 leaf_bottom_color : source_color = vec4(0.20, 0.44, 0.12, 1.0);
uniform vec4 transmission_color : source_color = vec4(0.38, 0.65, 0.18, 1.0);
uniform float transmission_strength : hint_range(0.0, 2.0) = 0.85;

uniform float roughness : hint_range(0.0, 1.0) = 0.68;
uniform float specular : hint_range(0.0, 1.0) = 0.28;

uniform float wind_speed : hint_range(0.0, 5.0) = 1.6;
uniform float wind_strength : hint_range(0.0, 1.0) = 0.15;
uniform float flutter_speed : hint_range(0.0, 15.0) = 5.2;
uniform float flutter_strength : hint_range(0.0, 1.0) = 0.06;

varying vec3 v_world_pos;
varying float v_leaf_shade;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Height factor: trunk base does not sway; upper canopy sways progressively more
	float height_sway = clamp((VERTEX.y - 0.5) * 0.12, 0.0, 1.0);
	
	// Multi-frequency wind
	float t = TIME * wind_speed;
	float gust = sin(t * 0.4 + v_world_pos.x * 0.08 + v_world_pos.z * 0.07);
	float wave1 = sin(t + v_world_pos.x * 0.25 + v_world_pos.z * 0.2);
	float wave2 = cos(t * 0.85 + v_world_pos.z * 0.3);
	
	// High frequency canopy flutter
	float flutter = sin(TIME * flutter_speed + v_world_pos.x * 3.0 + v_world_pos.y * 4.0) * flutter_strength;
	
	// Composite wind displacement
	float total_sway_x = (wave1 * 0.7 + gust * 0.5) * wind_strength * height_sway;
	float total_sway_z = (wave2 * 0.6 + gust * 0.4) * wind_strength * height_sway;
	
	VERTEX.x += total_sway_x + flutter * height_sway;
	VERTEX.z += total_sway_z + flutter * height_sway;
	VERTEX.y -= (abs(total_sway_x) + abs(total_sway_z)) * 0.15; // Natural branch drooping under wind bend
	
	// Subtle random hue shift per tree based on world position
	v_leaf_shade = sin(v_world_pos.x * 0.13 + v_world_pos.z * 0.17) * 0.15;
}

void fragment() {
	// Dual-tone leaf shading: top side faces up/outward, bottom side faces inward/down
	vec3 world_norm = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float up_facing = clamp(world_norm.y * 0.5 + 0.5, 0.0, 1.0);
	
	vec3 base_leaf = mix(leaf_bottom_color.rgb, leaf_top_color.rgb, up_facing);
	
	// Apply subtle per-tree color tint (golden-green vs deep forest emerald)
	base_leaf += vec3(v_leaf_shade * 0.5, v_leaf_shade * 0.8, -v_leaf_shade * 0.2);
	
	// Micro leaf vein noise
	float vein = sin(UV.x * 20.0) * cos(UV.y * 30.0) * 0.05;
	base_leaf += vec3(vein);

	ALBEDO = base_leaf;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
	// Subsurface transmission: foliage illuminates brilliantly when sunlight shines through from behind
	BACKLIGHT = transmission_color.rgb * transmission_strength;
}
