extends SceneTree

func _init() -> void:
	print("--- GENERATING SECTOR 7 QUARANTINE MAP ---")
	
	var root = Node3D.new()
	root.name = "Sector7Quarantine"
	var level_script = load("res://levels/zombie_outbreak/Sector7_Quarantine.gd")
	root.set_script(level_script)
	
	# Materials
	var mat_floor = load("res://assets/materials/mat_floor.tres")
	var mat_wall = load("res://assets/materials/mat_wall.tres")
	var mat_hazard = load("res://assets/materials/mat_hazard.tres")
	
	var mat_ceiling = StandardMaterial3D.new()
	mat_ceiling.albedo_color = Color(0.12, 0.13, 0.15)
	mat_ceiling.roughness = 0.8
	
	# 1. WorldEnvironment
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.05, 0.07)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.14, 0.16, 0.22)
	env.ambient_light_energy = 0.40 # Calibrated moody darkness
	env.ssao_enabled = true
	env.glow_enabled = true
	env.glow_bloom = 0.15
	env.glow_intensity = 0.85
	we.environment = env
	root.add_child(we)
	we.owner = root
	
	# 2. Directional Moonlight (cool & atmospheric)
	var sun = DirectionalLight3D.new()
	sun.name = "Moonlight"
	sun.light_color = Color(0.48, 0.62, 0.82)
	sun.light_energy = 0.35
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-58, 42, 0)
	root.add_child(sun)
	sun.owner = root
	
	# 3. Horde Wave Director
	var director_script = load("res://core/ZombieHordeDirector.gd")
	var director = Node3D.new()
	director.name = "ZombieHordeDirector"
	director.set_script(director_script)
	root.add_child(director)
	director.owner = root
	
	# 4. Player Instance
	var player_scene = load("res://entities/player/Player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	player.position = Vector3(0, 0.2, 0)
	root.add_child(player)
	player.owner = root
	
	# 5. HUD Instance
	var hud_scene = load("res://ui/HUD.tscn")
	var hud = hud_scene.instantiate()
	hud.name = "HUD"
	root.add_child(hud)
	hud.owner = root
	
	# Packed scenes for interactables
	var barricade_scene = load("res://interactables/BarricadeWindow.tscn")
	var wallbuy_scene = load("res://interactables/WallBuyStation.tscn")
	var mysterybox_scene = load("res://interactables/MysteryBox.tscn")
	var perk_scene = load("res://interactables/PerkMachine.tscn")
	var door_scene = load("res://interactables/DebrisDoor.tscn")
	var barrel_scene = load("res://interactables/ExplosiveBarrel.tscn")
	
	# =========================================================================
	# ROOM 1: ISOLATION MED-BAY (SPAWN ROOM: 18m x 16m x 5m)
	# =========================================================================
	var medbay_root = Node3D.new()
	medbay_root.name = "MedBaySpawn"
	root.add_child(medbay_root)
	medbay_root.owner = root
	
	# Floor & Ceiling
	_create_static_box(medbay_root, root, "MedbayFloor", Vector3(18, 0.4, 16), Vector3(0, -0.2, 0), mat_floor)
	_create_static_box(medbay_root, root, "MedbayCeiling", Vector3(18, 0.4, 16), Vector3(0, 5.0, 0), mat_ceiling)
	
	# South Wall (with M1911 Ammo buy)
	_create_static_box(medbay_root, root, "MedbaySouthWall", Vector3(18, 5.0, 0.5), Vector3(0, 2.5, 8.0), mat_wall)
	
	# West Wall (with Remington 870 Wall-buy and Window opening)
	_create_static_box(medbay_root, root, "MedbayWestWall_N", Vector3(0.5, 5.0, 5.5), Vector3(-9.0, 2.5, -5.25), mat_wall)
	_create_static_box(medbay_root, root, "MedbayWestWall_S", Vector3(0.5, 5.0, 7.5), Vector3(-9.0, 2.5, 4.25), mat_wall)
	_create_static_box(medbay_root, root, "MedbayWestWall_Top", Vector3(0.5, 2.2, 3.0), Vector3(-9.0, 3.9, -1.0), mat_wall)
	
	# East Wall (with East Window opening)
	_create_static_box(medbay_root, root, "MedbayEastWall_N", Vector3(0.5, 5.0, 6.5), Vector3(9.0, 2.5, -4.75), mat_wall)
	_create_static_box(medbay_root, root, "MedbayEastWall_S", Vector3(0.5, 5.0, 6.5), Vector3(9.0, 2.5, 4.75), mat_wall)
	_create_static_box(medbay_root, root, "MedbayEastWall_Top", Vector3(0.5, 2.2, 3.0), Vector3(9.0, 3.9, 0.0), mat_wall)
	
	# North Wall (Doorway to Atrium + North Window)
	_create_static_box(medbay_root, root, "MedbayNorthWall_L", Vector3(5.5, 5.0, 0.5), Vector3(-6.25, 2.5, -8.0), mat_wall)
	_create_static_box(medbay_root, root, "MedbayNorthWall_R", Vector3(6.5, 5.0, 0.5), Vector3(5.75, 2.5, -8.0), mat_wall)
	_create_static_box(medbay_root, root, "MedbayNorthWall_Top", Vector3(3.6, 1.8, 0.5), Vector3(0.0, 4.1, -8.0), mat_wall)
	
	# Debris Door to Atrium (750 pts)
	var door_atrium = door_scene.instantiate()
	door_atrium.name = "Door_To_Atrium"
	door_atrium.cost = 750
	door_atrium.position = Vector3(0, 0, -8.0)
	medbay_root.add_child(door_atrium)
	door_atrium.owner = root
	
	# Barricade Windows in Med-Bay
	var w_west = barricade_scene.instantiate()
	w_west.name = "Barricade_Medbay_West"
	w_west.window_id = "medbay_west"
	w_west.position = Vector3(-9.0, 0, -1.0)
	w_west.rotation_degrees = Vector3(0, 90, 0)
	medbay_root.add_child(w_west)
	w_west.owner = root
	
	var w_east = barricade_scene.instantiate()
	w_east.name = "Barricade_Medbay_East"
	w_east.window_id = "medbay_east"
	w_east.position = Vector3(9.0, 0, 0.0)
	w_east.rotation_degrees = Vector3(0, -90, 0)
	medbay_root.add_child(w_east)
	w_east.owner = root
	
	# Wall-Buys in Med-Bay
	var wb_m1911 = wallbuy_scene.instantiate()
	wb_m1911.name = "WallBuy_M1911Ammo"
	wb_m1911.weapon_resource_path = "res://weapons/pistol/M1911.tres"
	wb_m1911.weapon_display_name = "M1911 Ammo"
	wb_m1911.weapon_cost = 250
	wb_m1911.ammo_cost = 250
	wb_m1911.position = Vector3(0, 1.6, 7.7)
	wb_m1911.rotation_degrees = Vector3(0, 180, 0)
	medbay_root.add_child(wb_m1911)
	wb_m1911.owner = root
	
	var wb_rem = wallbuy_scene.instantiate()
	wb_rem.name = "WallBuy_Remington870"
	wb_rem.weapon_resource_path = "res://weapons/shotgun/Remington870.tres"
	wb_rem.weapon_display_name = "Remington 870"
	wb_rem.weapon_cost = 500
	wb_rem.ammo_cost = 250
	wb_rem.position = Vector3(-8.7, 1.6, 4.0)
	wb_rem.rotation_degrees = Vector3(0, 90, 0)
	medbay_root.add_child(wb_rem)
	wb_rem.owner = root
	
	# Med-Bay Lighting (calibrated ~0.9 energy)
	_create_omni_light(medbay_root, root, "MedbayLight1", Vector3(-4, 4.5, -3), Color(1.0, 0.88, 0.65), 0.9, 14.0)
	_create_omni_light(medbay_root, root, "MedbayLight2", Vector3(4, 4.5, -3), Color(1.0, 0.88, 0.65), 0.9, 14.0)
	_create_omni_light(medbay_root, root, "MedbayLight3", Vector3(-4, 4.5, 4), Color(1.0, 0.88, 0.65), 0.9, 14.0)
	_create_omni_light(medbay_root, root, "MedbayLight4", Vector3(4, 4.5, 4), Color(1.0, 0.88, 0.65), 0.9, 14.0)
	_create_omni_light(medbay_root, root, "MedbayRedBeacon", Vector3(0, 4.7, 0), Color(1.0, 0.15, 0.15), 1.1, 10.0)
	
	# Med-Bay Props (Gurneys, Cabinets)
	_create_static_box(medbay_root, root, "Gurney1", Vector3(1.2, 0.85, 2.4), Vector3(-3.5, 0.42, 1.5), mat_wall)
	_create_static_box(medbay_root, root, "Gurney2", Vector3(1.2, 0.85, 2.4), Vector3(3.5, 0.42, 2.0), mat_wall)
	_create_static_box(medbay_root, root, "FallenCabinet", Vector3(2.0, 0.6, 1.0), Vector3(4.0, 0.3, -4.5), mat_hazard)
	
	# =========================================================================
	# ROOM 2: MAIN DECONTAMINATION ATRIUM (34m x 32m x 8m)
	# =========================================================================
	var atrium_root = Node3D.new()
	atrium_root.name = "MainAtrium"
	root.add_child(atrium_root)
	atrium_root.owner = root
	
	# Floor & Ceiling
	_create_static_box(atrium_root, root, "AtriumFloor", Vector3(34, 0.4, 32), Vector3(0, -0.2, -28.0), mat_floor)
	_create_static_box(atrium_root, root, "AtriumCeiling", Vector3(34, 0.4, 32), Vector3(0, 8.0, -28.0), mat_ceiling)
	
	# North Wall (with 2 exterior barricades)
	_create_static_box(atrium_root, root, "AtriumNorthWall_L", Vector3(12, 8.0, 0.5), Vector3(-11.0, 4.0, -44.0), mat_wall)
	_create_static_box(atrium_root, root, "AtriumNorthWall_C", Vector3(8, 8.0, 0.5), Vector3(0.0, 4.0, -44.0), mat_wall)
	_create_static_box(atrium_root, root, "AtriumNorthWall_R", Vector3(12, 8.0, 0.5), Vector3(11.0, 4.0, -44.0), mat_wall)
	
	# South Wall (connects to Med-Bay)
	_create_static_box(atrium_root, root, "AtriumSouthWall_L", Vector3(12.5, 8.0, 0.5), Vector3(-10.75, 4.0, -12.0), mat_wall)
	_create_static_box(atrium_root, root, "AtriumSouthWall_R", Vector3(12.5, 8.0, 0.5), Vector3(10.75, 4.0, -12.0), mat_wall)
	
	# West Wall (with M4A1 buy)
	_create_static_box(atrium_root, root, "AtriumWestWall", Vector3(0.5, 8.0, 32), Vector3(-17.0, 4.0, -28.0), mat_wall)
	
	# East Wall (with Door to Lab)
	_create_static_box(atrium_root, root, "AtriumEastWall_N", Vector3(0.5, 8.0, 14), Vector3(17.0, 4.0, -35.0), mat_wall)
	_create_static_box(atrium_root, root, "AtriumEastWall_S", Vector3(0.5, 8.0, 14), Vector3(17.0, 4.0, -21.0), mat_wall)
	_create_static_box(atrium_root, root, "AtriumEastWall_Top", Vector3(0.5, 4.8, 4.0), Vector3(17.0, 5.6, -28.0), mat_wall)
	
	# Debris Door to Lab (1000 pts)
	var door_lab = door_scene.instantiate()
	door_lab.name = "Door_To_Lab"
	door_lab.cost = 1000
	door_lab.position = Vector3(17.0, 0, -28.0)
	door_lab.rotation_degrees = Vector3(0, 90, 0)
	atrium_root.add_child(door_lab)
	door_lab.owner = root
	
	# Mystery Box in Center of Atrium
	var box = mysterybox_scene.instantiate()
	box.name = "MysteryBox"
	box.position = Vector3(0, 0, -28.0)
	box.rotation_degrees = Vector3(0, 180, 0)
	atrium_root.add_child(box)
	box.owner = root
	
	# Wall-Buys in Atrium: AK-47 & M4A1
	var wb_ak = wallbuy_scene.instantiate()
	wb_ak.name = "WallBuy_AK47"
	wb_ak.weapon_resource_path = "res://weapons/rifle/AK47.tres"
	wb_ak.weapon_display_name = "AK-47"
	wb_ak.weapon_cost = 1200
	wb_ak.ammo_cost = 600
	wb_ak.position = Vector3(16.7, 1.8, -20.0)
	wb_ak.rotation_degrees = Vector3(0, -90, 0)
	atrium_root.add_child(wb_ak)
	wb_ak.owner = root
	
	var wb_m4 = wallbuy_scene.instantiate()
	wb_m4.name = "WallBuy_M4A1"
	wb_m4.weapon_resource_path = "res://weapons/carbine/M4A1.tres"
	wb_m4.weapon_display_name = "M4A1 Carbine"
	wb_m4.weapon_cost = 1500
	wb_m4.ammo_cost = 750
	wb_m4.position = Vector3(-16.7, 1.8, -20.0)
	wb_m4.rotation_degrees = Vector3(0, 90, 0)
	atrium_root.add_child(wb_m4)
	wb_m4.owner = root
	
	# Explosive Barrels in Atrium
	var barrel_positions = [
		Vector3(-6.0, 0, -22.0),
		Vector3(7.0, 0, -34.0),
		Vector3(-8.0, 0, -36.0),
		Vector3(8.0, 0, -22.0)
	]
	for i in range(barrel_positions.size()):
		var b = barrel_scene.instantiate()
		b.name = "ExplosiveBarrel_%d" % (i + 1)
		b.position = barrel_positions[i]
		atrium_root.add_child(b)
		b.owner = root
		
	# Atrium Lighting (calibrated ~1.0 energy)
	_create_omni_light(atrium_root, root, "AtriumLight1", Vector3(-8, 7.2, -20), Color(0.85, 0.9, 1.0), 1.0, 18.0)
	_create_omni_light(atrium_root, root, "AtriumLight2", Vector3(8, 7.2, -20), Color(0.85, 0.9, 1.0), 1.0, 18.0)
	_create_omni_light(atrium_root, root, "AtriumLight3", Vector3(-8, 7.2, -28), Color(0.85, 0.9, 1.0), 1.0, 18.0)
	_create_omni_light(atrium_root, root, "AtriumLight4", Vector3(8, 7.2, -28), Color(0.85, 0.9, 1.0), 1.0, 18.0)
	_create_omni_light(atrium_root, root, "AtriumLight5", Vector3(-8, 7.2, -36), Color(0.85, 0.9, 1.0), 1.0, 18.0)
	_create_omni_light(atrium_root, root, "AtriumLight6", Vector3(8, 7.2, -36), Color(0.85, 0.9, 1.0), 1.0, 18.0)
	_create_omni_light(atrium_root, root, "AtriumBeacon", Vector3(0, 7.5, -28), Color(0.2, 0.75, 1.0), 1.4, 22.0)
	
	# =========================================================================
	# ROOM 3: CONTAINMENT LAB & PERK BAY (24m x 18m x 6m)
	# =========================================================================
	var lab_root = Node3D.new()
	lab_root.name = "ContainmentLab"
	root.add_child(lab_root)
	lab_root.owner = root
	
	# Floor & Ceiling
	_create_static_box(lab_root, root, "LabFloor", Vector3(24, 0.4, 18), Vector3(29.0, -0.2, -28.0), mat_floor)
	_create_static_box(lab_root, root, "LabCeiling", Vector3(24, 0.4, 18), Vector3(29.0, 6.0, -28.0), mat_ceiling)
	
	# Walls
	_create_static_box(lab_root, root, "LabEastWall", Vector3(0.5, 6.0, 18), Vector3(41.0, 3.0, -28.0), mat_wall)
	_create_static_box(lab_root, root, "LabNorthWall", Vector3(24, 6.0, 0.5), Vector3(29.0, 3.0, -37.0), mat_wall)
	_create_static_box(lab_root, root, "LabSouthWall", Vector3(24, 6.0, 0.5), Vector3(29.0, 3.0, -19.0), mat_wall)
	
	# Perks in Lab: Juggernog & Speed Cola
	var perk_jug = perk_scene.instantiate()
	perk_jug.name = "Perk_Juggernog"
	perk_jug.perk_type = 0 # Juggernog
	perk_jug.position = Vector3(40.4, 0, -32.0)
	perk_jug.rotation_degrees = Vector3(0, -90, 0)
	lab_root.add_child(perk_jug)
	perk_jug.owner = root
	
	var perk_speed = perk_scene.instantiate()
	perk_speed.name = "Perk_SpeedCola"
	perk_speed.perk_type = 1 # Speed Cola
	perk_speed.position = Vector3(40.4, 0, -24.0)
	perk_speed.rotation_degrees = Vector3(0, -90, 0)
	lab_root.add_child(perk_speed)
	perk_speed.owner = root
	
	# Wall-Buy in Lab: Python .357 Magnum Hand-Cannon (2000 pts)
	var wb_mag = wallbuy_scene.instantiate()
	wb_mag.name = "WallBuy_Python357"
	wb_mag.weapon_resource_path = "res://weapons/magnum/Python357.tres"
	wb_mag.weapon_display_name = "Colt Python .357"
	wb_mag.weapon_cost = 2000
	wb_mag.ammo_cost = 1000
	wb_mag.position = Vector3(29.0, 1.8, -36.7)
	wb_mag.rotation_degrees = Vector3(0, 0, 0)
	lab_root.add_child(wb_mag)
	wb_mag.owner = root
	
	# Lab Lighting
	_create_omni_light(lab_root, root, "LabLight1", Vector3(25, 5.2, -28), Color(0.8, 0.95, 1.0), 0.95, 15.0)
	_create_omni_light(lab_root, root, "LabLight2", Vector3(35, 5.2, -28), Color(0.8, 0.95, 1.0), 0.95, 15.0)
	
	# =========================================================================
	# ZOMBIE SPAWN POINTS (Group: "zombie_spawns")
	# =========================================================================
	var spawn_positions = [
		Vector3(-11.0, 0, -1.0), # Outside West Window
		Vector3(11.0, 0, 0.0),   # Outside East Window
		Vector3(-14.0, 0, -28.0),# Atrium West Alcove
		Vector3(14.0, 0, -28.0), # Atrium East Alcove
		Vector3(0.0, 0, -42.0),  # Atrium North Back
		Vector3(38.0, 0, -28.0)  # Lab Containment Pods
	]
	for i in range(spawn_positions.size()):
		var sp = Marker3D.new()
		sp.name = "ZombieSpawn_%d" % (i + 1)
		sp.add_to_group("zombie_spawns")
		sp.position = spawn_positions[i]
		root.add_child(sp)
		sp.owner = root

	# Pack and Save
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_res = ResourceSaver.save(packed, "res://levels/zombie_outbreak/Sector7_Quarantine.tscn")
		print("SUCCESS: Sector7_Quarantine.tscn saved successfully! OK = ", save_res == OK)
	else:
		printerr("FAILED to pack Sector7_Quarantine.tscn, code: ", pack_res)
		
	quit()

func _create_static_box(parent: Node, root_node: Node, box_name: String, size: Vector3, pos: Vector3, mat: Material) -> StaticBody3D:
	var sb = StaticBody3D.new()
	sb.name = box_name
	sb.position = pos
	sb.collision_layer = 1
	sb.collision_mask = 0
	parent.add_child(sb)
	sb.owner = root_node
	
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	col.shape = box_shape
	sb.add_child(col)
	col.owner = root_node
	
	var mi = MeshInstance3D.new()
	mi.name = "MeshInstance3D"
	var b_mesh = BoxMesh.new()
	b_mesh.size = size
	mi.mesh = b_mesh
	if mat:
		mi.material_override = mat
	sb.add_child(mi)
	mi.owner = root_node
	
	return sb

func _create_omni_light(parent: Node, root_node: Node, light_name: String, pos: Vector3, color: Color, energy: float, range_dist: float) -> OmniLight3D:
	var ol = OmniLight3D.new()
	ol.name = light_name
	ol.position = pos
	ol.light_color = color
	ol.light_energy = energy
	ol.omni_range = range_dist
	parent.add_child(ol)
	ol.owner = root_node
	return ol
