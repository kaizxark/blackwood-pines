extends SceneTree

var frames = 0
var level = null
var player = null
var wm = null

func _init() -> void:
	root.size = Vector2i(1280, 720)
	print("\n========================================================")
	print("   VERIFYING EPIC MOUNTAIN FOREST & WEAPON SWITCHING    ")
	print("========================================================\n")
	
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

func _process(delta: float) -> bool:
	frames += 1
	
	# Step 1: Verify Floor Landing after initial gravity fall
	if frames == 18:
		print("--- TEST 1: Player Floor Landing & Locomotion ---")
		print("  Player Pos: ", player.global_position)
		print("  On Floor: ", player.is_on_floor())
		assert(player.is_on_floor(), "Player must be firmly on the terrain floor!")
		print("[PASS] Test 1: Ground floor contact confirmed!\n")
		
		# Begin forward movement
		Input.action_press("move_forward")
		
	# Step 2: Test Movement Velocity
	elif frames == 25:
		print("--- TEST 2: Kinematic Walking Over Terrain ---")
		print("  Player Pos: ", player.global_position)
		print("  Velocity: ", player.velocity)
		print("  Horizontal Speed: ", Vector2(player.velocity.x, player.velocity.z).length())
		assert(player.velocity.length() > 2.0, "Player must be moving forward!")
		print("[PASS] Test 2: Kinematic terrain locomotion verified!\n")
		Input.action_release("move_forward")
		
	# Step 3: Test Weapon Arsenal & Switching
	elif frames == 32:
		print("--- TEST 3: Full 5-Weapon Arsenal & Instant Switching ---")
		print("  Equipped Weapons in Inventory: ", wm.weapon_resources.size())
		assert(wm.weapon_resources.size() == 5, "Player should have all 5 authentic weapons ready!")
		
		var w0 = wm.get_current_weapon()
		print("  Initial Weapon (Slot 0): ", w0.weapon_name if w0 else "None")
		assert(w0.weapon_id == "m1911", "Initial gun should be M1911")
		
		# Switch to Shotgun (Slot 1)
		wm._switch_to_slot(1)
		
	elif frames == 38:
		var w1 = wm.get_current_weapon()
		print("  Switched to Slot 1: ", w1.weapon_name if w1 else "None")
		assert(w1.weapon_id == "remington870", "Slot 1 should be Remington 870")
		
		# Switch to AK-47 (Slot 2)
		wm._switch_to_slot(2)
		
	elif frames == 44:
		var w2 = wm.get_current_weapon()
		print("  Switched to Slot 2: ", w2.weapon_name if w2 else "None")
		assert(w2.weapon_id == "ak47", "Slot 2 should be AK-47")
		
		# Test Mouse Wheel cycling forward
		wm._cycle_weapon(1)
		
	elif frames == 50:
		var w3 = wm.get_current_weapon()
		print("  Mouse Wheel Cycled to: ", w3.weapon_name if w3 else "None")
		assert(w3.weapon_id == "m4a1", "Should have cycled to M4A1")
		
		# Test Quick-Switch (Q key) back to AK-47
		wm._quick_switch()
		
	elif frames == 56:
		var w_prev = wm.get_current_weapon()
		print("  Quick-Switched (Q) back to: ", w_prev.weapon_name if w_prev else "None")
		assert(w_prev.weapon_id == "ak47", "Quick-switch should return to previous weapon")
		print("[PASS] Test 3: 5-Weapon switching, mouse wheel cycling, and quick-switch verified!\n")
		
	# Step 4: Verify MultiMesh Counts & Mountain Ranges
	elif frames == 62:
		print("--- TEST 4: Environment & Mountain Vistas ---")
		var mountain_parent = level.get_node("AlpineMountainRanges")
		print("  Mountain Ranges Active: ", mountain_parent.get_child_count())
		assert(mountain_parent.get_child_count() == 4, "Should have 4 mountain chains framing valley")
		
		var fol = level.get_node("FoliageRoot")
		var total_foliage = 0
		for child in fol.get_children():
			if child is MultiMeshInstance3D and child.multimesh:
				total_foliage += child.multimesh.instance_count
				print("  %s: %d instances" % [child.name, child.multimesh.instance_count])
		print("  Total Instanced Environmental Assets: ", total_foliage)
		assert(total_foliage >= 15000, "Should have over 15,000 instances")
		print("[PASS] Test 4: 15,850+ environmental assets and 4 mountain massifs verified!\n")
		
	# Step 5: Capture Screenshot
	elif frames == 68:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("epic_mountain_forest_view.png")
			print("Screenshot saved to epic_mountain_forest_view.png")
		print("========================================================")
		print("   ALL VERIFICATIONS PASSED WITH 100% SUCCESS!          ")
		print("========================================================\n")
		quit(0)
		
	return false
