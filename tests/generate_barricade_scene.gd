extends SceneTree

func _init() -> void:
	print("--- GENERATING BARRICADE WINDOW SCENE ---")
	var root = StaticBody3D.new()
	root.name = "BarricadeWindow"
	root.collision_layer = 1 | 8
	root.collision_mask = 0
	
	var script = load("res://interactables/BarricadeWindow.gd")
	root.set_script(script)
	
	# Barrier collision
	var b_col = CollisionShape3D.new()
	b_col.name = "BarrierCollision"
	var b_box = BoxShape3D.new()
	b_box.size = Vector3(1.8, 2.2, 0.4)
	b_col.shape = b_box
	b_col.position = Vector3(0, 1.1, 0)
	root.add_child(b_col)
	b_col.owner = root
	
	# Materials
	var mat_frame = StandardMaterial3D.new()
	mat_frame.albedo_color = Color(0.22, 0.23, 0.25)
	mat_frame.metallic = 0.6
	mat_frame.roughness = 0.6
	
	var mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.45, 0.28, 0.14)
	mat_wood.roughness = 0.88
	
	# Frame
	var frame = Node3D.new()
	frame.name = "Frame"
	root.add_child(frame)
	frame.owner = root
	
	var l_post = MeshInstance3D.new()
	l_post.name = "LeftPost"
	var post_mesh = BoxMesh.new()
	post_mesh.size = Vector3(0.18, 2.2, 0.35)
	l_post.mesh = post_mesh
	l_post.material_override = mat_frame
	l_post.position = Vector3(-0.85, 1.1, 0)
	frame.add_child(l_post)
	l_post.owner = root
	
	var r_post = MeshInstance3D.new()
	r_post.name = "RightPost"
	r_post.mesh = post_mesh
	r_post.material_override = mat_frame
	r_post.position = Vector3(0.85, 1.1, 0)
	frame.add_child(r_post)
	r_post.owner = root
	
	var header = MeshInstance3D.new()
	header.name = "Header"
	var hdr_mesh = BoxMesh.new()
	hdr_mesh.size = Vector3(1.88, 0.22, 0.35)
	header.mesh = hdr_mesh
	header.material_override = mat_frame
	header.position = Vector3(0, 2.1, 0)
	frame.add_child(header)
	header.owner = root
	
	var sill = MeshInstance3D.new()
	sill.name = "Sill"
	var sill_mesh = BoxMesh.new()
	sill_mesh.size = Vector3(1.88, 0.22, 0.40)
	sill.mesh = sill_mesh
	sill.material_override = mat_frame
	sill.position = Vector3(0, 0.1, 0)
	frame.add_child(sill)
	sill.owner = root
	
	# Planks Container
	var p_cont = Node3D.new()
	p_cont.name = "PlanksContainer"
	root.add_child(p_cont)
	p_cont.owner = root
	
	var plank_mesh = BoxMesh.new()
	plank_mesh.size = Vector3(1.68, 0.24, 0.07)
	
	var plank_configs = [
		{"y": 0.42, "rot": 0.04, "z": 0.04},
		{"y": 0.76, "rot": -0.06, "z": -0.03},
		{"y": 1.10, "rot": 0.03, "z": 0.05},
		{"y": 1.44, "rot": -0.05, "z": -0.02},
		{"y": 1.78, "rot": 0.02, "z": 0.04}
	]
	
	for i in range(plank_configs.size()):
		var p_inst = MeshInstance3D.new()
		p_inst.name = "Plank_%d" % (i + 1)
		p_inst.mesh = plank_mesh
		p_inst.material_override = mat_wood
		p_inst.position = Vector3(0, plank_configs[i]["y"], plank_configs[i]["z"])
		p_inst.rotation.z = plank_configs[i]["rot"]
		p_cont.add_child(p_inst)
		p_inst.owner = root
		
	# Zombie Tear Area
	var z_area = Area3D.new()
	z_area.name = "ZombieTearArea"
	z_area.collision_layer = 0
	z_area.collision_mask = 4 # Detect zombies (layer 3)
	root.add_child(z_area)
	z_area.owner = root
	
	var z_col = CollisionShape3D.new()
	z_col.name = "AreaCollision"
	var z_box = BoxShape3D.new()
	z_box.size = Vector3(1.9, 2.2, 1.8)
	z_col.shape = z_box
	z_col.position = Vector3(0, 1.1, -0.9)
	z_area.add_child(z_col)
	z_col.owner = root
	
	# Markers
	var m_out = Marker3D.new()
	m_out.name = "OutsideMarker"
	m_out.position = Vector3(0, 0, -1.6)
	root.add_child(m_out)
	m_out.owner = root
	
	var m_in = Marker3D.new()
	m_in.name = "InsideMarker"
	m_in.position = Vector3(0, 0, 1.4)
	root.add_child(m_in)
	m_in.owner = root
	
	# Save
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_res = ResourceSaver.save(packed, "res://interactables/BarricadeWindow.tscn")
		print("BarricadeWindow.tscn saved successfully! OK = ", save_res == OK)
	else:
		printerr("Failed to pack scene: ", pack_res)
		
	quit()
