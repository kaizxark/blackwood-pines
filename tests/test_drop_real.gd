extends SceneTree

var frames = 0
var level = null
var player = null

func _init() -> void:
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	level = scene.instantiate()
	root.add_child(level)
	player = level.get_node("Player") as CharacterBody3D

func _process(delta: float) -> bool:
	frames += 1
	if frames == 2:
		# Player at 0.8m above ground (terrain is at 0.11, so y = 1.0)
		player.global_position = Vector3(0, 1.2, 14.0)
		player.velocity = Vector3.ZERO
		print("Frame 2: Set player to y=1.2 (bottom of capsule at y=0.3)")
		
	elif frames > 2 and frames <= 55:
		print("Frame %2d: pos.y=%.4f  vel.y=%.4f  on_floor=%s  slides=%d" % [
			frames, player.global_position.y, player.velocity.y, player.is_on_floor(), player.get_slide_collision_count()
		])
		if player.get_slide_collision_count() > 0:
			for c in range(player.get_slide_collision_count()):
				var col = player.get_slide_collision(c)
				print("   Collision with %s at pos=%s normal=%s" % [col.get_collider().name, col.get_position(), col.get_normal()])
		if player.is_on_floor():
			print(">>> SUCCESS: PLAYER IS ON FLOOR at pos=%s! Testing horizontal move..." % player.global_position)
			Input.action_press("move_forward")
			
	elif frames > 55 and frames <= 70:
		print("Walk Frame %2d: pos=%s vel=%s on_floor=%s" % [
			frames, player.global_position, player.velocity, player.is_on_floor()
		])
		if frames == 70:
			quit(0)
			
	return false
