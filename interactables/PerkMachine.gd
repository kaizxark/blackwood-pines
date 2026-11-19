class_name PerkMachine
extends StaticBody3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Perk Vending Machine
# Delivers classic survival perks: Juggernog (2500 pts) and Speed Cola (1500 pts).

enum PerkType {
	JUGGERNOG,
	SPEED_COLA
}

@export var perk_type: PerkType = PerkType.JUGGERNOG

var perk_id: String = "juggernog"
var perk_display_name: String = "Juggernog"
var perk_cost: int = 2500

@onready var prompt_label_3d: Label3D = $PromptLabel3D
@onready var title_label_3d: Label3D = $TitleLabel3D
@onready var machine_light: OmniLight3D = $MachineLight
@onready var body_mesh: MeshInstance3D = $MachineBody

func _ready() -> void:
	add_to_group("interactables")
	collision_layer = 8
	collision_mask = 0
	
	_configure_perk()
	_update_labels()

func _configure_perk() -> void:
	match perk_type:
		PerkType.JUGGERNOG:
			perk_id = "juggernog"
			perk_display_name = "Juggernog (+150 HP)"
			perk_cost = 2500
			if machine_light:
				machine_light.light_color = Color(1.0, 0.15, 0.15)
			if body_mesh:
				var m = StandardMaterial3D.new()
				m.albedo_color = Color(0.75, 0.08, 0.08)
				m.metallic = 0.5
				m.roughness = 0.35
				body_mesh.material_override = m
		PerkType.SPEED_COLA:
			perk_id = "speed_cola"
			perk_display_name = "Speed Cola (Fast Reload)"
			perk_cost = 1500
			if machine_light:
				machine_light.light_color = Color(0.15, 0.95, 0.35)
			if body_mesh:
				var m = StandardMaterial3D.new()
				m.albedo_color = Color(0.08, 0.65, 0.22)
				m.metallic = 0.5
				m.roughness = 0.35
				body_mesh.material_override = m

func _update_labels() -> void:
	if title_label_3d:
		title_label_3d.text = perk_display_name.to_upper()
	if prompt_label_3d:
		prompt_label_3d.text = "[E] BUY %s\n%d PTS" % [perk_display_name, perk_cost]

func interact(player: CharacterBody3D) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if not gm: return
	
	if gm.has_perk(perk_id):
		var sm = get_node_or_null("/root/SoundManager")
		if sm: sm.play_sfx("dry_fire", 0.05, -2.0)
		return
		
	if gm.spend_points(perk_cost):
		gm.grant_perk(perk_id)
		
		# Apply perk effects directly
		if perk_id == "juggernog":
			player.max_health = 250
			player.current_health = 250
			var eb = get_node_or_null("/root/EventBus")
			if eb:
				eb.player_health_changed.emit(player.current_health, player.max_health)
				
		_spawn_perk_particles()
		prompt_label_3d.text = "%s\n[ACTIVE]" % perk_display_name.to_upper()
	else:
		var sm = get_node_or_null("/root/SoundManager")
		if sm: sm.play_sfx("dry_fire", 0.05, -2.0)

func _spawn_perk_particles() -> void:
	var p = CPUParticles3D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = 24
	p.lifetime = 0.8
	p.direction = Vector3(0, 1, 0)
	p.spread = 40.0
	p.initial_velocity_min = 2.5
	p.initial_velocity_max = 5.0
	p.gravity = Vector3(0, -5.0, 0)
	
	var bmesh = BoxMesh.new()
	bmesh.size = Vector3(0.08, 0.08, 0.08)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.85, 0.2)
	mat.emission_energy_multiplier = 3.0
	p.mesh = bmesh
	p.material_override = mat
	
	get_tree().root.add_child(p)
	p.global_position = global_position + Vector3(0, 1.2, 0)
	p.restart()
	get_tree().create_timer(1.0).timeout.connect(func(): if is_instance_valid(p): p.queue_free())

func get_interaction_prompt(_player: CharacterBody3D) -> String:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_perk(perk_id):
		return "[%s - ACTIVE]" % perk_display_name.to_upper()
	return "[E] BUY %s - %d PTS" % [perk_display_name, perk_cost]

## Perk-a-Cola vending machine granting passive stat boosts upon purchase

# Juggernog purchase permanently increases player max HP from 100 to 250
