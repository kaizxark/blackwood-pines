class_name Player
extends CharacterBody3D

# PROJECT PROTO-BREACH - Player Controller
# Implements kinetic FPS movement: coyote time, jump buffering, slide-dashing,
# procedural head bob, camera lean, health/shield management, and recoil coupling.

# Movement Parameters
@export_group("Locomotion")
@export var walk_speed: float = 7.0
@export var sprint_speed: float = 11.0
@export var crouch_speed: float = 4.0
@export var slide_boost: float = 14.0
@export var jump_velocity: float = 8.5
@export var gravity: float = 24.0
@export var acceleration: float = 14.0
@export var friction: float = 10.0
@export var air_control: float = 3.5

# Camera & Aiming
@export_group("Camera & Feel")
@export var mouse_sensitivity: float = 0.0022
@export var default_fov: float = 85.0
@export var sprint_fov: float = 95.0
@export var bob_frequency: float = 2.4
@export var bob_amplitude: float = 0.06
@export var roll_tilt_angle: float = 2.5 # degrees

# Aim Assist Parameters
@export_group("Aim Assist")
@export var aim_assist_enabled: bool = true
@export var aim_friction_cone: float = 10.0 # degrees
@export var aim_friction_strength: float = 0.52 # 52% slowdown
@export var aim_snap_cone: float = 14.5 # degrees
@export var aim_snap_weight: float = 0.40 # 40% snap blend on ADS
@export var aim_rotational_speed: float = 3.2 # degrees/sec while strafing

var has_aim_assist_target: bool = false
var current_aim_target: Node3D = null

# Stats
@export_group("Stats")
@export var max_health: int = 100
@export var max_shield: int = 60

var current_health: int
var current_shield: int
var is_dead: bool = false

# Internal State
var is_sprinting: bool = false
var is_crouching: bool = false
var is_sliding: bool = false
var slide_timer: float = 0.0
var slide_direction: Vector3 = Vector3.ZERO

# Timers
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var bob_phase: float = 0.0
var camera_trauma: float = 0.0
var is_holding_interact: bool = false
var interact_hold_timer: float = 0.0

# Node References
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var weapon_holder: Node3D = $CameraPivot/WeaponHolder
@onready var weapon_manager: Node = $CameraPivot/WeaponHolder/WeaponManager
@onready var interaction_ray: RayCast3D = $CameraPivot/InteractionRay
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var default_camera_y: float = 1.6
var crouch_camera_y: float = 0.95
var default_capsule_height: float = 1.8
var crouch_capsule_height: float = 1.1

func _ready() -> void:
    add_to_group("player")
    floor_snap_length = 0.5
    floor_constant_speed = true
    floor_max_angle = deg_to_rad(55.0)
    floor_stop_on_slope = false
    acceleration = 24.0
    friction = 16.0
    current_health = max_health
    current_shield = max_shield
    
    if interaction_ray:
        interaction_ray.target_position = Vector3(0, 0, -3.2)
        
    var fl = camera.get_node_or_null("Flashlight")
    if fl:
        fl.visible = true
    
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.player_health_changed.emit(current_health, max_health)
        eb.player_shield_changed.emit(current_shield, max_shield)
        if eb.has_signal("camera_shake_requested"):
            eb.camera_shake_requested.connect(add_trauma)
        if eb.has_signal("perk_acquired"):
            eb.perk_acquired.connect(_on_perk_acquired)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    var gm = get_node_or_null("/root/GameManager")
    if is_dead or (gm and gm.current_state != gm.GameState.PLAYING):
        return
        
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        var effective_sensitivity = mouse_sensitivity
        if aim_assist_enabled:
            var is_aiming = weapon_manager and weapon_manager.get("is_aiming")
            var cone = aim_friction_cone * (1.25 if is_aiming else 1.0)
            var target_info = get_aim_assist_target(cone)
            if target_info.found:
                var mult = (1.0 - aim_friction_strength * (1.15 if is_aiming else 1.0))
                effective_sensitivity *= clamp(mult, 0.32, 0.95)
                
        # Yaw on body, Pitch on pivot
        rotate_y(-event.relative.x * effective_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * effective_sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))
        
        # Weapon sway signal
        if weapon_manager and weapon_manager.has_method("apply_mouse_sway"):
            weapon_manager.apply_mouse_sway(event.relative)
            
    # ADS Snap-to-Target when aiming starts
    if aim_assist_enabled and (event.is_action_pressed("alt_fire") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT)):
        var snap_target = get_aim_assist_target(aim_snap_cone)
        if snap_target.found:
            _snap_aim_towards(snap_target.target_pos, aim_snap_weight)
            
    if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
        is_holding_interact = true
        _try_interact()
    elif event.is_action_released("interact") or (event is InputEventKey and not event.pressed and event.keycode == KEY_E):
        is_holding_interact = false
        interact_hold_timer = 0.0
        
    # Toggle Flashlight with F key
    if event is InputEventKey and event.pressed and event.keycode == KEY_F:
        var fl = camera.get_node_or_null("Flashlight")
        if fl:
            fl.visible = !fl.visible
            var sm = get_node_or_null("/root/SoundManager")
            if sm: sm.play_sfx("dry_fire", 0.05, 0.0)

func _physics_process(delta: float) -> void:
    if is_dead:
        return
        
    if is_holding_interact:
        interact_hold_timer += delta
        if interact_hold_timer >= 0.35:
            interact_hold_timer = 0.0
            _try_interact()
        
    _update_timers(delta)
    _handle_crouch_and_slide(delta)
    _handle_movement(delta)
    _handle_aim_assist_physics(delta)
    _handle_camera_dynamics(delta)
    move_and_slide()

func _update_timers(delta: float) -> void:
    if is_on_floor():
        coyote_timer = 0.15
    else:
        coyote_timer = max(0.0, coyote_timer - delta)
        
    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = 0.10
    else:
        jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

func _handle_crouch_and_slide(delta: float) -> void:
    var want_crouch = Input.is_action_pressed("crouch")
    
    # Trigger slide if sprinting when pressing crouch on the floor
    if want_crouch and not is_crouching and is_sprinting and is_on_floor():
        is_sliding = true
        slide_timer = 0.75
        slide_direction = -transform.basis.z.normalized()
        var sm = get_node_or_null("/root/SoundManager")
        if sm: sm.play_sfx("footstep", 0.1, -2.0)
        
    if is_sliding:
        slide_timer -= delta
        if slide_timer <= 0.0 or not want_crouch:
            is_sliding = false
            
    is_crouching = want_crouch
    
    # Smoothly adjust camera & collider height
    var target_cam_y = crouch_camera_y if (is_crouching or is_sliding) else default_camera_y
    camera_pivot.position.y = lerp(camera_pivot.position.y, target_cam_y, delta * 12.0)
    
    var shape = collision_shape.shape as CapsuleShape3D
    if shape:
        var target_height = crouch_capsule_height if (is_crouching or is_sliding) else default_capsule_height
        shape.height = lerp(shape.height, target_height, delta * 12.0)

func _handle_movement(delta: float) -> void:
    # Gravity & Floor Snapping
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.5
        
    # Jump buffering + Coyote time
    var want_jump = (jump_buffer_timer > 0.0 or Input.is_key_pressed(KEY_SPACE)) and coyote_timer > 0.0
    if want_jump:
        velocity.y = jump_velocity
        jump_buffer_timer = 0.0
        coyote_timer = 0.0
        is_sliding = false
        var sm = get_node_or_null("/root/SoundManager")
        if sm: sm.play_sfx("footstep", 0.08, 0.0)

    # Input direction with direct key fallbacks
    var input_dir = Vector2.ZERO
    if not is_sliding:
        input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
        if input_dir.length_squared() < 0.01:
            var raw_x: float = 0.0
            var raw_y: float = 0.0
            if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): raw_y -= 1.0
            if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): raw_y += 1.0
            if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): raw_x -= 1.0
            if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): raw_x += 1.0
            input_dir = Vector2(raw_x, raw_y).normalized()
        
    var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    var want_sprint = (Input.is_action_pressed("sprint") or Input.is_key_pressed(KEY_SHIFT)) and input_dir.y < -0.1 and not is_crouching and not is_sliding
    is_sprinting = want_sprint
    
    var target_speed: float = walk_speed
    if is_sliding:
        target_speed = slide_boost * (slide_timer / 0.75)
        move_dir = slide_direction
    elif is_crouching:
        target_speed = crouch_speed
    elif is_sprinting:
        target_speed = sprint_speed

    var accel = acceleration if is_on_floor() else air_control
    var friction_rate = friction if is_on_floor() else 1.0
    
    if move_dir.length_squared() > 0.001:
        var target_vel = move_dir * target_speed
        velocity.x = lerp(velocity.x, target_vel.x, accel * delta)
        velocity.z = lerp(velocity.z, target_vel.z, accel * delta)
    else:
        velocity.x = lerp(velocity.x, 0.0, friction_rate * delta)
        velocity.z = lerp(velocity.z, 0.0, friction_rate * delta)

func _handle_camera_dynamics(delta: float) -> void:
    # 1. Dynamic FOV
    var target_fov = sprint_fov if is_sprinting else default_fov
    camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
    
    # 2. Camera Roll / Tilt during strafe and slide
    var strafe_input = Input.get_axis("move_right", "move_left")
    var target_roll = deg_to_rad(strafe_input * roll_tilt_angle)
    if is_sliding:
        target_roll *= 1.8
    camera.rotation.z = lerp(camera.rotation.z, target_roll, delta * 10.0)
    
    # 3. Procedural Head Bob
    var horizontal_speed = Vector2(velocity.x, velocity.z).length()
    if is_on_floor() and horizontal_speed > 1.0 and not is_sliding:
        bob_phase += delta * bob_frequency * (horizontal_speed / walk_speed)
        var bob_offset_y = sin(bob_phase * 2.0) * bob_amplitude
        var bob_offset_x = cos(bob_phase) * (bob_amplitude * 0.5)
        camera.position.y = bob_offset_y
        camera.position.x = bob_offset_x
        
        # Periodic footstep SFX at wave valley
        if sin(bob_phase * 2.0) < -0.95 and fmod(bob_phase, PI) < 0.15:
            var sm = get_node_or_null("/root/SoundManager")
            if sm: sm.play_sfx("footstep", 0.12, -4.0)
    else:
        camera.position.x = lerp(camera.position.x, 0.0, delta * 10.0)
        camera.position.y = lerp(camera.position.y, 0.0, delta * 10.0)
        bob_phase = 0.0
        
    # 4. Trauma-based Camera Shake
    if camera_trauma > 0.0:
        camera_trauma = max(0.0, camera_trauma - delta * 1.5)
        var shake_amount = camera_trauma * camera_trauma
        camera.rotation.x += randf_range(-0.04, 0.04) * shake_amount
        camera.rotation.y += randf_range(-0.04, 0.04) * shake_amount

func add_trauma(amount: float) -> void:
    camera_trauma = clamp(camera_trauma + amount, 0.0, 1.0)

func take_damage(amount: int, attacker_pos: Vector3 = Vector3.ZERO) -> void:
    if is_dead:
        return
        
    # Shield absorbs 65% of damage
    var absorbed_by_shield = int(amount * 0.65)
    var leftover_damage = amount - absorbed_by_shield
    
    if current_shield > 0:
        if current_shield >= absorbed_by_shield:
            current_shield -= absorbed_by_shield
        else:
            leftover_damage += (absorbed_by_shield - current_shield)
            current_shield = 0
            
    current_health = max(0, current_health - leftover_damage)
    
    add_trauma(0.4)
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.player_health_changed.emit(current_health, max_health)
        eb.player_shield_changed.emit(current_shield, max_shield)
        eb.player_damaged.emit(amount, attacker_pos)
        eb.damage_vignette_requested.emit(0.8)
    
    if current_health <= 0:
        _die()

func heal(amount: int) -> void:
    if is_dead:
        return
    current_health = min(max_health, current_health + amount)
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.player_health_changed.emit(current_health, max_health)
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx("pickup", 0.05, 0.0)

func add_shield(amount: int) -> void:
    if is_dead:
        return
    current_shield = min(max_shield, current_shield + amount)
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.player_shield_changed.emit(current_shield, max_shield)
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx("pickup", 0.05, 0.0)

func _die() -> void:
    is_dead = true
    velocity = Vector3.ZERO
    add_trauma(0.9)
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.player_died.emit()

func _try_interact() -> void:
    if interaction_ray and interaction_ray.is_colliding():
        var collider = interaction_ray.get_collider()
        if collider and collider.has_method("interact"):
            collider.interact(self)

func get_current_interaction_prompt() -> String:
    if interaction_ray and interaction_ray.is_colliding():
        var collider = interaction_ray.get_collider()
        if collider:
            if collider.has_method("get_interaction_prompt"):
                for m in collider.get_method_list():
                    if m["name"] == "get_interaction_prompt":
                        if m["args"].size() == 0:
                            return collider.call("get_interaction_prompt")
                        else:
                            return collider.call("get_interaction_prompt", self)
                return collider.call("get_interaction_prompt", self)
            elif collider.has_method("interact"):
                return "[E] INTERACT"
    return ""

func _on_perk_acquired(perk_name: String) -> void:
    if perk_name.to_lower() == "juggernog":
        max_health = 250
        current_health = 250
        var eb = get_node_or_null("/root/EventBus")
        if eb:
            eb.player_health_changed.emit(current_health, max_health)

# ==============================================================================
# AIM ASSIST SYSTEM (Target Friction, ADS Snap, Rotational Tracking, Reticle)
# ==============================================================================

func _handle_aim_assist_physics(delta: float) -> void:
    if not aim_assist_enabled:
        return
        
    var is_aiming = weapon_manager and weapon_manager.get("is_aiming")
    
    # 1. Rotational tracking while strafing/moving
    if velocity.length_squared() > 1.0:
        var track_info = get_aim_assist_target(aim_friction_cone * 0.95)
        if track_info.found:
            var cam_pos = camera.global_position
            var to_target = (track_info.target_pos - cam_pos).normalized()
            var target_yaw = atan2(-to_target.x, -to_target.z)
            var max_yaw_delta = deg_to_rad(aim_rotational_speed * (1.6 if is_aiming else 1.0) * delta)
            var yaw_diff = angle_difference(rotation.y, target_yaw)
            rotation.y += clamp(yaw_diff, -max_yaw_delta, max_yaw_delta)
            
    # 2. Reticle lock-on detection & EventBus broadcast
    var reticle_info = get_aim_assist_target(7.5 if is_aiming else 5.5)
    var has_target = reticle_info.found
    if has_target != has_aim_assist_target or reticle_info.enemy != current_aim_target:
        has_aim_assist_target = has_target
        current_aim_target = reticle_info.enemy
        var eb = get_node_or_null("/root/EventBus")
        if eb:
            eb.aim_assist_target_changed.emit(has_target, current_aim_target, reticle_info.screen_pos)

func _snap_aim_towards(target_pos: Vector3, blend_weight: float) -> void:
    if not camera:
        return
    var cam_pos = camera.global_position
    var to_target = (target_pos - cam_pos).normalized()
    if to_target.is_zero_approx():
        return
        
    # Yaw on body (Y rotation)
    var target_yaw = atan2(-to_target.x, -to_target.z)
    rotation.y = lerp_angle(rotation.y, target_yaw, blend_weight)
    
    # Pitch on camera pivot (X rotation)
    var horiz_dist = Vector2(to_target.x, to_target.z).length()
    var target_pitch = atan2(to_target.y, horiz_dist)
    camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x, target_pitch, blend_weight)
    camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))
    
    var sm = get_node_or_null("/root/SoundManager")
    if sm:
        sm.play_sfx("dry_fire", 0.04, 3.0)

func get_aim_assist_target(max_angle_deg: float = 12.0, max_dist: float = 45.0) -> Dictionary:
    var result = {
        "found": false,
        "enemy": null,
        "target_pos": Vector3.ZERO,
        "angle_deg": 999.0,
        "screen_pos": Vector2.ZERO
    }
    if not camera or not is_inside_tree():
        return result
        
    var cam_forward = -camera.global_transform.basis.z.normalized()
    var cam_origin = camera.global_position
    var enemies = get_tree().get_nodes_in_group("enemies")
    
    var best_angle = max_angle_deg
    var best_enemy = null
    var best_pos = Vector3.ZERO
    
    var space_state = get_world_3d().direct_space_state
    
    for e in enemies:
        if not is_instance_valid(e) or e.is_queued_for_deletion():
            continue
        if e.get("is_dead") == true:
            continue
            
        var target_pos = e.global_position
        if not e.get("is_flying"):
            target_pos += Vector3(0, 1.1, 0)
            
        var to_target = target_pos - cam_origin
        var dist = to_target.length()
        if dist > max_dist or dist < 0.6:
            continue
            
        var dir_to_target = to_target / dist
        var angle = rad_to_deg(cam_forward.angle_to(dir_to_target))
        if angle < best_angle:
            var ray_query = PhysicsRayQueryParameters3D.create(cam_origin, target_pos)
            ray_query.collision_mask = 1 # World layer
            var hit = space_state.intersect_ray(ray_query)
            if hit.is_empty():
                best_angle = angle
                best_enemy = e
                best_pos = target_pos
                
    if best_enemy:
        result.found = true
        result.enemy = best_enemy
        result.target_pos = best_pos
        result.angle_deg = best_angle
        if not camera.is_position_behind(best_pos):
            result.screen_pos = camera.unproject_position(best_pos)
            
    return result

## First-person kinematic character body with physical spring recoil

# 2nd-order damped harmonic spring model: pos += vel*dt, vel += (target-pos)*k - vel*d

# Mouse sensitivity conversion: pitch clamped between -89.0 and +89.0 degrees

# HeightMapShape3D integration: floor_snap_length = 0.5 prevents edge detachment

# Jump buffering allows 0.15s pre-landing jump requests to trigger on floor contact

# Head-bob sine wave evaluates horizontal velocity magnitude for step frequency
