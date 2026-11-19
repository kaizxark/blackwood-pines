extends SceneTree

var frames: int = 0
var level: Node3D = null
var cam: Camera3D = null

func _init() -> void:
	root.size = Vector2i(1280, 720)
	
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
		
	if not root.get_node_or_null("BloodManager"):
		var bm = Node.new()
		bm.name = "BloodManager"
		bm.set_script(load("res://core/BloodManager.gd"))
		root.add_child(bm)
		
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	level = scene.instantiate()
	root.add_child(level)
	
	# Add custom test camera so we can position and frame cinematic shots
	cam = Camera3D.new()
	cam.current = true
	cam.fov = 85.0
	level.add_child(cam)

func _process(_delta: float) -> bool:
	frames += 1
	
	# Shot 1: Trail View from Player Spawn Point
	if frames == 10:
		cam.global_position = Vector3(0.0, 1.6, 14.0)
		cam.rotation_degrees = Vector3(-6.0, 180.0, 0.0) # Look North down the path
		
	elif frames == 12:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("forest_trail_view.png")
			print("[SAVED] forest_trail_view.png")
			
	# Shot 2: High Angle Ridge View overlooking canopy & rolling hills
	elif frames == 20:
		cam.global_position = Vector3(25.0, 14.0, 32.0)
		cam.rotation_degrees = Vector3(-20.0, 150.0, 0.0)
		
	elif frames == 22:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("forest_canopy_ridge_view.png")
			print("[SAVED] forest_canopy_ridge_view.png")
			
	# Shot 3: Sunlit Glade & God-rays View
	elif frames == 30:
		cam.global_position = Vector3(-10.0, 2.5, -12.0)
		cam.rotation_degrees = Vector3(12.0, 42.0, 0.0) # Looking toward the morning sun and god-rays
		
	elif frames == 32:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("forest_grove_godrays_view.png")
			print("[SAVED] forest_grove_godrays_view.png")
			quit(0)
			
	return false
