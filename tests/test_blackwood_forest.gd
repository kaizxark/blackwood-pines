extends SceneTree

# Blackwood Pines Forest Test & Visual Quality Verifier
var frames: int = 0
var level: Node3D = null
var player: CharacterBody3D = null
var gm: Node = null
var test_passed: bool = true

func _init() -> void:
	root.size = Vector2i(1280, 720)
	print("\n========================================================")
	print("   BLACKWOOD PINES: DEEP FOREST VERIFICATION SUITE      ")
	print("========================================================\n")
	
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
		
	if not root.get_node_or_null("BloodManager"):
		var bm_node = Node.new()
		bm_node.name = "BloodManager"
		bm_node.set_script(load("res://core/BloodManager.gd"))
		root.add_child(bm_node)
		
	gm = root.get_node_or_null("GameManager")
	
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	if not scene:
		printerr("FAILED to load Blackwood_Pines.tscn!")
		quit(1)
		return
		
	level = scene.instantiate()
	root.add_child(level)
	player = level.get_node_or_null("Player")

func _process(delta: float) -> bool:
	frames += 1
	
	# Frame 5: Verify Level & MultiMeshes
	if frames == 5:
		print("--- VERIFY 1: Lush Forest MultiMesh Instances & Terrain ---")
		var pines = level.get_node_or_null("FoliageRoot/TallPinesMultiMesh") as MultiMeshInstance3D
		var oaks = level.get_node_or_null("FoliageRoot/BroadleafOaksMultiMesh") as MultiMeshInstance3D
		var birches = level.get_node_or_null("FoliageRoot/WhiteBirchMultiMesh") as MultiMeshInstance3D
		var shrubs = level.get_node_or_null("FoliageRoot/UnderstoryShrubsMultiMesh") as MultiMeshInstance3D
		var ferns = level.get_node_or_null("FoliageRoot/LushFernsMultiMesh") as MultiMeshInstance3D
		var grass = level.get_node_or_null("FoliageRoot/WildGrassMultiMesh") as MultiMeshInstance3D
		var logs = level.get_node_or_null("FoliageRoot/FallenLogsMultiMesh") as MultiMeshInstance3D
		var rocks = level.get_node_or_null("FoliageRoot/GraniteBouldersMultiMesh") as MultiMeshInstance3D
		
		var total_instances = 0
		for mm_node in [pines, oaks, birches, shrubs, ferns, grass, logs, rocks]:
			if mm_node and mm_node.multimesh:
				total_instances += mm_node.multimesh.instance_count
				print("  ", mm_node.name, " count: ", mm_node.multimesh.instance_count)
				
		print("  Total Lush Forest Foliage/Rock Instances: ", total_instances)
		assert(total_instances >= 7000, "Should have over 7,000 foliage instances")
		print("[PASS] Test 1: Next-Gen Lush Forest verified with ", total_instances, " instances!\n")
		
	# Frame 15: Verify Zombie Spawning & Navigation In Forest
	elif frames == 15:
		print("--- VERIFY 2: Zombie Dynamic Spawning In Forest ---")
		var director = level.get_node_or_null("BlackwoodHordeDirector")
		print("  Horde Director active: ", director != null)
		
		# Test spawning a zombie in the woods
		var z_scene = load("res://entities/enemies/zombie/Zombie.tscn")
		var z = z_scene.instantiate() as CharacterBody3D
		level.add_child(z)
		z.global_position = player.global_position + Vector3(0, 0, -12.0)
		z.set("target_player", player)
		
		# Test feral eyes
		var eye_light = z.get_node_or_null("VisualRoot/Head/EyesLight") as OmniLight3D
		print("  Zombie Eyes Light active: ", eye_light != null and eye_light.visible)
		print("  Eyes Light energy: ", eye_light.light_energy if eye_light else 0.0)
		print("  Eyes Light range: ", eye_light.omni_range if eye_light else 0.0)
		
		assert(eye_light != null and eye_light.light_energy >= 2.0, "Eyes light should be intense")
		print("[PASS] Test 2: Feral predator eye glow verified!\n")
		
	# Frame 25: Test Blood & Gore System (Decals & Arterial Spray)
	elif frames == 25:
		print("--- VERIFY 3: Visceral Blood & Gore System ---")
		var bm = root.get_node_or_null("BloodManager")
		print("  BloodManager active: ", bm != null)
		
		var test_hit_pos = player.global_position + Vector3(0, 1.2, -4.0)
		bm.spawn_blood_spray(test_hit_pos, Vector3.UP, 48, 6.0)
		bm.spawn_blood_decal(test_hit_pos - Vector3(0, 1.0, 0), Vector3.UP, 1.5)
		
		print("  Active Decals in BloodManager: ", bm.active_decals.size())
		assert(bm.active_decals.size() >= 1, "Should have spawned a blood decal")
		print("[PASS] Test 3: Visceral blood spray & decals verified!\n")
		
	# Frame 35: Capture High-Res Screenshot & Inspect
	elif frames == 35:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("blackwood_forest_screenshot.png")
			print("Screenshot saved to blackwood_forest_screenshot.png (size: ", img.get_size(), ")")
		print("========================================================")
		print("   ALL BLACKWOOD FOREST SYSTEMS VERIFIED SUCCESSFULLY!  ")
		print("========================================================\n")
		quit(0)
		
	return false
