class_name HUD
extends CanvasLayer

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Modernized High-Visibility Combat HUD
# Provides crystal-clear health, shield, real weapon stats, points economy, round counter,
# barricade/wall-buy interaction prompts, perk badges, and hitmarkers.

# Node references
@onready var ui_root: Control = $UIRoot

# Player Stats
@onready var health_bar: ProgressBar = $UIRoot/BottomLeftPanel/VBoxContainer/HealthBar
@onready var health_num_label: Label = $UIRoot/BottomLeftPanel/VBoxContainer/HealthHeader/HealthNumLabel
@onready var shield_bar: ProgressBar = $UIRoot/BottomLeftPanel/VBoxContainer/ShieldBar
@onready var shield_num_label: Label = $UIRoot/BottomLeftPanel/VBoxContainer/ShieldHeader/ShieldNumLabel

# Weapon Stats
@onready var weapon_name_label: Label = $UIRoot/BottomRightPanel/VBoxContainer/WeaponHeader/WeaponNameLabel
@onready var fire_mode_label: Label = $UIRoot/BottomRightPanel/VBoxContainer/WeaponHeader/FireModeLabel
@onready var ammo_main_label: Label = $UIRoot/BottomRightPanel/VBoxContainer/AmmoRow/AmmoMainLabel
@onready var ammo_reserve_label: Label = $UIRoot/BottomRightPanel/VBoxContainer/AmmoRow/AmmoReserveLabel
@onready var reload_prompt: Label = $UIRoot/BottomRightPanel/VBoxContainer/ReloadPromptLabel

# Crosshairs & Aim Assist
@onready var crosshair: Control = $UIRoot/Crosshair
@onready var lock_container: Control = $UIRoot/Crosshair/LockContainer
@onready var lock_label: Label = $UIRoot/Crosshair/LockContainer/LockLabel
@onready var hit_marker: Control = $UIRoot/HitMarker
@onready var objective_label: Label = $UIRoot/TopCenterPanel/ObjectiveLabel

# Zombie Survival UI Elements
@onready var round_panel: PanelContainer = $UIRoot/RoundPanel
@onready var round_label: Label = $UIRoot/RoundPanel/RoundLabel
@onready var points_panel: PanelContainer = $UIRoot/PointsPanel
@onready var points_label: Label = $UIRoot/PointsPanel/PointsHBox/PointsLabel
@onready var points_delta_label: Label = $UIRoot/PointsPanel/PointsHBox/PointsDeltaLabel
@onready var interact_panel: PanelContainer = $UIRoot/InteractionPanel
@onready var interact_label: Label = $UIRoot/InteractionPanel/InteractionLabel

# Perk Badges
@onready var perks_container: HBoxContainer = $UIRoot/PerksContainer
@onready var jug_badge: PanelContainer = $UIRoot/PerksContainer/JuggernogBadge
@onready var speed_badge: PanelContainer = $UIRoot/PerksContainer/SpeedColaBadge

# Screen effects & End screen
@onready var damage_vignette: ColorRect = $UIRoot/DamageVignette
@onready var end_screen: PanelContainer = $UIRoot/EndScreen
@onready var end_title_label: Label = $UIRoot/EndScreen/VBoxContainer/TitleLabel
@onready var end_stats_label: Label = $UIRoot/EndScreen/VBoxContainer/StatsLabel

var hit_marker_alpha: float = 0.0
var vignette_alpha: float = 0.0
var points_delta_alpha: float = 0.0
var has_synced_initial_stats: bool = false
var cached_player: CharacterBody3D = null

func _ready() -> void:
	_make_controls_ignore_mouse(self)
	_connect_events()
	_init_ui_state()
	_sync_with_game()

func _make_controls_ignore_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_make_controls_ignore_mouse(child)

func _connect_events() -> void:
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.player_health_changed.connect(_on_health_changed)
		eb.player_shield_changed.connect(_on_shield_changed)
		eb.weapon_fired.connect(_on_weapon_fired)
		eb.weapon_switched.connect(_on_weapon_switched)
		eb.weapon_reloaded.connect(_on_weapon_reloaded)
		eb.hit_confirmed.connect(_on_hit_confirmed)
		eb.objective_updated.connect(_on_objective_updated)
		eb.damage_vignette_requested.connect(_on_damage_vignette)
		eb.player_died.connect(_on_player_died)
		eb.level_completed.connect(_on_level_completed)
		if eb.has_signal("aim_assist_target_changed"):
			eb.aim_assist_target_changed.connect(_on_aim_assist_target_changed)
		if eb.has_signal("round_started"):
			eb.round_started.connect(_on_round_started)
		if eb.has_signal("round_ended"):
			eb.round_ended.connect(_on_round_ended)
		if eb.has_signal("points_changed"):
			eb.points_changed.connect(_on_points_changed)
		if eb.has_signal("perk_acquired"):
			eb.perk_acquired.connect(_on_perk_acquired)

func _init_ui_state() -> void:
	if end_screen: end_screen.visible = false
	if hit_marker: hit_marker.modulate.a = 0.0
	if damage_vignette: damage_vignette.modulate.a = 0.0
	if lock_container: lock_container.visible = false
	if reload_prompt: reload_prompt.visible = false
	if interact_panel: interact_panel.visible = false
	if points_delta_label: points_delta_label.modulate.a = 0.0
	if jug_badge: jug_badge.visible = false
	if speed_badge: speed_badge.visible = false

func _sync_with_game() -> void:
	cached_player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	if cached_player:
		_on_health_changed(cached_player.get("current_health"), cached_player.get("max_health"))
		_on_shield_changed(cached_player.get("current_shield"), cached_player.get("max_shield"))
		var wm = cached_player.get_node_or_null("CameraPivot/WeaponHolder/WeaponManager")
		if wm and wm.has_method("get_current_weapon"):
			var cur = wm.get_current_weapon()
			if cur:
				_on_weapon_switched(cur.weapon_name, cur.current_ammo_in_mag, cur.reserve_ammo)
		has_synced_initial_stats = true
		
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		_on_points_changed(gm.points, 0)
		_on_round_started(gm.current_round)

func _process(delta: float) -> void:
	if not has_synced_initial_stats:
		_sync_with_game()

	# 1. Fade Hit Marker
	if hit_marker_alpha > 0.0:
		hit_marker_alpha = max(0.0, hit_marker_alpha - delta * 4.5)
		if hit_marker: hit_marker.modulate.a = hit_marker_alpha
		
	# 2. Fade Damage Vignette
	if vignette_alpha > 0.0:
		vignette_alpha = max(0.0, vignette_alpha - delta * 2.5)
		if damage_vignette: damage_vignette.modulate.a = vignette_alpha
		
	# 3. Fade Points Delta Label
	if points_delta_alpha > 0.0:
		points_delta_alpha = max(0.0, points_delta_alpha - delta * 1.8)
		if points_delta_label: points_delta_label.modulate.a = points_delta_alpha
		
	# 4. Check interaction ray prompt
	_update_interaction_prompt()
			
	# Restart on Game Over
	if end_screen and end_screen.visible and Input.is_action_just_pressed("reload"):
		var gm = get_node_or_null("/root/GameManager")
		if gm: gm.restart_current_level()

func _update_interaction_prompt() -> void:
	if not is_instance_valid(cached_player):
		cached_player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		if not cached_player: return
		
	if cached_player.has_method("get_current_interaction_prompt"):
		var prompt = cached_player.get_current_interaction_prompt()
		if prompt != "":
			if interact_panel: interact_panel.visible = true
			if interact_label: interact_label.text = prompt
		else:
			if interact_panel: interact_panel.visible = false
	else:
		if interact_panel: interact_panel.visible = false

func _on_round_started(r_num: int) -> void:
	if round_label:
		round_label.text = "ROUND %d" % r_num
		# Pulse animation
		var tween = create_tween()
		tween.tween_property(round_label, "scale", Vector2(1.25, 1.25), 0.2).set_trans(Tween.TRANS_BACK)
		tween.tween_property(round_label, "scale", Vector2(1.0, 1.0), 0.2)

func _on_round_ended(r_num: int) -> void:
	if round_label:
		round_label.text = "ROUND %d [CLEARED]" % r_num

func _on_points_changed(total_pts: int, delta_pts: int) -> void:
	if points_label:
		points_label.text = "%d PTS" % total_pts
		
	if delta_pts != 0 and points_delta_label:
		points_delta_alpha = 1.0
		if delta_pts > 0:
			points_delta_label.text = "+%d" % delta_pts
			points_delta_label.modulate = Color(0.2, 1.0, 0.4)
		else:
			points_delta_label.text = "%d" % delta_pts
			points_delta_label.modulate = Color(1.0, 0.25, 0.25)

func _on_perk_acquired(perk_name: String) -> void:
	var p = perk_name.to_lower()
	if p == "juggernog" and jug_badge:
		jug_badge.visible = true
	elif p == "speed_cola" and speed_badge:
		speed_badge.visible = true

func _on_health_changed(hp: int, max_hp: int) -> void:
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = hp
	if health_num_label:
		health_num_label.text = "%d" % hp
		if hp <= 35:
			health_num_label.modulate = Color(1.0, 0.25, 0.25)
		elif hp <= 70:
			health_num_label.modulate = Color(1.0, 0.85, 0.25)
		else:
			health_num_label.modulate = Color(1.0, 1.0, 1.0)

func _on_shield_changed(shield: int, max_shield: int) -> void:
	if shield_bar:
		shield_bar.max_value = max_shield
		shield_bar.value = shield
	if shield_num_label:
		shield_num_label.text = "%d" % shield
		if shield <= 0:
			shield_num_label.modulate = Color(0.6, 0.6, 0.6)
		else:
			shield_num_label.modulate = Color(1.0, 1.0, 1.0)

func _on_weapon_fired(_w_name: String, ammo: int, _max_mag: int) -> void:
	if ammo_main_label:
		ammo_main_label.text = "%d" % ammo
		if ammo <= 3:
			ammo_main_label.modulate = Color(1.0, 0.3, 0.3)
			if reload_prompt: reload_prompt.visible = true
		else:
			ammo_main_label.modulate = Color(1.0, 0.88, 0.25)
			if reload_prompt: reload_prompt.visible = false

func _on_weapon_switched(w_name: String, ammo: int, reserve: int) -> void:
	if weapon_name_label:
		weapon_name_label.text = w_name.to_upper()
	if ammo_main_label:
		ammo_main_label.text = "%d" % ammo
		ammo_main_label.modulate = Color(1.0, 0.3, 0.3) if ammo <= 3 else Color(1.0, 0.88, 0.25)
	if ammo_reserve_label:
		ammo_reserve_label.text = " / %d" % reserve
	if reload_prompt:
		reload_prompt.visible = (ammo <= 3)
	if fire_mode_label:
		if "REMINGTON" in w_name.to_upper() or "SHOTGUN" in w_name.to_upper():
			fire_mode_label.text = "[PUMP-ACTION]"
		elif "AK-47" in w_name.to_upper() or "M4A1" in w_name.to_upper():
			fire_mode_label.text = "[FULL-AUTO]"
		else:
			fire_mode_label.text = "[SEMI-AUTO]"

func _on_weapon_reloaded(_w_name: String, ammo: int, reserve: int) -> void:
	if ammo_main_label:
		ammo_main_label.text = "%d" % ammo
		ammo_main_label.modulate = Color(1.0, 0.88, 0.25)
	if ammo_reserve_label:
		ammo_reserve_label.text = " / %d" % reserve
	if reload_prompt:
		reload_prompt.visible = false

func _on_aim_assist_target_changed(has_target: bool, _enemy: Node3D, _screen_pos: Vector2) -> void:
	if lock_container:
		lock_container.visible = has_target
	if crosshair:
		if has_target:
			crosshair.modulate = Color(1.0, 0.25, 0.25, 1.0)
		else:
			crosshair.modulate = Color(1.0, 1.0, 1.0, 0.95)

func _on_hit_confirmed(is_headshot: bool, _pos: Vector3) -> void:
	hit_marker_alpha = 1.0
	if hit_marker:
		hit_marker.modulate = Color(1.0, 0.15, 0.15) if is_headshot else Color(1.0, 1.0, 1.0)
		hit_marker.scale = Vector2(1.35, 1.35) if is_headshot else Vector2(1.0, 1.0)

func _on_objective_updated(_id: String, text: String, _completed: bool) -> void:
	if objective_label:
		objective_label.text = "[!] OBJECTIVE: " + text

func _on_damage_vignette(intensity: float) -> void:
	vignette_alpha = clamp(vignette_alpha + intensity, 0.0, 1.0)

func _on_player_died() -> void:
	if end_screen:
		end_screen.visible = true
		end_title_label.text = "YOU SURVIVED UNTIL THE END"
		end_title_label.modulate = Color(1.0, 0.2, 0.2)
		_populate_end_stats()

func _on_level_completed() -> void:
	if end_screen:
		end_screen.visible = true
		end_title_label.text = "OUTPOST SECURED - PROTOCOL RESTORED"
		end_title_label.modulate = Color(0.2, 1.0, 0.4)
		_populate_end_stats()

func _populate_end_stats() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and end_stats_label:
		var mins = int(gm.elapsed_time) / 60
		var secs = int(gm.elapsed_time) % 60
		end_stats_label.text = "ROUNDS SURVIVED: %d\nZOMBIES SLAIN: %d\nHEADSHOTS: %d\nTOTAL POINTS: %d\nACCURACY: %.1f%%\nSURVIVAL TIME: %02d:%02d\n\n[PRESS 'R' TO PLAY AGAIN]" % [
			gm.current_round,
			gm.zombies_killed,
			gm.headshot_kills,
			gm.points,
			gm.get_accuracy(),
			mins, secs
		]

## Heads-Up Display managing health bar, points, round counter, and kill notifications

# Round announcement banner scales up with an elastic bounce tween on wave change
