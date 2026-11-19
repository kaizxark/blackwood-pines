extends SceneTree

var frames: int = 0
var lvl: Node3D

func _init() -> void:
	root.size = Vector2i(1280, 720)
	# Autoloads
	if not root.get_node_or_null("EventBus"):
		var eb_node = Node.new()
		eb_node.name = "EventBus"
		eb_node.set_script(load("res://core/EventBus.gd"))
		root.add_child(eb_node)
		
	if not root.get_node_or_null("SoundManager"):
		var sm_node = Node.new()
		sm_node.name = "SoundManager"
		sm_node.set_script(load("res://core/SoundManager.gd"))
		root.add_child(sm_node)
		
	if not root.get_node_or_null("GameManager"):
		var gm_node = Node.new()
		gm_node.name = "GameManager"
		gm_node.set_script(load("res://core/GameManager.gd"))
		root.add_child(gm_node)

	lvl = load("res://levels/zombie_outbreak/Sector7_Quarantine.tscn").instantiate()
	root.add_child(lvl)

func _process(_delta: float) -> bool:
	frames += 1
	if frames == 20:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("zombie_outbreak_screenshot.png")
			print("Screenshot saved to zombie_outbreak_screenshot.png (size: ", img.get_size(), ")")
		quit()
	return false
