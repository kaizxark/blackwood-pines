extends SceneTree

var frames: int = 0
var level: Node3D = null
var cam: Camera3D = null
var player: CharacterBody3D = null
var wm = null

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
	player = level.get_node("Player") as CharacterBody3D
	wm = player.get_node("CameraPivot/WeaponHolder/WeaponManager")
	
	cam = Camera3D.new()
	cam.current = true
	cam.fov = 85.0
	level.add_child(cam)

func _process(_delta: float) -> bool:
	frames += 1
	
	# Shot 1: Alpine Mountain Panorama (looking North at the majestic jagged mountain chain)
	if frames == 10:
		cam.global_position = Vector3(0.0, 6.0, 10.0)
		cam.rotation_degrees = Vector3(12.0, 180.0, 0.0) # Angle up toward the peaks
		
	elif frames == 12:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("alpine_mountains_panorama.png")
			print("[SAVED] alpine_mountains_panorama.png")
			
	# Shot 2: Deep Forest Undergrowth (dense ferns, mossy logs, oaks, pines, godrays)
	elif frames == 20:
		cam.global_position = Vector3(-12.0, 2.2, -10.0)
		cam.rotation_degrees = Vector3(-4.0, 48.0, 0.0)
		
	elif frames == 22:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("lush_forest_undergrowth.png")
			print("[SAVED] lush_forest_undergrowth.png")
			
	# Shot 3: Weapon in hand on the trail
	elif frames == 30:
		wm._switch_to_slot(2) # Switch to AK-47
		# Use player's own first-person camera
		cam.current = false
		var p_cam = player.get_node("CameraPivot/Camera3D") as Camera3D
		p_cam.current = true
		
	elif frames == 34:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("weapon_ready_trail.png")
			print("[SAVED] weapon_ready_trail.png")
			quit(0)
			
	return false
