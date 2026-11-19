class_name MysteryBox
extends StaticBody3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Mystery Weapon Box
# Crate that rolls random weapons for 950 points with classic music jingle and rotating viewmodel.

const BOX_COST: int = 950

enum BoxState {
	IDLE,
	ROLLING,
	WEAPON_READY,
	CLOSING
}

var current_state: BoxState = BoxState.IDLE
var roll_timer: float = 0.0
var roll_duration: float = 3.6
var pickup_timer: float = 0.0
var pickup_timeout: float = 8.0

var weapon_pool: Array[WeaponResource] = []
var selected_weapon: WeaponResource = null

# Visual nodes
@onready var lid_pivot: Node3D = $LidPivot
@onready var weapon_display_root: Node3D = $WeaponDisplayRoot
@onready var chest_light: OmniLight3D = $ChestLight
@onready var question_marks: Label3D = $QuestionMarksLabel
@onready var prompt_label_3d: Label3D = $PromptLabel3D

func _ready() -> void:
	add_to_group("interactables")
	collision_layer = 8
	collision_mask = 0
	
	_load_weapon_pool()
	_update_prompt()

func _load_weapon_pool() -> void:
	var paths = [
		"res://weapons/pistol/M1911.tres",
		"res://weapons/shotgun/Remington870.tres",
		"res://weapons/rifle/AK47.tres",
		"res://weapons/carbine/M4A1.tres",
		"res://weapons/magnum/Python357.tres"
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var w = load(p) as WeaponResource
			if w: weapon_pool.append(w)

func _process(delta: float) -> void:
	match current_state:
		BoxState.ROLLING:
			roll_timer -= delta
			# Rapid weapon cycling rotation
			if weapon_display_root:
				weapon_display_root.rotation.y += delta * 12.0
				weapon_display_root.position.y = lerp(weapon_display_root.position.y, 0.95, delta * 3.0)
				
			if roll_timer <= 0.0:
				_finish_roll()
				
		BoxState.WEAPON_READY:
			pickup_timer -= delta
			if weapon_display_root:
				weapon_display_root.rotation.y += delta * 2.5
				
			if pickup_timer <= 0.0:
				_close_box()

func interact(player: CharacterBody3D) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if not gm: return
	
	match current_state:
		BoxState.IDLE:
			if gm.spend_points(BOX_COST):
				_start_roll()
			else:
				var sm = get_node_or_null("/root/SoundManager")
				if sm: sm.play_sfx("dry_fire", 0.05, -2.0)
				
		BoxState.WEAPON_READY:
			if selected_weapon:
				var wm = player.get_node_or_null("CameraPivot/WeaponHolder/WeaponManager")
				if wm:
					wm.add_or_replace_weapon(selected_weapon)
					var sm = get_node_or_null("/root/SoundManager")
					if sm:
						sm.play_sfx("pickup", 0.05, 2.0)
						sm.play_sfx("slide_rack", 0.04, 1.0)
				_close_box()

func _start_roll() -> void:
	current_state = BoxState.ROLLING
	roll_timer = roll_duration
	
	# Open Lid
	if lid_pivot:
		var tween = create_tween()
		tween.tween_property(lid_pivot, "rotation:x", -deg_to_rad(105.0), 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	# Music jingle & light
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_sfx_3d("mystery_box_jingle", global_position, 35.0, 3.0)
		
	if chest_light:
		chest_light.light_energy = 2.5
		
	if weapon_display_root:
		weapon_display_root.visible = true
		weapon_display_root.position.y = 0.2
		
	_update_prompt()

func _finish_roll() -> void:
	current_state = BoxState.WEAPON_READY
	pickup_timer = pickup_timeout
	
	if not weapon_pool.is_empty():
		selected_weapon = weapon_pool[randi() % weapon_pool.size()]
	
	_update_prompt()

func _close_box() -> void:
	current_state = BoxState.CLOSING
	selected_weapon = null
	
	if weapon_display_root:
		var t = create_tween()
		t.tween_property(weapon_display_root, "position:y", 0.1, 0.4)
		t.tween_callback(func(): weapon_display_root.visible = false)
		
	if lid_pivot:
		var tween = create_tween()
		tween.tween_property(lid_pivot, "rotation:x", 0.0, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
	if chest_light:
		chest_light.light_energy = 0.6
		
	get_tree().create_timer(0.6).timeout.connect(func():
		current_state = BoxState.IDLE
		_update_prompt()
	)

func _update_prompt() -> void:
	if prompt_label_3d:
		match current_state:
			BoxState.IDLE:
				prompt_label_3d.text = "MYSTERY BOX\n[E] 950 PTS"
			BoxState.ROLLING:
				prompt_label_3d.text = "ROLLING..."
			BoxState.WEAPON_READY:
				prompt_label_3d.text = "TAKE: %s\n[E] (EXPIRES IN %d)" % [selected_weapon.weapon_name if selected_weapon else "WEAPON", int(ceil(pickup_timer))]
			BoxState.CLOSING:
				prompt_label_3d.text = ""

func get_interaction_prompt(_player: CharacterBody3D) -> String:
	match current_state:
		BoxState.IDLE:
			return "[E] MYSTERY BOX - 950 PTS"
		BoxState.WEAPON_READY:
			return "[E] TAKE [%s]" % [selected_weapon.weapon_name if selected_weapon else "WEAPON"]
		_:
			return ""
