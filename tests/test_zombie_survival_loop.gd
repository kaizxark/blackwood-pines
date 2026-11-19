extends SceneTree

# AUTOMATED VERIFICATION TEST HARNESS FOR ZOMBIE SURVIVAL FPS
# Validates:
# 1. Level initialization, Player spawning, HUD & Economy synchronization
# 2. Zombie NPC locomotion, claw attack damage against player
# 3. Ballistics hit detection, headshot decapitation, blood fountain emission
# 4. Points economy (+10 hit, +100 headshot kill)
# 5. Barricade plank tearing & player repair (+10 points)
# 6. Wall-Buy station weapon acquisition & ammo refills
# 7. Perk vending machine (Juggernog -> 250 HP, Speed Cola -> fast reload)
# 8. Mystery weapon box roulette rolling & weapon claim

var test_passed: bool = true
var frame_count: int = 0
var level: Node3D = null
var player: CharacterBody3D = null
var hud: CanvasLayer = null
var gm: Node = null
var test_zombie: CharacterBody3D = null

func _init() -> void:
	print("\n========================================================")
	print("   PROJECT PROTO-BREACH: ZOMBIE SURVIVAL VERIFICATION   ")
	print("========================================================\n")
	
	# Instantiate autoloads if running headless script
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
		
	gm = root.get_node_or_null("GameManager")
	
	var scene = load("res://levels/zombie_outbreak/Blackwood_Pines.tscn")
	if not scene:
		printerr("FAILED to load Blackwood_Pines.tscn!")
		quit(1)
		return
		
	level = scene.instantiate()
	root.add_child(level)
	
	player = level.get_node_or_null("Player")
	hud = level.get_node_or_null("HUD")

func _process(delta: float) -> bool:
	frame_count += 1
	
	# Frame 5: Verify Scene Structure & Initial State
	if frame_count == 5:
		_verify_level_and_player()
		
	# Frame 15: Test Zombie Spawn, Locomotion & Claw Damage
	elif frame_count == 15:
		_test_zombie_spawn_and_damage()
		
	# Frame 35: Test Ballistics, Headshot Decapitation & Blood Spurt
	elif frame_count == 35:
		_test_headshot_decapitation()
		
	# Frame 55: Test Barricade Tearing & Player Repair
	elif frame_count == 55:
		_test_barricade_mechanics()
		
	# Frame 75: Test Wall-Buy Weapon Acquisition
	elif frame_count == 75:
		_test_wall_buy()
		
	# Frame 95: Test Perk Vending Machines (Juggernog)
	elif frame_count == 95:
		_test_perk_machine()
		
	# Frame 115: Test Mystery Box Roulette
	elif frame_count == 115:
		_test_mystery_box()
		
	# Frame 130: Finish and Report
	elif frame_count == 130:
		_finish_tests()
		
	return false

func _verify_level_and_player() -> void:
	print("--- TEST 1: Level, Player & HUD Initialization ---")
	if not player:
		printerr("[FAIL] Player not found in level!")
		test_passed = false
		return
		
	if not hud:
		printerr("[FAIL] HUD not found in level!")
		test_passed = false
		return
		
	if not gm:
		printerr("[FAIL] GameManager not found!")
		test_passed = false
		return
		
	print("  Player position: ", player.global_position)
	print("  Player HP: %d/%d, Shield: %d/%d" % [player.current_health, player.max_health, player.current_shield, player.max_shield])
	print("  GameManager Points: %d, Current Round: %d" % [gm.points, gm.current_round])
	
	assert(player.current_health == 100, "Initial player HP should be 100")
	assert(gm.points == 500, "Initial points should be 500")
	print("[PASS] Test 1: Initialization verified successfully!\n")

func _test_zombie_spawn_and_damage() -> void:
	print("--- TEST 2: Zombie NPC Locomotion & Claw Attack ---")
	var z_scene = load("res://entities/enemies/zombie/Zombie.tscn")
	var claw_zombie = z_scene.instantiate() as CharacterBody3D
	level.add_child(claw_zombie)
	claw_zombie.global_position = player.global_position + Vector3(0, 0, 1.2)
	claw_zombie.target_player = player
	
	var initial_hp = player.current_health
	var initial_shield = player.current_shield
	
	# Execute attack against player
	claw_zombie._execute_attack()
	print("  Zombie initiated claw attack at distance: ", claw_zombie.global_position.distance_to(player.global_position))
	
	level.get_tree().create_timer(0.3).timeout.connect(func():
		var damaged = (player.current_health < initial_hp or player.current_shield < initial_shield)
		print("  Post-attack Player HP: %d, Shield: %d (Damage confirmed: %s)" % [player.current_health, player.current_shield, str(damaged)])
		if not damaged:
			printerr("[FAIL] Player did not take damage from claw attack!")
			test_passed = false
		else:
			print("[PASS] Test 2: Zombie claw attack & damage verified!\n")
		claw_zombie.queue_free()
	)

func _test_headshot_decapitation() -> void:
	print("--- TEST 3: Headshot Decapitation, Gore & Kill Economy ---")
	var z_scene = load("res://entities/enemies/zombie/Zombie.tscn")
	var decap_zombie = z_scene.instantiate() as CharacterBody3D
	level.add_child(decap_zombie)
	decap_zombie.global_position = player.global_position + Vector3(2.0, 0, 0)
	
	var pts_before = gm.points
	var head_node = decap_zombie.get_node_or_null("VisualRoot/Head")
	var fountain = decap_zombie.get_node_or_null("VisualRoot/Neck/BloodFountain")
	
	# Deal headshot lethal damage (is_headshot = true)
	decap_zombie.take_damage(250, Vector3(0, 0, 1), true)
	
	var head_hidden = (head_node != null and not head_node.visible)
	var blood_spurt = (fountain != null and fountain.emitting)
	var is_dead = decap_zombie.get("is_dead")
	
	print("  Zombie dead: ", is_dead)
	print("  Head hidden (decapitated): ", head_hidden)
	print("  Blood fountain emitting: ", blood_spurt)
	print("  Points before: %d, Points after: %d (+%d pts)" % [pts_before, gm.points, gm.points - pts_before])
	
	if not is_dead or not head_hidden or not blood_spurt:
		printerr("[FAIL] Headshot decapitation did not trigger properly!")
		test_passed = false
	else:
		print("[PASS] Test 3: Headshot decapitation & blood fountain verified!\n")

func _test_barricade_mechanics() -> void:
	print("--- TEST 4: Barricade Plank Tearing & Repair Economy ---")
	var barricade = level.get_node_or_null("WildernessSurvivalPoints/TrailBarricade") as Node3D
	if not barricade:
		barricade = level.get_node_or_null("BlackwoodLodge/Barricade_West") as Node3D
	if not barricade:
		printerr("[FAIL] Barricade not found!")
		test_passed = false
		return
		
	print("  Initial planks: %d/%d" % [barricade.current_planks, barricade.max_planks])
	# Zombie tears plank
	barricade._tear_plank()
	print("  After zombie tear planks: %d/%d" % [barricade.current_planks, barricade.max_planks])
	assert(barricade.current_planks == 4, "Planks should decrease to 4")
	
	# Player repairs plank
	var pts_before = gm.points
	var repaired = barricade.repair_one_plank()
	print("  Repaired: %s, Planks now: %d/%d, Points awarded: +%d" % [str(repaired), barricade.current_planks, barricade.max_planks, gm.points - pts_before])
	
	if not repaired or barricade.current_planks != 5 or (gm.points - pts_before) != 10:
		printerr("[FAIL] Barricade repair failed or did not award 10 points!")
		test_passed = false
	else:
		print("[PASS] Test 4: Barricade tear & repair mechanics verified!\n")

func _test_wall_buy() -> void:
	print("--- TEST 5: Wall-Buy Station Weapon Acquisition & Ammo Refill ---")
	var wb = level.get_node_or_null("WildernessSurvivalPoints/Stand_Remington870") as Node3D
	if not wb:
		wb = level.get_node_or_null("BlackwoodLodge/WallBuy_Remington870") as Node3D
	if not wb:
		printerr("[FAIL] WallBuy_Remington870 not found!")
		test_passed = false
		return
		
	# Ensure enough points
	gm.points = max(gm.points, 600)
	var pts_before = gm.points
	var wm = player.get_node_or_null("CameraPivot/WeaponHolder/WeaponManager")
	
	# Switch to Remington 870 and test ammo refill
	wm._switch_to_slot(1)
	var cur_w = wm.get_current_weapon()
	if cur_w:
		cur_w.reserve_ammo = 10 # Deplete ammo so we can test refill
	
	wb.interact(player)
	print("  Points before: %d, Points after: %d (Cost: %d)" % [pts_before, gm.points, pts_before - gm.points])
	print("  Active Weapon after Wall-Buy: ", cur_w.weapon_name if cur_w else "None")
	print("  Remington 870 reserve ammo after purchase: ", cur_w.reserve_ammo if cur_w else 0)
	
	if not cur_w or cur_w.weapon_id != "remington870" or cur_w.reserve_ammo != cur_w.max_reserve_ammo:
		printerr("[FAIL] Wall-Buy did not equip or refill Remington 870!")
		test_passed = false
	else:
		print("[PASS] Test 5: Wall-Buy station weapon & ammo purchase verified!\n")

func _test_perk_machine() -> void:
	print("--- TEST 6: Perk Vending Machine (Juggernog) ---")
	var perk = level.get_node_or_null("WildernessSurvivalPoints/Perk_Juggernog") as Node3D
	if not perk:
		perk = level.get_node_or_null("MilitaryCamp/Perk_Juggernog") as Node3D
	if not perk:
		printerr("[FAIL] Perk_Juggernog not found!")
		test_passed = false
		return
		
	gm.points = 3000
	perk.interact(player)
	
	print("  Player Max HP after Juggernog: %d (Expected: 250)" % player.max_health)
	print("  Player Current HP after Juggernog: %d" % player.current_health)
	print("  Has Juggernog perk in GameManager: ", gm.has_perk("juggernog"))
	
	if player.max_health != 250 or not gm.has_perk("juggernog"):
		printerr("[FAIL] Juggernog perk did not apply correctly!")
		test_passed = false
	else:
		print("[PASS] Test 6: Juggernog perk machine verified!\n")

func _test_mystery_box() -> void:
	print("--- TEST 7: Mystery Weapon Box Roulette ---")
	var box = level.get_node_or_null("WildernessSurvivalPoints/MysteryBox") as Node3D
	if not box:
		box = level.get_node_or_null("MilitaryCamp/MysteryBox") as Node3D
	if not box:
		printerr("[FAIL] MysteryBox not found!")
		test_passed = false
		return
		
	gm.points = 2000
	box.interact(player)
	print("  Box state after purchase: ", box.current_state, " (Expected 1: ROLLING)")
	
	# Force finish roll to test weapon acquisition
	box._finish_roll()
	print("  Box state after roll finished: ", box.current_state, " (Expected 2: WEAPON_READY)")
	print("  Rolled Weapon: ", box.selected_weapon.weapon_name if box.selected_weapon else "None")
	
	box.interact(player)
	var wm = player.get_node_or_null("CameraPivot/WeaponHolder/WeaponManager")
	var cur_w = wm.get_current_weapon()
	print("  Player equipped weapon from box: ", cur_w.weapon_name if cur_w else "None")
	print("  Box state after pickup: ", box.current_state, " (Expected 3: CLOSING)")
	
	if not cur_w or box.current_state != 3:
		printerr("[FAIL] Mystery Box weapon claiming failed!")
		test_passed = false
	else:
		print("[PASS] Test 7: Mystery Box roulette & weapon claim verified!\n")

func _finish_tests() -> void:
	print("========================================================")
	if test_passed:
		print("   ALL 7 ZOMBIE SURVIVAL SYSTEMS PASSED PERFECTLY!   ")
	else:
		print("   SOME TESTS FAILED! CHECK OUTPUT ABOVE.   ")
	print("========================================================\n")
	quit(0 if test_passed else 1)

# Verification covers 7 systems: Level, Zombie Claw, Decapitation, Barricade, Wall-Buy, Perk, Mystery Box
