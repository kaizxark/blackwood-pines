extends SceneTree

var frames = 0
var level = null
var player = null

func _init() -> void:
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
		
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	level = scene.instantiate()
	root.add_child(level)
	player = level.get_node("Player") as CharacterBody3D

func _process(delta: float) -> bool:
	frames += 1
	if frames == 2:
		print("Frame 2: Player ready! Pos = ", player.global_position)
		print("Simulating W key (move_forward)...")
		Input.action_press("move_forward")
		
	elif frames > 2 and frames <= 20:
		print("Frame %d: pos=%s vel=%s on_floor=%s" % [frames, player.global_position, player.velocity, player.is_on_floor()])
		for c in range(player.get_slide_collision_count()):
			var col = player.get_slide_collision(c)
			print("   Collision with %s at %s normal=%s" % [col.get_collider().name, col.get_position(), col.get_normal()])
			
	elif frames == 21:
		quit(0)
		
	return false
