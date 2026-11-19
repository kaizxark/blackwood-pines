extends SceneTree

func _init() -> void:
	print("Generating modernized high-visibility HUD scene with Zombie Survival extensions...")
	
	var hud = CanvasLayer.new()
	hud.name = "HUD"
	var hud_script = load("res://ui/HUD.gd")
	hud.set_script(hud_script)
	
	# Root full-screen Control
	var ui_root = Control.new()
	ui_root.name = "UIRoot"
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(ui_root)
	ui_root.owner = hud
	
	# Panel styles
	var style_cyan_panel = StyleBoxFlat.new()
	style_cyan_panel.bg_color = Color(0.02, 0.04, 0.07, 0.92)
	style_cyan_panel.border_width_left = 2
	style_cyan_panel.border_width_top = 2
	style_cyan_panel.border_width_right = 2
	style_cyan_panel.border_width_bottom = 2
	style_cyan_panel.border_color = Color(0.2, 0.8, 1.0, 0.75)
	style_cyan_panel.corner_radius_top_left = 8
	style_cyan_panel.corner_radius_top_right = 8
	style_cyan_panel.corner_radius_bottom_right = 8
	style_cyan_panel.corner_radius_bottom_left = 8
	style_cyan_panel.content_margin_left = 14
	style_cyan_panel.content_margin_top = 10
	style_cyan_panel.content_margin_right = 14
	style_cyan_panel.content_margin_bottom = 10

	var style_amber_panel = style_cyan_panel.duplicate()
	style_amber_panel.border_color = Color(1.0, 0.75, 0.2, 0.75)

	var style_blood_panel = style_cyan_panel.duplicate()
	style_blood_panel.bg_color = Color(0.12, 0.02, 0.02, 0.88)
	style_blood_panel.border_color = Color(0.9, 0.15, 0.15, 0.85)

	var style_perk_jug = style_cyan_panel.duplicate()
	style_perk_jug.bg_color = Color(0.4, 0.05, 0.05, 0.85)
	style_perk_jug.border_color = Color(1.0, 0.2, 0.2, 0.9)
	style_perk_jug.content_margin_left = 8
	style_perk_jug.content_margin_right = 8
	style_perk_jug.content_margin_top = 4
	style_perk_jug.content_margin_bottom = 4

	var style_perk_speed = style_cyan_panel.duplicate()
	style_perk_speed.bg_color = Color(0.05, 0.35, 0.12, 0.85)
	style_perk_speed.border_color = Color(0.2, 1.0, 0.4, 0.9)
	style_perk_speed.content_margin_left = 8
	style_perk_speed.content_margin_right = 8
	style_perk_speed.content_margin_top = 4
	style_perk_speed.content_margin_bottom = 4

	# 1. Damage Vignette
	var vignette = ColorRect.new()
	vignette.name = "DamageVignette"
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.85, 0.05, 0.05, 0.35)
	vignette.modulate.a = 0.0
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(vignette)
	vignette.owner = hud

	# 2. Crosshair & Aim Assist Lock
	var crosshair = Control.new()
	crosshair.name = "Crosshair"
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(crosshair)
	crosshair.owner = hud

	var dot = ColorRect.new()
	dot.name = "Dot"
	dot.offset_left = -2
	dot.offset_top = -2
	dot.offset_right = 2
	dot.offset_bottom = 2
	dot.color = Color(1, 1, 1, 0.95)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair.add_child(dot)
	dot.owner = hud

	var tick_offsets = [
		Vector4(-16, -1, -6, 1),
		Vector4(6, -1, 16, 1),
		Vector4(-1, -16, 1, -6),
		Vector4(-1, 6, 1, 16)
	]
	for i in range(tick_offsets.size()):
		var t = ColorRect.new()
		t.name = "Tick_%d" % i
		var o = tick_offsets[i]
		t.offset_left = o.x
		t.offset_top = o.y
		t.offset_right = o.z
		t.offset_bottom = o.w
		t.color = Color(0.9, 0.95, 1.0, 0.9)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		crosshair.add_child(t)
		t.owner = hud

	var lock_container = Control.new()
	lock_container.name = "LockContainer"
	lock_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_container.visible = false
	crosshair.add_child(lock_container)
	lock_container.owner = hud

	var lock_corners = [
		Vector4(-24, -24, -14, -22),
		Vector4(-24, -24, -22, -14),
		Vector4(14, -24, 24, -22),
		Vector4(22, -24, 24, -14),
		Vector4(-24, 22, -14, 24),
		Vector4(-24, 14, -22, 24),
		Vector4(14, 22, 24, 24),
		Vector4(22, 14, 24, 24)
	]
	for i in range(lock_corners.size()):
		var c = ColorRect.new()
		c.name = "LockBracket_%d" % i
		var o = lock_corners[i]
		c.offset_left = o.x
		c.offset_top = o.y
		c.offset_right = o.z
		c.offset_bottom = o.w
		c.color = Color(1.0, 0.2, 0.2, 0.95)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock_container.add_child(c)
		c.owner = hud

	var lock_lbl = Label.new()
	lock_lbl.name = "LockLabel"
	lock_lbl.text = "AIM LOCKED"
	lock_lbl.add_theme_font_size_override("font_size", 10)
	lock_lbl.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
	lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_lbl.offset_left = -40
	lock_lbl.offset_top = 26
	lock_lbl.offset_right = 40
	lock_lbl.offset_bottom = 40
	lock_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_container.add_child(lock_lbl)
	lock_lbl.owner = hud

	# 3. HitMarker
	var hit_marker = Control.new()
	hit_marker.name = "HitMarker"
	hit_marker.set_anchors_preset(Control.PRESET_CENTER)
	hit_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hit_marker.modulate.a = 0.0
	ui_root.add_child(hit_marker)
	hit_marker.owner = hud

	var hm_lines = [
		Vector4(-10, -10, -4, -4),
		Vector4(4, -10, 10, -4),
		Vector4(-10, 4, -4, 10),
		Vector4(4, 4, 10, 10)
	]
	for i in range(hm_lines.size()):
		var hl = ColorRect.new()
		hl.name = "HM_%d" % i
		var o = hm_lines[i]
		hl.offset_left = o.x
		hl.offset_top = o.y
		hl.offset_right = o.z
		hl.offset_bottom = o.w
		hl.color = Color(1.0, 0.1, 0.1, 1.0)
		hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hit_marker.add_child(hl)
		hl.owner = hud

	# 4. Interaction Prompt Panel (Center, below crosshair)
	var interact_panel = PanelContainer.new()
	interact_panel.name = "InteractionPanel"
	interact_panel.set_anchors_preset(Control.PRESET_CENTER)
	interact_panel.offset_left = -260
	interact_panel.offset_top = 65
	interact_panel.offset_right = 260
	interact_panel.offset_bottom = 115
	interact_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interact_panel.add_theme_stylebox_override("panel", style_amber_panel)
	interact_panel.visible = false
	ui_root.add_child(interact_panel)
	interact_panel.owner = hud

	var interact_lbl = Label.new()
	interact_lbl.name = "InteractionLabel"
	interact_lbl.text = "[E] REBUILD BARRICADE (+10 PTS)"
	interact_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interact_lbl.add_theme_font_size_override("font_size", 16)
	interact_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	interact_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interact_panel.add_child(interact_lbl)
	interact_lbl.owner = hud

	# 5. Round Tally Panel (Top-Left)
	var round_panel = PanelContainer.new()
	round_panel.name = "RoundPanel"
	round_panel.offset_left = 30
	round_panel.offset_top = 25
	round_panel.offset_right = 220
	round_panel.offset_bottom = 85
	round_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_panel.add_theme_stylebox_override("panel", style_blood_panel)
	ui_root.add_child(round_panel)
	round_panel.owner = hud

	var round_lbl = Label.new()
	round_lbl.name = "RoundLabel"
	round_lbl.text = "ROUND 1"
	round_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	round_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	round_lbl.add_theme_font_size_override("font_size", 30)
	round_lbl.add_theme_color_override("font_color", Color(1.0, 0.22, 0.22))
	round_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_panel.add_child(round_lbl)
	round_lbl.owner = hud

	# 6. Points Panel (Bottom-Right, above Weapon Panel)
	var points_panel = PanelContainer.new()
	points_panel.name = "PointsPanel"
	points_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	points_panel.offset_left = -280
	points_panel.offset_top = -205
	points_panel.offset_right = -30
	points_panel.offset_bottom = -150
	points_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	points_panel.add_theme_stylebox_override("panel", style_amber_panel)
	ui_root.add_child(points_panel)
	points_panel.owner = hud

	var points_hbox = HBoxContainer.new()
	points_hbox.name = "PointsHBox"
	points_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	points_panel.add_child(points_hbox)
	points_hbox.owner = hud

	var points_num_lbl = Label.new()
	points_num_lbl.name = "PointsLabel"
	points_num_lbl.text = "500 PTS"
	points_num_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	points_num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	points_num_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	points_num_lbl.add_theme_font_size_override("font_size", 28)
	points_num_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	points_num_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	points_hbox.add_child(points_num_lbl)
	points_num_lbl.owner = hud

	var points_delta_lbl = Label.new()
	points_delta_lbl.name = "PointsDeltaLabel"
	points_delta_lbl.text = "+100"
	points_delta_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	points_delta_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	points_delta_lbl.add_theme_font_size_override("font_size", 20)
	points_delta_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	points_delta_lbl.modulate.a = 0.0
	points_delta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	points_hbox.add_child(points_delta_lbl)
	points_delta_lbl.owner = hud

	# 7. Perks Badges Container (Bottom-Left, above Health)
	var perks_cont = HBoxContainer.new()
	perks_cont.name = "PerksContainer"
	perks_cont.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	perks_cont.offset_left = 30
	perks_cont.offset_top = -185
	perks_cont.offset_right = 320
	perks_cont.offset_bottom = -148
	perks_cont.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(perks_cont)
	perks_cont.owner = hud

	var jug_badge = PanelContainer.new()
	jug_badge.name = "JuggernogBadge"
	jug_badge.add_theme_stylebox_override("panel", style_perk_jug)
	jug_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	jug_badge.visible = false
	perks_cont.add_child(jug_badge)
	jug_badge.owner = hud

	var jug_lbl = Label.new()
	jug_lbl.name = "JugLabel"
	jug_lbl.text = "+ JUGGERNOG"
	jug_lbl.add_theme_font_size_override("font_size", 13)
	jug_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	jug_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	jug_badge.add_child(jug_lbl)
	jug_lbl.owner = hud

	var speed_badge = PanelContainer.new()
	speed_badge.name = "SpeedColaBadge"
	speed_badge.add_theme_stylebox_override("panel", style_perk_speed)
	speed_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speed_badge.visible = false
	perks_cont.add_child(speed_badge)
	speed_badge.owner = hud

	var speed_lbl = Label.new()
	speed_lbl.name = "SpeedLabel"
	speed_lbl.text = "⚡ SPEED COLA"
	speed_lbl.add_theme_font_size_override("font_size", 13)
	speed_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	speed_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speed_badge.add_child(speed_lbl)
	speed_lbl.owner = hud

	# 8. Bottom-Left Panel (Health & Shield)
	var bl_panel = PanelContainer.new()
	bl_panel.name = "BottomLeftPanel"
	bl_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bl_panel.offset_left = 30
	bl_panel.offset_top = -140
	bl_panel.offset_right = 320
	bl_panel.offset_bottom = -25
	bl_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bl_panel.add_theme_stylebox_override("panel", style_cyan_panel)
	ui_root.add_child(bl_panel)
	bl_panel.owner = hud

	var bl_vbox = VBoxContainer.new()
	bl_vbox.name = "VBoxContainer"
	bl_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bl_panel.add_child(bl_vbox)
	bl_vbox.owner = hud

	var hp_header = HBoxContainer.new()
	hp_header.name = "HealthHeader"
	hp_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bl_vbox.add_child(hp_header)
	hp_header.owner = hud

	var hp_title = Label.new()
	hp_title.name = "HealthTitle"
	hp_title.text = "VITAL SIGNS"
	hp_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_title.add_theme_font_size_override("font_size", 13)
	hp_title.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0, 0.8))
	hp_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_header.add_child(hp_title)
	hp_title.owner = hud

	var hp_num = Label.new()
	hp_num.name = "HealthNumLabel"
	hp_num.text = "100"
	hp_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hp_num.add_theme_font_size_override("font_size", 28)
	hp_num.add_theme_color_override("font_color", Color(1, 1, 1))
	hp_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_header.add_child(hp_num)
	hp_num.owner = hud

	var hp_bar = ProgressBar.new()
	hp_bar.name = "HealthBar"
	hp_bar.custom_minimum_size = Vector2(0, 16)
	hp_bar.show_percentage = false
	hp_bar.value = 100
	hp_bar.max_value = 100
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_hp = StyleBoxFlat.new()
	bg_hp.bg_color = Color(0.2, 0.04, 0.04, 0.85)
	bg_hp.corner_radius_top_left = 4; bg_hp.corner_radius_top_right = 4
	bg_hp.corner_radius_bottom_right = 4; bg_hp.corner_radius_bottom_left = 4
	var fg_hp = StyleBoxFlat.new()
	fg_hp.bg_color = Color(0.15, 0.95, 0.38)
	fg_hp.corner_radius_top_left = 4; fg_hp.corner_radius_top_right = 4
	fg_hp.corner_radius_bottom_right = 4; fg_hp.corner_radius_bottom_left = 4
	hp_bar.add_theme_stylebox_override("background", bg_hp)
	hp_bar.add_theme_stylebox_override("fill", fg_hp)
	bl_vbox.add_child(hp_bar)
	hp_bar.owner = hud

	var sh_header = HBoxContainer.new()
	sh_header.name = "ShieldHeader"
	sh_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bl_vbox.add_child(sh_header)
	sh_header.owner = hud

	var sh_title = Label.new()
	sh_title.name = "ShieldTitle"
	sh_title.text = "ENERGY SHIELD"
	sh_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sh_title.add_theme_font_size_override("font_size", 12)
	sh_title.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0, 0.8))
	sh_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sh_header.add_child(sh_title)
	sh_title.owner = hud

	var sh_num = Label.new()
	sh_num.name = "ShieldNumLabel"
	sh_num.text = "60"
	sh_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sh_num.add_theme_font_size_override("font_size", 22)
	sh_num.add_theme_color_override("font_color", Color(1, 1, 1))
	sh_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sh_header.add_child(sh_num)
	sh_num.owner = hud

	var sh_bar = ProgressBar.new()
	sh_bar.name = "ShieldBar"
	sh_bar.custom_minimum_size = Vector2(0, 10)
	sh_bar.show_percentage = false
	sh_bar.value = 60
	sh_bar.max_value = 60
	sh_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_sh = StyleBoxFlat.new()
	bg_sh.bg_color = Color(0.03, 0.1, 0.18, 0.85)
	bg_sh.corner_radius_top_left = 4; bg_sh.corner_radius_top_right = 4
	bg_sh.corner_radius_bottom_right = 4; bg_sh.corner_radius_bottom_left = 4
	var fg_sh = StyleBoxFlat.new()
	fg_sh.bg_color = Color(0.1, 0.8, 1.0)
	fg_sh.corner_radius_top_left = 4; fg_sh.corner_radius_top_right = 4
	fg_sh.corner_radius_bottom_right = 4; fg_sh.corner_radius_bottom_left = 4
	sh_bar.add_theme_stylebox_override("background", bg_sh)
	sh_bar.add_theme_stylebox_override("fill", fg_sh)
	bl_vbox.add_child(sh_bar)
	sh_bar.owner = hud

	# 9. Bottom-Right Panel (Weapons & Ammo)
	var br_panel = PanelContainer.new()
	br_panel.name = "BottomRightPanel"
	br_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	br_panel.offset_left = -280
	br_panel.offset_top = -140
	br_panel.offset_right = -30
	br_panel.offset_bottom = -25
	br_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	br_panel.add_theme_stylebox_override("panel", style_amber_panel)
	ui_root.add_child(br_panel)
	br_panel.owner = hud

	var br_vbox = VBoxContainer.new()
	br_vbox.name = "VBoxContainer"
	br_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	br_panel.add_child(br_vbox)
	br_vbox.owner = hud

	var w_header = HBoxContainer.new()
	w_header.name = "WeaponHeader"
	w_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	br_vbox.add_child(w_header)
	w_header.owner = hud

	var w_name = Label.new()
	w_name.name = "WeaponNameLabel"
	w_name.text = "M1911 TACTICAL"
	w_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	w_name.add_theme_font_size_override("font_size", 14)
	w_name.add_theme_color_override("font_color", Color(1.0, 0.75, 0.2))
	w_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	w_header.add_child(w_name)
	w_name.owner = hud

	var f_mode = Label.new()
	f_mode.name = "FireModeLabel"
	f_mode.text = "[SEMI-AUTO]"
	f_mode.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	f_mode.add_theme_font_size_override("font_size", 11)
	f_mode.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	f_mode.mouse_filter = Control.MOUSE_FILTER_IGNORE
	w_header.add_child(f_mode)
	f_mode.owner = hud

	var ammo_row = HBoxContainer.new()
	ammo_row.name = "AmmoRow"
	ammo_row.alignment = BoxContainer.ALIGNMENT_END
	ammo_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	br_vbox.add_child(ammo_row)
	ammo_row.owner = hud

	var ammo_main = Label.new()
	ammo_main.name = "AmmoMainLabel"
	ammo_main.text = "12"
	ammo_main.add_theme_font_size_override("font_size", 44)
	ammo_main.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
	ammo_main.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ammo_row.add_child(ammo_main)
	ammo_main.owner = hud

	var ammo_res = Label.new()
	ammo_res.name = "AmmoReserveLabel"
	ammo_res.text = " / 72"
	ammo_res.add_theme_font_size_override("font_size", 24)
	ammo_res.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	ammo_res.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	ammo_res.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ammo_row.add_child(ammo_res)
	ammo_res.owner = hud

	var reload_pr = Label.new()
	reload_pr.name = "ReloadPromptLabel"
	reload_pr.text = "[R] RELOAD WEAPON"
	reload_pr.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	reload_pr.add_theme_font_size_override("font_size", 12)
	reload_pr.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	reload_pr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reload_pr.visible = false
	br_vbox.add_child(reload_pr)
	reload_pr.owner = hud

	# 10. Top-Center Objective & Keybinds
	var tc_panel = PanelContainer.new()
	tc_panel.name = "TopCenterPanel"
	tc_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tc_panel.offset_left = 320
	tc_panel.offset_top = 18
	tc_panel.offset_right = -320
	tc_panel.offset_bottom = 60
	tc_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tc_panel.add_theme_stylebox_override("panel", style_cyan_panel)
	ui_root.add_child(tc_panel)
	tc_panel.owner = hud

	var obj_lbl = Label.new()
	obj_lbl.name = "ObjectiveLabel"
	obj_lbl.text = "[!] SURVIVE THE OUTBREAK | [F] FLASHLIGHT | [E] INTERACT | [1-5] WEAPONS"
	obj_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	obj_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	obj_lbl.add_theme_font_size_override("font_size", 14)
	obj_lbl.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	obj_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tc_panel.add_child(obj_lbl)
	obj_lbl.owner = hud

	# 11. EndScreen
	var end_screen = PanelContainer.new()
	end_screen.name = "EndScreen"
	end_screen.set_anchors_preset(Control.PRESET_CENTER)
	end_screen.offset_left = -260
	end_screen.offset_top = -140
	end_screen.offset_right = 260
	end_screen.offset_bottom = 140
	end_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_screen.add_theme_stylebox_override("panel", style_blood_panel)
	end_screen.visible = false
	ui_root.add_child(end_screen)
	end_screen.owner = hud

	var end_vbox = VBoxContainer.new()
	end_vbox.name = "VBoxContainer"
	end_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	end_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_screen.add_child(end_vbox)
	end_vbox.owner = hud

	var end_title = Label.new()
	end_title.name = "TitleLabel"
	end_title.text = "YOU DIED"
	end_title.add_theme_font_size_override("font_size", 28)
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_vbox.add_child(end_title)
	end_title.owner = hud

	var end_stats = Label.new()
	end_stats.name = "StatsLabel"
	end_stats.text = "Rounds Survived: 1\nZombies Killed: 0\n\n[PRESS 'R' TO RESTART]"
	end_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_vbox.add_child(end_stats)
	end_stats.owner = hud

	# Pack and Save
	var packed = PackedScene.new()
	var result = packed.pack(hud)
	if result == OK:
		ResourceSaver.save(packed, "res://ui/HUD.tscn")
		print("SUCCESS: PackedScene saved to res://ui/HUD.tscn")
	else:
		printerr("FAILED to pack HUD scene, error code: ", result)
	quit()
