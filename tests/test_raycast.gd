extends SceneTree

func _init() -> void:
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	var level = scene.instantiate()
	root.add_child(level)
	
	var space = level.get_world_3d().direct_space_state
	var q = PhysicsRayQueryParameters3D.create(Vector3(0, 5, 14), Vector3(0, -5, 14), 1)
	var hit = space.intersect_ray(q)
	print("Raycast hit: ", hit)
	quit(0)
