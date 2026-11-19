extends SceneTree

func _init() -> void:
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	var level = scene.instantiate()
	root.add_child(level)
	
	var terrain = level.get_node("ForestTerrain") as StaticBody3D
	var player = level.get_node("Player") as CharacterBody3D
	
	print("Terrain collision_layer: ", terrain.collision_layer)
	print("Player collision_mask: ", player.collision_mask)
	print("Layer match (terrain.layer & player.mask): ", terrain.collision_layer & player.collision_mask)
	
	var t_col = terrain.get_node("TerrainCollision") as CollisionShape3D
	print("t_col exists: ", t_col != null)
	print("t_col disabled: ", t_col.disabled)
	print("t_col shape: ", t_col.shape)
	
	quit(0)
