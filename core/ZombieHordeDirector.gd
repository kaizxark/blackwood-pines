class_name ZombieHordeDirector
extends Node3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Horde Wave Director
# Manages round progression (Round 1, 2, 3...), dynamic zombie pool spawning,
# intermission timers, archetype distribution, and horn announcements.

@export var zombie_scene: PackedScene = preload("res://entities/enemies/zombie/Zombie.tscn")
@export var auto_start: bool = true
@export var intermission_duration: float = 6.0
@export var max_active_zombies: int = 24

var current_round: int = 0
var total_zombies_for_round: int = 0
var zombies_spawned_this_round: int = 0
var zombies_alive_count: int = 0

var is_in_intermission: bool = false
var intermission_timer: float = 0.0
var spawn_cooldown_timer: float = 0.0
var spawn_interval: float = 1.8

var spawn_points: Array[Node3D] = []
var active_zombies: Array[CharacterBody3D] = []

func _ready() -> void:
	add_to_group("horde_director")
	_gather_spawn_points()
	_connect_events()
	
	if auto_start:
		intermission_timer = 3.0
		is_in_intermission = true

func _gather_spawn_points() -> void:
	spawn_points.clear()
	var spawners = get_tree().get_nodes_in_group("zombie_spawns")
	for s in spawners:
		if s is Node3D:
			spawn_points.append(s)
			
	# Also gather barricade outside markers
	var barricades = get_tree().get_nodes_in_group("barricades")
	for b in barricades:
		var out_marker = b.get_node_or_null("OutsideMarker")
		if out_marker and out_marker is Node3D:
			spawn_points.append(out_marker)

func _connect_events() -> void:
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		if eb.has_signal("enemy_killed"):
			eb.enemy_killed.connect(_on_enemy_killed)

func _process(delta: float) -> void:
	if is_in_intermission:
		intermission_timer -= delta
		if intermission_timer <= 0.0:
			_start_next_round()
		return
		
	# Active round spawning
	if zombies_spawned_this_round < total_zombies_for_round:
		spawn_cooldown_timer -= delta
		if spawn_cooldown_timer <= 0.0 and zombies_alive_count < max_active_zombies:
			spawn_cooldown_timer = spawn_interval
			_spawn_single_zombie()
			
	# Check wave completion
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
	
	# Round scaling: R1: 6, R2: 9, R3: 13, R4: 18, R5: 24...
	total_zombies_for_round = int(5 + current_round * 3.5 + pow(current_round, 1.25))
	spawn_interval = clamp(2.2 - (current_round * 0.15), 0.6, 2.2)
	
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.round_started.emit(current_round)
		
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx("round_start_horn", 0.02, 3.0)

func _end_current_round() -> void:
	is_in_intermission = true
	intermission_timer = intermission_duration
	
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.round_ended.emit(current_round)
		
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx("round_end_calm", 0.02, 2.0)

func _spawn_single_zombie() -> void:
	if spawn_points.is_empty():
		_gather_spawn_points()
		if spawn_points.is_empty(): return
		
	var pt = spawn_points[randi() % spawn_points.size()]
	var z = zombie_scene.instantiate() as CharacterBody3D
	if not z: return
	
	# Select Archetype based on round (0: WALKER, 1: RUNNER, 2: BRUTE, 3: CRAWLER)
	var r = randf()
	if current_round >= 5 and r < 0.15:
		z.set("zombie_type", 2) # BRUTE
	elif current_round >= 2 and r < (0.2 + current_round * 0.05):
		z.set("zombie_type", 1) # RUNNER
	else:
		z.set("zombie_type", 0) # WALKER
		
	get_parent().add_child(z)
	z.global_position = pt.global_position + Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
	
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

# Standardized wave state definitions and timer transitions
