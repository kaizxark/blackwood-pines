extends SceneTree

# PROJECT PROTO-BREACH - Next-Gen Alpine Mountain & Lush Forest Map Generator
# Generates "Blackwood Alpine Valley" - a breathtaking real-world mountain forest environment:
# 1. HeightMapShape3D rock-solid terrain physics (zero snags, flawless character locomotion)
# 2. Majestic 360-degree alpine mountain ranges with snow caps and granite cliffs
# 3. Dense multi-species flora: 15,850+ instances (Pines, Oaks, Birches, Shrubs, Ferns, Grass, Logs, Boulders)
# 4. Cinematic sun god-rays, floating pollen/leaf particles, and morning sun mist
# 5. Seamless wilderness survival points (tactical weapon stands, mystery box in stone grove, weathered perk shrines)

func _init() -> void:
	print("\n==================================================================")
	print("  GENERATING EPIC ALPINE MOUNTAIN & LUSH FOREST MAP (BLACKWOOD)   ")
	print("==================================================================\n")
	
	var root = Node3D.new()
	root.name = "BlackwoodForest"
	
	# Shaders & Materials
	var terrain_shader = load("res://assets/shaders/terrain_forest_lush.gdshader")
	var foliage_shader = load("res://assets/shaders/foliage_lush.gdshader")
	var bark_shader = load("res://assets/shaders/bark_realistic.gdshader")
	var rock_shader = load("res://assets/shaders/mossy_rock.gdshader")
	var godray_shader = load("res://assets/shaders/god_rays.gdshader")
	var mountain_shader = load("res://assets/shaders/alpine_mountain.gdshader")
	
	var mat_terrain = ShaderMaterial.new()
	mat_terrain.shader = terrain_shader
	
	var mat_mountain = ShaderMaterial.new()
	mat_mountain.shader = mountain_shader
	
	# Foliage Materials with rich subsurface scattering
	var mat_pine_foliage = ShaderMaterial.new()
	mat_pine_foliage.shader = foliage_shader
	mat_pine_foliage.set_shader_parameter("leaf_top_color", Color(0.08, 0.24, 0.06))
	mat_pine_foliage.set_shader_parameter("leaf_bottom_color", Color(0.15, 0.38, 0.10))
	mat_pine_foliage.set_shader_parameter("transmission_color", Color(0.32, 0.58, 0.16))
	mat_pine_foliage.set_shader_parameter("transmission_strength", 0.95)
	
	var mat_deciduous_foliage = ShaderMaterial.new()
	mat_deciduous_foliage.shader = foliage_shader
	mat_deciduous_foliage.set_shader_parameter("leaf_top_color", Color(0.14, 0.38, 0.09))
	mat_deciduous_foliage.set_shader_parameter("leaf_bottom_color", Color(0.24, 0.52, 0.15))
	mat_deciduous_foliage.set_shader_parameter("transmission_color", Color(0.42, 0.72, 0.20))
	mat_deciduous_foliage.set_shader_parameter("transmission_strength", 1.15)
	mat_deciduous_foliage.set_shader_parameter("roughness", 0.58)
	
	var mat_birch_foliage = ShaderMaterial.new()
	mat_birch_foliage.shader = foliage_shader
	mat_birch_foliage.set_shader_parameter("leaf_top_color", Color(0.22, 0.46, 0.12))
	mat_birch_foliage.set_shader_parameter("leaf_bottom_color", Color(0.32, 0.60, 0.18))
	mat_birch_foliage.set_shader_parameter("transmission_color", Color(0.52, 0.80, 0.25))
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
	mat_grass.set_shader_parameter("leaf_bottom_color", Color(0.28, 0.52, 0.16))
	mat_grass.set_shader_parameter("transmission_color", Color(0.48, 0.74, 0.22))
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
	# 1. WorldEnvironment (Atmosphere, Sky & Mountain Depth)
	# -------------------------------------------------------------------------
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.32, 0.52, 0.85) # Vivid alpine sky
	sky_mat.sky_horizon_color = Color(0.68, 0.78, 0.88)
	sky_mat.ground_bottom_color = Color(0.10, 0.16, 0.08) # Rich forest floor bounce
	sky_mat.ground_horizon_color = Color(0.40, 0.52, 0.36)
	sky_mat.sun_angle_max = 35.0
	sky.sky_material = sky_mat
	env.sky = sky
	
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.55, 0.65, 0.78)
	env.ambient_light_sky_contribution = 0.7
	env.ambient_light_energy = 0.95
	
	# Atmospheric distance fog (sunlit alpine mist)
	env.fog_enabled = true
	env.fog_light_color = Color(0.58, 0.70, 0.65)
	env.fog_density = 0.009
	env.fog_aerial_perspective = 0.45
	env.fog_sky_affect = 0.3
	
	env.glow_enabled = true
	env.glow_bloom = 0.18
	env.glow_intensity = 0.85
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.05
	
	we.environment = env
	root.add_child(we)
	we.owner = root
	
	# -------------------------------------------------------------------------
	# 2. Golden Directional Sun
	# -------------------------------------------------------------------------
	var sun = DirectionalLight3D.new()
	sun.name = "DirectionalSun"
	sun.light_color = Color(1.0, 0.94, 0.82)
	sun.light_energy = 2.4
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun.shadow_blur = 1.5
	sun.rotation_degrees = Vector3(-38, 38, 0)
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
	# 4. TERRAIN ENGINE (HeightMapShape3D Physics + ArrayMesh Visuals)
	# -------------------------------------------------------------------------
	var terrain_sb = StaticBody3D.new()
	terrain_sb.name = "ForestTerrain"
	terrain_sb.collision_layer = 1
	terrain_sb.collision_mask = 0
	root.add_child(terrain_sb)
	terrain_sb.owner = root
	
	var res = 120
	var size = 180.0
	var step = size / float(res)
	var count = res + 1
	
	# A. Build HeightMapShape3D Physics Shape (ROCK-SOLID LOCOMOTION!)
	var terrain_cs = CollisionShape3D.new()
	terrain_cs.name = "TerrainCollision"
	var hms = HeightMapShape3D.new()
	hms.map_width = count
	hms.map_depth = count
	
	var h_data = PackedFloat32Array()
	h_data.resize(count * count)
	
	for z_i in range(count):
		var z = -size * 0.5 + float(z_i) * step
		for x_i in range(count):
			var x = -size * 0.5 + float(x_i) * step
			var h = _get_terrain_height(x, z)
			h_data[z_i * count + x_i] = h
			
	hms.map_data = h_data
	terrain_cs.shape = hms
	terrain_cs.scale = Vector3(step, 1.0, step)
	terrain_sb.add_child(terrain_cs)
	terrain_cs.owner = root
	
	# B. Build ArrayMesh Visuals
	var terrain_mi = MeshInstance3D.new()
	terrain_mi.name = "TerrainMeshInstance"
	terrain_mi.material_override = mat_terrain
	var t_mesh = _generate_terrain_mesh(size, res)
	terrain_mi.mesh = t_mesh
	terrain_sb.add_child(terrain_mi)
	terrain_mi.owner = root
	
	# Invisible World Boundaries
	_build_world_boundaries(root, size)
	
	# -------------------------------------------------------------------------
	# 5. MAJESTIC ALPINE MOUNTAIN RANGES (360-Degree Mountain Panorama)
	# -------------------------------------------------------------------------
	var mountain_root = Node3D.new()
	mountain_root.name = "AlpineMountainRanges"
	root.add_child(mountain_root)
	mountain_root.owner = root
	
	_build_mountain_ranges(mountain_root, root, mat_mountain)
	
	# -------------------------------------------------------------------------
	# 6. Player Instance (Spawned smoothly on the forest trail)
	# -------------------------------------------------------------------------
	var player_scene = load("res://entities/player/Player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	var spawn_x = 0.0
	var spawn_z = 14.0
	var ground_h = _get_terrain_height(spawn_x, spawn_z)
	player.position = Vector3(spawn_x, ground_h + 0.95, spawn_z)
	player.rotation_degrees = Vector3(0, 180, 0) # Facing North
	root.add_child(player)
	player.owner = root
	
	# -------------------------------------------------------------------------
	# 7. HUD Instance
	# -------------------------------------------------------------------------
	var hud_scene = load("res://ui/HUD.tscn")
	var hud = hud_scene.instantiate()
	hud.name = "HUD"
	root.add_child(hud)
	hud.owner = root
	
	# -------------------------------------------------------------------------
	# 8. Airborne Forest Particulates
	# -------------------------------------------------------------------------
	var particles = _create_ambient_forest_particles()
	particles.name = "AmbientForestParticles"
	particles.position = Vector3(0, 6.0, 0)
	root.add_child(particles)
	particles.owner = root
	
	# -------------------------------------------------------------------------
	# 9. MULTIMESH FOREST ENGINE (15,850+ Foliage & Rock Instances)
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
	# 10. CINEMATIC VOLUMETRIC GOD-RAYS
	# -------------------------------------------------------------------------
	_build_cinematic_god_rays(foliage_root, root, mat_godray)
	
	# -------------------------------------------------------------------------
	# 11. WILDERNESS SURVIVAL STATIONS (NO ROOM! PURE OUTDOOR SURVIVAL)
	# -------------------------------------------------------------------------
	_build_wilderness_survival_points(root)
	
	# -------------------------------------------------------------------------
	# 12. Save Scene
	# -------------------------------------------------------------------------
	var packed = PackedScene.new()
	var pack_err = packed.pack(root)
	if pack_err != OK:
		printerr("ERROR: Failed to pack scene! Error code: ", pack_err)
		quit(1)
		return
		
	var save_path = "res://levels/zombie_outbreak/Blackwood_Pines.tscn"
	var save_err = ResourceSaver.save(packed, save_path)
	if save_err != OK:
		printerr("ERROR: Failed to save to ", save_path, "! Error: ", save_err)
		quit(1)
		return
		
	print("[SUCCESS] Epic Alpine Mountain & Lush Forest Map generated and saved to ", save_path)
	quit(0)

# =============================================================================
# TERRAIN MATHEMATICS
# =============================================================================

static func _get_terrain_height(x: float, z: float) -> float:
	var h1 = sin(x * 0.038) * cos(z * 0.034) * 3.4
	var h2 = sin(x * 0.075 + 1.2) * sin(z * 0.068 - 0.7) * 1.6
	var h3 = cos(x * 0.14 - z * 0.12) * 0.5
	
	var edge_dist = max(abs(x), abs(z))
	var ridge_t = clamp((edge_dist - 55.0) / 30.0, 0.0, 1.0)
	var ridge_h = ridge_t * ridge_t * 7.5
	
	var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
	var dist_path = abs(x - path_x)
	var path_dip = (1.0 - clamp(dist_path / 3.8, 0.0, 1.0)) * 0.35
	
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
	
	for gz in range(vertex_count_per_row):
		var z = -half_size + float(gz) * step
		for gx in range(vertex_count_per_row):
			var x = -half_size + float(gx) * step
			var y = _get_terrain_height(x, z)
			verts.append(Vector3(x, y, z))
			uvs.append(Vector2(float(gx) / float(resolution), float(gz) / float(resolution)))
			
			var eps = 0.5
			var dhdx = (_get_terrain_height(x + eps, z) - _get_terrain_height(x - eps, z)) / (2.0 * eps)
			var dhdz = (_get_terrain_height(x, z + eps) - _get_terrain_height(x, z - eps)) / (2.0 * eps)
			var norm = Vector3(-dhdx, 1.0, -dhdz).normalized()
			normals.append(norm)
			
	for gz in range(resolution):
		for gx in range(resolution):
			var i0 = gz * vertex_count_per_row + gx
			var i1 = i0 + 1
			var i2 = (gz + 1) * vertex_count_per_row + gx
			var i3 = i2 + 1
			
			indices.append(i0)
			indices.append(i2)
			indices.append(i1)
			
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

# =============================================================================
# MAJESTIC ALPINE MOUNTAIN BUILDER (360-Degree Panorama)
# =============================================================================

func _build_mountain_ranges(parent: Node3D, root: Node3D, mat_mountain: Material) -> void:
	# 4 Mountain Ranges framing the horizon: North, South, East, West
	var ranges = [
		{"name": "NorthAlpineRange", "offset": Vector3(0, 0, -145.0), "rot": 0.0, "width": 280.0, "height": 78.0, "depth": 70.0},
		{"name": "SouthAlpineRange", "offset": Vector3(0, 0, 145.0), "rot": PI, "width": 280.0, "height": 68.0, "depth": 70.0},
		{"name": "EastAlpineCliffs", "offset": Vector3(145.0, 0, 0), "rot": -PI*0.5, "width": 280.0, "height": 72.0, "depth": 70.0},
		{"name": "WestAlpineFoothills", "offset": Vector3(-145.0, 0, 0), "rot": PI*0.5, "width": 280.0, "height": 64.0, "depth": 70.0}
	]
	
	for r in ranges:
		var m_mesh = _generate_mountain_mesh(r["width"], r["depth"], r["height"], 28, 12)
		var mi = MeshInstance3D.new()
		mi.name = r["name"]
		mi.mesh = m_mesh
		mi.material_override = mat_mountain
		mi.position = r["offset"]
		mi.rotation.y = r["rot"]
		parent.add_child(mi)
		mi.owner = root

func _generate_mountain_mesh(width: float, depth: float, peak_height: float, res_x: int, res_z: int) -> ArrayMesh:
	var verts = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	var step_x = width / float(res_x)
	var step_z = depth / float(res_z)
	var cols = res_x + 1
	var rows = res_z + 1
	
	for r in range(rows):
		var z = -depth * 0.5 + float(r) * step_z
		var z_factor = 1.0 - abs(z) / (depth * 0.5) # Ridge crest in middle
		z_factor = pow(clamp(z_factor, 0.0, 1.0), 1.4)
		
		for c in range(cols):
			var x = -width * 0.5 + float(c) * step_x
			# Jagged serrated alpine peaks
			var p1 = sin(x * 0.045) * cos(x * 0.09) * 0.5 + 0.5
			var p2 = sin(x * 0.12 + 1.4) * 0.3
			var p3 = cos(x * 0.28) * 0.15
			var peak_profile = p1 + p2 + p3
			
			var y = peak_height * peak_profile * z_factor
			# Add craggy ridge noise
			y += sin(x * 0.35 + z * 0.4) * 3.5 * z_factor
			
			verts.append(Vector3(x, y, z))
			uvs.append(Vector2(float(c)/float(res_x), float(r)/float(res_z)))
			
	# Generate normals & indices
	for r in range(res_z):
		for c in range(res_x):
			var i0 = r * cols + c
			var i1 = i0 + 1
			var i2 = (r + 1) * cols + c
			var i3 = i2 + 1
			
			indices.append(i0)
			indices.append(i2)
			indices.append(i1)
			
			indices.append(i1)
			indices.append(i2)
			indices.append(i3)
			
	# Generate smooth surface normals
	normals.resize(verts.size())
	for i in range(normals.size()):
		normals[i] = Vector3.ZERO
		
	for i in range(0, indices.size(), 3):
		var i0 = indices[i]
		var i1 = indices[i+1]
		var i2 = indices[i+2]
		var v0 = verts[i0]
		var v1 = verts[i1]
		var v2 = verts[i2]
		var fn = (v1 - v0).cross(v2 - v0)
		normals[i0] += fn
		normals[i1] += fn
		normals[i2] += fn
		
	for i in range(normals.size()):
		normals[i] = normals[i].normalized()
		
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
		{"pos": Vector3(0, 15, half), "size": Vector3(size, 40, 2)},
		{"pos": Vector3(0, 15, -half), "size": Vector3(size, 40, 2)},
		{"pos": Vector3(half, 15, 0), "size": Vector3(2, 40, size)},
		{"pos": Vector3(-half, 15, 0), "size": Vector3(2, 40, size)}
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
# MULTIMESH VEGETATION BUILDERS (15,850+ Instances)
# =============================================================================

# 1. Tall Douglas Firs & Northern Pines (1,800 trees, 18m - 28m)
func _populate_tall_pines(parent: Node3D, root: Node3D, mat_bark: Material, mat_foliage: Material) -> void:
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.top_radius = 0.28
	trunk_mesh.bottom_radius = 0.95
	trunk_mesh.height = 18.0
	trunk_mesh.radial_segments = 7
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_bark)
	st.append_from(trunk_mesh, 0, Transform3D(Basis(), Vector3(0, 9.0, 0)))
	
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
		tier_mesh.radial_segments = 7
		st.append_from(tier_mesh, 0, Transform3D(Basis(), Vector3(0, tier["y"], 0)))
		
	var combined_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "TallPinesMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = combined_mesh
	
	var count = 1800
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 42819
	
	while placed < count:
		var x = rng.randf_range(-82.0, 82.0)
		var z = rng.randf_range(-82.0, 82.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.8: continue
		if Vector2(x, z - 14.0).length() < 7.0: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.45)
		var yaw = rng.randf_range(0.0, TAU)
		var lean = rng.randf_range(-0.06, 0.06)
		
		var b = Basis().rotated(Vector3.UP, yaw).rotated(Vector3.RIGHT, lean).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 2. Hardwood Broadleaf Oaks (1,000 trees, 12m - 18m)
func _populate_broadleaf_oaks(parent: Node3D, root: Node3D, mat_bark: Material, mat_foliage: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_bark)
	
	var trunk = CylinderMesh.new()
	trunk.top_radius = 0.55
	trunk.bottom_radius = 1.15
	trunk.height = 7.5
	trunk.radial_segments = 6
	st.append_from(trunk, 0, Transform3D(Basis(), Vector3(0, 3.75, 0)))
	
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
		sph.radial_segments = 6
		sph.rings = 4
		st.append_from(sph, 0, Transform3D(Basis(), c["pos"]))
		
	var oak_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "BroadleafOaksMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = oak_mesh
	
	var count = 1000
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 83912
	
	while placed < count:
		var x = rng.randf_range(-80.0, 80.0)
		var z = rng.randf_range(-80.0, 80.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 4.2: continue
		if Vector2(x, z - 14.0).length() < 8.0: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.9, 1.35)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 3. Mountain Birches (700 trees, 10m - 16m)
func _populate_white_birches(parent: Node3D, root: Node3D, mat_birch_bark: Material, mat_foliage: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_birch_bark)
	
	var trunk = CylinderMesh.new()
	trunk.top_radius = 0.16
	trunk.bottom_radius = 0.38
	trunk.height = 10.0
	trunk.radial_segments = 6
	var b_t = Basis().rotated(Vector3.RIGHT, 0.08)
	st.append_from(trunk, 0, Transform3D(b_t, Vector3(0, 5.0, 0)))
	
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
		sph.radial_segments = 5
		sph.rings = 4
		st.append_from(sph, 0, Transform3D(Basis(), c["pos"]))
		
	var birch_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "WhiteBirchMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = birch_mesh
	
	var count = 700
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 29314
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.2: continue
		if Vector2(x, z - 14.0).length() < 7.0: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.3)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.1, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 4. Understory Forest Bushes & Shrubs (1,800 bushes, 1.8m - 3.2m)
func _populate_understory_shrubs(parent: Node3D, root: Node3D, mat_foliage: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_foliage)
	
	var c1 = SphereMesh.new()
	c1.radius = 1.3
	c1.height = 1.8
	c1.radial_segments = 5
	c1.rings = 3
	st.append_from(c1, 0, Transform3D(Basis(), Vector3(0, 0.9, 0)))
	
	var c2 = SphereMesh.new()
	c2.radius = 1.0
	c2.height = 1.5
	c2.radial_segments = 5
	c2.rings = 3
	st.append_from(c2, 0, Transform3D(Basis(), Vector3(0.8, 0.7, 0.4)))
	
	var shrub_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "UnderstoryShrubsMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = shrub_mesh
	
	var count = 1800
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 66129
	
	while placed < count:
		var x = rng.randf_range(-82.0, 82.0)
		var z = rng.randf_range(-82.0, 82.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 2.5: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.8, 1.45)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 5. Lush Feathered Ferns (3,500 ferns, 0.7m - 1.3m)
func _populate_lush_ferns(parent: Node3D, root: Node3D, mat_fern: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_fern)
	
	for frond in range(6):
		var ang = float(frond) * (TAU / 6.0)
		var quad = QuadMesh.new()
		quad.size = Vector2(0.45, 1.3)
		var b = Basis().rotated(Vector3.UP, ang).rotated(Vector3.RIGHT, deg_to_rad(45.0))
		st.append_from(quad, 0, Transform3D(b, Vector3(0, 0.45, 0)))
		
	var fern_mesh = st.commit()
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "LushFernsMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = fern_mesh
	
	var count = 3500
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 99318
	
	while placed < count:
		var x = rng.randf_range(-82.0, 82.0)
		var z = rng.randf_range(-82.0, 82.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 1.4: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.5)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 6. Alpine Grass & Wildflower Tufts (5,500 tufts, 0.4m - 0.8m)
func _populate_wild_grass(parent: Node3D, root: Node3D, mat_grass: Material) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_grass)
	
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
	
	var count = 5500
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 44102
	
	while placed < count:
		var x = rng.randf_range(-82.0, 82.0)
		var z = rng.randf_range(-82.0, 82.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 1.0: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.8, 1.55)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 7. Mossy Fallen Nurse Logs (450 logs, 6m - 10m)
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
	
	var count = 450
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 71239
	
	while placed < count:
		var x = rng.randf_range(-80.0, 80.0)
		var z = rng.randf_range(-80.0, 80.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.0: continue
			
		var y = _get_terrain_height(x, z)
		var yaw = rng.randf_range(0.0, TAU)
		var roll = deg_to_rad(90.0)
		
		var b = Basis().rotated(Vector3.UP, yaw).rotated(Vector3.FORWARD, roll)
		var sc = rng.randf_range(0.8, 1.35)
		b = b.scaled(Vector3(sc, sc, sc))
		
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y + 0.35, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 8. Glacial Granite Boulders (600 boulders, 1.8m - 4.5m)
func _populate_granite_boulders(parent: Node3D, root: Node3D, mat_rock: Material) -> void:
	var rock_mesh = BoxMesh.new()
	rock_mesh.size = Vector3(2.4, 1.8, 2.6)
	rock_mesh.material = mat_rock
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "GraniteBouldersMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = rock_mesh
	
	var count = 600
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 33812
	
	while placed < count:
		var x = rng.randf_range(-82.0, 82.0)
		var z = rng.randf_range(-82.0, 82.0)
		
		var path_x = sin(z * 0.045) * 12.0 + cos(z * 0.09) * 4.0
		if abs(x - path_x) < 3.2: continue
			
		var y = _get_terrain_height(x, z)
		var yaw = rng.randf_range(0.0, TAU)
		var sc = rng.randf_range(0.75, 1.9)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y + 0.4 * sc, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# -----------------------------------------------------------------------------
# CINEMATIC GOD RAYS
# -----------------------------------------------------------------------------
func _build_cinematic_god_rays(parent: Node3D, root: Node3D, mat_godray: Material) -> void:
	var ray_node = Node3D.new()
	ray_node.name = "CinematicGodRays"
	parent.add_child(ray_node)
	ray_node.owner = root
	
	var ray_positions = [
		Vector3(0, 16.0, 14.0),
		Vector3(-8.0, 18.0, 6.0),
		Vector3(12.0, 17.0, -4.0),
		Vector3(-14.0, 18.0, -18.0),
		Vector3(6.0, 16.0, 24.0),
		Vector3(-16.0, 19.0, 28.0),
		Vector3(18.0, 17.0, -22.0),
		Vector3(-4.0, 16.0, -32.0),
		Vector3(10.0, 18.0, 10.0),
		Vector3(-10.0, 17.0, -8.0)
	]
	
	for i in range(ray_positions.size()):
		var mi = MeshInstance3D.new()
		mi.name = "GodRay_%d" % i
		var qmesh = QuadMesh.new()
		qmesh.size = Vector2(8.0, 30.0)
		mi.mesh = qmesh
		mi.material_override = mat_godray
		mi.position = ray_positions[i]
		mi.rotation_degrees = Vector3(-52, 38, 0)
		ray_node.add_child(mi)
		mi.owner = root

# -----------------------------------------------------------------------------
# AMBIENT FOREST PARTICLES
# -----------------------------------------------------------------------------
func _create_ambient_forest_particles() -> CPUParticles3D:
	var p = CPUParticles3D.new()
	p.amount = 220
	p.lifetime = 6.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(50.0, 10.0, 50.0)
	p.direction = Vector3(0.6, -0.4, 0.4)
	p.spread = 45.0
	p.initial_velocity_min = 0.8
	p.initial_velocity_max = 2.4
	p.gravity = Vector3(0, -0.35, 0)
	
	var quad = QuadMesh.new()
	quad.size = Vector2(0.08, 0.08)
	var mat = StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.85, 0.95, 0.55, 0.65)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	p.mesh = quad
	p.material_override = mat
	return p

# -----------------------------------------------------------------------------
# WILDERNESS SURVIVAL STATIONS
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
	
	# Timber Trail Barricade across rock cut (x=-6, z=0)
	var barricade = barricade_scene.instantiate()
	barricade.name = "TrailBarricade"
	barricade.window_id = "forest_trail_choke"
	var pos_bar = Vector3(-6.0, _get_terrain_height(-6.0, 0.0) + 0.1, 0.0)
	barricade.position = pos_bar
	barricade.rotation_degrees = Vector3(0, 45, 0)
	survival_root.add_child(barricade)
	barricade.owner = root
	
	# M1911 Ammo Cache by player spawn
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
	
	# Remington 870 Stand
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
	
	# AK-47 Stand
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
	
	# M4A1 Stand
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
	
	# Colt Python .357 Stand
	var wb_py = wallbuy_scene.instantiate()
	wb_py.name = "Stand_Python357"
	wb_py.weapon_resource_path = "res://weapons/magnum/Python357.tres"
	wb_py.weapon_display_name = "Colt Python .357"
	wb_py.weapon_cost = 2000
	wb_py.ammo_cost = 1000
	var pos_py = Vector3(5.2, _get_terrain_height(5.2, -36.0) + 1.2, -36.0)
	wb_py.position = pos_py
	wb_py.rotation_degrees = Vector3(0, -60, 0)
	survival_root.add_child(wb_py)
	wb_py.owner = root
	
	# Mystery Box in Ancient Stone Grove
	var mbox = mysterybox_scene.instantiate()
	mbox.name = "MysteryBox"
	var pos_mbox = Vector3(-14.0, _get_terrain_height(-14.0, -18.0) + 0.1, -18.0)
	mbox.position = pos_mbox
	mbox.rotation_degrees = Vector3(0, 35, 0)
	survival_root.add_child(mbox)
	mbox.owner = root
	
	# Perk Shrines (Juggernog & Speed Cola)
	var perk_jug = perk_scene.instantiate()
	perk_jug.name = "Perk_Juggernog"
	perk_jug.perk_type = 0
	var pos_jug = Vector3(16.0, _get_terrain_height(16.0, -12.0) + 0.1, -12.0)
	perk_jug.position = pos_jug
	perk_jug.rotation_degrees = Vector3(0, -75, 0)
	survival_root.add_child(perk_jug)
	perk_jug.owner = root
	
	var perk_spd = perk_scene.instantiate()
	perk_spd.name = "Perk_SpeedCola"
	perk_spd.perk_type = 1
	var pos_spd = Vector3(19.0, _get_terrain_height(19.0, -9.5) + 0.1, -9.5)
	perk_spd.position = pos_spd
	perk_spd.rotation_degrees = Vector3(0, -85, 0)
	survival_root.add_child(perk_spd)
	perk_spd.owner = root
	
	# Explosive Fuel Barrels
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
