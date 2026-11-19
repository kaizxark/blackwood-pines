extends SceneTree

func _init() -> void:
	var sb = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	var hms = HeightMapShape3D.new()
	
	var res = 60
	var size = 180.0
	var step = size / float(res)
	var count = res + 1
	
	hms.map_width = count
	hms.map_depth = count
	
	var data = PackedFloat32Array()
	data.resize(count * count)
	
	for z_i in range(count):
		var z = -size * 0.5 + float(z_i) * step
		for x_i in range(count):
			var x = -size * 0.5 + float(x_i) * step
			var h = sin(x * 0.05) * 2.0
			data[z_i * count + x_i] = h
			
	hms.map_data = data
	cs.shape = hms
	cs.scale = Vector3(step, 1.0, step)
	sb.add_child(cs)
	root.add_child(sb)
	
	# Test CharacterBody3D on top of it
	var cb = CharacterBody3D.new()
	var cb_cs = CollisionShape3D.new()
	var cap = CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	cb_cs.shape = cap
	cb_cs.position = Vector3(0, 0.9, 0)
	cb.add_child(cb_cs)
	
	cb.position = Vector3(0, 4.0, 0)
	root.add_child(cb)
	
	print("Stepping physics...")
	for f in range(30):
		cb.velocity.y -= 24.0 * (1.0 / 60.0)
		cb.velocity.z = -5.0 # Walk forward
		cb.move_and_slide()
		if f % 5 == 0:
			print("Frame %d: pos=%s vel=%s on_floor=%s slides=%d" % [f, cb.global_position, cb.velocity, cb.is_on_floor(), cb.get_slide_collision_count()])
			
	quit(0)
