extends SceneTree

func _init() -> void:
	print("--- GENERATING MYSTERY BOX SCENE ---")
	var root = StaticBody3D.new()
	root.name = "MysteryBox"
	root.collision_layer = 8
	root.collision_mask = 0
	
	var script = load("res://interactables/MysteryBox.gd")
	root.set_script(script)
	
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var box_col = BoxShape3D.new()
	box_col.size = Vector3(1.8, 1.0, 1.0)
	col.shape = box_col
	col.position = Vector3(0, 0.5, 0)
	root.add_child(col)
	col.owner = root
	
	# Materials
	var mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.28, 0.18, 0.12)
	mat_wood.roughness = 0.75
	
	var mat_brass = StandardMaterial3D.new()
	mat_brass.albedo_color = Color(0.85, 0.68, 0.22)
	mat_brass.metallic = 0.85
	mat_brass.roughness = 0.3
	
	# Base Crate
	var base_crate = MeshInstance3D.new()
	base_crate.name = "BaseCrate"
	var crate_mesh = BoxMesh.new()
	crate_mesh.size = Vector3(1.7, 0.6, 0.9)
	base_crate.mesh = crate_mesh
	base_crate.material_override = mat_wood
	base_crate.position = Vector3(0, 0.3, 0)
	root.add_child(base_crate)
	base_crate.owner = root
	
	# Brass Straps
	var strap = MeshInstance3D.new()
	strap.name = "Strap"
	var strap_mesh = BoxMesh.new()
	strap_mesh.size = Vector3(1.72, 0.62, 0.08)
	strap.mesh = strap_mesh
	strap.material_override = mat_brass
	strap.position = Vector3(0, 0.3, 0)
	root.add_child(strap)
	strap.owner = root
	
	# Lid Pivot
	var lid_pivot = Node3D.new()
	lid_pivot.name = "LidPivot"
	lid_pivot.position = Vector3(0, 0.6, -0.45)
	root.add_child(lid_pivot)
	lid_pivot.owner = root
	
	var lid_mesh_inst = MeshInstance3D.new()
	lid_mesh_inst.name = "LidMesh"
	var lid_mesh = BoxMesh.new()
	lid_mesh.size = Vector3(1.72, 0.16, 0.92)
	lid_mesh_inst.mesh = lid_mesh
	lid_mesh_inst.material_override = mat_wood
	lid_mesh_inst.position = Vector3(0, 0.08, 0.45)
	lid_pivot.add_child(lid_mesh_inst)
	lid_mesh_inst.owner = root
	
	# Weapon Display Root
	var disp_root = Node3D.new()
	disp_root.name = "WeaponDisplayRoot"
	disp_root.position = Vector3(0, 0.2, 0)
	disp_root.visible = false
	root.add_child(disp_root)
	disp_root.owner = root
	
	var disp_gun = MeshInstance3D.new()
	disp_gun.name = "DisplayGun"
	var gun_mesh = BoxMesh.new()
	gun_mesh.size = Vector3(0.12, 0.24, 0.8)
	disp_gun.mesh = gun_mesh
	disp_gun.material_override = mat_brass
	disp_gun.position = Vector3(0, 0.1, 0)
	disp_root.add_child(disp_gun)
	disp_gun.owner = root
	
	# Chest Light
	var clight = OmniLight3D.new()
	clight.name = "ChestLight"
	clight.light_color = Color(0.3, 0.85, 1.0)
	clight.light_energy = 0.6
	clight.omni_range = 4.0
	clight.position = Vector3(0, 0.65, 0)
	root.add_child(clight)
	clight.owner = root
	
	# Question Marks Label
	var q_lbl = Label3D.new()
	q_lbl.name = "QuestionMarksLabel"
	q_lbl.text = "?  ?  ?"
	q_lbl.font_size = 48
	q_lbl.outline_size = 8
	q_lbl.modulate = Color(0.3, 0.85, 1.0)
	q_lbl.position = Vector3(0, 0.35, 0.47)
	root.add_child(q_lbl)
	q_lbl.owner = root
	
	# Prompt Label 3D
	var p_lbl = Label3D.new()
	p_lbl.name = "PromptLabel3D"
	p_lbl.text = "MYSTERY BOX\n[E] 950 PTS"
	p_lbl.font_size = 28
	p_lbl.outline_size = 6
	p_lbl.modulate = Color(1.0, 0.85, 0.2)
	p_lbl.position = Vector3(0, 1.25, 0)
	root.add_child(p_lbl)
	p_lbl.owner = root
	
	# Pack and Save
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_res = ResourceSaver.save(packed, "res://interactables/MysteryBox.tscn")
		print("MysteryBox.tscn saved successfully! OK = ", save_res == OK)
	else:
		printerr("Failed to pack scene: ", pack_res)
		
	quit()
