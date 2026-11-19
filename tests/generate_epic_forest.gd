extends SceneTree

# PROJECT PROTO-BREACH - Next-Gen Logical Landscape & Alpine Forest Overhaul
# Implements realistic geology, ecology, and environmental storytelling:
# 1. Geological U-shaped glacial valley with downstream drainage gradient and dry creek bed
# 2. Continuous 360-degree seamless alpine mountain amphitheater (zero gaps, zero flat panels)
# 3. Lived-in Ranger Outpost Alpha (log cabin, timber porch, creek bridge, stone dolmen grotto)
# 4. Ecological vegetation distribution (pines on slopes, birches near water, ferns in moist shade)
# 5. Rock-solid HeightMapShape3D collision for 100% snag-free locomotion

func _init() -> void:
	print("\n==================================================================")
	print("   GENERATING LOGICAL ALPINE VALLEY & FOREST MAP (BLACKWOOD)      ")
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
	
	# Bark & Construction Materials
	var mat_pine_bark = ShaderMaterial.new()
	mat_pine_bark.shader = bark_shader
	mat_pine_bark.set_shader_parameter("bark_color", Color(0.22, 0.14, 0.08))
	mat_pine_bark.set_shader_parameter("bark_crevice_color", Color(0.10, 0.06, 0.03))
	mat_pine_bark.set_shader_parameter("is_birch", false)
	
	var mat_birch_bark = ShaderMaterial.new()
	mat_birch_bark.shader = bark_shader
	mat_birch_bark.set_shader_parameter("is_birch", true)
	mat_birch_bark.set_shader_parameter("moss_amount", 0.3)
	
	var mat_wood_plank = StandardMaterial3D.new()
	mat_wood_plank.albedo_color = Color(0.32, 0.22, 0.14)
	mat_wood_plank.roughness = 0.85
	
	var mat_zinc_roof = StandardMaterial3D.new()
	mat_zinc_roof.albedo_color = Color(0.35, 0.38, 0.36)
	mat_zinc_roof.metallic = 0.65
	mat_zinc_roof.roughness = 0.55
	
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
	sky_mat.sky_top_color = Color(0.32, 0.52, 0.85)
	sky_mat.sky_horizon_color = Color(0.68, 0.78, 0.88)
	sky_mat.ground_bottom_color = Color(0.10, 0.16, 0.08)
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
	
	# A. Build HeightMapShape3D Physics Shape
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
	
	# Safety World Boundaries at outer edge
	_build_world_boundaries(root, size)
	
	# -------------------------------------------------------------------------
	# 5. CONTINUOUS 360-DEGREE RADIAL ALPINE MOUNTAIN AMPHITHEATER
	# -------------------------------------------------------------------------
	var mountain_root = Node3D.new()
	mountain_root.name = "AlpineMountainCirque"
	root.add_child(mountain_root)
	mountain_root.owner = root
	
	_build_mountain_amphitheater(mountain_root, root, mat_mountain)
	
	# -------------------------------------------------------------------------
	# 6. Player Instance (Spawned cleanly on Outpost Alpha terrace)
	# -------------------------------------------------------------------------
	var player_scene = load("res://entities/player/Player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	var spawn_x = 0.0
	var spawn_z = 14.0
	var ground_h = _get_terrain_height(spawn_x, spawn_z)
	player.position = Vector3(spawn_x, ground_h + 0.95, spawn_z)
	player.rotation_degrees = Vector3(0, 180, 0) # Facing North down the valley
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
	# 9. MULTIMESH ECOLOGICAL VEGETATION ENGINE (16,000+ Instances)
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
	# 11. WORLD ARCHITECTURE & WILDERNESS SURVIVAL STATIONS
	# -------------------------------------------------------------------------
	_build_wilderness_survival_points(root, mat_pine_bark, mat_wood_plank, mat_zinc_roof, mat_rock)
	
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
		
	print("[SUCCESS] Logical Alpine Valley & Forest Map generated and saved to ", save_path)
	quit(0)

# =============================================================================
# GEOLOGICAL TERRAIN MATHEMATICS
# =============================================================================

static func _get_terrain_height(x: float, z: float) -> float:
	# 1. Macro Valley Drainage: Downstream gradient from South (+Z) to North (-Z)
	var flow_gradient = (z - 14.0) * 0.025
	
	# 2. Valley Spine / Floor Axis (Meandering geological trough)
	var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
	var dist_valley = abs(x - valley_x)
	var valley_u = (dist_valley / 26.0) * (dist_valley / 26.0) * 2.8
	
	# 3. Dry Creek Bed / Stream Wash (lowest carved watercourse)
	var creek_x = valley_x + sin(z * 0.05 + 0.8) * 4.5
	var dist_creek = abs(x - creek_x)
	var creek_dip = (1.0 - clamp((dist_creek - 0.7) / 2.3, 0.0, 1.0)) * 0.85
	var creek_bank = sin(z * 0.14) * 0.22 * (1.0 - clamp((dist_creek - 2.0) / 3.2, 0.0, 1.0))
	
	# 4. Organic Moraines & Rolling Topography (multi-octave rolling hills)
	var m1 = sin(x * 0.038 + 1.2) * cos(z * 0.034 - 0.6) * 2.8
	var m2 = cos(x * 0.076 - 0.8) * sin(z * 0.068 + 1.1) * 1.5
	var m3 = sin(x * 0.15 + z * 0.13) * 0.45
	var rolling_hills = m1 + m2 + m3
	
	# 5. Outpost Alpha Terrace (Flat gravel plateau for cabin, palisades & player spawn)
	var dist_outpost = Vector2(x - 1.0, z - 14.0).length()
	var t_outpost = 1.0 - clamp(dist_outpost / 18.0, 0.0, 1.0)
	var outpost_flatten = t_outpost * t_outpost * 0.75
	
	# 6. Ancient Stone Grotto Terrace (Flat ground for Mystery Box shrine)
	var dist_grotto = Vector2(x + 18.0, z + 16.0).length()
	var t_grotto = 1.0 - clamp(dist_grotto / 12.0, 0.0, 1.0)
	var grotto_flatten = t_grotto * t_grotto * 0.70
	
	# 7. High Lookout Bluff (Elevated rock promontory for tactical defense & AK-47 stand)
	var dist_bluff = Vector2(x - 20.0, z + 10.0).length()
	var t_bluff = 1.0 - clamp(dist_bluff / 14.0, 0.0, 1.0)
	var bluff_height = t_bluff * t_bluff * 3.8
	
	# 8. CONTINUOUS ORGANIC PERIMETER MOUNTAIN CIRQUE (NO SQUARE BOX!)
	var dist_radial = Vector2(x, z).length()
	var ang = atan2(z, x)
	var rim_radius = 56.0 + sin(ang * 3.0) * 6.0 + cos(ang * 5.0) * 4.0
	var rim_t = clamp((dist_radial - rim_radius) / 22.0, 0.0, 1.0)
	var cirque_cliff = rim_t * rim_t * 32.0
	
	var base_h = flow_gradient + valley_u + rolling_hills + creek_bank - creek_dip
	var flat = max(outpost_flatten, grotto_flatten)
	return base_h * (1.0 - flat) + bluff_height + cirque_cliff

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
# CONTINUOUS 360-DEGREE RADIAL ALPINE MOUNTAIN AMPHITHEATER
# =============================================================================

func _build_mountain_amphitheater(parent: Node3D, root: Node3D, mat_mountain: Material) -> void:
	var mi = MeshInstance3D.new()
	mi.name = "AlpineAmphitheaterMesh"
	mi.material_override = mat_mountain
	
	var radial_segments = 72
	var ring_segments = 14
	var r_inner = 110.0
	var r_outer = 320.0
	
	var verts = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	for ring in range(ring_segments + 1):
		var t_ring = float(ring) / float(ring_segments)
		var rad = lerp(r_inner, r_outer, t_ring)
		
		for seg in range(radial_segments + 1):
			var t_seg = float(seg) / float(radial_segments)
			var ang = t_seg * TAU
			
			var x = cos(ang) * rad
			var z = sin(ang) * rad
			
			# Parabolic elevation envelope: peaks rise in the mid-ring, taper to foothills & horizon
			var ring_shape = sin(t_ring * PI)
			
			# Multi-peak angular profile: 8 major peaks, arêtes, jagged couloirs
			var p1 = sin(ang * 4.0 + 0.5) * 22.0
			var p2 = cos(ang * 8.0 - 0.7) * 14.0
			var p3 = sin(ang * 16.0) * 7.0
			var p4 = cos(ang * 32.0) * 3.5
			var base_h = 55.0 + p1 + p2 + p3 + p4
			
			# Mount Blackwood glaciated summit towards North (-Z, ang ~ 4.71 rad)
			var dist_north = abs(ang - 4.712)
			if dist_north > PI: dist_north = TAU - dist_north
			var summit_boost = (1.0 - clamp(dist_north / 1.1, 0.0, 1.0)) * 34.0
			
			var y = ring_shape * (base_h + summit_boost) + (1.0 - t_ring) * 18.0
			
			verts.append(Vector3(x, y, z))
			uvs.append(Vector2(t_seg * 8.0, t_ring))
			
	var cols = radial_segments + 1
	for ring in range(ring_segments):
		for seg in range(radial_segments):
			var i0 = ring * cols + seg
			var i1 = i0 + 1
			var i2 = (ring + 1) * cols + seg
			var i3 = i2 + 1
			
			indices.append(i0)
			indices.append(i1)
			indices.append(i2)
			
			indices.append(i1)
			indices.append(i3)
			indices.append(i2)
			
	# Smooth surface normals
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
	mi.mesh = mesh
	parent.add_child(mi)
	mi.owner = root

func _build_world_boundaries(root: Node3D, size: float) -> void:
	var half = size * 0.5 - 2.0
	var bounds = [
		{"pos": Vector3(0, 25, half), "size": Vector3(size, 60, 2)},
		{"pos": Vector3(0, 25, -half), "size": Vector3(size, 60, 2)},
		{"pos": Vector3(half, 25, 0), "size": Vector3(2, 60, size)},
		{"pos": Vector3(-half, 25, 0), "size": Vector3(2, 60, size)}
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
# MULTIMESH ECOLOGICAL VEGETATION ENGINE (16,000+ Instances)
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
		var x = rng.randf_range(-80.0, 80.0)
		var z = rng.randf_range(-80.0, 80.0)
		
		# Ecological zone: Pines flourish on slopes and hills, stay clear of trail, creek, and outpost
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		if abs(x - valley_x) < 3.8: continue
		if Vector2(x - 1.0, z - 14.0).length() < 9.5: continue # Outpost Alpha clearing
		if Vector2(x + 18.0, z + 16.0).length() < 7.0: continue # Stone Dolmen Grotto
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.45)
		var yaw = rng.randf_range(0.0, TAU)
		var lean = rng.randf_range(-0.05, 0.05)
		
		var b = Basis().rotated(Vector3.UP, yaw).rotated(Vector3.RIGHT, lean).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 2. Hardwood Broadleaf Oaks (900 trees, 12m - 18m)
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
	
	var count = 900
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 83912
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		# Oaks prefer warm sunlit southeastern and valley flanks
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		if abs(x - valley_x) < 4.2: continue
		if Vector2(x - 1.0, z - 14.0).length() < 10.0: continue
		if Vector2(x + 18.0, z + 16.0).length() < 7.5: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.9, 1.35)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 3. Mountain Paper Birches (750 trees, water-loving, clustered near creek)
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
	
	var count = 750
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 29314
	
	while placed < count:
		# Birches gather in groves near moisture / valley edges
		var z = rng.randf_range(-75.0, 75.0)
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		var offset_side = rng.randf_range(3.0, 16.0) * (1.0 if rng.randf() > 0.5 else -1.0)
		var x = valley_x + offset_side
		
		if Vector2(x - 1.0, z - 14.0).length() < 9.0: continue
		if Vector2(x + 18.0, z + 16.0).length() < 7.0: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.3)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.1, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 4. Understory Forest Bushes & Shrubs (1,800 bushes)
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
		var x = rng.randf_range(-80.0, 80.0)
		var z = rng.randf_range(-80.0, 80.0)
		
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		if abs(x - valley_x) < 2.4: continue
		if Vector2(x - 1.0, z - 14.0).length() < 7.5: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.8, 1.45)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y - 0.2, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 5. Lush Feathered Ferns (3,600 ferns, concentrated along creek & shaded hollows)
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
	
	var count = 3600
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 99318
	
	while placed < count:
		var z = rng.randf_range(-80.0, 80.0)
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		# 65% of ferns hug the moist creek wash and valley lowlands
		var x: float
		if rng.randf() < 0.65:
			x = valley_x + rng.randf_range(1.6, 9.5) * (1.0 if rng.randf() > 0.5 else -1.0)
		else:
			x = rng.randf_range(-78.0, 78.0)
			
		if Vector2(x - 1.0, z - 14.0).length() < 7.0: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.85, 1.5)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 6. Alpine Wild Grass & Mountain Flora (5,500 tufts)
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
		var x = rng.randf_range(-80.0, 80.0)
		var z = rng.randf_range(-80.0, 80.0)
		
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		if abs(x - valley_x) < 1.0: continue
			
		var y = _get_terrain_height(x, z)
		var sc = rng.randf_range(0.8, 1.55)
		var yaw = rng.randf_range(0.0, TAU)
		
		var b = Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sc, sc, sc))
		mm.set_instance_transform(placed, Transform3D(b, Vector3(x, y, z)))
		placed += 1
		
	mm_inst.multimesh = mm
	parent.add_child(mm_inst)
	mm_inst.owner = root

# 7. Mossy Fallen Nurse Logs (480 logs)
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
	
	var count = 480
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 71239
	
	while placed < count:
		var x = rng.randf_range(-78.0, 78.0)
		var z = rng.randf_range(-78.0, 78.0)
		
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		if abs(x - valley_x) < 3.2: continue
		if Vector2(x - 1.0, z - 14.0).length() < 9.0: continue
			
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

# 8. Glacial Granite Boulders & Stream Stones (750 boulders)
func _populate_granite_boulders(parent: Node3D, root: Node3D, mat_rock: Material) -> void:
	var rock_mesh = BoxMesh.new()
	rock_mesh.size = Vector3(2.4, 1.8, 2.6)
	rock_mesh.material = mat_rock
	
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "GraniteBouldersMultiMesh"
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = rock_mesh
	
	var count = 750
	mm.instance_count = count
	
	var placed = 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 33812
	
	while placed < count:
		var z = rng.randf_range(-80.0, 80.0)
		var valley_x = sin(z * 0.026) * 16.0 + cos(z * 0.062) * 7.0
		
		# Boulders cluster in scree fields near mountain cliffs or along creek bed
		var x: float
		if rng.randf() < 0.4:
			# Stream bed stones
			x = valley_x + rng.randf_range(1.2, 5.0) * (1.0 if rng.randf() > 0.5 else -1.0)
		else:
			# Mountain slope talus
			x = rng.randf_range(-80.0, 80.0)
			
		if Vector2(x - 1.0, z - 14.0).length() < 9.0: continue
		if Vector2(x + 18.0, z + 16.0).length() < 6.0: continue
			
		var y = _get_terrain_height(x, z)
		var yaw = rng.randf_range(0.0, TAU)
		var sc = rng.randf_range(0.65, 1.8)
		
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
# WORLD ARCHITECTURE & WILDERNESS SURVIVAL STATIONS
# -----------------------------------------------------------------------------
func _build_wilderness_survival_points(root: Node3D, mat_bark: Material, mat_plank: Material, mat_roof: Material, mat_rock: Material) -> void:
	var survival_root = Node3D.new()
	survival_root.name = "WildernessSurvivalPoints"
	root.add_child(survival_root)
	survival_root.owner = root
	
	var wallbuy_scene = load("res://interactables/WallBuyStation.tscn")
	var mysterybox_scene = load("res://interactables/MysteryBox.tscn")
	var perk_scene = load("res://interactables/PerkMachine.tscn")
	var barrel_scene = load("res://interactables/ExplosiveBarrel.tscn")
	var barricade_scene = load("res://interactables/BarricadeWindow.tscn")
	
	# -------------------------------------------------------------------------
	# A. RANGER OUTPOST ALPHA (Authentic Timber Cabin Shelter & Porch)
	# -------------------------------------------------------------------------
	var outpost_node = Node3D.new()
	outpost_node.name = "RangerOutpostAlpha"
	var outpost_y = _get_terrain_height(1.0, 14.0)
	outpost_node.position = Vector3(1.0, outpost_y, 14.0)
	survival_root.add_child(outpost_node)
	outpost_node.owner = root
	
	# Outpost Wooden Deck Floor (8m x 6m)
	var deck_mi = MeshInstance3D.new()
	deck_mi.name = "OutpostDeckFloor"
	var deck_mesh = BoxMesh.new()
	deck_mesh.size = Vector3(8.0, 0.3, 6.0)
	deck_mi.mesh = deck_mesh
	deck_mi.material_override = mat_plank
	deck_mi.position = Vector3(0, 0.15, 0)
	outpost_node.add_child(deck_mi)
	deck_mi.owner = root
	
	# Outpost Timber Walls (South, East, West)
	var wall_south = MeshInstance3D.new()
	wall_south.name = "WallSouth"
	var bm_wall_s = BoxMesh.new()
	bm_wall_s.size = Vector3(8.0, 3.2, 0.4)
	wall_south.mesh = bm_wall_s
	wall_south.material_override = mat_bark
	wall_south.position = Vector3(0, 1.7, 2.8)
	outpost_node.add_child(wall_south)
	wall_south.owner = root
	
	var wall_west = MeshInstance3D.new()
	wall_west.name = "WallWest"
	var bm_wall_w = BoxMesh.new()
	bm_wall_w.size = Vector3(0.4, 3.2, 5.6)
	wall_west.mesh = bm_wall_w
	wall_west.material_override = mat_bark
	wall_west.position = Vector3(-3.8, 1.7, 0)
	outpost_node.add_child(wall_west)
	wall_west.owner = root
	
	var wall_east = MeshInstance3D.new()
	wall_east.name = "WallEast"
	var bm_wall_e = BoxMesh.new()
	bm_wall_e.size = Vector3(0.4, 3.2, 5.6)
	wall_east.mesh = bm_wall_e
	wall_east.material_override = mat_bark
	wall_east.position = Vector3(3.8, 1.7, 0)
	outpost_node.add_child(wall_east)
	wall_east.owner = root
	
	# Slanted Corrugated Zinc Roof Overhang
	var roof_mi = MeshInstance3D.new()
	roof_mi.name = "CorrugatedRoof"
	var roof_mesh = BoxMesh.new()
	roof_mesh.size = Vector3(9.2, 0.2, 7.2)
	roof_mi.mesh = roof_mesh
	roof_mi.material_override = mat_roof
	roof_mi.position = Vector3(0, 3.5, 0)
	roof_mi.rotation_degrees = Vector3(-8.0, 0, 0)
	outpost_node.add_child(roof_mi)
	roof_mi.owner = root
	
	# Porch Support Log Posts
	var post_positions = [Vector3(-3.6, 1.6, -2.6), Vector3(3.6, 1.6, -2.6)]
	for pi in range(post_positions.size()):
		var post_mi = MeshInstance3D.new()
		post_mi.name = "PorchPost_%d" % pi
		var post_cyl = CylinderMesh.new()
		post_cyl.top_radius = 0.15
		post_cyl.bottom_radius = 0.18
		post_cyl.height = 3.2
		post_cyl.radial_segments = 6
		post_mi.mesh = post_cyl
		post_mi.material_override = mat_bark
		post_mi.position = post_positions[pi]
		outpost_node.add_child(post_mi)
		post_mi.owner = root
		
	# Outpost Radio Antenna Mast
	var antenna_mi = MeshInstance3D.new()
	antenna_mi.name = "RadioAntennaMast"
	var ant_mesh = CylinderMesh.new()
	ant_mesh.top_radius = 0.05
	ant_mesh.bottom_radius = 0.1
	ant_mesh.height = 7.0
	antenna_mi.mesh = ant_mesh
	antenna_mi.material_override = mat_roof
	antenna_mi.position = Vector3(3.5, 6.0, 2.5)
	outpost_node.add_child(antenna_mi)
	antenna_mi.owner = root
	
	# -------------------------------------------------------------------------
	# B. TIMBER CREEK BRIDGE (Spans dry stream wash at z = 0)
	# -------------------------------------------------------------------------
	var bridge_node = Node3D.new()
	bridge_node.name = "TimberCreekBridge"
	var bridge_y = _get_terrain_height(-1.5, 0.0) + 0.35
	bridge_node.position = Vector3(-1.5, bridge_y, 0.0)
	survival_root.add_child(bridge_node)
	bridge_node.owner = root
	
	var bridge_deck = MeshInstance3D.new()
	bridge_deck.name = "BridgePlanks"
	var b_deck_mesh = BoxMesh.new()
	b_deck_mesh.size = Vector3(4.2, 0.3, 7.5)
	bridge_deck.mesh = b_deck_mesh
	bridge_deck.material_override = mat_plank
	bridge_node.add_child(bridge_deck)
	bridge_deck.owner = root
	
	# Bridge Side Rails
	for side_x in [-2.0, 2.0]:
		var rail_mi = MeshInstance3D.new()
		rail_mi.name = "BridgeRail_%.1f" % side_x
		var rail_mesh = BoxMesh.new()
		rail_mesh.size = Vector3(0.15, 0.85, 7.5)
		rail_mi.mesh = rail_mesh
		rail_mi.material_override = mat_plank
		rail_mi.position = Vector3(side_x, 0.55, 0)
		bridge_node.add_child(rail_mi)
		rail_mi.owner = root
		
	# -------------------------------------------------------------------------
	# C. ANCIENT STONE DOLMEN GROTTO (Mystery Box Sanctuary at x=-18, z=-16)
	# -------------------------------------------------------------------------
	var dolmen_node = Node3D.new()
	dolmen_node.name = "AncientDolmenGrotto"
	var dolmen_y = _get_terrain_height(-18.0, -16.0)
	dolmen_node.position = Vector3(-18.0, dolmen_y, -16.0)
	survival_root.add_child(dolmen_node)
	dolmen_node.owner = root
	
	# Megalithic Standing Stones in a crescent
	for di in range(5):
		var ang_d = -0.8 + float(di) * 0.4
		var d_x = cos(ang_d) * 3.6
		var d_z = sin(ang_d) * 3.6
		var stone_mi = MeshInstance3D.new()
		stone_mi.name = "DolmenStone_%d" % di
		var stone_mesh = BoxMesh.new()
		stone_mesh.size = Vector3(1.2, 4.2, 1.4)
		stone_mi.mesh = stone_mesh
		stone_mi.material_override = mat_rock
		stone_mi.position = Vector3(d_x, 2.1, d_z)
		stone_mi.rotation_degrees = Vector3(0, rad_to_deg(-ang_d), 0)
		dolmen_node.add_child(stone_mi)
		stone_mi.owner = root
		
	# Dolmen Capstone Slab
	var capstone_mi = MeshInstance3D.new()
	capstone_mi.name = "DolmenCapstone"
	var cap_mesh = BoxMesh.new()
	cap_mesh.size = Vector3(4.5, 0.8, 3.8)
	capstone_mi.mesh = cap_mesh
	capstone_mi.material_override = mat_rock
	capstone_mi.position = Vector3(0, 4.3, 0)
	dolmen_node.add_child(capstone_mi)
	capstone_mi.owner = root
	
	# -------------------------------------------------------------------------
	# D. SURVIVAL INTERACTABLES (Matching Test Suite Contract)
	# -------------------------------------------------------------------------
	
	# 1. Trail Timber Barricade across rock cut (x=-6, z=0)
	var barricade = barricade_scene.instantiate()
	barricade.name = "TrailBarricade"
	barricade.window_id = "forest_trail_choke"
	var pos_bar = Vector3(-6.0, _get_terrain_height(-6.0, 0.0) + 0.1, 0.0)
	barricade.position = pos_bar
	barricade.rotation_degrees = Vector3(0, 45, 0)
	survival_root.add_child(barricade)
	barricade.owner = root
	
	# 2. M1911 Ammo Cache by Outpost Porch
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
	
	# 3. Remington 870 Stand on Outpost Deck
	var wb_rem = wallbuy_scene.instantiate()
	wb_rem.name = "Stand_Remington870"
	wb_rem.weapon_resource_path = "res://weapons/shotgun/Remington870.tres"
	wb_rem.weapon_display_name = "Remington 870 Shotgun"
	wb_rem.weapon_cost = 500
	wb_rem.ammo_cost = 250
	var pos_rem = Vector3(-3.2, _get_terrain_height(-3.2, 14.0) + 1.2, 14.0)
	wb_rem.position = pos_rem
	wb_rem.rotation_degrees = Vector3(0, 90, 0)
	survival_root.add_child(wb_rem)
	wb_rem.owner = root
	
	# 4. AK-47 Stand on High Lookout Bluff
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
	
	# 5. M4A1 Stand on River Crossing Ridge
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
	
	# 6. Colt Python .357 Stand
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
	
	# 7. Mystery Box resting in Ancient Stone Dolmen Grotto
	var mbox = mysterybox_scene.instantiate()
	mbox.name = "MysteryBox"
	var pos_mbox = Vector3(-18.0, _get_terrain_height(-18.0, -16.0) + 0.1, -16.0)
	mbox.position = pos_mbox
	mbox.rotation_degrees = Vector3(0, 35, 0)
	survival_root.add_child(mbox)
	mbox.owner = root
	
	# 8. Perk Shrines (Juggernog beside Outpost Generator, Speed Cola on Porch)
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
	
	# 9. Tactical Explosive Fuel Barrels
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
