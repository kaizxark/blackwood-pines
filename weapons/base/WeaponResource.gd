class_name WeaponResource
extends Resource

# WeaponResource defines data-driven weapon configurations

@export var weapon_name: String = "Weapon"
@export var weapon_id: String = "m1911"
@export var weapon_type_label: String = "[SEMI-AUTO]"
@export var damage: int = 25
@export var headshot_multiplier: float = 3.5
@export var fire_rate_rpm: float = 400.0 # Rounds per minute
@export var is_automatic: bool = false
@export var mag_capacity: int = 12
@export var current_ammo_in_mag: int = 12
@export var reserve_ammo: int = 72
@export var max_reserve_ammo: int = 120
@export var reload_time: float = 1.4
@export var cost: int = 0
@export var ammo_cost: int = 250

# Procedural Spring Recoil parameters
@export_group("Recoil & Sway")
@export var recoil_rotation_impulse: Vector3 = Vector3(0.08, 0.015, -0.01) # Pitch up, slight yaw
@export var recoil_position_impulse: Vector3 = Vector3(0.0, 0.02, 0.06) # Back towards camera
@export var spread_angle: float = 0.012 # In radians
@export var pellets_per_shot: int = 1
@export var range_distance: float = 120.0
@export var fire_sound: String = "pistol_fire"
@export var viewmodel_color: Color = Color(0.2, 0.22, 0.25)
@export var emissive_accent_color: Color = Color(0.1, 0.7, 1.0)

## Data resource defining weapon ballistics, audio, recoil, and 3D mesh offsets

# Damage drop-off parameters: maximum effective range before linear damage attenuation

# Base spread angle in degrees; multiplied by 0.25 when aim-down-sights is active
