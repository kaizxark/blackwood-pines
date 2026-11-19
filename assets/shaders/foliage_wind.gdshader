shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

// High-fidelity wind foliage shader for Blackwood Pines
// Computes world-space noise wind displacement, canopy flutter, and subsurface transmission.

uniform vec4 albedo_color : source_color = vec4(0.12, 0.22, 0.10, 1.0);
uniform vec4 transmission_color : source_color = vec4(0.25, 0.45, 0.15, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.75;
uniform float wind_speed : hint_range(0.0, 6.0) = 1.4;
uniform float wind_strength : hint_range(0.0, 1.0) = 0.12;
uniform float canopy_flutter : hint_range(0.0, 2.0) = 0.25;

void vertex() {
	// World position for uncoordinated natural sway
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Height mask: base of trunk doesn't sway; upper branches sway strongly
	float height_factor = clamp((VERTEX.y - 1.0) * 0.1, 0.0, 1.0);
	
	// Primary wind wave
	float time_val = TIME * wind_speed;
	float wave1 = sin(time_val + world_pos.x * 0.15 + world_pos.z * 0.12);
	float wave2 = cos(time_val * 0.8 + world_pos.z * 0.18);
	
	// Canopy needle flutter (higher frequency)
	float flutter = sin(TIME * 4.0 + world_pos.x * 2.0 + world_pos.y * 3.0) * canopy_flutter * height_factor;
	
	// Apply displacement along X and Z
	VERTEX.x += (wave1 * wind_strength + flutter * 0.04) * height_factor;
	VERTEX.z += (wave2 * wind_strength * 0.8 + flutter * 0.04) * height_factor;
}

void fragment() {
	ALBEDO = albedo_color.rgb;
	ROUGHNESS = roughness;
	SPECULAR = 0.2;
	// Subsurface transmission makes needles glow when backlit by moonlight or flashlights
	BACKLIGHT = transmission_color.rgb * 0.45;
}
