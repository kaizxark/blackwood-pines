class_name WallBuyStation
extends StaticBody3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Wall-Buy Station
# Allows players to purchase firearms and ammunition using points.

@export var weapon_resource_path: String = "res://weapons/shotgun/Remington870.tres"
@export var weapon_display_name: String = "Remington 870"
@export var weapon_cost: int = 500
@export var ammo_cost: int = 250

var weapon_res: WeaponResource = null

@onready var chalk_mesh: MeshInstance3D = $ChalkOutline
@onready var price_label_3d: Label3D = $PriceLabel3D
@onready var glow_light: OmniLight3D = $GlowLight

func _ready() -> void:
	add_to_group("interactables")
	collision_layer = 8 # Layer 4 (Interactable)
	collision_mask = 0
	
	if ResourceLoader.exists(weapon_resource_path):
		weapon_res = load(weapon_resource_path) as WeaponResource
		if weapon_res:
			weapon_display_name = weapon_res.weapon_name
			
	_update_label()

func _update_label() -> void:
	if price_label_3d:
		price_label_3d.text = "%s\nBUY: %d PTS | AMMO: %d PTS" % [weapon_display_name.to_upper(), weapon_cost, ammo_cost]

func interact(player: CharacterBody3D) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if not gm or not weapon_res:
		return
		
	var wm = player.get_node_or_null("CameraPivot/WeaponHolder/WeaponManager")
	if not wm:
		return
		
	# Check if player has this weapon
	var has_gun = false
	var gun_slot_index = -1
	for i in range(wm.weapon_resources.size()):
		if wm.weapon_resources[i].weapon_id == weapon_res.weapon_id:
			has_gun = true
			gun_slot_index = i
			break
			
	if not has_gun:
		# Purchase new weapon
		if gm.spend_points(weapon_cost):
			wm.add_or_replace_weapon(weapon_res)
			var sm = get_node_or_null("/root/SoundManager")
			if sm:
				sm.play_sfx("pickup", 0.05, 2.0)
				sm.play_sfx("slide_rack", 0.04, 1.0)
		else:
			# Not enough points
			var sm = get_node_or_null("/root/SoundManager")
			if sm: sm.play_sfx("dry_fire", 0.05, -2.0)
	else:
		# Purchase ammo
		var cur_w = wm.weapon_resources[gun_slot_index]
		if cur_w.reserve_ammo < cur_w.max_reserve_ammo:
			if gm.spend_points(ammo_cost):
				cur_w.reserve_ammo = cur_w.max_reserve_ammo
				var cur_active = wm.get_current_weapon()
				if cur_active and cur_active.weapon_id == cur_w.weapon_id:
					var eb = get_node_or_null("/root/EventBus")
					if eb: eb.weapon_switched.emit(cur_active.weapon_name, cur_active.current_ammo_in_mag, cur_active.reserve_ammo)
				var sm = get_node_or_null("/root/SoundManager")
				if sm:
					sm.play_sfx("mag_in", 0.04, 1.5)
			else:
				var sm = get_node_or_null("/root/SoundManager")
				if sm: sm.play_sfx("dry_fire", 0.05, -2.0)
		else:
			# Ammo already full
			var sm = get_node_or_null("/root/SoundManager")
			if sm: sm.play_sfx("dry_fire", 0.05, -2.0)

func get_interaction_prompt(player: CharacterBody3D) -> String:
	var wm = player.get_node_or_null("CameraPivot/WeaponHolder/WeaponManager")
	if wm:
		for w in wm.weapon_resources:
			if weapon_res and w.weapon_id == weapon_res.weapon_id:
				return "[E] BUY AMMO [%s] - %d PTS" % [weapon_display_name, ammo_cost]
	return "[E] BUY [%s] - %d PTS" % [weapon_display_name, weapon_cost]

## Interactive chalk wall outline station for weapon purchase and ammunition refill
