class_name DebrisDoor
extends StaticBody3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Debris / Bulkhead Door
# Costs points to clear/unlock (e.g. 750 pts) to expand the playable survival area.

@export var door_id: String = "door_atrium"
@export var cost: int = 750
@export var door_name: String = "Decontamination Air双lock"
var is_unlocked: bool = false

@onready var prompt_label_3d: Label3D = $PromptLabel3D
@onready var col_shape: CollisionShape3D = $CollisionShape3D
@onready var door_mesh: MeshInstance3D = $DoorMesh

func _ready() -> void:
	add_to_group("interactables")
	collision_layer = 1 | 8
	collision_mask = 0
	_update_prompt()

func interact(_player: CharacterBody3D) -> void:
	if is_unlocked: return
	
	var gm = get_node_or_null("/root/GameManager")
	if not gm: return
	
	if gm.spend_points(cost):
		_unlock_door()
	else:
		var sm = get_node_or_null("/root/SoundManager")
		if sm: sm.play_sfx("dry_fire", 0.05, -2.0)

func _unlock_door() -> void:
	is_unlocked = true
	col_shape.set_deferred("disabled", true)
	prompt_label_3d.visible = false
	
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx_3d("slide_rack", global_position, 35.0, 3.0)
		sm.play_sfx_3d("pickup", global_position, 35.0, 2.0)
		
	# Sliding open animation
	var tween = create_tween()
	tween.tween_property(door_mesh, "position:y", 3.2, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _update_prompt() -> void:
	if prompt_label_3d:
		if is_unlocked:
			prompt_label_3d.text = ""
		else:
			prompt_label_3d.text = "[E] CLEAR DEBRIS / OPEN DOOR\n%d PTS" % cost

func get_interaction_prompt(_player: CharacterBody3D) -> String:
	if is_unlocked: return ""
	return "[E] OPEN DOOR - %d PTS" % cost

# Clearing debris barrier costs 750 PTS and frees navigation pathway to outer zones
