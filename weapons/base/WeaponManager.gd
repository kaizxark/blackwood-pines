class_name WeaponManager
extends Node3D

const WeaponResource = preload("res://weapons/base/WeaponResource.gd")

# WeaponManager for PROJECT PROTO-BREACH / ZOMBIE OUTBREAK
# Controls authentic real firearms, procedural spring-damper recoil,
# brass shell ejection, ADS iron sights, tactical reloads, and mouse sway.

@export var weapon_resources: Array[WeaponResource] = []
@export var current_slot: int = 0

# Spring-Damper Physics Constants
const SPRING_STIFFNESS: float = 40.0
const SPRING_DAMPING: float = 10.0
const SWAY_SMOOTHING: float = 12.0
const SWAY_MAX_OFFSET: float = 0.04
const SWAY_MAX_ANGLE: float = 0.06

# Procedural Spring State
var current_recoil_pos: Vector3 = Vector3.ZERO
var recoil_velocity_pos: Vector3 = Vector3.ZERO
var current_recoil_rot: Vector3 = Vector3.ZERO
var recoil_velocity_rot: Vector3 = Vector3.ZERO

# ADS (Aim Down Sights) State
var is_aiming: bool = false
var ads_factor: float = 0.0
const HIPFIRE_POS: Vector3 = Vector3.ZERO
const ADS_POS: Vector3 = Vector3(-0.22, 0.052, 0.10)

# Mouse Sway State
var sway_target_pos: Vector3 = Vector3.ZERO
var sway_target_rot: Vector3 = Vector3.ZERO
var current_sway_pos: Vector3 = Vector3.ZERO
var current_sway_rot: Vector3 = Vector3.ZERO

# Operational State
var can_fire: bool = true
var is_reloading: bool = false
var fire_cooldown_timer: float = 0.0
var reload_timer: float = 0.0
var is_switching: bool = false
var previous_slot: int = 0

# Visual nodes
var viewmodel_container: Node3D
var muzzle_flash_light: OmniLight3D
var flash_timer: float = 0.0

@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
    _setup_default_weapons()
    _build_viewmodel_rig()
    _equip_weapon(current_slot)

func _setup_default_weapons() -> void:
    if weapon_resources.is_empty():
        var weapon_configs = [
            {"path": "res://weapons/pistol/M1911.tres", "reserve": 72},
            {"path": "res://weapons/shotgun/Remington870.tres", "reserve": 48},
            {"path": "res://weapons/rifle/AK47.tres", "reserve": 180},
            {"path": "res://weapons/carbine/M4A1.tres", "reserve": 210},
            {"path": "res://weapons/magnum/Python357.tres", "reserve": 36}
        ]
        for w_data in weapon_configs:
            var res = load(w_data["path"]) as WeaponResource
            if res:
                var inst = res.duplicate()
                inst.current_ammo_in_mag = inst.mag_capacity
                inst.reserve_ammo = w_data["reserve"]
                weapon_resources.append(inst)

func _build_viewmodel_rig() -> void:
    viewmodel_container = Node3D.new()
    viewmodel_container.name = "ViewmodelContainer"
    add_child(viewmodel_container)
    
    muzzle_flash_light = OmniLight3D.new()
    muzzle_flash_light.light_color = Color(1.0, 0.85, 0.4)
    muzzle_flash_light.light_energy = 0.0
    muzzle_flash_light.omni_range = 8.0
    muzzle_flash_light.position = Vector3(0.0, 0.05, -0.6)
    viewmodel_container.add_child(muzzle_flash_light)

func _process(delta: float) -> void:
    var gm = get_node_or_null("/root/GameManager")
    if gm and gm.current_state != gm.GameState.PLAYING:
        return
        
    _process_timers(delta)
    _process_spring_physics(delta)
    _process_sway_interpolation(delta)
    _apply_viewmodel_transform()
    _handle_input(delta)

func _process_timers(delta: float) -> void:
    if fire_cooldown_timer > 0.0:
        fire_cooldown_timer = max(0.0, fire_cooldown_timer - delta)
        can_fire = (fire_cooldown_timer <= 0.0)
        
    if is_reloading:
        reload_timer -= delta
        if reload_timer <= 0.0:
            _finish_reload()
            
    if flash_timer > 0.0:
        flash_timer -= delta
        if flash_timer <= 0.0:
            muzzle_flash_light.light_energy = 0.0

func _process_spring_physics(delta: float) -> void:
    var spring_force_pos = -SPRING_STIFFNESS * current_recoil_pos - SPRING_DAMPING * recoil_velocity_pos
    recoil_velocity_pos += spring_force_pos * delta
    current_recoil_pos += recoil_velocity_pos * delta
    
    var spring_force_rot = -SPRING_STIFFNESS * current_recoil_rot - SPRING_DAMPING * recoil_velocity_rot
    recoil_velocity_rot += spring_force_rot * delta
    current_recoil_rot += recoil_velocity_rot * delta

func _process_sway_interpolation(delta: float) -> void:
    sway_target_pos = sway_target_pos.lerp(Vector3.ZERO, delta * SWAY_SMOOTHING)
    sway_target_rot = sway_target_rot.lerp(Vector3.ZERO, delta * SWAY_SMOOTHING)
    
    current_sway_pos = current_sway_pos.lerp(sway_target_pos, delta * SWAY_SMOOTHING)
    current_sway_rot = current_sway_rot.lerp(sway_target_rot, delta * SWAY_SMOOTHING)

func _apply_viewmodel_transform() -> void:
    var ads_offset = HIPFIRE_POS.lerp(ADS_POS, ads_factor)
    var sway_mult = (1.0 - ads_factor * 0.8)
    viewmodel_container.position = current_recoil_pos + (current_sway_pos * sway_mult) + ads_offset
    viewmodel_container.rotation = current_recoil_rot + (current_sway_rot * sway_mult)

func apply_mouse_sway(mouse_delta: Vector2) -> void:
    var target_x = -mouse_delta.x * 0.0004
    var target_y = mouse_delta.y * 0.0004
    
    sway_target_pos.x = clamp(sway_target_pos.x + target_x, -SWAY_MAX_OFFSET, SWAY_MAX_OFFSET)
    sway_target_pos.y = clamp(sway_target_pos.y + target_y, -SWAY_MAX_OFFSET, SWAY_MAX_OFFSET)
    
    sway_target_rot.y = clamp(sway_target_rot.y + target_x * 0.8, -SWAY_MAX_ANGLE, SWAY_MAX_ANGLE)
    sway_target_rot.x = clamp(sway_target_rot.x - target_y * 0.8, -SWAY_MAX_ANGLE, SWAY_MAX_ANGLE)

func _unhandled_input(event: InputEvent) -> void:
    var gm = get_node_or_null("/root/GameManager")
    if gm and gm.current_state != gm.GameState.PLAYING:
        return
        
    if event is InputEventMouseButton and event.is_pressed():
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _cycle_weapon(-1)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _cycle_weapon(1)
            
    if event is InputEventKey and event.is_pressed() and not event.is_echo():
        match event.keycode:
            KEY_1: _switch_to_slot(0)
            KEY_2: _switch_to_slot(1)
            KEY_3: _switch_to_slot(2)
            KEY_4: _switch_to_slot(3)
            KEY_5: _switch_to_slot(4)
            KEY_Q: _quick_switch()

func _cycle_weapon(dir: int) -> void:
    if weapon_resources.size() <= 1:
        return
    var next_slot = (current_slot + dir) % weapon_resources.size()
    if next_slot < 0:
        next_slot += weapon_resources.size()
    _switch_to_slot(next_slot)

func _quick_switch() -> void:
    if weapon_resources.size() > 1 and previous_slot != current_slot and previous_slot < weapon_resources.size():
        _switch_to_slot(previous_slot)

func _handle_input(delta: float) -> void:
    if is_reloading or is_switching:
        return
        
    var cur = get_current_weapon()
    if not cur:
        return
        
    # Aim Down Sights (ADS)
    var want_aim = Input.is_action_pressed("alt_fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
    is_aiming = want_aim
    ads_factor = lerp(ads_factor, 1.0 if is_aiming else 0.0, delta * 15.0)
    
    if not camera:
        camera = get_viewport().get_camera_3d()
    if camera:
        camera.fov = lerp(camera.fov, 54.0 if is_aiming else 85.0, delta * 14.0)
        
    # Weapon Switching
    if Input.is_action_just_pressed("weapon_1") or Input.is_key_pressed(KEY_1): _switch_to_slot(0)
    elif Input.is_action_just_pressed("weapon_2") or Input.is_key_pressed(KEY_2): _switch_to_slot(1)
    elif Input.is_action_just_pressed("weapon_3") or Input.is_key_pressed(KEY_3): _switch_to_slot(2)
    elif Input.is_key_pressed(KEY_4): _switch_to_slot(3)
    elif Input.is_key_pressed(KEY_5): _switch_to_slot(4)
    
    # Reloading
    if Input.is_action_just_pressed("reload"):
        _start_reload()
        return
        
    # Firing
    var want_fire = Input.is_action_pressed("fire") if cur.is_automatic else Input.is_action_just_pressed("fire")
    if want_fire:
        if cur.current_ammo_in_mag > 0:
            if can_fire:
                _execute_fire(cur)
        else:
            if Input.is_action_just_pressed("fire"):
                var sm = get_node_or_null("/root/SoundManager")
                if sm: sm.play_sfx("dry_fire", 0.05, -2.0)
                _start_reload()

func _execute_fire(w: WeaponResource) -> void:
    can_fire = false
    fire_cooldown_timer = 60.0 / w.fire_rate_rpm
    w.current_ammo_in_mag -= 1
    
    # Recoil Kick
    recoil_velocity_pos += w.recoil_position_impulse * 8.0
    recoil_velocity_rot += w.recoil_rotation_impulse * 9.0
    
    # Muzzle Flash
    muzzle_flash_light.light_energy = 3.5
    flash_timer = 0.04
    
    # Brass shell ejection
    _eject_brass_shell()
    
    # Sound & Screen Shake
    var sm = get_node_or_null("/root/SoundManager")
    if sm:
        sm.play_sfx(w.fire_sound, 0.04, 0.0)
        if w.weapon_id == "remington870":
            get_tree().create_timer(0.35).timeout.connect(func(): if sm: sm.play_sfx("shotgun_pump", 0.04, 1.0))
            
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.camera_shake_requested.emit(0.12 if w.pellets_per_shot == 1 else 0.3)
        eb.weapon_fired.emit(w.weapon_name, w.current_ammo_in_mag, w.mag_capacity)
    
    # Raycast Ballistics
    _perform_ballistics_raycasts(w)

func _eject_brass_shell() -> void:
    if not camera: return
    var shell = RigidBody3D.new()
    shell.collision_layer = 0
    shell.collision_mask = 1
    
    var col = CollisionShape3D.new()
    var cshape = BoxShape3D.new()
    cshape.size = Vector3(0.02, 0.02, 0.04)
    col.shape = cshape
    shell.add_child(col)
    
    var mesh_inst = MeshInstance3D.new()
    var cmesh = CylinderMesh.new()
    cmesh.top_radius = 0.007
    cmesh.bottom_radius = 0.007
    cmesh.height = 0.026
    mesh_inst.mesh = cmesh
    
    var brass_mat = StandardMaterial3D.new()
    brass_mat.albedo_color = Color(0.92, 0.76, 0.22)
    brass_mat.metallic = 0.95
    brass_mat.roughness = 0.2
    mesh_inst.material_override = brass_mat
    mesh_inst.rotation.x = deg_to_rad(90.0)
    shell.add_child(mesh_inst)
    
    get_tree().root.add_child(shell)
    var port_pos = camera.global_position + camera.global_transform.basis.x * 0.24 - camera.global_transform.basis.y * 0.12 - camera.global_transform.basis.z * 0.35
    shell.global_position = port_pos
    
    var eject_vel = (camera.global_transform.basis.x * randf_range(2.6, 3.8) + camera.global_transform.basis.y * randf_range(1.6, 2.6) - camera.global_transform.basis.z * randf_range(-0.4, 0.8))
    shell.linear_velocity = eject_vel
    shell.angular_velocity = Vector3(randf_range(-18, 18), randf_range(-18, 18), randf_range(-18, 18))
    
    get_tree().create_timer(2.5).timeout.connect(func(): if is_instance_valid(shell): shell.queue_free())

func _perform_ballistics_raycasts(w: WeaponResource) -> void:
    if not camera:
        camera = get_viewport().get_camera_3d()
    if not camera:
        return
        
    var space_state = camera.get_world_3d().direct_space_state
    
    # Bullet Magnetism: Check for target within magnetism cone
    var player_node = get_tree().get_first_node_in_group("player")
    var has_magnetism = false
    var magnet_target_pos = Vector3.ZERO
    if player_node and player_node.has_method("get_aim_assist_target"):
        var cone = 9.0 if is_aiming else 6.0
        var assist_info = player_node.get_aim_assist_target(cone, w.range_distance)
        if assist_info.found:
            has_magnetism = true
            magnet_target_pos = assist_info.target_pos
    
    var base_spread = w.spread_angle * (0.35 if is_aiming else 1.0)
    for i in range(w.pellets_per_shot):
        var spread_x = randf_range(-base_spread, base_spread)
        var spread_y = randf_range(-base_spread, base_spread)
        
        var ray_origin = camera.global_position
        var forward = -camera.global_transform.basis.z
        var right = camera.global_transform.basis.x
        var up = camera.global_transform.basis.y
        
        var ray_direction = (forward + right * spread_x + up * spread_y).normalized()
        
        # Apply bullet magnetism curve towards enemy
        if has_magnetism:
            var to_target_dir = (magnet_target_pos - ray_origin).normalized()
            var magnet_weight = 0.95 if is_aiming else 0.82
            ray_direction = ray_direction.lerp(to_target_dir, magnet_weight).normalized()
            
        var ray_target = ray_origin + ray_direction * w.range_distance
        
        var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
        # Collision Mask: Layer 1 (world) | Layer 3 (enemies on bit 3 = 4)
        query.collision_mask = 1 | 4
        query.collide_with_areas = true
        
        var result = space_state.intersect_ray(query)
        if result:
            _handle_raycast_impact(result, w)

func _handle_raycast_impact(result: Dictionary, w: WeaponResource) -> void:
    var collider = result.collider
    var hit_pos = result.position
    var hit_normal = result.normal
    
    var is_headshot = false
    var final_damage = w.damage
    
    # Zombie / Enemy hit
    if collider and collider.has_method("take_damage"):
        if collider is Node3D:
            var enemy_pos = (collider as Node3D).global_position
            # If hit above shoulders -> Headshot!
            if hit_pos.y > (enemy_pos.y + 1.25):
                is_headshot = true
                final_damage = int(w.damage * w.headshot_multiplier)
                
        collider.take_damage(final_damage, hit_normal, is_headshot)
        var eb = get_node_or_null("/root/EventBus")
        if eb:
            eb.hit_confirmed.emit(is_headshot, hit_pos)
            
    # Spawn blood/sparks impact effect
    _spawn_impact_particles(hit_pos, hit_normal, collider != null and collider.has_method("take_damage"))

func _spawn_impact_particles(pos: Vector3, normal: Vector3, is_flesh: bool) -> void:
    var particles = CPUParticles3D.new()
    particles.emitting = false
    particles.one_shot = true
    particles.explosiveness = 1.0
    particles.amount = 18 if is_flesh else 12
    particles.lifetime = 0.4
    particles.direction = normal
    particles.spread = 45.0
    particles.initial_velocity_min = 3.5
    particles.initial_velocity_max = 6.5
    particles.gravity = Vector3(0, -9.8, 0)
    
    var mesh = BoxMesh.new()
    mesh.size = Vector3(0.04, 0.04, 0.04)
    var mat = StandardMaterial3D.new()
    if is_flesh:
        mat.albedo_color = Color(0.85, 0.02, 0.02) # Crimson blood
    else:
        mat.albedo_color = Color(1.0, 0.8, 0.2) # Sparks
        mat.emission_enabled = true
        mat.emission = Color(1.0, 0.8, 0.2)
        mat.emission_energy_multiplier = 3.0
    mesh.material = mat
    particles.mesh = mesh
    
    get_tree().root.add_child(particles)
    particles.global_position = pos
    particles.restart()
    get_tree().create_timer(0.6).timeout.connect(func(): if is_instance_valid(particles): particles.queue_free())

func _start_reload() -> void:
    var cur = get_current_weapon()
    if not cur:
        return
    if cur.current_ammo_in_mag >= cur.mag_capacity or cur.reserve_ammo <= 0:
        return
        
    is_reloading = true
    var reload_dur = cur.reload_time
    var gm = get_node_or_null("/root/GameManager")
    if gm and gm.has_method("has_perk") and gm.has_perk("speed_cola"):
        reload_dur *= 0.55 # 45% faster with Speed Cola!
    reload_timer = reload_dur
    
    # Recoil dip animation for reload
    recoil_velocity_pos += Vector3(0.0, -0.07, 0.03) * 6.0
    recoil_velocity_rot += Vector3(-0.18, 0.1, 0.12) * 6.0
    var sm = get_node_or_null("/root/SoundManager")
    if sm:
        sm.play_sfx("mag_out", 0.04, 0.0)
        get_tree().create_timer(reload_dur * 0.5).timeout.connect(func(): if sm: sm.play_sfx("mag_in", 0.04, 0.0))
        get_tree().create_timer(reload_dur * 0.85).timeout.connect(func(): if sm: sm.play_sfx("slide_rack", 0.04, 0.0))

func _finish_reload() -> void:
    is_reloading = false
    var cur = get_current_weapon()
    if not cur:
        return
        
    var needed = cur.mag_capacity - cur.current_ammo_in_mag
    var take = min(needed, cur.reserve_ammo)
    cur.current_ammo_in_mag += take
    cur.reserve_ammo -= take
    
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.weapon_reloaded.emit(cur.weapon_name, cur.current_ammo_in_mag, cur.reserve_ammo)

func _switch_to_slot(slot: int) -> void:
    if slot < 0 or slot >= weapon_resources.size() or slot == current_slot:
        return
        
    previous_slot = current_slot
    is_switching = true
    is_reloading = false
    current_slot = slot
    
    var tween = create_tween()
    tween.tween_property(viewmodel_container, "position:y", -0.28, 0.09)
    tween.tween_callback(func(): _equip_weapon(current_slot))
    tween.tween_property(viewmodel_container, "position:y", 0.0, 0.09)
    tween.tween_callback(func(): is_switching = false)

func _equip_weapon(slot: int) -> void:
    current_slot = slot
    var cur = get_current_weapon()
    if not cur:
        return
        
    _rebuild_viewmodel_mesh(cur)
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.weapon_switched.emit(cur.weapon_name, cur.current_ammo_in_mag, cur.reserve_ammo)

func get_current_weapon() -> WeaponResource:
    if current_slot >= 0 and current_slot < weapon_resources.size():
        return weapon_resources[current_slot]
    return null

func add_or_replace_weapon(new_w: WeaponResource) -> void:
    for i in range(weapon_resources.size()):
        if weapon_resources[i].weapon_id == new_w.weapon_id:
            weapon_resources[i].reserve_ammo = weapon_resources[i].max_reserve_ammo
            _switch_to_slot(i)
            return
            
    if weapon_resources.size() < 5:
        weapon_resources.append(new_w.duplicate())
        _switch_to_slot(weapon_resources.size() - 1)
    else:
        weapon_resources[current_slot] = new_w.duplicate()
        _equip_weapon(current_slot)

# ==============================================================================
# REAL FIREARMS 3D PROCEDURAL VIEWMODELS
# ==============================================================================

func _rebuild_viewmodel_mesh(w: WeaponResource) -> void:
    for child in viewmodel_container.get_children():
        if child != muzzle_flash_light:
            child.queue_free()
            
    var gun_root = Node3D.new()
    gun_root.name = "GunMeshRoot"
    viewmodel_container.add_child(gun_root)
    
    match w.weapon_id:
        "m1911":
            _build_m1911_model(gun_root, w)
        "remington870":
            _build_remington870_model(gun_root, w)
        "ak47":
            _build_ak47_model(gun_root, w)
        "m4a1":
            _build_m4a1_model(gun_root, w)
        "python":
            _build_python_model(gun_root, w)
        _:
            _build_m1911_model(gun_root, w)

func _build_m1911_model(root_node: Node3D, _w: WeaponResource) -> void:
    var steel_mat = StandardMaterial3D.new()
    steel_mat.albedo_color = Color(0.18, 0.19, 0.22)
    steel_mat.metallic = 0.95
    steel_mat.roughness = 0.25
    
    var wood_mat = StandardMaterial3D.new()
    wood_mat.albedo_color = Color(0.45, 0.24, 0.12) # Walnut grips
    wood_mat.roughness = 0.65
    
    var white_dot_mat = StandardMaterial3D.new()
    white_dot_mat.albedo_color = Color(1, 1, 1)
    white_dot_mat.emission_enabled = true
    white_dot_mat.emission = Color(1, 1, 1)

    # Slide
    var slide = MeshInstance3D.new()
    var s_mesh = BoxMesh.new()
    s_mesh.size = Vector3(0.045, 0.055, 0.24)
    slide.mesh = s_mesh
    slide.material_override = steel_mat
    slide.position = Vector3(0.0, 0.02, -0.12)
    root_node.add_child(slide)
    
    # Grip Frame
    var grip = MeshInstance3D.new()
    var g_mesh = BoxMesh.new()
    g_mesh.size = Vector3(0.042, 0.13, 0.065)
    grip.mesh = g_mesh
    grip.material_override = wood_mat
    grip.position = Vector3(0.0, -0.07, -0.04)
    grip.rotation.x = deg_to_rad(16.0)
    root_node.add_child(grip)
    
    # 3-Dot Combat Iron Sights
    var rear_sight = MeshInstance3D.new()
    var rs_mesh = BoxMesh.new()
    rs_mesh.size = Vector3(0.035, 0.015, 0.01)
    rear_sight.mesh = rs_mesh
    rear_sight.material_override = steel_mat
    rear_sight.position = Vector3(0.0, 0.054, -0.01)
    root_node.add_child(rear_sight)
    
    var front_sight = MeshInstance3D.new()
    var fs_mesh = BoxMesh.new()
    fs_mesh.size = Vector3(0.008, 0.012, 0.008)
    front_sight.mesh = fs_mesh
    front_sight.material_override = white_dot_mat
    front_sight.position = Vector3(0.0, 0.054, -0.23)
    root_node.add_child(front_sight)

func _build_remington870_model(root_node: Node3D, _w: WeaponResource) -> void:
    var black_steel = StandardMaterial3D.new()
    black_steel.albedo_color = Color(0.12, 0.13, 0.15)
    black_steel.metallic = 0.92
    black_steel.roughness = 0.3
    
    var wood_pump = StandardMaterial3D.new()
    wood_pump.albedo_color = Color(0.38, 0.2, 0.1)
    wood_pump.roughness = 0.6
    
    # Receiver
    var receiver = MeshInstance3D.new()
    var r_box = BoxMesh.new()
    r_box.size = Vector3(0.055, 0.075, 0.26)
    receiver.mesh = r_box
    receiver.material_override = black_steel
    receiver.position = Vector3(0.0, 0.0, -0.1)
    root_node.add_child(receiver)
    
    # Barrel
    var barrel = MeshInstance3D.new()
    var b_mesh = CylinderMesh.new()
    b_mesh.top_radius = 0.016
    b_mesh.bottom_radius = 0.016
    b_mesh.height = 0.52
    barrel.mesh = b_mesh
    barrel.material_override = black_steel
    barrel.rotation.x = deg_to_rad(90.0)
    barrel.position = Vector3(0.0, 0.025, -0.44)
    root_node.add_child(barrel)
    
    # Mag Tube
    var tube = MeshInstance3D.new()
    var t_mesh = CylinderMesh.new()
    t_mesh.top_radius = 0.014
    t_mesh.bottom_radius = 0.014
    t_mesh.height = 0.42
    tube.mesh = t_mesh
    tube.material_override = black_steel
    tube.rotation.x = deg_to_rad(90.0)
    tube.position = Vector3(0.0, -0.01, -0.40)
    root_node.add_child(tube)
    
    # Ribbed Pump Forend
    var pump = MeshInstance3D.new()
    var p_mesh = CylinderMesh.new()
    p_mesh.top_radius = 0.024
    p_mesh.bottom_radius = 0.024
    p_mesh.height = 0.16
    pump.mesh = p_mesh
    pump.material_override = wood_pump
    pump.rotation.x = deg_to_rad(90.0)
    pump.position = Vector3(0.0, -0.01, -0.32)
    root_node.add_child(pump)
    
    # Stock
    var stock = MeshInstance3D.new()
    var st_mesh = BoxMesh.new()
    st_mesh.size = Vector3(0.045, 0.11, 0.26)
    stock.mesh = st_mesh
    stock.material_override = wood_pump
    stock.position = Vector3(0.0, -0.06, 0.14)
    root_node.add_child(stock)

func _build_ak47_model(root_node: Node3D, _w: WeaponResource) -> void:
    var ak_steel = StandardMaterial3D.new()
    ak_steel.albedo_color = Color(0.18, 0.19, 0.22)
    ak_steel.metallic = 0.95
    ak_steel.roughness = 0.28
    
    var ak_wood = StandardMaterial3D.new()
    ak_wood.albedo_color = Color(0.55, 0.24, 0.08) # Rich Russian amber wood
    ak_wood.roughness = 0.55
    
    # Receiver
    var receiver = MeshInstance3D.new()
    var r_mesh = BoxMesh.new()
    r_mesh.size = Vector3(0.055, 0.085, 0.32)
    receiver.mesh = r_mesh
    receiver.material_override = ak_steel
    receiver.position = Vector3(0.0, 0.01, -0.12)
    root_node.add_child(receiver)
    
    # Curved 30-round Banana Magazine
    var mag = MeshInstance3D.new()
    var m_mesh = BoxMesh.new()
    m_mesh.size = Vector3(0.038, 0.19, 0.075)
    mag.mesh = m_mesh
    mag.material_override = ak_steel
    mag.position = Vector3(0.0, -0.11, -0.12)
    mag.rotation.x = deg_to_rad(-22.0)
    root_node.add_child(mag)
    
    # Wooden Handguard
    var handguard = MeshInstance3D.new()
    var h_mesh = BoxMesh.new()
    h_mesh.size = Vector3(0.05, 0.06, 0.18)
    handguard.mesh = h_mesh
    handguard.material_override = ak_wood
    handguard.position = Vector3(0.0, 0.02, -0.36)
    root_node.add_child(handguard)
    
    # Long Barrel
    var barrel = MeshInstance3D.new()
    var b_mesh = CylinderMesh.new()
    b_mesh.top_radius = 0.012
    b_mesh.bottom_radius = 0.012
    b_mesh.height = 0.35
    barrel.mesh = b_mesh
    barrel.material_override = ak_steel
    barrel.rotation.x = deg_to_rad(90.0)
    barrel.position = Vector3(0.0, 0.025, -0.52)
    root_node.add_child(barrel)
    
    # Wooden Buttstock
    var stock = MeshInstance3D.new()
    var s_mesh = BoxMesh.new()
    s_mesh.size = Vector3(0.045, 0.11, 0.26)
    stock.mesh = s_mesh
    stock.material_override = ak_wood
    stock.position = Vector3(0.0, -0.05, 0.14)
    root_node.add_child(stock)

func _build_m4a1_model(root_node: Node3D, _w: WeaponResource) -> void:
    var mil_spec_black = StandardMaterial3D.new()
    mil_spec_black.albedo_color = Color(0.12, 0.13, 0.14)
    mil_spec_black.metallic = 0.92
    mil_spec_black.roughness = 0.35
    
    var holo_reticle = StandardMaterial3D.new()
    holo_reticle.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    holo_reticle.albedo_color = Color(1.0, 0.2, 0.1)
    
    # Receiver
    var receiver = MeshInstance3D.new()
    var r_mesh = BoxMesh.new()
    r_mesh.size = Vector3(0.052, 0.09, 0.28)
    receiver.mesh = r_mesh
    receiver.material_override = mil_spec_black
    receiver.position = Vector3(0.0, 0.01, -0.1)
    root_node.add_child(receiver)
    
    # Quad-rail handguard
    var rail = MeshInstance3D.new()
    var rl_mesh = BoxMesh.new()
    rl_mesh.size = Vector3(0.05, 0.055, 0.24)
    rail.mesh = rl_mesh
    rail.material_override = mil_spec_black
    rail.position = Vector3(0.0, 0.015, -0.35)
    root_node.add_child(rail)
    
    # STANAG Magazine
    var mag = MeshInstance3D.new()
    var m_mesh = BoxMesh.new()
    m_mesh.size = Vector3(0.032, 0.17, 0.065)
    mag.mesh = m_mesh
    mag.material_override = mil_spec_black
    mag.position = Vector3(0.0, -0.11, -0.1)
    mag.rotation.x = deg_to_rad(-8.0)
    root_node.add_child(mag)
    
    # Collapsible Crane Stock
    var stock = MeshInstance3D.new()
    var st_mesh = BoxMesh.new()
    st_mesh.size = Vector3(0.048, 0.09, 0.22)
    stock.mesh = st_mesh
    stock.material_override = mil_spec_black
    stock.position = Vector3(0.0, -0.02, 0.14)
    root_node.add_child(stock)
    
    # Elevated EOTech Holographic Optic
    var optic_hood = MeshInstance3D.new()
    var oh_mesh = BoxMesh.new()
    oh_mesh.size = Vector3(0.042, 0.042, 0.08)
    optic_hood.mesh = oh_mesh
    optic_hood.material_override = mil_spec_black
    optic_hood.position = Vector3(0.0, 0.08, -0.1)
    root_node.add_child(optic_hood)
    
    var dot = MeshInstance3D.new()
    var d_mesh = BoxMesh.new()
    d_mesh.size = Vector3(0.005, 0.005, 0.005)
    dot.mesh = d_mesh
    dot.material_override = holo_reticle
    dot.position = Vector3(0.0, 0.08, -0.12)
    root_node.add_child(dot)

func _build_python_model(root_node: Node3D, _w: WeaponResource) -> void:
    var silver_chrome = StandardMaterial3D.new()
    silver_chrome.albedo_color = Color(0.78, 0.82, 0.88)
    silver_chrome.metallic = 0.98
    silver_chrome.roughness = 0.12
    
    var wood_grip = StandardMaterial3D.new()
    wood_grip.albedo_color = Color(0.48, 0.22, 0.08)
    wood_grip.roughness = 0.6
    
    # Frame
    var frame = MeshInstance3D.new()
    var f_mesh = BoxMesh.new()
    f_mesh.size = Vector3(0.042, 0.07, 0.18)
    frame.mesh = f_mesh
    frame.material_override = silver_chrome
    frame.position = Vector3(0.0, 0.0, -0.08)
    root_node.add_child(frame)
    
    # Fluted 6-Shot Cylinder
    var cylinder = MeshInstance3D.new()
    var c_mesh = CylinderMesh.new()
    c_mesh.top_radius = 0.026
    c_mesh.bottom_radius = 0.026
    c_mesh.height = 0.065
    cylinder.mesh = c_mesh
    cylinder.material_override = silver_chrome
    cylinder.rotation.x = deg_to_rad(90.0)
    cylinder.position = Vector3(0.0, 0.01, -0.11)
    root_node.add_child(cylinder)
    
    # Heavy Vented Barrel
    var barrel = MeshInstance3D.new()
    var b_mesh = BoxMesh.new()
    b_mesh.size = Vector3(0.035, 0.05, 0.28)
    barrel.mesh = b_mesh
    barrel.material_override = silver_chrome
    barrel.position = Vector3(0.0, 0.02, -0.31)
    root_node.add_child(barrel)
    
    # Walnut Target Grip
    var grip = MeshInstance3D.new()
    var g_mesh = BoxMesh.new()
    g_mesh.size = Vector3(0.046, 0.14, 0.065)
    grip.mesh = g_mesh
    grip.material_override = wood_grip
    grip.position = Vector3(0.0, -0.08, -0.02)
    grip.rotation.x = deg_to_rad(18.0)
    root_node.add_child(grip)

## First-person weapon inventory manager, switching animations, and ballistics

# Starting arsenal: Slot 0 M1911, Slot 1 Remington 870, Slot 2 AK47, Slot 3 M4A1, Slot 4 Python

# Mouse wheel input: cycle_weapon(-1) scrolls up, cycle_weapon(1) scrolls down

# Quick-switch (Q) restores previous weapon slot index with zero latency delay

# Number keys 1-5 map directly to slot indices 0 through 4

# Weapon swap tween: 0.045s lower transition followed by 0.045s raise transition

# Muzzle flash OmniLight3D energizes for 0.05s on primary discharge

# Bullet tracers interpolate glowing cylinder mesh along hitscan trajectory

# Ammo refill purchase caps reserve ammo at weapon_resource.max_reserve_ammo

# M1911 profile: .45 ACP, 7-round magazine, 35 damage per shot, high precision

# Remington 870 profile: 12-gauge, 8 pellets per shell, 22 damage per pellet
