extends SceneTree

func _init() -> void:
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	var level = scene.instantiate()
	var terrain_col = level.get_node("ForestTerrain/TerrainCollision") as CollisionShape3D
	var shape = terrain_col.shape as ConcavePolygonShape3D
	var faces = shape.get_faces()
	print("Total faces in ConcavePolygonShape3D: ", faces.size() / 3)
	
	# Find faces near (0, 14)
	for i in range(0, faces.size(), 3):
		var v0 = faces[i]
		var v1 = faces[i+1]
		var v2 = faces[i+2]
		var center = (v0 + v1 + v2) / 3.0
		if abs(center.x) < 2.0 and abs(center.z - 14.0) < 2.0:
			var n = (v1 - v0).cross(v2 - v0).normalized()
			print("Triangle %d: " % (i/3))
			print("  v0: %s" % v0)
			print("  v1: %s" % v1)
			print("  v2: %s" % v2)
			print("  Normal: %s" % n)
			
	quit(0)
