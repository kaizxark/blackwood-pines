class_name BarricadeWindow
extends StaticBody3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Barricade Window
# Protects interior bunker spaces from advancing zombie hordes.
# Zombies tear planks to breach; players repair planks for +10 points each.

@export var window_id: String = "window_1"
@export var max_planks: int = 5
var current_planks: int = 5

var plank_nodes: Array[MeshInstance3D] = []
var tear_timer: float = 0.0
var tear_interval: float = 1.3
var zombies_at_window: Array[Node3D] = []

@onready var barrier_col: CollisionShape3D = $BarrierCollision
@onready var planks_container: Node3D = $PlanksContainer
@onready var zombie_tear_area: Area3D = $ZombieTearArea
@onready var outside_marker: Marker3D = $OutsideMarker
@onready var inside_marker: Marker3D = $InsideMarker

func _ready() -> void:
	add_to_group("barricades")
	collision_layer = 1 | 8 # World & Interactable
	
	_gather_planks()
	_update_plank_visuals()
	
	if zombie_tear_area:
		zombie_tear_area.body_entered.connect(_on_zombie_entered)
		zombie_tear_area.body_exited.connect(_on_zombie_exited)

func _gather_planks() -> void:
	plank_nodes.clear()
	if planks_container:
		for child in planks_container.get_children():
			if child is MeshInstance3D:
				plank_nodes.append(child)

func _process(delta: float) -> void:
	_clean_zombies_list()
	
	# If zombies are actively at the barricade and planks exist, tear them down!
	if not zombies_at_window.is_empty() and current_planks > 0:
		tear_timer += delta
		if tear_timer >= tear_interval:
			tear_timer = 0.0
			_tear_plank()
	else:
		tear_timer = 0.0

func _clean_zombies_list() -> void:
	for i in range(zombies_at_window.size() - 1, -1, -1):
		var z = zombies_at_window[i]
		if not is_instance_valid(z) or (z.has_method("is_dead") and z.is_dead):
			zombies_at_window.remove_at(i)

func _on_zombie_entered(body: Node3D) -> void:
	if body.is_in_group("zombies") and not zombies_at_window.has(body):
		zombies_at_window.append(body)
		if body.has_method("on_reached_barricade"):
			body.on_reached_barricade(self)

func _on_zombie_exited(body: Node3D) -> void:
	if zombies_at_window.has(body):
		zombies_at_window.erase(body)

func _tear_plank() -> void:
	if current_planks <= 0:
		return
		
	current_planks -= 1
	_update_plank_visuals()
	_spawn_wood_splinters()
	
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx_3d("barricade_tear", global_position, 28.0, 1.0)
		
	# Notify zombies tearing
	for z in zombies_at_window:
		if is_instance_valid(z) and z.has_method("_execute_attack"):
			z._execute_attack()
			
	if current_planks <= 0:
		# Barrier breached!
		barrier_col.set_deferred("disabled", true)
		for z in zombies_at_window:
			if is_instance_valid(z) and z.has_method("on_barricade_breached"):
				z.on_barricade_breached(self)

func interact(player: CharacterBody3D) -> void:
	repair_one_plank()

func repair_one_plank() -> bool:
	if current_planks >= max_planks:
		return false
		
	current_planks += 1
	barrier_col.set_deferred("disabled", false)
	_update_plank_visuals()
	
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx_3d("barricade_hammer", global_position, 25.0, 1.5)
		
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.barricade_plank_restored.emit(window_id, current_planks)
		
	return true

func _update_plank_visuals() -> void:
	for i in range(plank_nodes.size()):
		plank_nodes[i].visible = (i < current_planks)

func _spawn_wood_splinters() -> void:
	var splinters = CPUParticles3D.new()
	splinters.emitting = false
	splinters.one_shot = true
	splinters.explosiveness = 1.0
	splinters.amount = 12
	splinters.lifetime = 0.5
	splinters.direction = Vector3(0, 0.5, 1)
	splinters.spread = 45.0
	splinters.initial_velocity_min = 2.0
	splinters.initial_velocity_max = 4.5
	splinters.gravity = Vector3(0, -9.8, 0)
	
	var splinter_mesh = BoxMesh.new()
	splinter_mesh.size = Vector3(0.08, 0.04, 0.04)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.28, 0.14)
	splinters.mesh = splinter_mesh
	splinters.material_override = mat
	
	get_tree().root.add_child(splinters)
	splinters.global_position = global_position + Vector3(0, 1.0, 0)
	splinters.restart()
	get_tree().create_timer(0.7).timeout.connect(func(): if is_instance_valid(splinters): splinters.queue_free())

func get_interaction_prompt(_player: CharacterBody3D = null) -> String:
	if current_planks < max_planks:
		return "[E] REBUILD PLANK (+10 PTS) [%d/%d]" % [current_planks, max_planks]
	return ""

## Repairable wooden window barricade with damage tracking and player rebuild

# Zombies tear down 1 plank every 1.8 seconds; player repairs 1 plank per E press
