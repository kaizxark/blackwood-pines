extends SceneTree

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
		
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	var level = scene.instantiate()
	root.add_child(level)
	
	var player = level.get_node("Player") as CharacterBody3D
	print("Initial player position: ", player.global_position)
	print("Collision layer: ", player.collision_layer, " mask: ", player.collision_mask)
	print("Floor max angle: ", rad_to_deg(player.floor_max_angle))
	print("Floor snap length: ", player.floor_snap_length)
	
	# Simulate pressing W (move_forward) for 40 frames
	Input.action_press("move_forward")
	
	for frame in range(40):
		player._physics_process(1.0 / 60.0)
		if frame % 10 == 0:
			print("Frame %d: pos=%s vel=%s on_floor=%s slides=%d" % [
				frame,
				player.global_position,
				player.velocity,
				player.is_on_floor(),
				player.get_slide_collision_count()
			])
			for c in range(player.get_slide_collision_count()):
				var col = player.get_slide_collision(c)
				print("   Collision with: %s at %s normal=%s" % [col.get_collider().name, col.get_position(), col.get_normal()])
				
	quit(0)
