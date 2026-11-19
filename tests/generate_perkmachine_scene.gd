extends SceneTree

func _init() -> void:
	print("--- GENERATING PERK MACHINE SCENE ---")
	var root = StaticBody3D.new()
	root.name = "PerkMachine"
	root.collision_layer = 8
	root.collision_mask = 0
	
	var script = load("res://interactables/PerkMachine.gd")
	root.set_script(script)
	
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var box_col = BoxShape3D.new()
	box_col.size = Vector3(1.1, 2.2, 0.9)
	col.shape = box_col
	col.position = Vector3(0, 1.1, 0)
	root.add_child(col)
	col.owner = root
	
	# Machine Body
	var body = MeshInstance3D.new()
	body.name = "MachineBody"
	var b_mesh = BoxMesh.new()
	b_mesh.size = Vector3(1.0, 2.1, 0.8)
	body.mesh = b_mesh
	var mat_body = StandardMaterial3D.new()
	mat_body.albedo_color = Color(0.75, 0.08, 0.08)
	mat_body.metallic = 0.5
	mat_body.roughness = 0.35
	body.material_override = mat_body
	body.position = Vector3(0, 1.05, 0)
	root.add_child(body)
	body.owner = root
	
	# Dispenser Slot
	var slot = MeshInstance3D.new()
	slot.name = "VendingDispenser"
	var slot_mesh = BoxMesh.new()
	slot_mesh.size = Vector3(0.7, 0.35, 0.15)
	slot.mesh = slot_mesh
	var mat_slot = StandardMaterial3D.new()
	mat_slot.albedo_color = Color(0.12, 0.12, 0.14)
	mat_slot.metallic = 0.8
	slot.material_override = mat_slot
	slot.position = Vector3(0, 0.3, 0.38)
	root.add_child(slot)
	slot.owner = root
	
	# Title Plate
	var tplate = MeshInstance3D.new()
	tplate.name = "TitlePlate"
	var t_mesh = BoxMesh.new()
	t_mesh.size = Vector3(0.9, 0.35, 0.1)
	tplate.mesh = t_mesh
	var mat_plate = StandardMaterial3D.new()
	mat_plate.albedo_color = Color(0.9, 0.9, 0.9)
	tplate.material_override = mat_plate
	tplate.position = Vector3(0, 1.85, 0.38)
	root.add_child(tplate)
	tplate.owner = root
	
	# Title Label 3D
	var t_lbl = Label3D.new()
	t_lbl.name = "TitleLabel3D"
	t_lbl.text = "JUGGERNOG"
	t_lbl.font_size = 28
	t_lbl.outline_size = 6
	t_lbl.modulate = Color(0.05, 0.05, 0.05)
	t_lbl.position = Vector3(0, 1.85, 0.44)
	root.add_child(t_lbl)
	t_lbl.owner = root
	
	# Prompt Label 3D
	var p_lbl = Label3D.new()
	p_lbl.name = "PromptLabel3D"
	p_lbl.text = "[E] BUY JUGGERNOG\n2500 PTS"
	p_lbl.font_size = 24
	p_lbl.outline_size = 6
	p_lbl.modulate = Color(1.0, 0.85, 0.2)
	p_lbl.position = Vector3(0, 1.15, 0.44)
	root.add_child(p_lbl)
	p_lbl.owner = root
	
	# Machine Light
	var mlight = OmniLight3D.new()
	mlight.name = "MachineLight"
	mlight.light_color = Color(1.0, 0.15, 0.15)
	mlight.light_energy = 1.2
	mlight.omni_range = 4.0
	mlight.position = Vector3(0, 1.4, 0.6)
	root.add_child(mlight)
	mlight.owner = root
	
	# Pack and Save
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_res = ResourceSaver.save(packed, "res://interactables/PerkMachine.tscn")
		print("PerkMachine.tscn saved successfully! OK = ", save_res == OK)
	else:
		printerr("Failed to pack scene: ", pack_res)
		
	quit()
