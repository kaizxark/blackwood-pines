extends Node

# PROJECT PROTO-BREACH - Visceral Blood & Gore System
# Manages dynamic arterial blood fountains, surface decals, dismemberment chunks,
# and camera screen-space blood splatters.

const MAX_ACTIVE_DECALS: int = 64
var active_decals: Array[Decal] = []

var blood_decal_scene: PackedScene = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_blood_decal_template()
	_connect_events()

func _connect_events() -> void:
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		if eb.has_signal("hit_confirmed"):
			eb.hit_confirmed.connect(_on_hit_confirmed)
		if eb.has_signal("zombie_killed"):
			eb.zombie_killed.connect(_on_zombie_killed)

func _create_blood_decal_template() -> void:
	# Build procedural blood splatter texture
	var img = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var center = Vector2(64, 64)
	# Draw organic jagged splatter droplets
	for y in range(128):
		for x in range(128):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			var angle = atan2(pos.y - center.y, pos.x - center.x)
			var jagged = sin(angle * 7.0) * cos(angle * 3.0) * 14.0 + sin(angle * 13.0) * 8.0
			var radius = 38.0 + jagged
			
			if dist < radius:
				var edge_fade = clamp((radius - dist) / 6.0, 0.0, 1.0)
				# Dark coagulated arterial crimson
				var col = Color(0.24, 0.02, 0.02, edge_fade * 0.95)
				img.set_pixel(x, y, col)
				
	# Add surrounding droplets
	for s in range(18):
		var s_ang = randf() * TAU
		var s_dist = randf_range(35.0, 56.0)
		var s_pos = center + Vector2(cos(s_ang), sin(s_ang)) * s_dist
		var s_rad = randf_range(2.0, 6.0)
		for dy in range(-int(s_rad), int(s_rad) + 1):
			for dx in range(-int(s_rad), int(s_rad) + 1):
				var p = s_pos + Vector2(dx, dy)
				if p.x >= 0 and p.x < 128 and p.y >= 0 and p.y < 128:
					if Vector2(dx, dy).length() <= s_rad:
						img.set_pixel(int(p.x), int(p.y), Color(0.28, 0.02, 0.02, 0.9))
						
	var tex = ImageTexture.create_from_image(img)
	
	# Create Decal resource template
	var d = Decal.new()
	d.name = "BloodDecal"
	d.size = Vector3(1.2, 0.8, 1.2)
	d.texture_albedo = tex
	d.modulate = Color(0.85, 0.15, 0.15, 0.95)
	d.cull_mask = 1 # Affects world layer (terrain, trees, cabins)
	d.distance_fade_enabled = true
	d.distance_fade_begin = 35.0
	d.distance_fade_length = 10.0
	
	var packed = PackedScene.new()
	packed.pack(d)
	blood_decal_scene = packed

func spawn_blood_spray(pos: Vector3, normal: Vector3, count: int = 36, speed: float = 5.0) -> void:
	var particles = CPUParticles3D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = count
	particles.lifetime = 0.65
	particles.direction = normal
	particles.spread = 50.0
	particles.initial_velocity_min = speed * 0.7
	particles.initial_velocity_max = speed * 1.3
	particles.gravity = Vector3(0, -11.0, 0)
	
	var blood_cube = BoxMesh.new()
	blood_cube.size = Vector3(0.06, 0.06, 0.06)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.32, 0.02, 0.02)
	mat.roughness = 0.1
	mat.metallic = 0.15
	particles.mesh = blood_cube
	particles.material_override = mat
	
	var parent_scene = get_tree().current_scene
	if not parent_scene: parent_scene = get_tree().root
	parent_scene.add_child(particles)
	particles.global_position = pos
	particles.restart()
	
	get_tree().create_timer(0.75).timeout.connect(func():
		if is_instance_valid(particles): particles.queue_free()
	)

func spawn_blood_decal(pos: Vector3, normal: Vector3, scale_mult: float = 1.0) -> void:
	if not blood_decal_scene: return
	
	var decal = blood_decal_scene.instantiate() as Decal
	if not decal: return
	
	var parent_scene = get_tree().current_scene
	if not parent_scene: parent_scene = get_tree().root
	parent_scene.add_child(decal)
	
	decal.global_position = pos
	
	# Align decal with surface normal
	if abs(normal.dot(Vector3.UP)) < 0.99:
		decal.look_at(pos + normal, Vector3.UP)
	else:
		decal.rotation.x = deg_to_rad(90.0) if normal.y > 0 else -deg_to_rad(90.0)
		
	# Random yaw spin
	decal.rotate_object_local(Vector3.FORWARD, randf() * TAU)
	
	# Juicy squash & stretch impact tween
	decal.scale = Vector3(0.2, 0.2, 0.2) * scale_mult
	var target_scale = Vector3(randf_range(0.85, 1.25), 1.0, randf_range(0.85, 1.25)) * scale_mult
	var tween = decal.create_tween()
	tween.tween_property(decal, "scale", target_scale, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	active_decals.append(decal)
	if active_decals.size() > MAX_ACTIVE_DECALS:
		var old = active_decals.pop_front()
		if is_instance_valid(old):
			var fade = old.create_tween()
			fade.tween_property(old, "modulate:a", 0.0, 1.0)
			fade.tween_callback(old.queue_free)

func _on_hit_confirmed(is_headshot: bool, hit_pos: Vector3) -> void:
	var count = 48 if is_headshot else 28
	var speed = 7.0 if is_headshot else 4.5
	spawn_blood_spray(hit_pos, Vector3.UP + Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5)), count, speed)
	spawn_blood_decal(hit_pos - Vector3(0, 0.5, 0), Vector3.UP, 1.4 if is_headshot else 0.9)
	
	# Check distance to player for Camera Lens Blood Splatter
	var player = get_tree().get_first_node_in_group("player") as Node3D
	if player and hit_pos.distance_to(player.global_position) < 3.2:
		var eb = get_node_or_null("/root/EventBus")
		if eb and eb.has_signal("damage_vignette_requested"):
			eb.damage_vignette_requested.emit(0.4)

func _on_zombie_killed(is_headshot: bool, _points: int) -> void:
	if is_headshot:
		# Extra squishy head explosion audio & splat
		var sm = get_node_or_null("/root/SoundManager")
		if sm:
			sm.play_sfx("zombie_headshot_splat", 0.05, 3.0)

## Blood splatter, dynamic floor decals, and arterial fountain coordinator

# High-velocity arterial blood spurt physics applied during headshot decapitations
