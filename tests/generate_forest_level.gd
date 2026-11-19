extends SceneTree

func _init() -> void:
	print("--- GENERATING BLACKWOOD PINES DEEP FOREST SURVIVAL MAP ---")
	
	var root = Node3D.new()
	root.name = "BlackwoodPines"
	
	# Shaders & Materials
	var wind_shader = load("res://assets/shaders/foliage_wind.gdshader")
	var bark_shader = load("res://assets/shaders/bark_pbr.gdshader")
	var floor_shader = load("res://assets/shaders/forest_floor.gdshader")
	
	var mat_floor = ShaderMaterial.new()
	mat_floor.shader = floor_shader
	
	var mat_bark = ShaderMaterial.new()
	mat_bark.shader = bark_shader
	
	var mat_foliage = ShaderMaterial.new()
	mat_foliage.shader = wind_shader
	
	var mat_rock = StandardMaterial3D.new()
	mat_rock.albedo_color = Color(0.22, 0.24, 0.26)
	mat_rock.roughness = 0.85
	
	var mat_timber = StandardMaterial3D.new()
	mat_timber.albedo_color = Color(0.25, 0.16, 0.10)
	mat_timber.roughness = 0.82
	
	var mat_roof = StandardMaterial3D.new()
	mat_roof.albedo_color = Color(0.18, 0.18, 0.20)
	mat_roof.metallic = 0.7
	mat_roof.roughness = 0.4
	
	var mat_sandbag = StandardMaterial3D.new()
	mat_sandbag.albedo_color = Color(0.48, 0.42, 0.32)
	mat_sandbag.roughness = 0.95
	
	# 1. WorldEnvironment (Atmospheric Deep Forest Fog)
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.05, 0.08) # Midnight forest sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.18, 0.22, 0.28)
	env.ambient_light_energy = 0.62 # Calibrated horror lighting (not pitch black, not washed out)
	
	# Distance mist & volumetric fog
	env.fog_enabled = true
	env.fog_light_color = Color(0.14, 0.18, 0.26)
	env.fog_density = 0.018
	env.fog_aerial_perspective = 0.55
	
	env.glow_enabled = true
	env.glow_bloom = 0.2
	env.glow_intensity = 0.9
	we.environment = env
	root.add_child(we)
	we.owner = root
	
	# 2. Cold Directional Moonlight
	var moon = DirectionalLight3D.new()
	moon.name = "DirectionalMoonlight"
	moon.light_color = Color(0.55, 0.68, 0.90)
	moon.light_energy = 0.65
	moon.shadow_enabled = true
	moon.rotation_degrees = Vector3(-55, 38, 0)
	root.add_child(moon)
	moon.owner = root
	
	# 3. Horde Wave Director
	var director_script = load("res://core/BlackwoodHordeDirector.gd")
	var director = Node3D.new()
	director.name = "BlackwoodHordeDirector"
	director.set_script(director_script)
	root.add_child(director)
	director.owner = root
	
	# 4. Player Instance (Spawned at Ranger Cabin Porch)
	var player_scene = load("res://entities/player/Player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	player.position = Vector3(0, 0.2, 5.0)
	root.add_child(player)
	player.owner = root
	
	# 5. HUD Instance
	var hud_scene = load("res://ui/HUD.tscn")
	var hud = hud_scene.instantiate()
	hud.name = "HUD"
	root.add_child(hud)
	hud.owner = root
	
	# 6. Terrain Ground Mesh & Collision (120m x 120m)
	var ground_sb = StaticBody3D.new()
	ground_sb.name = "ForestTerrain"
	ground_sb.collision_layer = 1
	ground_sb.collision_mask = 0
	root.add_child(ground_sb)
	ground_sb.owner = root
	
	var ground_col = CollisionShape3D.new()
	ground_col.name = "TerrainCollision"
	var ground_box = BoxShape3D.new()
	ground_box.size = Vector3(120.0, 1.0, 120.0)
	ground_col.shape = ground_box
	ground_col.position = Vector3(0, -0.5, 0)
	ground_sb.add_child(ground_col)
	ground_col.owner = root
	
	var ground_mesh = MeshInstance3D.new()
	ground_mesh.name = "TerrainMesh"
	var pmesh = PlaneMesh.new()
	pmesh.size = Vector2(120.0, 120.0)
	pmesh.subdivide_width = 32
	pmesh.subdivide_depth = 32
	ground_mesh.mesh = pmesh
	ground_mesh.material_override = mat_floor
	ground_sb.add_child(ground_mesh)
	ground_mesh.owner = root
	
	# Invisible World Boundaries (keep player & zombies inside forest play area)
	var bounds = [
		{"pos": Vector3(0, 5, 58), "size": Vector3(120, 12, 1)},
		{"pos": Vector3(0, 5, -58), "size": Vector3(120, 12, 1)},
		{"pos": Vector3(58, 5, 0), "size": Vector3(1, 12, 120)},
		{"pos": Vector3(-58, 5, 0), "size": Vector3(1, 12, 120)}
	]
	for i in range(bounds.size()):
		var b_sb = StaticBody3D.new()
		b_sb.name = "BoundaryWall_%d" % i
		b_sb.position = bounds[i]["pos"]
		b_sb.collision_layer = 1
		b_sb.collision_mask = 0
		root.add_child(b_sb)
		b_sb.owner = root
		
		var b_col = CollisionShape3D.new()
		var b_box = BoxShape3D.new()
		b_box.size = bounds[i]["size"]
		b_col.shape = b_box
		b_sb.add_child(b_col)
		b_col.owner = root
		
	# =========================================================================
	# 7. MULTIMESH FOREST ENGINE (1,200 Pines, 350 Snags, 800 Ferns, 220 Rocks)
	# =========================================================================
	var foliage_root = Node3D.new()
	foliage_root.name = "FoliageRoot"
	root.add_child(foliage_root)
	foliage_root.owner = root
	
	_build_pine_multimesh(foliage_root, root, mat_bark, mat_foliage)
	_build_snag_multimesh(foliage_root, root, mat_bark)
	_build_fern_multimesh(foliage_root, root, mat_foliage)
	_build_boulder_multimesh(foliage_root, root, mat_rock)
	
	# =========================================================================
	# 8. BLACKWOOD RANGER LODGE (SAFEHOUSE AT (0, 0, 0))
	# =========================================================================
	var lodge_root = Node3D.new()
	lodge_root.name = "BlackwoodLodge"
	root.add_child(lodge_root)
	lodge_root.owner = root
	
	# Lodge Floor & Porch (16m x 12m)
	_create_static_box(lodge_root, root, "LodgeFloor", Vector3(16.0, 0.4, 12.0), Vector3(0, 0.1, 0), mat_timber)
	_create_static_box(lodge_root, root, "LodgeCeiling", Vector3(16.0, 0.4, 12.0), Vector3(0, 4.8, 0), mat_roof)
	
	# South Wall (Front with Doorway and Porch Pillars)
	_create_static_box(lodge_root, root, "LodgeSouthWall_L", Vector3(6.5, 4.8, 0.5), Vector3(-4.75, 2.4, 6.0), mat_timber)
	_create_static_box(lodge_root, root, "LodgeSouthWall_R", Vector3(6.5, 4.8, 0.5), Vector3(4.75, 2.4, 6.0), mat_timber)
	_create_static_box(lodge_root, root, "LodgeSouthWall_Top", Vector3(3.0, 1.8, 0.5), Vector3(0.0, 3.9, 6.0), mat_timber)
	
	# Porch Pillars
	_create_static_box(lodge_root, root, "Pillar_1", Vector3(0.35, 4.8, 0.35), Vector3(-7.5, 2.4, 7.8), mat_timber)
	_create_static_box(lodge_root, root, "Pillar_2", Vector3(0.35, 4.8, 0.35), Vector3(7.5, 2.4, 7.8), mat_timber)
	_create_static_box(lodge_root, root, "PorchRoof", Vector3(16.5, 0.3, 2.2), Vector3(0, 4.8, 6.9), mat_roof)
	
	# North Wall (Back) with AK-47 wall buy
	_create_static_box(lodge_root, root, "LodgeNorthWall", Vector3(16.0, 4.8, 0.5), Vector3(0, 2.4, -6.0), mat_timber)
	
	# West Wall (with Barricade Window and Shotgun buy)
	_create_static_box(lodge_root, root, "LodgeWestWall_S", Vector3(0.5, 4.8, 4.5), Vector3(-8.0, 2.4, 3.75), mat_timber)
	_create_static_box(lodge_root, root, "LodgeWestWall_N", Vector3(0.5, 4.8, 4.5), Vector3(-8.0, 2.4, -3.75), mat_timber)
	_create_static_box(lodge_root, root, "LodgeWestWall_Top", Vector3(0.5, 2.2, 3.0), Vector3(-8.0, 3.7, 0.0), mat_timber)
	
	# East Wall (with Barricade Window)
	_create_static_box(lodge_root, root, "LodgeEastWall_S", Vector3(0.5, 4.8, 4.5), Vector3(8.0, 2.4, 3.75), mat_timber)
	_create_static_box(lodge_root, root, "LodgeEastWall_N", Vector3(0.5, 4.8, 4.5), Vector3(8.0, 2.4, -3.75), mat_timber)
	_create_static_box(lodge_root, root, "LodgeEastWall_Top", Vector3(0.5, 2.2, 3.0), Vector3(8.0, 3.7, 0.0), mat_timber)
	
	# Barricade Windows
	var barricade_scene = load("res://interactables/BarricadeWindow.tscn")
	var w_west = barricade_scene.instantiate()
	w_west.name = "Barricade_West"
	w_west.window_id = "lodge_west"
	w_west.position = Vector3(-8.0, 0.2, 0.0)
	w_west.rotation_degrees = Vector3(0, 90, 0)
	lodge_root.add_child(w_west)
	w_west.owner = root
	
	var w_east = barricade_scene.instantiate()
	w_east.name = "Barricade_East"
	w_east.window_id = "lodge_east"
	w_east.position = Vector3(8.0, 0.2, 0.0)
	w_east.rotation_degrees = Vector3(0, -90, 0)
	lodge_root.add_child(w_east)
	w_east.owner = root
	
	# Interior Lighting: Warm swinging kerosene lantern
	var lantern = OmniLight3D.new()
	lantern.name = "LodgeLantern"
	lantern.position = Vector3(0, 3.8, 0)
	lantern.light_color = Color(1.0, 0.82, 0.48)
	lantern.light_energy = 1.3
	lantern.omni_range = 14.0
	lantern.shadow_enabled = true
	lodge_root.add_child(lantern)
	lantern.owner = root
	
	# Wall-Buys in Lodge
	var wallbuy_scene = load("res://interactables/WallBuyStation.tscn")
	var wb_rem = wallbuy_scene.instantiate()
	wb_rem.name = "WallBuy_Remington870"
	wb_rem.weapon_resource_path = "res://weapons/shotgun/Remington870.tres"
	wb_rem.weapon_display_name = "Remington 870"
	wb_rem.weapon_cost = 500
	wb_rem.ammo_cost = 250
	wb_rem.position = Vector3(-7.7, 1.8, 3.2)
	wb_rem.rotation_degrees = Vector3(0, 90, 0)
	lodge_root.add_child(wb_rem)
	wb_rem.owner = root
	
	var wb_m1911 = wallbuy_scene.instantiate()
	wb_m1911.name = "WallBuy_M1911Ammo"
	wb_m1911.weapon_resource_path = "res://weapons/pistol/M1911.tres"
	wb_m1911.weapon_display_name = "M1911 Ammo"
	wb_m1911.weapon_cost = 250
	wb_m1911.ammo_cost = 250
	wb_m1911.position = Vector3(4.5, 1.8, 5.7)
	wb_m1911.rotation_degrees = Vector3(0, 180, 0)
	lodge_root.add_child(wb_m1911)
	wb_m1911.owner = root
	
	var wb_ak = wallbuy_scene.instantiate()
	wb_ak.name = "WallBuy_AK47"
	wb_ak.weapon_resource_path = "res://weapons/rifle/AK47.tres"
	wb_ak.weapon_display_name = "AK-47"
	wb_ak.weapon_cost = 1200
	wb_ak.ammo_cost = 600
	wb_ak.position = Vector3(0, 1.8, -5.7)
	wb_ak.rotation_degrees = Vector3(0, 0, 0)
	lodge_root.add_child(wb_ak)
	wb_ak.owner = root
	
	# =========================================================================
	# 9. MILITARY QUARANTINE CAMP (CLEARING AT (0, 0, -28))
	# =========================================================================
	var camp_root = Node3D.new()
	camp_root.name = "MilitaryCamp"
	root.add_child(camp_root)
	camp_root.owner = root
	
	# Sandbag fortifications
	_create_static_box(camp_root, root, "Sandbags_West", Vector3(1.2, 1.1, 10.0), Vector3(-8.0, 0.55, -28.0), mat_sandbag)
	_create_static_box(camp_root, root, "Sandbags_East", Vector3(1.2, 1.1, 10.0), Vector3(8.0, 0.55, -28.0), mat_sandbag)
	_create_static_box(camp_root, root, "Sandbags_North", Vector3(16.0, 1.1, 1.2), Vector3(0, 0.55, -34.0), mat_sandbag)
	
	# Utility Generator Pole & Floodlight
	_create_static_box(camp_root, root, "GeneratorPole", Vector3(0.35, 6.5, 0.35), Vector3(0, 3.25, -28.0), mat_timber)
	var floodlight = OmniLight3D.new()
	floodlight.name = "CampFloodlight"
	floodlight.position = Vector3(0, 6.2, -28.0)
	floodlight.light_color = Color(0.85, 0.92, 1.0)
	floodlight.light_energy = 1.4
	floodlight.omni_range = 22.0
	floodlight.shadow_enabled = true
	camp_root.add_child(floodlight)
	floodlight.owner = root
	
	# Mystery Box on wooden pallets
	var mysterybox_scene = load("res://interactables/MysteryBox.tscn")
	var box = mysterybox_scene.instantiate()
	box.name = "MysteryBox"
	box.position = Vector3(0, 0.0, -26.0)
	box.rotation_degrees = Vector3(0, 180, 0)
	camp_root.add_child(box)
	box.owner = root
	
	# Wall-Buys in Camp: M4A1 Carbine & Colt Python .357
	var wb_m4 = wallbuy_scene.instantiate()
	wb_m4.name = "WallBuy_M4A1"
	wb_m4.weapon_resource_path = "res://weapons/carbine/M4A1.tres"
	wb_m4.weapon_display_name = "M4A1 Carbine"
	wb_m4.weapon_cost = 1500
	wb_m4.ammo_cost = 750
	wb_m4.position = Vector3(-7.4, 1.6, -28.0)
	wb_m4.rotation_degrees = Vector3(0, 90, 0)
	camp_root.add_child(wb_m4)
	wb_m4.owner = root
	
	var wb_python = wallbuy_scene.instantiate()
	wb_python.name = "WallBuy_Python357"
	wb_python.weapon_resource_path = "res://weapons/magnum/Python357.tres"
	wb_python.weapon_display_name = "Colt Python .357"
	wb_python.weapon_cost = 2000
	wb_python.ammo_cost = 1000
	wb_python.position = Vector3(7.4, 1.6, -28.0)
	wb_python.rotation_degrees = Vector3(0, -90, 0)
	camp_root.add_child(wb_python)
	wb_python.owner = root
	
	# Perks in Camp: Juggernog & Speed Cola
	var perk_scene = load("res://interactables/PerkMachine.tscn")
	var perk_jug = perk_scene.instantiate()
	perk_jug.name = "Perk_Juggernog"
	perk_jug.perk_type = 0 # Juggernog
	perk_jug.position = Vector3(-5.5, 0.0, -33.2)
	perk_jug.rotation_degrees = Vector3(0, 0, 0)
	camp_root.add_child(perk_jug)
	perk_jug.owner = root
	
	var perk_speed = perk_scene.instantiate()
	perk_speed.name = "Perk_SpeedCola"
	perk_speed.perk_type = 1 # Speed Cola
	perk_speed.position = Vector3(5.5, 0.0, -33.2)
	perk_speed.rotation_degrees = Vector3(0, 0, 0)
	camp_root.add_child(perk_speed)
	perk_speed.owner = root
	
	# Explosive Barrels in perimeter choke points
	var barrel_scene = load("res://interactables/ExplosiveBarrel.tscn")
	var barrel_locs = [
		Vector3(-6.5, 0, -18.0),
		Vector3(6.5, 0, -18.0),
		Vector3(-10.0, 0, -32.0),
		Vector3(10.0, 0, -32.0),
		Vector3(0, 0, 10.0) # South trail
	]
	for i in range(barrel_locs.size()):
		var b = barrel_scene.instantiate()
		b.name = "ExplosiveBarrel_%d" % (i + 1)
		b.position = barrel_locs[i]
		camp_root.add_child(b)
		b.owner = root
		
	# Pack and Save Scene
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_res = ResourceSaver.save(packed, "res://levels/zombie_outbreak/Blackwood_Pines.tscn")
		print("SUCCESS: Blackwood_Pines.tscn saved! OK = ", save_res == OK)
	else:
		printerr("FAILED to pack Blackwood_Pines.tscn: ", pack_res)
		
	quit()

# MultiMesh Builders
func _build_pine_multimesh(parent: Node, root_node: Node, mat_trunk: Material, mat_needles: Material) -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "PineTreesMultiMesh"
	parent.add_child(mmi)
	mmi.owner = root_node
	
	# Build composite Pine Tree Mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_trunk)
	# Trunk: 8-sided tapered cylinder (height 16m)
	var sides = 8
	var h = 16.0
	var r_bot = 0.45
	var r_top = 0.12
	for i in range(sides):
		var a1 = (float(i) / sides) * TAU
		var a2 = (float(i + 1) / sides) * TAU
		var p1 = Vector3(cos(a1) * r_bot, 0.0, sin(a1) * r_bot)
		var p2 = Vector3(cos(a2) * r_bot, 0.0, sin(a2) * r_bot)
		var p3 = Vector3(cos(a2) * r_top, h, sin(a2) * r_top)
		var p4 = Vector3(cos(a1) * r_top, h, sin(a1) * r_top)
		
		var norm = Vector3(cos((a1 + a2) * 0.5), 0.05, sin((a1 + a2) * 0.5)).normalized()
		st.set_normal(norm)
		st.set_uv(Vector2(float(i) / sides, 0))
		st.add_vertex(p1)
		st.set_uv(Vector2(float(i + 1) / sides, 0))
		st.add_vertex(p2)
		st.set_uv(Vector2(float(i + 1) / sides, 1))
		st.add_vertex(p3)
		
		st.add_vertex(p1)
		st.add_vertex(p3)
		st.set_uv(Vector2(float(i) / sides, 1))
		st.add_vertex(p4)
		
	var trunk_mesh = st.commit()
	
	# Add Needle Canopies as secondary surface
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_needles)
	# 4 tiers of needle cones
	var tiers = [
		{"y_bot": 4.5, "y_top": 8.5, "rad": 3.6},
		{"y_bot": 7.5, "y_top": 11.5, "rad": 2.8},
		{"y_bot": 10.5, "y_top": 14.5, "rad": 2.0},
		{"y_bot": 13.5, "y_top": 17.0, "rad": 1.2}
	]
	for t in tiers:
		for i in range(sides):
			var a1 = (float(i) / sides) * TAU
			var a2 = (float(i + 1) / sides) * TAU
			var p1 = Vector3(cos(a1) * t["rad"], t["y_bot"], sin(a1) * t["rad"])
			var p2 = Vector3(cos(a2) * t["rad"], t["y_bot"], sin(a2) * t["rad"])
			var p_tip = Vector3(0, t["y_top"], 0)
			
			var n = (p1 + p2).normalized() + Vector3(0, 0.4, 0)
			st.set_normal(n.normalized())
			st.set_uv(Vector2(0, 0))
			st.add_vertex(p1)
			st.set_uv(Vector2(1, 0))
			st.add_vertex(p2)
			st.set_uv(Vector2(0.5, 1))
			st.add_vertex(p_tip)
			
	var tree_mesh = st.commit(trunk_mesh)
	
	# MultiMesh setup
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = tree_mesh
	
	var total_trees = 1100
	mm.instance_count = total_trees
	
	var seeded_rng = RandomNumberGenerator.new()
	seeded_rng.seed = 42817
	
	for i in range(total_trees):
		var x = seeded_rng.randf_range(-52.0, 52.0)
		var z = seeded_rng.randf_range(-52.0, 52.0)
		
		# Exclude central lodge clearing (r < 11m) and military camp
		var dist_center = Vector2(x, z).length()
		var in_camp = (abs(x) < 11.0 and z > -36.0 and z < -16.0)
		if dist_center < 11.0 or in_camp:
			x += 16.0 if x > 0 else -16.0
			z += 16.0 if z > 0 else -16.0
			
		var t = Transform3D()
		var s = seeded_rng.randf_range(0.75, 1.35)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, seeded_rng.randf() * TAU)
		t.origin = Vector3(x, 0.0, z)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

func _build_snag_multimesh(parent: Node, root_node: Node, mat: Material) -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "SnagsMultiMesh"
	parent.add_child(mmi)
	mmi.owner = root_node
	
	var bmesh = BoxMesh.new()
	bmesh.size = Vector3(0.5, 4.2, 0.5)
	bmesh.material = mat
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = bmesh
	var count = 350
	mm.instance_count = count
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 98124
	for i in range(count):
		var x = rng.randf_range(-50.0, 50.0)
		var z = rng.randf_range(-50.0, 50.0)
		var t = Transform3D()
		var s = rng.randf_range(0.6, 1.4)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, rng.randf() * TAU)
		t = t.rotated(Vector3.RIGHT, rng.randf_range(-0.15, 0.15))
		t.origin = Vector3(x, 2.0 * s * 0.5, z)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

func _build_fern_multimesh(parent: Node, root_node: Node, mat: Material) -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "FernsMultiMesh"
	parent.add_child(mmi)
	mmi.owner = root_node
	
	# Frond cluster
	var fmesh = BoxMesh.new()
	fmesh.size = Vector3(1.4, 0.6, 1.4)
	fmesh.material = mat
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = fmesh
	var count = 750
	mm.instance_count = count
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 66129
	for i in range(count):
		var x = rng.randf_range(-48.0, 48.0)
		var z = rng.randf_range(-48.0, 48.0)
		var t = Transform3D()
		var s = rng.randf_range(0.7, 1.5)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, rng.randf() * TAU)
		t.origin = Vector3(x, 0.3 * s, z)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

func _build_boulder_multimesh(parent: Node, root_node: Node, mat: Material) -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "BouldersMultiMesh"
	parent.add_child(mmi)
	mmi.owner = root_node
	
	var bmesh = BoxMesh.new()
	bmesh.size = Vector3(1.8, 1.2, 1.6)
	bmesh.material = mat
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = bmesh
	var count = 220
	mm.instance_count = count
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 33814
	for i in range(count):
		var x = rng.randf_range(-48.0, 48.0)
		var z = rng.randf_range(-48.0, 48.0)
		var t = Transform3D()
		var s = rng.randf_range(0.6, 1.8)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, rng.randf() * TAU)
		t = t.rotated(Vector3.RIGHT, rng.randf_range(-0.2, 0.2))
		t.origin = Vector3(x, 0.5 * s, z)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

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
