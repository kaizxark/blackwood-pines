class_name BaseZombie
extends CharacterBody3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Humanoid Zombie NPC Controller
# Features modular articulated limbs, procedural locomotion & limp animation,
# claw attack routines, headshot decapitation with blood fountains, and audio groans.

enum ZombieType {
    WALKER,
    RUNNER,
    BRUTE,
    CRAWLER
}

enum ZombieState {
    SPAWNING,
    WANDER,
    CHASE,
    ATTACK,
    TEARING_BARRICADE,
    STAGGER,
    DEAD
}

@export var zombie_type: ZombieType = ZombieType.WALKER
@export var enemy_name: String = "Zombie Walker"
@export var max_health: int = 75
@export var base_speed: float = 2.4
@export var attack_damage: int = 15
@export var attack_range: float = 1.7
@export var attack_cooldown: float = 1.2
@export var score_value: int = 60

var current_state: ZombieState = ZombieState.WANDER
var current_health: int
var is_dead: bool = false
var is_flying: bool = false # for aim assist compatibility

# Target & Navigation
var target_player: CharacterBody3D = null
var target_barricade: Node3D = null
var current_velocity_horizontal: Vector3 = Vector3.ZERO

# Animation state variables
var anim_phase: float = 0.0
var attack_anim_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var stagger_timer: float = 0.0
var groan_timer: float = 0.0
var is_attacking: bool = false
var has_decapitated: bool = false

# Node references
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visual_root: Node3D = $VisualRoot
@onready var head_node: Node3D = $VisualRoot/Head
@onready var torso_node: Node3D = $VisualRoot/Torso
@onready var left_arm_pivot: Node3D = $VisualRoot/LeftArmPivot
@onready var right_arm_pivot: Node3D = $VisualRoot/RightArmPivot
@onready var left_leg_pivot: Node3D = $VisualRoot/LeftLegPivot
@onready var right_leg_pivot: Node3D = $VisualRoot/RightLegPivot
@onready var blood_fountain: CPUParticles3D = $VisualRoot/Neck/BloodFountain
@onready var eyes_light: OmniLight3D = $VisualRoot/Head/EyesLight

func _ready() -> void:
    add_to_group("enemies")
    add_to_group("zombies")
    
    _configure_archetype()
    current_health = max_health
    groan_timer = randf_range(2.0, 6.0)
    
    # Locate player
    target_player = get_tree().get_first_node_in_group("player") as CharacterBody3D
    
    var eb = get_node_or_null("/root/EventBus")
    if eb and eb.has_signal("weapon_fired"):
        eb.weapon_fired.connect(_on_weapon_heard)

func _on_weapon_heard(_w_name: String, _ammo: int, _max_ammo: int) -> void:
    if is_dead: return
    if not is_instance_valid(target_player):
        target_player = get_tree().get_first_node_in_group("player") as CharacterBody3D
    if target_player:
        current_state = ZombieState.CHASE

func _configure_archetype() -> void:
    match zombie_type:
        ZombieType.WALKER:
            enemy_name = "Zombie Walker"
            max_health = 75
            base_speed = randf_range(2.0, 2.7)
            attack_damage = 15
            score_value = 60
        ZombieType.RUNNER:
            enemy_name = "Infected Sprinter"
            max_health = 50
            base_speed = randf_range(5.8, 7.0)
            attack_damage = 20
            score_value = 75
            scale = Vector3(0.95, 0.95, 0.95)
        ZombieType.BRUTE:
            enemy_name = "Mutated Brute"
            max_health = 350
            base_speed = 1.8
            attack_damage = 38
            score_value = 250
            scale = Vector3(1.35, 1.35, 1.35)
        ZombieType.CRAWLER:
            enemy_name = "Crawler"
            max_health = 40
            base_speed = 1.3
            attack_damage = 22
            score_value = 50
            position.y -= 0.6
            if left_leg_pivot: left_leg_pivot.visible = false
            if right_leg_pivot: right_leg_pivot.visible = false

func _physics_process(delta: float) -> void:
    if is_dead:
        _process_death_drift(delta)
        return
        
    _update_timers(delta)
    _update_ai_state(delta)
    _apply_movement_physics(delta)
    _update_procedural_animation(delta)
    move_and_slide()

func _update_timers(delta: float) -> void:
    if attack_cooldown_timer > 0.0:
        attack_cooldown_timer = max(0.0, attack_cooldown_timer - delta)
        
    if attack_anim_timer > 0.0:
        attack_anim_timer -= delta
        if attack_anim_timer <= 0.0:
            is_attacking = false
            
    if stagger_timer > 0.0:
        stagger_timer -= delta
        
    groan_timer -= delta
    if groan_timer <= 0.0:
        groan_timer = randf_range(4.0, 9.0)
        _play_groan()

func _play_groan() -> void:
    var sm = get_node_or_null("/root/SoundManager")
    if sm:
        if zombie_type == ZombieType.RUNNER and current_state == ZombieState.CHASE:
            sm.play_sfx_3d("zombie_shriek", global_position, 30.0, 2.0)
        else:
            var sounds = ["zombie_groan_1", "zombie_groan_2", "zombie_groan_3"]
            sm.play_sfx_3d(sounds[randi() % sounds.size()], global_position, 25.0, 0.0)

func _update_ai_state(_delta: float) -> void:
    if stagger_timer > 0.0:
        current_state = ZombieState.STAGGER
        return
        
    if current_state == ZombieState.TEARING_BARRICADE:
        if is_instance_valid(target_barricade):
            _face_target(target_barricade.global_position)
            return
        else:
            current_state = ZombieState.CHASE
        
    if not is_instance_valid(target_player):
        target_player = get_tree().get_first_node_in_group("player") as CharacterBody3D
        if not target_player:
            current_state = ZombieState.WANDER
            return

    var dist_to_player = global_position.distance_to(target_player.global_position)
    
    # 1. Attack Range Check
    if dist_to_player <= attack_range:
        current_state = ZombieState.ATTACK
        if attack_cooldown_timer <= 0.0 and not is_attacking:
            _execute_attack()
    else:
        current_state = ZombieState.CHASE

func on_reached_barricade(barricade: Node3D) -> void:
    target_barricade = barricade
    current_state = ZombieState.TEARING_BARRICADE

func on_barricade_breached(barricade: Node3D) -> void:
    if target_barricade == barricade:
        target_barricade = null
        current_state = ZombieState.CHASE

func _execute_attack() -> void:
    is_attacking = true
    attack_anim_timer = 0.55
    attack_cooldown_timer = attack_cooldown
    
    # Look directly at player
    _face_target(target_player.global_position)
    
    # Delay hit window slightly to match swipe animation
    get_tree().create_timer(0.24).timeout.connect(func():
        if is_dead: return
        if is_instance_valid(target_player) and global_position.distance_to(target_player.global_position) <= (attack_range + 0.4):
            if target_player.has_method("take_damage"):
                target_player.take_damage(attack_damage, (target_player.global_position - global_position).normalized())
    )

func _apply_movement_physics(delta: float) -> void:
    # Gravity
    if not is_on_floor():
        velocity.y -= 22.0 * delta
    else:
        velocity.y = -0.5
        
    if current_state == ZombieState.STAGGER:
        velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)
        return
        
    if current_state == ZombieState.ATTACK or current_state == ZombieState.TEARING_BARRICADE:
        velocity.x = move_toward(velocity.x, 0.0, 18.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 18.0 * delta)
        return

    if current_state == ZombieState.CHASE and is_instance_valid(target_player):
        var player_pos = target_player.global_position
        var to_player = (player_pos - global_position).normalized()
        to_player.y = 0.0
        
        var move_dir = _calculate_avoidance_direction(to_player)
        _face_target(global_position + move_dir * 4.0)
        
        velocity.x = move_toward(velocity.x, move_dir.x * base_speed, 18.0 * delta)
        velocity.z = move_toward(velocity.z, move_dir.z * base_speed, 18.0 * delta)

func _calculate_avoidance_direction(desired_dir: Vector3) -> Vector3:
    var space_state = get_world_3d().direct_space_state
    if not space_state: return desired_dir
    
    var origin = global_position + Vector3(0, 0.8, 0)
    var fwd = desired_dir.normalized()
    
    # Forward ray probe
    var q_fwd = PhysicsRayQueryParameters3D.create(origin, origin + fwd * 1.8, 1)
    q_fwd.exclude = [self]
    var hit_fwd = space_state.intersect_ray(q_fwd)
    
    if hit_fwd.is_empty():
        return desired_dir
        
    # Whiskers: Left (-35 deg) and Right (+35 deg)
    var left_dir = fwd.rotated(Vector3.UP, deg_to_rad(35.0))
    var right_dir = fwd.rotated(Vector3.UP, deg_to_rad(-35.0))
    
    var q_left = PhysicsRayQueryParameters3D.create(origin, origin + left_dir * 1.8, 1)
    q_left.exclude = [self]
    var hit_left = space_state.intersect_ray(q_left)
    
    var q_right = PhysicsRayQueryParameters3D.create(origin, origin + right_dir * 1.8, 1)
    q_right.exclude = [self]
    var hit_right = space_state.intersect_ray(q_right)
    
    if hit_left.is_empty() and not hit_right.is_empty():
        return left_dir
    elif hit_right.is_empty() and not hit_left.is_empty():
        return right_dir
    elif hit_left.is_empty() and hit_right.is_empty():
        return left_dir if randf() > 0.5 else right_dir
    else:
        return fwd.rotated(Vector3.UP, deg_to_rad(75.0))

func _face_target(target_pos: Vector3) -> void:
    var to_target = target_pos - global_position
    to_target.y = 0.0
    if to_target.length_squared() > 0.01:
        var target_yaw = atan2(-to_target.x, -to_target.z)
        rotation.y = lerp_angle(rotation.y, target_yaw, 0.18)

# ==============================================================================
# PROCEDURAL ZOMBIE ANIMATION ENGINE
# ==============================================================================

func _update_procedural_animation(delta: float) -> void:
    var h_vel = Vector2(velocity.x, velocity.z).length()
    
    # 1. Locomotion Cycle
    if h_vel > 0.1:
        var anim_speed_mult = 4.2 if zombie_type != ZombieType.RUNNER else 7.5
        anim_phase += delta * h_vel * anim_speed_mult
        
        var leg_swing = sin(anim_phase) * 0.65
        var limp_bias = 0.12 * sin(anim_phase * 0.5)
        
        if left_leg_pivot and right_leg_pivot:
            left_leg_pivot.rotation.x = leg_swing + limp_bias
            right_leg_pivot.rotation.x = -leg_swing
            
        if torso_node:
            torso_node.rotation.z = sin(anim_phase * 0.5) * 0.06
            torso_node.rotation.x = deg_to_rad(12.0) + sin(anim_phase) * 0.04
            
        if head_node and not has_decapitated:
            head_node.rotation.z = cos(anim_phase * 0.5) * 0.14
            head_node.rotation.y = sin(anim_phase * 0.7) * 0.1
    else:
        # Idle breathing
        anim_phase += delta * 2.0
        if torso_node:
            torso_node.position.y = lerp(torso_node.position.y, 0.95 + sin(anim_phase) * 0.02, delta * 5.0)

    # 2. Arm Poses & Attack Swipes
    if is_attacking:
        var progress = 1.0 - (attack_anim_timer / 0.55)
        var slash = sin(progress * PI)
        if right_arm_pivot:
            right_arm_pivot.rotation.x = lerp(-deg_to_rad(120.0), deg_to_rad(30.0), slash)
            right_arm_pivot.rotation.y = lerp(0.0, deg_to_rad(45.0), slash)
        if left_arm_pivot:
            left_arm_pivot.rotation.x = lerp(-deg_to_rad(80.0), deg_to_rad(20.0), slash)
    else:
        # Standard outstretched zombie grab
        var arm_sway = sin(anim_phase * 0.8) * 0.12
        if left_arm_pivot:
            left_arm_pivot.rotation.x = lerp(left_arm_pivot.rotation.x, -deg_to_rad(75.0) + arm_sway, delta * 8.0)
            left_arm_pivot.rotation.y = lerp(left_arm_pivot.rotation.y, deg_to_rad(10.0), delta * 8.0)
        if right_arm_pivot:
            right_arm_pivot.rotation.x = lerp(right_arm_pivot.rotation.x, -deg_to_rad(80.0) - arm_sway, delta * 8.0)
            right_arm_pivot.rotation.y = lerp(right_arm_pivot.rotation.y, -deg_to_rad(10.0), delta * 8.0)

# ==============================================================================
# DAMAGE, HEADSHOTS & DECAPITATION
# ==============================================================================

func take_damage(amount: int, hit_normal: Vector3, is_headshot: bool = false) -> void:
    if is_dead:
        return
        
    current_health -= amount
    
    # Recoil stagger
    stagger_timer = 0.22 if zombie_type != ZombieType.BRUTE else 0.08
    velocity += -hit_normal * (3.5 if is_headshot else 2.0)
    
    if torso_node:
        torso_node.rotation.x -= 0.35
        
    # Check Headshot Decapitation
    if is_headshot:
        _trigger_headshot_decapitation()
        
    if current_health <= 0:
        _die(is_headshot)

func _trigger_headshot_decapitation() -> void:
    if has_decapitated: return
    has_decapitated = true
    
    if head_node:
        head_node.visible = false
    if blood_fountain:
        blood_fountain.emitting = true
        blood_fountain.restart()
    if eyes_light:
        eyes_light.visible = false
        
    # Extra gore chunks
    _spawn_head_chunks()

func _spawn_head_chunks() -> void:
    var chunks = CPUParticles3D.new()
    chunks.emitting = false
    chunks.one_shot = true
    chunks.explosiveness = 1.0
    chunks.amount = 14
    chunks.lifetime = 0.5
    chunks.direction = Vector3(0, 1, 0)
    chunks.spread = 60.0
    chunks.initial_velocity_min = 4.0
    chunks.initial_velocity_max = 7.0
    chunks.gravity = Vector3(0, -12.0, 0)
    
    var bmesh = BoxMesh.new()
    bmesh.size = Vector3(0.06, 0.06, 0.06)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.35, 0.02, 0.02)
    chunks.mesh = bmesh
    chunks.material_override = mat
    
    get_tree().root.add_child(chunks)
    chunks.global_position = global_position + Vector3(0, 1.5, 0)
    chunks.restart()
    get_tree().create_timer(0.8).timeout.connect(func(): if is_instance_valid(chunks): chunks.queue_free())

func _die(is_headshot: bool) -> void:
    is_dead = true
    current_state = ZombieState.DEAD
    
    # Disable collisions so player doesn't trip
    set_collision_layer_value(3, false)
    set_collision_mask_value(1, false)
    set_collision_mask_value(2, false)
    
    var final_score = 100 if is_headshot else score_value
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.enemy_killed.emit(enemy_name, final_score)
        eb.zombie_killed.emit(is_headshot, final_score)
        
    # Death collapse animation
    var tween = create_tween()
    var death_rot = -deg_to_rad(85.0) if randf() > 0.5 else deg_to_rad(85.0)
    tween.tween_property(visual_root, "rotation:x", death_rot, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(visual_root, "position:y", -0.7, 0.35)
    
    # Despawn corpse after 12 seconds
    get_tree().create_timer(12.0).timeout.connect(func():
        if is_instance_valid(self):
            var fade_tween = create_tween()
            fade_tween.tween_property(self, "position:y", position.y - 1.0, 1.5)
            fade_tween.tween_callback(queue_free)
    )

func _process_death_drift(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= 22.0 * delta
    else:
        velocity.y = 0.0
    velocity.x = move_toward(velocity.x, 0.0, 15.0 * delta)
    velocity.z = move_toward(velocity.z, 0.0, 15.0 * delta)
    move_and_slide()
