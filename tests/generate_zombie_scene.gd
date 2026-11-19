extends SceneTree

func _init() -> void:
	print("--- GENERATING ZOMBIE PACKED SCENE ---")
	var zombie = CharacterBody3D.new()
	zombie.name = "Zombie"
	zombie.collision_layer = 4
	zombie.collision_mask = 7
	
	var script = load("res://entities/enemies/zombie/BaseZombie.gd")
	zombie.set_script(script)
	
	# Collision Shape
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.85
	col.shape = capsule
	col.position = Vector3(0, 0.925, 0)
	zombie.add_child(col)
	col.owner = zombie
	
	# Nav Agent
	var nav = NavigationAgent3D.new()
	nav.name = "NavigationAgent3D"
	zombie.add_child(nav)
	nav.owner = zombie
	
	# Materials
	var mat_flesh = StandardMaterial3D.new()
	mat_flesh.albedo_color = Color(0.28, 0.35, 0.24)
	mat_flesh.roughness = 0.85
	
	var mat_clothes = StandardMaterial3D.new()
	mat_clothes.albedo_color = Color(0.18, 0.22, 0.25)
	mat_clothes.roughness = 0.9
	
	var mat_bone = StandardMaterial3D.new()
	mat_bone.albedo_color = Color(0.85, 0.8, 0.65)
	mat_bone.roughness = 0.4
	
	var mat_blood = StandardMaterial3D.new()
	mat_blood.albedo_color = Color(0.38, 0.03, 0.03)
	mat_blood.roughness = 0.2
	
	var mat_eye = StandardMaterial3D.new()
	mat_eye.albedo_color = Color(1.0, 0.25, 0.05)
	mat_eye.emission_enabled = true
	mat_eye.emission = Color(1.0, 0.25, 0.05)
	mat_eye.emission_energy_multiplier = 3.0
	
	var mat_claw = StandardMaterial3D.new()
	mat_claw.albedo_color = Color(0.12, 0.1, 0.08)
	
	# Visual Root
	var vroot = Node3D.new()
	vroot.name = "VisualRoot"
	zombie.add_child(vroot)
	vroot.owner = zombie
	
	# Torso
	var torso = Node3D.new()
	torso.name = "Torso"
	torso.position = Vector3(0, 0.95, 0)
	vroot.add_child(torso)
	torso.owner = zombie
	
	var chest = MeshInstance3D.new()
	chest.name = "Chest"
	var chest_mesh = BoxMesh.new()
	chest_mesh.size = Vector3(0.52, 0.42, 0.28)
	chest.mesh = chest_mesh
	chest.material_override = mat_clothes
	chest.position = Vector3(0, 0.2, 0)
	torso.add_child(chest)
	chest.owner = zombie
	
	var abdomen = MeshInstance3D.new()
	abdomen.name = "Abdomen"
	var abd_mesh = BoxMesh.new()
	abd_mesh.size = Vector3(0.44, 0.32, 0.24)
	abdomen.mesh = abd_mesh
	abdomen.material_override = mat_flesh
	abdomen.position = Vector3(0, -0.15, 0)
	torso.add_child(abdomen)
	abdomen.owner = zombie
	
	var ribs = MeshInstance3D.new()
	ribs.name = "Ribs"
	var ribs_mesh = BoxMesh.new()
	ribs_mesh.size = Vector3(0.32, 0.20, 0.08)
	ribs.mesh = ribs_mesh
	ribs.material_override = mat_bone
	ribs.position = Vector3(0, 0.05, -0.13)
	torso.add_child(ribs)
	ribs.owner = zombie
	
	# Neck & Blood Fountain
	var neck = Node3D.new()
	neck.name = "Neck"
	neck.position = Vector3(0, 1.4, 0)
	vroot.add_child(neck)
	neck.owner = zombie
	
	var neck_mesh_inst = MeshInstance3D.new()
	neck_mesh_inst.name = "NeckMesh"
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.1
	cyl.bottom_radius = 0.12
	cyl.height = 0.12
	neck_mesh_inst.mesh = cyl
	neck_mesh_inst.material_override = mat_flesh
	neck.add_child(neck_mesh_inst)
	neck_mesh_inst.owner = zombie
	
	var fountain = CPUParticles3D.new()
	fountain.name = "BloodFountain"
	fountain.emitting = false
	fountain.one_shot = false
	fountain.amount = 32
	fountain.lifetime = 0.8
	fountain.direction = Vector3(0, 1, 0)
	fountain.spread = 28.0
	fountain.initial_velocity_min = 3.5
	fountain.initial_velocity_max = 6.0
	fountain.gravity = Vector3(0, -9.8, 0)
	var blood_cube = BoxMesh.new()
	blood_cube.size = Vector3(0.06, 0.06, 0.06)
	fountain.mesh = blood_cube
	fountain.material_override = mat_blood
	neck.add_child(fountain)
	fountain.owner = zombie
	
	# Head
	var head = Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 1.55, 0)
	vroot.add_child(head)
	head.owner = zombie
	
	var head_mesh_inst = MeshInstance3D.new()
	head_mesh_inst.name = "HeadMesh"
	var head_box = BoxMesh.new()
	head_box.size = Vector3(0.32, 0.34, 0.34)
	head_mesh_inst.mesh = head_box
	head_mesh_inst.material_override = mat_flesh
	head.add_child(head_mesh_inst)
	head_mesh_inst.owner = zombie
	
	var jaw = MeshInstance3D.new()
	jaw.name = "Jaw"
	var jaw_box = BoxMesh.new()
	jaw_box.size = Vector3(0.28, 0.12, 0.28)
	jaw.mesh = jaw_box
	jaw.material_override = mat_flesh
	jaw.position = Vector3(0, -0.13, -0.04)
	head.add_child(jaw)
	jaw.owner = zombie
	
	var teeth = MeshInstance3D.new()
	teeth.name = "Teeth"
	var teeth_box = BoxMesh.new()
	teeth_box.size = Vector3(0.24, 0.04, 0.06)
	teeth.mesh = teeth_box
	teeth.material_override = mat_bone
	teeth.position = Vector3(0, -0.07, -0.17)
	head.add_child(teeth)
	teeth.owner = zombie
	
	var left_eye = MeshInstance3D.new()
	left_eye.name = "LeftEye"
	var eye_box = BoxMesh.new()
	eye_box.size = Vector3(0.06, 0.06, 0.04)
	left_eye.mesh = eye_box
	left_eye.material_override = mat_eye
	left_eye.position = Vector3(-0.08, 0.05, -0.17)
	head.add_child(left_eye)
	left_eye.owner = zombie
	
	var right_eye = MeshInstance3D.new()
	right_eye.name = "RightEye"
	right_eye.mesh = eye_box
	right_eye.material_override = mat_eye
	right_eye.position = Vector3(0.08, 0.05, -0.17)
	head.add_child(right_eye)
	right_eye.owner = zombie
	
	var eye_light = OmniLight3D.new()
	eye_light.name = "EyesLight"
	eye_light.light_color = Color(1.0, 0.2, 0.05)
	eye_light.light_energy = 2.4
	eye_light.omni_range = 8.5
	eye_light.position = Vector3(0, 0.05, -0.22)
	head.add_child(eye_light)
	eye_light.owner = zombie
	
	# Left Arm Pivot
	var left_arm = Node3D.new()
	left_arm.name = "LeftArmPivot"
	left_arm.position = Vector3(-0.34, 1.35, 0)
	vroot.add_child(left_arm)
	left_arm.owner = zombie
	
	var l_sh = MeshInstance3D.new()
	l_sh.name = "Shoulder"
	var sh_mesh = BoxMesh.new()
	sh_mesh.size = Vector3(0.16, 0.34, 0.16)
	l_sh.mesh = sh_mesh
	l_sh.material_override = mat_clothes
	l_sh.position = Vector3(0, -0.16, 0)
	left_arm.add_child(l_sh)
	l_sh.owner = zombie
	
	var l_fa = MeshInstance3D.new()
	l_fa.name = "Forearm"
	var fa_mesh = BoxMesh.new()
	fa_mesh.size = Vector3(0.13, 0.36, 0.13)
	l_fa.mesh = fa_mesh
	l_fa.material_override = mat_flesh
	l_fa.position = Vector3(0, -0.48, 0)
	left_arm.add_child(l_fa)
	l_fa.owner = zombie
	
	var l_claw = MeshInstance3D.new()
	l_claw.name = "Claws"
	var claw_mesh = BoxMesh.new()
	claw_mesh.size = Vector3(0.15, 0.14, 0.06)
	l_claw.mesh = claw_mesh
	l_claw.material_override = mat_claw
	l_claw.position = Vector3(0, -0.70, 0)
	left_arm.add_child(l_claw)
	l_claw.owner = zombie
	
	# Right Arm Pivot
	var right_arm = Node3D.new()
	right_arm.name = "RightArmPivot"
	right_arm.position = Vector3(0.34, 1.35, 0)
	vroot.add_child(right_arm)
	right_arm.owner = zombie
	
	var r_sh = MeshInstance3D.new()
	r_sh.name = "Shoulder"
	r_sh.mesh = sh_mesh
	r_sh.material_override = mat_clothes
	r_sh.position = Vector3(0, -0.16, 0)
	right_arm.add_child(r_sh)
	r_sh.owner = zombie
	
	var r_fa = MeshInstance3D.new()
	r_fa.name = "Forearm"
	r_fa.mesh = fa_mesh
	r_fa.material_override = mat_flesh
	r_fa.position = Vector3(0, -0.48, 0)
	right_arm.add_child(r_fa)
	r_fa.owner = zombie
	
	var r_claw = MeshInstance3D.new()
	r_claw.name = "Claws"
	r_claw.mesh = claw_mesh
	r_claw.material_override = mat_claw
	r_claw.position = Vector3(0, -0.70, 0)
	right_arm.add_child(r_claw)
	r_claw.owner = zombie
	
	# Left Leg Pivot
	var left_leg = Node3D.new()
	left_leg.name = "LeftLegPivot"
	left_leg.position = Vector3(-0.16, 0.75, 0)
	vroot.add_child(left_leg)
	left_leg.owner = zombie
	
	var l_thigh = MeshInstance3D.new()
	l_thigh.name = "Thigh"
	var thigh_mesh = BoxMesh.new()
	thigh_mesh.size = Vector3(0.18, 0.40, 0.18)
	l_thigh.mesh = thigh_mesh
	l_thigh.material_override = mat_clothes
	l_thigh.position = Vector3(0, -0.18, 0)
	left_leg.add_child(l_thigh)
	l_thigh.owner = zombie
	
	var l_shin = MeshInstance3D.new()
	l_shin.name = "Shin"
	var shin_mesh = BoxMesh.new()
	shin_mesh.size = Vector3(0.15, 0.40, 0.15)
	l_shin.mesh = shin_mesh
	l_shin.material_override = mat_flesh
	l_shin.position = Vector3(0, -0.54, 0)
	left_leg.add_child(l_shin)
	l_shin.owner = zombie
	
	var l_foot = MeshInstance3D.new()
	l_foot.name = "Foot"
	var foot_mesh = BoxMesh.new()
	foot_mesh.size = Vector3(0.16, 0.10, 0.28)
	l_foot.mesh = foot_mesh
	l_foot.material_override = mat_clothes
	l_foot.position = Vector3(0, -0.72, -0.06)
	left_leg.add_child(l_foot)
	l_foot.owner = zombie
	
	# Right Leg Pivot
	var right_leg = Node3D.new()
	right_leg.name = "RightLegPivot"
	right_leg.position = Vector3(0.16, 0.75, 0)
	vroot.add_child(right_leg)
	right_leg.owner = zombie
	
	var r_thigh = MeshInstance3D.new()
	r_thigh.name = "Thigh"
	r_thigh.mesh = thigh_mesh
	r_thigh.material_override = mat_clothes
	r_thigh.position = Vector3(0, -0.18, 0)
	right_leg.add_child(r_thigh)
	r_thigh.owner = zombie
	
	var r_shin = MeshInstance3D.new()
	r_shin.name = "Shin"
	r_shin.mesh = shin_mesh
	r_shin.material_override = mat_flesh
	r_shin.position = Vector3(0, -0.54, 0)
	right_leg.add_child(r_shin)
	r_shin.owner = zombie
	
	var r_foot = MeshInstance3D.new()
	r_foot.name = "Foot"
	r_foot.mesh = foot_mesh
	r_foot.material_override = mat_clothes
	r_foot.position = Vector3(0, -0.72, -0.06)
	right_leg.add_child(r_foot)
	r_foot.owner = zombie
	
	# Pack and Save
	var packed = PackedScene.new()
	var pack_result = packed.pack(zombie)
	if pack_result == OK:
		var save_result = ResourceSaver.save(packed, "res://entities/enemies/zombie/Zombie.tscn")
		print("Zombie.tscn saved successfully! OK = ", save_result == OK)
	else:
		printerr("Failed to pack scene! Error: ", pack_result)
		
	quit()
