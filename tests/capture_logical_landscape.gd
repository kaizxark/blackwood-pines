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
	
	cam = Camera3D.new()
	cam.current = true
	cam.fov = 85.0
	level.add_child(cam)

func _process(_delta: float) -> bool:
	frames += 1
	
	# Shot 1: Outpost Alpha Log Cabin & Defensive Porch
	if frames == 10:
		cam.global_position = Vector3(1.0, 3.2, 7.5)
		cam.rotation_degrees = Vector3(4.0, 0.0, 0.0) # Looking South at the cabin & porch
		
	elif frames == 12:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("outpost_alpha_cabin_view.png")
			print("[SAVED] outpost_alpha_cabin_view.png")
			
	# Shot 2: Timber Creek Bridge & Stream Wash
	elif frames == 20:
		cam.global_position = Vector3(5.0, 3.8, 4.5)
		cam.rotation_degrees = Vector3(-12.0, -125.0, 0.0) # Looking at the bridge spanning the creek
		
	elif frames == 22:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("creek_bridge_wash_view.png")
			print("[SAVED] creek_bridge_wash_view.png")
			
	# Shot 3: Ancient Dolmen Grotto (Mystery Box Sanctuary)
	elif frames == 30:
		cam.global_position = Vector3(-14.0, 2.5, -12.0)
		cam.rotation_degrees = Vector3(-8.0, -135.0, 0.0) # Looking into the megalithic stone circle
		
	elif frames == 32:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("ancient_dolmen_grotto_view.png")
			print("[SAVED] ancient_dolmen_grotto_view.png")
			
	# Shot 4: Panoramic Alpine Cirque Vista
	elif frames == 40:
		cam.global_position = Vector3(28.0, 18.0, 32.0)
		cam.rotation_degrees = Vector3(-16.0, 140.0, 0.0) # Sweeping panorama across the entire valley & cirque
		
	elif frames == 42:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("alpine_cirque_panorama_view.png")
			print("[SAVED] alpine_cirque_panorama_view.png")
			
	elif frames >= 45:
		quit(0)
		return true
		
	return false
