extends SceneTree

func _init() -> void:
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	var level = scene.instantiate()
	root.add_child(level)
	
	var player = level.get_node("Player") as CharacterBody3D
	# Drop from 2 meters above terrain
	player.global_position = Vector3(0, 3.0, 14)
	player.velocity = Vector3.ZERO
	
	print("Starting drop test from y=3.0...")
	for f in range(60):
		player._physics_process(1.0 / 60.0)
		print("Frame %2d: pos.y=%.4f  vel.y=%.4f  on_floor=%s  slides=%d" % [
			f, player.global_position.y, player.velocity.y, player.is_on_floor(), player.get_slide_collision_count()
		])
		if player.is_on_floor():
			print("LANDED ON FLOOR AT FRAME %d! pos=%s" % [f, player.global_position])
			break
			
	quit(0)
