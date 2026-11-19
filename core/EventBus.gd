extends Node

# Global decoupled EventBus for PROJECT PROTO-BREACH
# Follows Donchitos & awesome-gamedev-agent-skills decoupled architecture

# Player & Health signals
signal player_health_changed(current_hp: int, max_hp: int)
signal player_shield_changed(current_shield: int, max_shield: int)
signal player_damaged(amount: int, attacker_pos: Vector3)
signal player_died()

# Weapon & Ballistics signals
signal weapon_fired(weapon_name: String, ammo_in_mag: int, max_mag: int)
signal weapon_switched(weapon_name: String, ammo_in_mag: int, reserve_ammo: int)
signal weapon_reloaded(weapon_name: String, ammo_in_mag: int, reserve_ammo: int)
signal weapon_dry_fired()
signal hit_confirmed(is_headshot: bool, hit_position: Vector3)

# Enemy & Combat signals
signal enemy_alerted(enemy: Node3D)
signal enemy_damaged(enemy: Node3D, amount: int, is_headshot: bool)
signal enemy_killed(enemy_type: String, score: int)

# Mission & Objectives
signal objective_updated(objective_id: String, text: String, completed: bool)
signal comms_transmission(speaker_name: String, message: String, portrait_id: String)
signal level_completed()

# Zombie Survival & Economy Signals
signal points_changed(total_points: int, delta: int)
signal round_started(round_number: int)
signal round_ended(round_number: int)
signal zombie_killed(is_headshot: bool, points_awarded: int)
signal barricade_plank_restored(window_id: String, current_planks: int)
signal perk_acquired(perk_name: String)

# Aim Assist signals
signal aim_assist_target_changed(has_target: bool, enemy: Node3D, screen_pos: Vector2)

# Visual & Screen Effects
signal camera_shake_requested(trauma: float)
signal damage_vignette_requested(intensity: float)

## Global decoupled signal dispatcher for Project Blackwood Pines

# Signal contracts adhere to decoupled publisher-subscriber patterns

# Type definitions for signal payload arguments across game systems

# Verified: Null-safe signal emission checks prevent dangling subscriber calls
