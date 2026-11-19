extends SceneTree

var frames = 0
var player: CharacterBody3D = null

func _init() -> void:
	if not root.get_node_or_null("EventBus"):
		var eb = Node.new()
		eb.name = "EventBus"
		eb.set_script(load("res://core/EventBus.gd"))
		root.add_child(eb)
		
	if not root.get_node_or_null("SoundManager"):
		var sm = Node.new()
		sm.name = "SoundManager"
		sm.set_script(load("res://core/SoundManager.gd"))
		root.add_child(sm)
		
	if not root.get_node_or_null("GameManager"):
		var gm = Node.new()
		gm.name = "GameManager"
		gm.set_script(load("res://core/GameManager.gd"))
		root.add_child(gm)
		
	# 1. Create Terrain StaticBody3D with HeightMapShape3D
	var sb = StaticBody3D.new()
	sb.name = "TerrainSB"
	sb.collision_layer = 1
	sb.collision_mask = 0
	root.add_child(sb)
	
	var cs = CollisionShape3D.new()
	cs.name = "TerrainCS"
	var hms = HeightMapShape3D.new()
	
	var res = 120
	var size = 180.0
	var step = size / float(res)
	var count = res + 1
	
	hms.map_width = count
	hms.map_depth = count
	
	var data = PackedFloat32Array()
	data.resize(count * count)
	
	# Compute heights matching our formula
	for z_i in range(count):
		var z = -size * 0.5 + float(z_i) * step
		for x_i in range(count):
			var x = -size * 0.5 + float(x_i) * step
			# Rolling hills formula
			var h1 = sin(x * 0.038) * cos(z * 0.034) * 3.4
			var h2 = sin(x * 0.075 + 1.2) * sin(z * 0.068 - 0.7) * 1.6
			data[z_i * count + x_i] = h1 + h2
			
	hms.map_data = data
	cs.shape = hms
	cs.scale = Vector3(step, 1.0, step)
	sb.add_child(cs)
	
	# 2. Add Player
	var p_scene = load("res://entities/player/Player.tscn")
	player = p_scene.instantiate()
	player.position = Vector3(0, 1.0, 14.0)
	root.add_child(player)

func _process(delta: float) -> bool:
	frames += 1
	
	# Simulate pressing W to move forward
	Input.action_press("move_forward")
	
	if frames >= 15 and frames <= 30:
		print("Frame %2d: pos=%s vel=%s on_floor=%s slides=%d" % [
			frames, player.global_position, player.velocity, player.is_on_floor(), player.get_slide_collision_count()
		])
		if player.get_slide_collision_count() > 0:
			var col = player.get_slide_collision(0)
			print("   Floor col: normal=%s at %s" % [col.get_normal(), col.get_position()])
			
	if frames == 30:
		assert(player.is_on_floor(), "Player MUST be on floor!")
		assert(player.velocity.length() > 1.0, "Player MUST be moving!")
		print("\n>>> TEST PASSED: HeightMapShape3D locomotion is FLAWLESS! <<<\n")
		quit(0)
		
	return false
