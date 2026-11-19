extends SceneTree
func _init() -> void:
	var hms = HeightMapShape3D.new()
	print("HeightMapShape3D properties:")
	for prop in hms.get_property_list():
		if prop.name.begins_with("map_"):
			print("  ", prop.name, " type: ", prop.type)
	quit(0)
