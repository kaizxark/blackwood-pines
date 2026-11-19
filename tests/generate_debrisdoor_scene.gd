extends SceneTree

func _init() -> void:
	print("--- GENERATING DEBRIS DOOR SCENE ---")
	var root = StaticBody3D.new()
	root.name = "DebrisDoor"
	root.collision_layer = 1 | 8
	root.collision_mask = 0
	
	var script = load("res://interactables/DebrisDoor.gd")
	root.set_script(script)
	
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var box_col = BoxShape3D.new()
	box_col.size = Vector3(3.2, 3.2, 0.4)
	col.shape = box_col
	col.position = Vector3(0, 1.6, 0)
	root.add_child(col)
	col.owner = root
	
	# Door Mesh
	var dmesh = MeshInstance3D.new()
	dmesh.name = "DoorMesh"
	var bmesh = BoxMesh.new()
	bmesh.size = Vector3(3.2, 3.2, 0.3)
	dmesh.mesh = bmesh
	var mat_door = StandardMaterial3D.new()
	mat_door.albedo_color = Color(0.2, 0.22, 0.24)
	mat_door.metallic = 0.8
	mat_door.roughness = 0.4
	dmesh.material_override = mat_door
	dmesh.position = Vector3(0, 1.6, 0)
	root.add_child(dmesh)
	dmesh.owner = root
	
	# Prompt Label
	var lbl = Label3D.new()
	lbl.name = "PromptLabel3D"
	lbl.text = "[E] CLEAR DEBRIS / OPEN DOOR\n750 PTS"
	lbl.font_size = 28
	lbl.outline_size = 6
	lbl.modulate = Color(1.0, 0.85, 0.2)
	lbl.position = Vector3(0, 1.6, 0.22)
	root.add_child(lbl)
	lbl.owner = root
	
	# Save
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_res = ResourceSaver.save(packed, "res://interactables/DebrisDoor.tscn")
		print("DebrisDoor.tscn saved successfully! OK = ", save_res == OK)
	quit()
