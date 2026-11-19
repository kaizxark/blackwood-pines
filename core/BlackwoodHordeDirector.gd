class_name BlackwoodHordeDirector
extends Node3D

# PROJECT PROTO-BREACH - Blackwood Forest Horde Director
# Spawns infected zombies dynamically from the surrounding dark pine forest perimeter.
# Supports wave scaling, round horns, audio alerts, and horde stalking.

@export var zombie_scene: PackedScene = preload("res://entities/enemies/zombie/Zombie.tscn")
@export var auto_start: bool = true
@export var intermission_duration: float = 6.0
@export var max_active_zombies: int = 28

var current_round: int = 0
var total_zombies_for_round: int = 0
var zombies_spawned_this_round: int = 0
var zombies_alive_count: int = 0

var is_in_intermission: bool = false
var intermission_timer: float = 0.0
var spawn_cooldown_timer: float = 0.0
var spawn_interval: float = 1.4

var active_zombies: Array[CharacterBody3D] = []
var player_ref: CharacterBody3D = null

func _ready() -> void:
	add_to_group("horde_director")
	_connect_events()
	player_ref = get_tree().get_first_node_in_group("player") as CharacterBody3D
	
	if auto_start:
		intermission_timer = 1.0
		is_in_intermission = true
		# Spawn initial zombies on the forest path right ahead in player's field of view
		get_tree().create_timer(1.2).timeout.connect(func():
			_spawn_trail_zombie(Vector3(-1.8, 10.0, 2.0))
			_spawn_trail_zombie(Vector3(2.2, 10.0, -5.0))
		)

func _spawn_trail_zombie(pos: Vector3) -> void:
	var z = zombie_scene.instantiate() as CharacterBody3D
	if not z: return
	
	# Snap to ground via raycast
	var space_state = get_world_3d().direct_space_state
	if space_state:
		var q = PhysicsRayQueryParameters3D.create(Vector3(pos.x, 30.0, pos.z), Vector3(pos.x, -10.0, pos.z), 1)
		var hit = space_state.intersect_ray(q)
		if not hit.is_empty():
			pos.y = hit.position.y + 0.2
	
	get_parent().add_child(z)
	z.global_position = pos
	z.set("target_player", player_ref)
	z.set("current_state", 2) # CHASE
	zombies_alive_count += 1
	active_zombies.append(z)

func _connect_events() -> void:
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		if eb.has_signal("enemy_killed"):
			eb.enemy_killed.connect(_on_enemy_killed)

func _process(delta: float) -> void:
	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player") as CharacterBody3D

	if is_in_intermission:
		intermission_timer -= delta
		if intermission_timer <= 0.0:
			_start_next_round()
		return
		
	# Dynamic wave spawning from the forest
	if zombies_spawned_this_round < total_zombies_for_round:
		spawn_cooldown_timer -= delta
		if spawn_cooldown_timer <= 0.0 and zombies_alive_count < max_active_zombies:
			spawn_cooldown_timer = spawn_interval
			_spawn_forest_zombie()
			
	_clean_active_zombies()
	if zombies_spawned_this_round >= total_zombies_for_round and zombies_alive_count == 0:
		_end_current_round()

func _start_next_round() -> void:
	is_in_intermission = false
	current_round += 1
	zombies_spawned_this_round = 0
	zombies_alive_count = 0
	
	var gm = get_node_or_null("/root/GameManager")
	if gm: gm.current_round = current_round
	
	# Round scaling
	total_zombies_for_round = int(6 + current_round * 4.0 + pow(current_round, 1.25))
	spawn_interval = clamp(1.8 - (current_round * 0.12), 0.5, 1.8)
	
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.round_started.emit(current_round)
		
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx("round_start_horn", 0.02, 3.5)

func _end_current_round() -> void:
	is_in_intermission = true
	intermission_timer = intermission_duration
	
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.round_ended.emit(current_round)
		
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx("round_end_calm", 0.02, 2.5)

func _spawn_forest_zombie() -> void:
	if not is_instance_valid(player_ref):
		return
		
	var z = zombie_scene.instantiate() as CharacterBody3D
	if not z: return
	
	# Spawn in an organic ring (20m to 35m) around the player in the dark mist
	var angle = randf() * TAU
	var dist = randf_range(20.0, 34.0)
	var spawn_pos = player_ref.global_position + Vector3(cos(angle) * dist, 0.2, sin(angle) * dist)
	
	# Clamp inside forest boundaries (-65m to 65m)
	spawn_pos.x = clamp(spawn_pos.x, -65.0, 65.0)
	spawn_pos.z = clamp(spawn_pos.z, -65.0, 65.0)
	
	# Raycast snap to terrain surface
	var space_state = get_world_3d().direct_space_state
	if space_state:
		var q = PhysicsRayQueryParameters3D.create(Vector3(spawn_pos.x, 35.0, spawn_pos.z), Vector3(spawn_pos.x, -10.0, spawn_pos.z), 1)
		var hit = space_state.intersect_ray(q)
		if not hit.is_empty():
			spawn_pos.y = hit.position.y + 0.2
		else:
			spawn_pos.y = 2.0
	
	# Archetype distribution
	var r = randf()
	if current_round >= 4 and r < 0.15:
		z.set("zombie_type", 2) # Mutated Brute
	elif current_round >= 2 and r < (0.25 + current_round * 0.06):
		z.set("zombie_type", 1) # Infected Sprinter
	else:
		z.set("zombie_type", 0) # Walker
		
	get_parent().add_child(z)
	z.global_position = spawn_pos
	z.set("target_player", player_ref)
	z.set("current_state", 2) # CHASE
	
	zombies_spawned_this_round += 1
	zombies_alive_count += 1
	active_zombies.append(z)

func _on_enemy_killed(_enemy_type: String, _score: int) -> void:
	zombies_alive_count = max(0, zombies_alive_count - 1)

func _clean_active_zombies() -> void:
	for i in range(active_zombies.size() - 1, -1, -1):
		var z = active_zombies[i]
		if not is_instance_valid(z) or z.get("is_dead") == true:
			active_zombies.remove_at(i)
	var alive = 0
	for z in active_zombies:
		if is_instance_valid(z) and z.get("is_dead") == false:
			alive += 1
	zombies_alive_count = alive

## Wave director managing undead horde pacing, spawn zones, and escalation

# Zombie count formula: 6 + round_number * 4 with geometric speed scaling

# Spawn zones evaluate distance to player and cull occluded wilderness spawners
