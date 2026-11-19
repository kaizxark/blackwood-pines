extends SceneTree

func _init() -> void:
	print("--- GENERATING WALL-BUY STATION SCENE ---")
	var root = StaticBody3D.new()
	root.name = "WallBuyStation"
	root.collision_layer = 8 # Layer 4
	root.collision_mask = 0
	
	var script = load("res://interactables/WallBuyStation.gd")
	root.set_script(script)
	
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var box_col = BoxShape3D.new()
	box_col.size = Vector3(1.5, 0.9, 0.4)
	col.shape = box_col
	root.add_child(col)
	col.owner = root
	
	# Backing plate
	var plate = MeshInstance3D.new()
	plate.name = "BackingPlate"
	var plate_mesh = BoxMesh.new()
	plate_mesh.size = Vector3(1.4, 0.8, 0.05)
	plate.mesh = plate_mesh
	var mat_plate = StandardMaterial3D.new()
	mat_plate.albedo_color = Color(0.12, 0.14, 0.16)
	mat_plate.metallic = 0.8
	mat_plate.roughness = 0.4
	plate.material_override = mat_plate
	root.add_child(plate)
	plate.owner = root
	
	# Chalk Outline
	var chalk = MeshInstance3D.new()
	chalk.name = "ChalkOutline"
	var chalk_mesh = BoxMesh.new()
	chalk_mesh.size = Vector3(1.1, 0.32, 0.02)
	chalk.mesh = chalk_mesh
	var mat_chalk = StandardMaterial3D.new()
	mat_chalk.albedo_color = Color(0.2, 0.85, 1.0)
	mat_chalk.emission_enabled = true
	mat_chalk.emission = Color(0.2, 0.85, 1.0)
	mat_chalk.emission_energy_multiplier = 2.0
	chalk.material_override = mat_chalk
	chalk.position = Vector3(0, 0.08, 0.04)
	root.add_child(chalk)
	chalk.owner = root
	
	# Price Label 3D
	var lbl = Label3D.new()
	lbl.name = "PriceLabel3D"
	lbl.text = "REMINGTON 870\nBUY: 500 PTS | AMMO: 250 PTS"
	lbl.font_size = 26
	lbl.outline_size = 6
	lbl.modulate = Color(1.0, 0.85, 0.2)
	lbl.position = Vector3(0, -0.24, 0.06)
	root.add_child(lbl)
	lbl.owner = root
	
	# Glow Light
	var light = OmniLight3D.new()
	light.name = "GlowLight"
	light.light_color = Color(0.2, 0.85, 1.0)
	light.light_energy = 0.9
	light.omni_range = 3.2
	light.position = Vector3(0, 0, 0.35)
	root.add_child(light)
	light.owner = root
	
	# Pack and Save
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_res = ResourceSaver.save(packed, "res://interactables/WallBuyStation.tscn")
		print("WallBuyStation.tscn saved successfully! OK = ", save_res == OK)
	else:
		printerr("Failed to pack scene: ", pack_res)
		
	quit()
