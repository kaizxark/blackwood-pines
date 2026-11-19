extends SceneTree

# PROJECT PROTO-BREACH - Next-Gen Lush Forest Map Generator
# Generates "Blackwood Wilderness" - a breathtaking, high-fidelity real-world green forest
# with undulating terrain topography, multi-species flora (Pines, Oaks, Birches, Shrubs, Ferns, Grass, Logs, Boulders),
# cinematic sun god-rays, dynamic lighting, and integrated wilderness survival points (NO STARTING ROOM).

func _init() -> void:
	print("\n========================================================")
	print("  GENERATING NEXT-GEN LUSH GREEN FOREST MAP (BLACKWOOD) ")
	print("========================================================\n")
	
	var root = Node3D.new()
	root.name = "BlackwoodForest"
	
	# Shaders & Materials
	var terrain_shader = load("res://assets/shaders/terrain_forest_lush.gdshader")
	var foliage_shader = load("res://assets/shaders/foliage_lush.gdshader")
	var bark_shader = load("res://assets/shaders/bark_realistic.gdshader")
	var rock_shader = load("res://assets/shaders/mossy_rock.gdshader")
	var godray_shader = load("res://assets/shaders/god_rays.gdshader")
	
	var mat_terrain = ShaderMaterial.new()
	mat_terrain.shader = terrain_shader
	
	# Foliage Materials with rich subsurface scattering
	var mat_pine_foliage = ShaderMaterial.new()
	mat_pine_foliage.shader = foliage_shader
	mat_pine_foliage.set_shader_parameter("leaf_top_color", Color(0.09, 0.24, 0.07))
	mat_pine_foliage.set_shader_parameter("leaf_bottom_color", Color(0.16, 0.38, 0.11))
	mat_pine_foliage.set_shader_parameter("transmission_color", Color(0.32, 0.58, 0.16))
	mat_pine_foliage.set_shader_parameter("transmission_strength", 0.9)
	
	var mat_deciduous_foliage = ShaderMaterial.new()
	mat_deciduous_foliage.shader = foliage_shader
	mat_deciduous_foliage.set_shader_parameter("leaf_top_color", Color(0.14, 0.38, 0.09))
	mat_deciduous_foliage.set_shader_parameter("leaf_bottom_color", Color(0.24, 0.52, 0.15))
	mat_deciduous_foliage.set_shader_parameter("transmission_color", Color(0.42, 0.72, 0.20))
	mat_deciduous_foliage.set_shader_parameter("transmission_strength", 1.1)
	mat_deciduous_foliage.set_shader_parameter("roughness", 0.6)
	
	var mat_birch_foliage = ShaderMaterial.new()
	mat_birch_foliage.shader = foliage_shader
	mat_birch_foliage.set_shader_parameter("leaf_top_color", Color(0.22, 0.45, 0.12))
	mat_birch_foliage.set_shader_parameter("leaf_bottom_color", Color(0.32, 0.58, 0.18))
	mat_birch_foliage.set_shader_parameter("transmission_color", Color(0.52, 0.78, 0.25))
	mat_birch_foliage.set_shader_parameter("transmission_strength", 1.25)
	
	var mat_fern_foliage = ShaderMaterial.new()
	mat_fern_foliage.shader = foliage_shader
	mat_fern_foliage.set_shader_parameter("leaf_top_color", Color(0.15, 0.42, 0.10))
	mat_fern_foliage.set_shader_parameter("leaf_bottom_color", Color(0.26, 0.56, 0.16))
	mat_fern_foliage.set_shader_parameter("transmission_color", Color(0.45, 0.75, 0.22))
	mat_fern_foliage.set_shader_parameter("transmission_strength", 1.2)
	mat_fern_foliage.set_shader_parameter("wind_strength", 0.22)
	
	var mat_grass = ShaderMaterial.new()
	mat_grass.shader = foliage_shader
	mat_grass.set_shader_parameter("leaf_top_color", Color(0.18, 0.38, 0.11))
	mat_grass.set_shader_parameter("leaf_bottom_color", Color(0.28, 0.50, 0.16))
	mat_grass.set_shader_parameter("transmission_color", Color(0.48, 0.72, 0.22))
	mat_grass.set_shader_parameter("wind_strength", 0.28)
	
	# Bark Materials
	var mat_pine_bark = ShaderMaterial.new()
	mat_pine_bark.shader = bark_shader
	mat_pine_bark.set_shader_parameter("bark_color", Color(0.22, 0.14, 0.08))
	mat_pine_bark.set_shader_parameter("bark_crevice_color", Color(0.10, 0.06, 0.03))
	mat_pine_bark.set_shader_parameter("is_birch", false)
	
	var mat_birch_bark = ShaderMaterial.new()
	mat_birch_bark.shader = bark_shader
	mat_birch_bark.set_shader_parameter("is_birch", true)
	mat_birch_bark.set_shader_parameter("moss_amount", 0.3)
	
	var mat_rock = ShaderMaterial.new()
	mat_rock.shader = rock_shader
	
	var mat_godray = ShaderMaterial.new()
	mat_godray.shader = godray_shader
	
	# -------------------------------------------------------------------------
	# 1. WorldEnvironment (Lush Morning Atmosphere & Sun Mist)
	# -------------------------------------------------------------------------
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.35, 0.52, 0.82) # Rich clear morning blue
	sky_mat.sky_horizon_color = Color(0.68, 0.78, 0.85)
	sky_mat.ground_bottom_color = Color(0.12, 0.18, 0.10) # Dark forest bounce
	sky_mat.ground_horizon_color = Color(0.42, 0.52, 0.38) # Mossy green horizon
	sky_mat.sun_angle_max = 35.0
	sky.sky_material = sky_mat
	env.sky = sky
	
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.55, 0.65, 0.75)
	env.ambient_light_sky_contribution = 0.65
	env.ambient_light_energy = 0.95
	
	# Atmospheric depth fog (sun-infused morning forest mist)
	env.fog_enabled = true
	env.fog_light_color = Color(0.58, 0.70, 0.64) # Soft morning green-gold mist
	env.fog_density = 0.012
	env.fog_aerial_perspective = 0.45
	env.fog_sky_affect = 0.35
	
	# Bloom & Glow
	env.glow_enabled = true
	env.glow_bloom = 0.18
	env.glow_intensity = 0.85
	
	# Tonemap for rich cinematic contrast & lush green saturation
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.05
	
	we.environment = env
	root.add_child(we)
	we.owner = root
	
	# -------------------------------------------------------------------------
	# 2. Golden Morning Directional Sunlight
	# -------------------------------------------------------------------------
	var sun = DirectionalLight3D.new()
	sun.name = "DirectionalSun"
	sun.light_color = Color(1.0, 0.94, 0.82) # Warm morning sun
	sun.light_energy = 2.4
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun.shadow_blur = 1.5
	sun.rotation_degrees = Vector3(-40, 38, 0)
	root.add_child(sun)
	sun.owner = root
	
	# -------------------------------------------------------------------------
	# 3. Horde Wave Director
	# -------------------------------------------------------------------------
	var director_script = load("res://core/BlackwoodHordeDirector.gd")
	var director = Node3D.new()
	director.name = "BlackwoodHordeDirector"
	director.set_script(director_script)
	root.add_child(director)
	director.owner = root
	
	# -------------------------------------------------------------------------
	# 4. Undulating Terrain Generation (180m x 180m ArrayMesh + Trimesh Collision)
	# -------------------------------------------------------------------------
	var terrain_sb = StaticBody3D.new()
	terrain_sb.name = "ForestTerrain"
	terrain_sb.collision_layer = 1
	terrain_sb.collision_mask = 0
	root.add_child(terrain_sb)
	terrain_sb.owner = root
	
	var terrain_mesh_instance = MeshInstance3D.new()
	terrain_mesh_instance.name = "TerrainMeshInstance"
	terrain_mesh_instance.material_override = mat_terrain
	
	var terrain_mesh = _generate_terrain_mesh(180.0, 120)
	terrain_mesh_instance.mesh = terrain_mesh
	terrain_sb.add_child(terrain_mesh_instance)
	terrain_mesh_instance.owner = root
	
	# Physics Collision Shape
	var terrain_col = CollisionShape3D.new()
	terrain_col.name = "TerrainCollision"
	terrain_col.shape = terrain_mesh.create_trimesh_shape()
	terrain_sb.add_child(terrain_col)
	terrain_col.owner = root
	
	# Invisible World Boundaries (keep player & zombies inside play area)
	_build_world_boundaries(root, 180.0)
	
	# -------------------------------------------------------------------------
	# 5. Player Instance (Spawned directly on the scenic forest trail)
	# -------------------------------------------------------------------------
	var player_scene = load("res://entities/player/Player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	var spawn_x = 0.0
	var spawn_z = 14.0
	var spawn_y = _get_terrain_height(spawn_x, spawn_z) + 0.3
	player.position = Vector3(spawn_x, spawn_y, spawn_z)
	player.rotation_degrees = Vector3(0, 180, 0) # Facing North down the trail
	root.add_child(player)
	player.owner = root
	
	# -------------------------------------------------------------------------
	# 6. HUD Instance
	# -------------------------------------------------------------------------
	var hud_scene = load("res://ui/HUD.tscn")
	var hud = hud_scene.instantiate()
	hud.name = "HUD"
	root.add_child(hud)
	hud.owner = root
	
	# -------------------------------------------------------------------------
	# 7. Ambient Forest Particulates (Floating pollen & falling leaves)
	# -------------------------------------------------------------------------
	var ambient_particles = _create_ambient_forest_particles()
	ambient_particles.name = "AmbientForestParticles"
	ambient_particles.position = Vector3(0, 6.0, 0)
	root.add_child(ambient_particles)
	ambient_particles.owner = root
	
	# -------------------------------------------------------------------------
	# 8. MULTIMESH FOREST ENGINE (7,000+ Foliage & Natural Objects)
	# -------------------------------------------------------------------------
	var foliage_root = Node3D.new()
	foliage_root.name = "FoliageRoot"
	root.add_child(foliage_root)
	foliage_root.owner = root
	
	_populate_tall_pines(foliage_root, root, mat_pine_bark, mat_pine_foliage)
	_populate_broadleaf_oaks(foliage_root, root, mat_pine_bark, mat_deciduous_foliage)
	_populate_white_birches(foliage_root, root, mat_birch_bark, mat_birch_foliage)
	_populate_understory_shrubs(foliage_root, root, mat_deciduous_foliage)
	_populate_lush_ferns(foliage_root, root, mat_fern_foliage)
	_populate_wild_grass(foliage_root, root, mat_grass)
	_populate_fallen_logs(foliage_root, root, mat_pine_bark)
	_populate_granite_boulders(foliage_root, root, mat_rock)
	
	# -------------------------------------------------------------------------
	# 9. CINEMATIC VOLUMETRIC GOD-RAYS (Sunlight slicing through canopies)
	# -------------------------------------------------------------------------
	_build_cinematic_god_rays(foliage_root, root, mat_godray)
	
	# -------------------------------------------------------------------------
	# 10. WILDERNESS SURVIVAL STATIONS (NO ROOM - INTEGRATED INTO WILD NATURE)
	# -------------------------------------------------------------------------
	_build_wilderness_survival_points(root)
	
	# -------------------------------------------------------------------------
	# 11. Pack and Save Scene
	# -------------------------------------------------------------------------
	var packed = PackedScene.new()
	var pack_err = packed.pack(root)
	if pack_err != OK:
		printerr("ERROR: Failed to pack Blackwood_Pines scene! Error code: ", pack_err)
		quit(1)
		return
		
	var save_path = "res://levels/zombie_outbreak/Blackwood_Pines.tscn"
	var save_err = ResourceSaver.save(packed, save_path)
	if save_err != OK:
		printerr("ERROR: Failed to save to ", save_path, "! Error: ", save_err)
		quit(1)
		return
		
	print("[SUCCESS] Next-Gen Lush Green Forest Map generated and saved to ", save_path)
	quit(0)

# =============================================================================
# TERRAIN HEIGHT FUNCTION & MESH GENERATION
# =============================================================================

static func _get_terrain_height(x: float, z: float) -> float:
	# 1. Base rolling hills
	var h1 = sin(x * 0.038) * cos(z * 0.034) * 3.4
	var h2 = sin(x * 0.075 + 1.2) * sin(z * 0.068 - 0.7) * 1.6
	var h3 = cos(x * 0.14 - z * 0.12) * 0.5
	
	# 2. Cradling boundary ridges (+7.5m at perimeter)
	var edge_dist = max(abs(x), abs(z))
	var ridge_t = clamp((edge_dist - 55.0) / 30.0, 0.0, 1.0)
	var ridge_h = ridge_t * ridge_t * 7.5
	
	# 3. Winding forest trail (depressed gently by 0.35m to form packed path)
	var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
	var dist_path = abs(x - path_x)
	var path_dip = (1.0 - clamp(dist_path / 3.8, 0.0, 1.0)) * 0.35
	
	# 4. Sunlit forest clearings (player spawn at z=14 and mystery box at z=-18)
	var clearing_1 = 1.0 - clamp(Vector2(x, z - 14.0).length() / 16.0, 0.0, 1.0)
	var clearing_2 = 1.0 - clamp(Vector2(x + 14.0, z + 18.0).length() / 20.0, 0.0, 1.0)
	var flatten = max(clearing_1, clearing_2) * 0.65
	
	return (h1 + h2 + h3) * (1.0 - flatten) + ridge_h - path_dip

func _generate_terrain_mesh(size: float, resolution: int) -> ArrayMesh:
	var verts = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	var step = size / float(resolution)
	var half_size = size * 0.5
	var vertex_count_per_row = resolution + 1
	
	# Generate Grid Vertices
	for gz in range(vertex_count_per_row):
		var z = -half_size + float(gz) * step
		for gx in range(vertex_count_per_row):
			var x = -half_size + float(gx) * step
			var y = _get_terrain_height(x, z)
			verts.append(Vector3(x, y, z))
			uvs.append(Vector2(float(gx) / float(resolution), float(gz) / float(resolution)))
			
			# Numerical gradient for smooth normals
			var eps = 0.5
			var dhdx = (_get_terrain_height(x + eps, z) - _get_terrain_height(x - eps, z)) / (2.0 * eps)
			var dhdz = (_get_terrain_height(x, z + eps) - _get_terrain_height(x, z - eps)) / (2.0 * eps)
			var norm = Vector3(-dhdx, 1.0, -dhdz).normalized()
			normals.append(norm)
			
	# Generate Triangle Indices
	for gz in range(resolution):
		for gx in range(resolution):
			var i0 = gz * vertex_count_per_row + gx
			var i1 = i0 + 1
			var i2 = (gz + 1) * vertex_count_per_row + gx
			var i3 = i2 + 1
			
			# Triangle 1
			indices.append(i0)
			indices.append(i2)
			indices.append(i1)
			
			# Triangle 2
			indices.append(i1)
			indices.append(i2)
			indices.append(i3)
			
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func _build_world_boundaries(root: Node3D, size: float) -> void:
	var half = size * 0.5 - 2.0
	var bounds = [
		{"pos": Vector3(0, 10, half), "size": Vector3(size, 25, 2)},
		{"pos": Vector3(0, 10, -half), "size": Vector3(size, 25, 2)},
		{"pos": Vector3(half, 10, 0), "size": Vector3(2, 25, size)},
		{"pos": Vector3(-half, 10, 0), "size": Vector3(2, 25, size)}
	]
	for i in range(bounds.size()):
		var sb = StaticBody3D.new()
		sb.name = "Boundary_%d" % i
		sb.position = bounds[i]["pos"]
		sb.collision_layer = 1
		sb.collision_mask = 0
		root.add_child(sb)
		sb.owner = root
		
		var cs = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = bounds[i]["size"]
		cs.shape = box
		sb.add_child(cs)
		cs.owner = root

# =============================================================================
# MULTIMESH VEGETATION BUILDERS
# =============================================================================

# 1. Giant Emerald Pines (1,100 trees, 18m - 26m)
func _populate_tall_pines(parent: Node3D, root: Node3D, mat_bark: Material, mat_foliage: Material) -> void:
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.top_radius = 0.28
	trunk_mesh.bottom_radius = 0.95
	trunk_mesh.height = 18.0
	trunk_mesh.radial_segments = 8
	trunk_mesh.material = mat_bark
	
	var canopy_mesh = CylinderMesh.new()
	canopy_mesh.top_radius = 0.05
	canopy_mesh.bottom_radius = 4.2
	canopy_mesh.height = 14.0
	canopy_mesh.radial_segments = 8
	canopy_mesh.material = mat_foliage
	
	# Combined Pine Mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_bark)
	# Build trunk
	var t_trans = Transform3D(Basis(), Vector3(0, 9.0, 0))
	st.append_from(trunk_mesh, 0, t_trans)
	
	# Build 4 drooping canopy tiers
	st.set_material(mat_foliage)
	var tiers = [
		{"y": 10.0, "rad": 4.6, "h": 5.5},
		{"y": 13.5, "rad": 3.8, "h": 5.0},
		{"y": 16.5, "rad": 2.8, "h": 4.5},
		{"y": 19.5, "rad": 1.6, "h": 4.0}
	]
	for tier in tiers:
		var tier_mesh = CylinderMesh.new()
		tier_mesh.top_radius = 0.08
		tier_mesh.bottom_radius = tier["rad"]
		tier_mesh.height = tier["h"]
		tier_mesh.radial_segments = 8
		var c_trans = Transform3D(Basis(), Vector3(0, tier["y"], 0))
		st.append_from(tier_mesh, 0, c_trans)
		
	var combined_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "TallPinesMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = combined_mesh
	
	var count = 1100
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 42819
	
	while placed < count:
		var x = rng.randf_range(-82.0, 82.0)
		var z = rng.randf_range(-82.0, 82.0)
		
		# Avoid trail center
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.8:
			continue
			
		# Avoid player spawn clearing
		if Vector2(x, z - 14.0).length() < 7.0:
			continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.35)
		var yaw = rng.randf_range(0.0, TAU)
		var lean_x = rng.randf_range(-0.06, 0.06)
		var lean_z = rng.randf_range(-0.06, 0.06)
		
		var b = Basis().rotated(Vector3.UP, yaw)
		b = b.rotated(Vector3.RIGHT, lean_x)
		b = b.rotated(Vector3.FORWARD, lean_z)
		b = b.scaled(Vector3(sc, sc, sc))
		
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 2. Lush Hardwood Deciduous Trees (Oaks & Maples, 600 trees, 12m - 16m)
func _populate_broadleaf_oaks(parent: Node3D, root: Node3D, mat_bark: Material, mat_foliage: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_bark)
	
	# Gnarled trunk
	var trunk = CylinderMesh.new()
	trunk.top_radius = 0.55
	trunk.bottom_radius = 1.15
	trunk.height = 7.5
	trunk.radial_segments = 7
	st.append_from(trunk, 0, Transform3D(Basis(), Vector3(0, 3.75, 0)))
	
	# Spreading leafy canopy clumps
	st.set_material(mat_foliage)
	var clumps = [
		{"pos": Vector3(0, 7.5, 0), "r": 3.6},
		{"pos": Vector3(1.8, 6.8, 1.2), "r": 2.8},
		{"pos": Vector3(-1.6, 6.5, -1.0), "r": 2.6},
		{"pos": Vector3(0.5, 9.2, -0.6), "r": 2.7}
	]
	for c in clumps:
		var sph = SphereMesh.new()
		sph.radius = c["r"]
		sph.height = c["r"] * 1.6
		sph.radial_segments = 7
		sph.rings = 5
		st.append_from(sph, 0, Transform3D(Basis(), c["pos"]))
		
	var oak_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "BroadleafOaksMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = oak_mesh
	
	var count = 600
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 83912
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 4.2:
			continue
		if Vector2(x, z - 14.0).length() < 8.0:
			continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.9, 1.3)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 3. White Silver Birches (400 trees, 9m - 14m)
func _populate_white_birches(parent: Node3D, root: Node3D, mat_birch_bark: Material, mat_foliage: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_birch_bark)
	
	# Slender crooked trunk
	var trunk = CylinderMesh.new()
	trunk.top_radius = 0.16
	trunk.bottom_radius = 0.38
	trunk.height = 10.0
	trunk.radial_segments = 6
	var b_t = Basis().rotated(Vector3.RIGHT, 0.08)
	st.append_from(trunk, 0, Transform3D(b_t, Vector3(0, 5.0, 0)))
	
	# Delicate bright green foliage clumps
	st.set_material(mat_foliage)
	var clumps = [
		{"pos": Vector3(0.3, 7.8, 0.4), "r": 2.0},
		{"pos": Vector3(-0.4, 9.6, -0.2), "r": 1.8},
		{"pos": Vector3(0.0, 11.2, 0.2), "r": 1.4}
	]
	for c in clumps:
		var sph = SphereMesh.new()
		sph.radius = c["r"]
		sph.height = c["r"] * 1.8
		sph.radial_segments = 6
		sph.rings = 4
		st.append_from(sph, 0, Transform3D(Basis(), c["pos"]))
		
	var birch_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "WhiteBirchMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = birch_mesh
	
	var count = 400
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 29314
	
	while placed < count:
		var x = rng.randf_range(-75.0, 75.0)
		var z = rng.randf_range(-75.0, 75.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.2:
			continue
		if Vector2(x, z - 14.0).length() < 7.0:
			continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.25)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.1, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 4. Understory Forest Bushes & Rhododendrons (900 bushes, 1.8m - 3.0m)
func _populate_understory_shrubs(parent: Node3D, root: Node3D, mat_foliage: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_foliage)
	
	var c1 = SphereMesh.new()
	c1.radius = 1.3
	c1.height = 1.8
	c1.radial_segments = 6
	c1.rings = 4
	st.append_from(c1, 0, Transform3D(Basis(), Vector3(0, 0.9, 0)))
	
	var c2 = SphereMesh.new()
	c2.radius = 1.0
	c2.height = 1.5
	c2.radial_segments = 6
	c2.rings = 4
	st.append_from(c2, 0, Transform3D(Basis(), Vector3(0.8, 0.7, 0.4)))
	
	var shrub_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "UnderstoryShrubsMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = shrub_mesh
	
	var count = 900
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 66129
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 2.5:
			continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.8, 1.4)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 5. Lush Forest Ferns (1,600 ferns, 0.7m - 1.2m)
func _populate_lush_ferns(parent: Node3D, root: Node3D, mat_fern: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_fern)
	
	# Radial arching fronds
	for frond in range(6):
		var ang = float(frond) * (TAU / 6.0)
		var quad = QuadMesh.new()
		quad.size = Vector2(0.45, 1.3)
		var b = Basis().rotated(Vector3.UP, ang)
		b = b.rotated(b.x, deg_to_rad(45.0))
		st.append_from(quad, 0, Transform3D(b, Vector3(0, 0.45, 0)))
		
	var fern_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "LushFernsMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = fern_mesh
	
	var count = 1600
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 99318
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		# Ferns love shaded margins of the trail (2.0m to 6.0m away)
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		var dist_to_path = abs(x - path_x)
		if dist_to_path < 1.4:
			continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.45)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 6. Wild Forest Grass (2,200 tufts, 0.4m - 0.7m)
func _populate_wild_grass(parent: Node3D, root: Node3D, mat_grass: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_grass)
	
	# Cross-quad grass tuft
	var q1 = QuadMesh.new()
	q1.size = Vector2(0.9, 0.55)
	st.append_from(q1, 0, Transform3D(Basis(), Vector3(0, 0.28, 0)))
	
	var q2 = QuadMesh.new()
	q2.size = Vector2(0.9, 0.55)
	var b2 = Basis().rotated(Vector3.UP, deg_to_rad(60.0))
	st.append_from(q2, 0, Transform3D(b2, Vector3(0, 0.28, 0)))
	
	var q3 = QuadMesh.new()
	q3.size = Vector2(0.9, 0.55)
	var b3 = Basis().rotated(Vector3.UP, deg_to_rad(120.0))
	st.append_from(q3, 0, Transform3D(b3, Vector3(0, 0.28, 0)))
	
	var grass_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "WildGrassMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = grass_mesh
	
	var count = 2200
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 44102
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		var dist_path = abs(x - path_x)
		if dist_path < 1.2:
			continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.8, 1.5)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 7. Mossy Fallen Nurse Logs & Stumps (250 instances)
func _populate_fallen_logs(parent: Node3D, root: Node3D, mat_bark: Material) -> void:
	var log_mesh = CylinderMesh.new()
	log_mesh.top_radius = 0.5
	log_mesh.bottom_radius = 0.65
	log_mesh.height = 7.5
	log_mesh.radial_segments = 6
	log_mesh.material = mat_bark
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "FallenLogsMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = log_mesh
	
	var count = 250
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 71239
	
	while placed < count:
		var x = rng.randf_range(-75.0, 75.0)
		var z = rng.randf_range(-75.0, 75.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.0:
			continue
			
		var y = _get_terrain_height(x, z)
		var yaw = rng.randf_range(0.0, TAU)
		var roll = deg_to_rad(90.0) # Lie horizontal
		
		var b = Basis().rotated(Vector3.UP, yaw).rotated(Vector3.FORWARD, roll)
		var sc = rng.randf_range(0.8, 1.3)
		b = b.scaled(Vector3(sc, sc, sc))
		
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y + 0.35, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 8. Glacial Granite Boulders (350 boulders)
func _populate_granite_boulders(parent: Node3D, root: Node3D, mat_rock: Material) -> void:
	var rock_mesh = BoxMesh.new()
	rock_mesh.size = Vector3(2.4, 1.8, 2.6)
	rock_mesh.material = mat_rock
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "GraniteBouldersMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = rock_mesh
	
	var count = 350
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 33812
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.2:
			continue
			
		var y = _get_terrain_height(x, z)
		var yaw = rng.randf_range(0.0, TAU)
		var sc = rng.randf_range(0.75, 1.8)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y + 0.4 * sc, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# -----------------------------------------------------------------------------
# CINEMATIC VOLUMETRIC SUN SHAFTS (GOD RAYS)
# -----------------------------------------------------------------------------
func _build_cinematic_god_rays(parent: Node3D, root: Node3D, mat_godray: Material) -> void:
	var ray_node = Node3D.new()
	ray_node.name = "CinematicGodRays"
	parent.add_child(ray_node)
	ray_node.owner = root
	
	# Sun direction is rotation (-40, 38, 0)
	var ray_positions = [
		Vector3(0, 16.0, 14.0),
		Vector3(-8.0, 18.0, 6.0),
		Vector3(12.0, 17.0, -4.0),
		Vector3(-14.0, 18.0, -18.0),
		Vector3(6.0, 16.0, 24.0),
		Vector3(-16.0, 19.0, 28.0),
		Vector3(18.0, 17.0, -22.0),
		Vector3(-4.0, 16.0, -32.0)
	]
	
	for i in range(ray_positions.size()):
		var mi = MeshInstance3D.new()
		mi.name = "GodRay_%d" % i
		var qmesh = QuadMesh.new()
		qmesh.size = Vector2(8.0, 28.0)
		mi.mesh = qmesh
		mi.material_override = mat_godray
		mi.position = ray_positions[i]
		
		# Align beam parallel with sun vector
		mi.rotation_degrees = Vector3(-50, 38, 0)
		ray_node.add_child(mi)
		mi.owner = root

# -----------------------------------------------------------------------------
# AMBIENT FOREST PARTICLES (Drifting Pollen Motes & Falling Leaves)
# -----------------------------------------------------------------------------
func _create_ambient_forest_particles() -> CPUParticles3D:
	var p = CPUParticles3D.new()
	p.amount = 180
	p.lifetime = 6.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(45.0, 8.0, 45.0)
	p.direction = Vector3(0.6, -0.4, 0.4)
	p.spread = 45.0
	p.initial_velocity_min = 0.8
	p.initial_velocity_max = 2.2
	p.gravity = Vector3(0, -0.35, 0)
	
	var quad = QuadMesh.new()
	quad.size = Vector2(0.08, 0.08)
	var mat = StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.85, 0.95, 0.55, 0.65) # Sunlit golden-green motes
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	p.mesh = quad
	p.material_override = mat
	return p

# -----------------------------------------------------------------------------
# WILDERNESS SURVIVAL STATIONS (NO ROOM! PURE ORGANIC OUTDOOR SURVIVAL)
# -----------------------------------------------------------------------------
func _build_wilderness_survival_points(root: Node3D) -> void:
	var survival_root = Node3D.new()
	survival_root.name = "WildernessSurvivalPoints"
	root.add_child(survival_root)
	survival_root.owner = root
	
	var wallbuy_scene = load("res://interactables/WallBuyStation.tscn")
	var mysterybox_scene = load("res://interactables/MysteryBox.tscn")
	var perk_scene = load("res://interactables/PerkMachine.tscn")
	var barrel_scene = load("res://interactables/ExplosiveBarrel.tscn")
	var barricade_scene = load("res://interactables/BarricadeWindow.tscn")
	
	# 0. Wilderness Trail Timber Barricade (Between mossy boulders at x=-6.0, z=0.0)
	var barricade = barricade_scene.instantiate()
	barricade.name = "TrailBarricade"
	barricade.window_id = "forest_trail_choke"
	var pos_bar = Vector3(-6.0, _get_terrain_height(-6.0, 0.0) + 0.1, 0.0)
	barricade.position = pos_bar
	barricade.rotation_degrees = Vector3(0, 45, 0)
	survival_root.add_child(barricade)
	barricade.owner = root
	
	# 1. Starting Field Ammo Cache (Next to player spawn on a mossy rock)
	var wb_m1911 = wallbuy_scene.instantiate()
	wb_m1911.name = "Cache_M1911Ammo"
	wb_m1911.weapon_resource_path = "res://weapons/pistol/M1911.tres"
	wb_m1911.weapon_display_name = "M1911 Tactical Ammo"
	wb_m1911.weapon_cost = 250
	wb_m1911.ammo_cost = 250
	var pos_m1911 = Vector3(2.8, _get_terrain_height(2.8, 14.5) + 1.2, 14.5)
	wb_m1911.position = pos_m1911
	wb_m1911.rotation_degrees = Vector3(0, -120, 0)
	survival_root.add_child(wb_m1911)
	wb_m1911.owner = root
	
	# 2. Shotgun Stand: Remington 870 on a notched cedar post by trail (z=4)
	var wb_rem = wallbuy_scene.instantiate()
	wb_rem.name = "Stand_Remington870"
	wb_rem.weapon_resource_path = "res://weapons/shotgun/Remington870.tres"
	wb_rem.weapon_display_name = "Remington 870 Shotgun"
	wb_rem.weapon_cost = 500
	wb_rem.ammo_cost = 250
	var pos_rem = Vector3(-3.2, _get_terrain_height(-3.2, 4.0) + 1.2, 4.0)
	wb_rem.position = pos_rem
	wb_rem.rotation_degrees = Vector3(0, 45, 0)
	survival_root.add_child(wb_rem)
	wb_rem.owner = root
	
	# 3. Assault Rifle Stand: AK-47 on weathered forestry marker (z=-10)
	var wb_ak = wallbuy_scene.instantiate()
	wb_ak.name = "Stand_AK47"
	wb_ak.weapon_resource_path = "res://weapons/rifle/AK47.tres"
	wb_ak.weapon_display_name = "AK-47 Tactical"
	wb_ak.weapon_cost = 1200
	wb_ak.ammo_cost = 600
	var pos_ak = Vector3(4.5, _get_terrain_height(4.5, -10.0) + 1.2, -10.0)
	wb_ak.position = pos_ak
	wb_ak.rotation_degrees = Vector3(0, -90, 0)
	survival_root.add_child(wb_ak)
	wb_ak.owner = root
	
	# 4. Carbine Stand: M4A1 on military cache crate (z=-24)
	var wb_m4 = wallbuy_scene.instantiate()
	wb_m4.name = "Stand_M4A1"
	wb_m4.weapon_resource_path = "res://weapons/carbine/M4A1.tres"
	wb_m4.weapon_display_name = "M4A1 Carbine"
	wb_m4.weapon_cost = 1500
	wb_m4.ammo_cost = 750
	var pos_m4 = Vector3(-6.5, _get_terrain_height(-6.5, -24.0) + 1.2, -24.0)
	wb_m4.position = pos_m4
	wb_m4.rotation_degrees = Vector3(0, 90, 0)
	survival_root.add_child(wb_m4)
	wb_m4.owner = root
	
	# 5. Magnum Stand: Colt Python .357 on stone monolith (z=-36)
	var wb_py = wallbuy_scene.instantiate()
	wb_py.name = "Stand_Python357"
	wb_py.weapon_resource_path = "res://weapons/magnum/ColtPython.tres"
	wb_py.weapon_display_name = "Colt Python .357"
	wb_py.weapon_cost = 2000
	wb_py.ammo_cost = 1000
	var pos_py = Vector3(5.2, _get_terrain_height(5.2, -36.0) + 1.2, -36.0)
	wb_py.position = pos_py
	wb_py.rotation_degrees = Vector3(0, -60, 0)
	survival_root.add_child(wb_py)
	wb_py.owner = root
	
	# 6. Ancient Stone Circle Mystery Box (x=-14, z=-18)
	var mbox = mysterybox_scene.instantiate()
	mbox.name = "MysteryBox"
	var pos_mbox = Vector3(-14.0, _get_terrain_height(-14.0, -18.0) + 0.1, -18.0)
	mbox.position = pos_mbox
	mbox.rotation_degrees = Vector3(0, 35, 0)
	survival_root.add_child(mbox)
	mbox.owner = root
	
	# 7. Perk Shrines (Overgrown weathered field units nestled by granite cliff at x=16, z=-12)
	var perk_jug = perk_scene.instantiate()
	perk_jug.name = "Perk_Juggernog"
	perk_jug.perk_type = 0 # Juggernog
	var pos_jug = Vector3(16.0, _get_terrain_height(16.0, -12.0) + 0.1, -12.0)
	perk_jug.position = pos_jug
	perk_jug.rotation_degrees = Vector3(0, -75, 0)
	survival_root.add_child(perk_jug)
	perk_jug.owner = root
	
	var perk_spd = perk_scene.instantiate()
	perk_spd.name = "Perk_SpeedCola"
	perk_spd.perk_type = 1 # Speed Cola
	var pos_spd = Vector3(19.0, _get_terrain_height(19.0, -9.5) + 0.1, -9.5)
	perk_spd.position = pos_spd
	perk_spd.rotation_degrees = Vector3(0, -85, 0)
	survival_root.add_child(perk_spd)
	perk_spd.owner = root
	
	# 8. Explosive Fuel Barrels at natural rock choke points
	var barrel_positions = [
		Vector3(3.2, 0, 7.5),
		Vector3(-4.5, 0, -5.0),
		Vector3(7.0, 0, -18.0),
		Vector3(-10.5, 0, -28.0)
	]
	for i in range(barrel_positions.size()):
		var b = barrel_scene.instantiate()
		b.name = "ExplosiveBarrel_%d" % i
		var bp = barrel_positions[i]
		bp.y = _get_terrain_height(bp.x, bp.z) + 0.1
		b.position = bp
		survival_root.add_child(b)
		b.owner = root
