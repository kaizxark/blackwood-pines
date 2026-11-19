class_name BaseEnemy
extends CharacterBody3D

# BaseEnemy for PROJECT PROTO-BREACH
# Modular FSM Enemy with NavigationAgent3D pathfinding, sensory sight/hearing,
# procedural hit reactions, and combat state handling.

enum AIState {
    IDLE,
    PATROL,
    ALERT,
    CHASE,
    ATTACK,
    STAGGER,
    DEAD
}

@export_group("Stats")
@export var enemy_name: String = "Enforcer"
@export var max_health: int = 90
@export var score_value: int = 150
@export var is_flying: bool = false

@export_group("Locomotion")
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 6.0
@export var gravity: float = 20.0
@export var acceleration: float = 8.0

@export_group("Combat")
@export var attack_range: float = 18.0
@export var attack_cooldown: float = 1.4
@export var attack_damage: int = 14
@export var vision_angle_deg: float = 110.0
@export var vision_range: float = 28.0
@export var hearing_range: float = 32.0

var current_state: AIState = AIState.PATROL
var current_health: int
var target_player: CharacterBody3D = null
var last_known_player_pos: Vector3 = Vector3.ZERO

# Timers
var state_timer: float = 0.0
var attack_timer: float = 0.0
var patrol_wait_timer: float = 0.0

# Node references
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_ray: RayCast3D = $VisionRay
@onready var visual_root: Node3D = $VisualRoot

var patrol_origin: Vector3
var current_patrol_target: Vector3

func _ready() -> void:
    add_to_group("enemies")
    current_health = max_health
    patrol_origin = global_position
    current_patrol_target = patrol_origin
    
    # Configure nav agent
    if nav_agent:
        nav_agent.path_desired_distance = 1.0
        nav_agent.target_desired_distance = 1.5
        
    _connect_events()
    _find_player()

func _connect_events() -> void:
    var eb = get_node_or_null("/root/EventBus")
    if eb and eb.has_signal("weapon_fired"):
        eb.weapon_fired.connect(_on_weapon_fired)

func _find_player() -> void:
    var players = get_tree().get_nodes_in_group("player")
    if not players.is_empty():
        target_player = players[0] as CharacterBody3D

func _physics_process(delta: float) -> void:
    if current_state == AIState.DEAD:
        return
        
    if not target_player or not is_instance_valid(target_player):
        _find_player()
        
    attack_timer = max(0.0, attack_timer - delta)
    state_timer += delta
    
    _check_sensory_perception()
    _execute_state_behavior(delta)
    
    if not is_flying and not is_on_floor():
        velocity.y -= gravity * delta
    elif is_flying:
        velocity.y = lerp(velocity.y, 0.0, delta * 4.0)
        
    move_and_slide()

func _check_sensory_perception() -> void:
    if not target_player or target_player.get("is_dead") == true:
        if current_state in [AIState.CHASE, AIState.ATTACK]:
            _transition_to(AIState.PATROL)
        return
        
    var to_player = target_player.global_position - global_position
    var dist = to_player.length()
    
    if dist > vision_range:
        return
        
    # Check vision cone angle
    var forward = -global_transform.basis.z.normalized()
    var dir_to_player = to_player.normalized()
    var angle = rad_to_deg(forward.angle_to(dir_to_player))
    
    if angle <= (vision_angle_deg * 0.5) or dist < 4.0: # Close proximity always detects
        # Raycast check for wall occlusion
        if vision_ray:
            vision_ray.target_position = vision_ray.to_local(target_player.global_position + Vector3(0, 1.2, 0))
            vision_ray.force_raycast_update()
            
            if not vision_ray.is_colliding() or vision_ray.get_collider() == target_player:
                last_known_player_pos = target_player.global_position
                if current_state in [AIState.IDLE, AIState.PATROL, AIState.ALERT]:
                    _alert_enemy()
                    _transition_to(AIState.CHASE)

func _alert_enemy() -> void:
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.enemy_alerted.emit(self)
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx_3d("footstep", global_position, 20.0, 2.0)

func _execute_state_behavior(delta: float) -> void:
    match current_state:
        AIState.PATROL:
            _process_patrol(delta)
        AIState.ALERT:
            _process_alert(delta)
        AIState.CHASE:
            _process_chase(delta)
        AIState.ATTACK:
            _process_attack(delta)
        AIState.STAGGER:
            if state_timer > 0.35:
                _transition_to(AIState.CHASE)

func _process_patrol(delta: float) -> void:
    var dist_to_patrol = global_position.distance_to(current_patrol_target)
    if dist_to_patrol < 2.0:
        patrol_wait_timer += delta
        velocity.x = lerp(velocity.x, 0.0, delta * 6.0)
        velocity.z = lerp(velocity.z, 0.0, delta * 6.0)
        if patrol_wait_timer > randf_range(2.0, 4.0):
            patrol_wait_timer = 0.0
            var offset = Vector3(randf_range(-10.0, 10.0), 0, randf_range(-10.0, 10.0))
            current_patrol_target = patrol_origin + offset
            if nav_agent:
                nav_agent.target_position = current_patrol_target
    else:
        _move_towards_target(nav_agent.get_next_path_position() if nav_agent else current_patrol_target, patrol_speed, delta)

func _process_alert(delta: float) -> void:
    _move_towards_target(last_known_player_pos, chase_speed * 0.8, delta)
    if global_position.distance_to(last_known_player_pos) < 2.5 or state_timer > 6.0:
        _transition_to(AIState.PATROL)

func _process_chase(delta: float) -> void:
    if not target_player:
        _transition_to(AIState.PATROL)
        return
        
    var dist = global_position.distance_to(target_player.global_position)
    if nav_agent:
        nav_agent.target_position = target_player.global_position
        
    var next_pos = nav_agent.get_next_path_position() if nav_agent else target_player.global_position
    _move_towards_target(next_pos, chase_speed, delta)
    
    if dist <= attack_range:
        _transition_to(AIState.ATTACK)

func _process_attack(delta: float) -> void:
    if not target_player:
        _transition_to(AIState.PATROL)
        return
        
    var dist = global_position.distance_to(target_player.global_position)
    # Face player
    _face_target(target_player.global_position, delta * 8.0)
    
    # Strafing movement
    var strafe_dir = global_transform.basis.x * sin(state_timer * 2.0)
    velocity.x = lerp(velocity.x, strafe_dir.x * 2.5, delta * 4.0)
    velocity.z = lerp(velocity.z, strafe_dir.z * 2.5, delta * 4.0)
    
    if attack_timer <= 0.0:
        _execute_attack()
        attack_timer = attack_cooldown
        
    if dist > (attack_range * 1.35):
        _transition_to(AIState.CHASE)

func _move_towards_target(target_pos: Vector3, speed: float, delta: float) -> void:
    var dir = (target_pos - global_position)
    if not is_flying:
        dir.y = 0.0
    dir = dir.normalized()
    
    velocity.x = lerp(velocity.x, dir.x * speed, delta * acceleration)
    velocity.z = lerp(velocity.z, dir.z * speed, delta * acceleration)
    if is_flying:
        velocity.y = lerp(velocity.y, dir.y * speed, delta * acceleration)
        
    _face_target(global_position + dir * 5.0, delta * 6.0)

func _face_target(target_pos: Vector3, blend: float) -> void:
    var look_dir = target_pos - global_position
    if not is_flying:
        look_dir.y = 0.0
    if look_dir.length_squared() > 0.01:
        var target_basis = Basis.looking_at(look_dir.normalized(), Vector3.UP)
        global_transform.basis = global_transform.basis.slerp(target_basis, clamp(blend, 0.0, 1.0))

func _execute_attack() -> void:
    # Virtual method overridden by specialized enemies
    if target_player and target_player.has_method("take_damage"):
        var sm = get_node_or_null("/root/SoundManager")
        if sm: sm.play_sfx_3d("pistol_fire", global_position, 35.0, -2.0)
        # Apply damage if line of sight is clear
        target_player.take_damage(attack_damage, global_position)

func _transition_to(new_state: AIState) -> void:
    current_state = new_state
    state_timer = 0.0

func _on_weapon_fired(_w_name: String, _ammo: int, _max: int) -> void:
    if current_state in [AIState.IDLE, AIState.PATROL]:
        if target_player and global_position.distance_to(target_player.global_position) <= hearing_range:
            last_known_player_pos = target_player.global_position
            _alert_enemy()
            _transition_to(AIState.ALERT)

func take_damage(amount: int, hit_normal: Vector3, is_headshot: bool = false) -> void:
    if current_state == AIState.DEAD:
        return
        
    current_health -= amount
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.enemy_damaged.emit(self, amount, is_headshot)
    
    # Hit reaction impulse
    velocity += hit_normal * 4.0
    _transition_to(AIState.STAGGER)
    
    # Visual damage flash
    _flash_hit_materials()
    
    if current_health <= 0:
        _die()

func _flash_hit_materials() -> void:
    if not visual_root:
        return
    var tween = create_tween()
    for mesh in visual_root.find_children("", "MeshInstance3D"):
        var original_color = Color(1, 1, 1)
        if mesh.material_override:
            original_color = mesh.material_override.albedo_color
            mesh.material_override.albedo_color = Color(1.5, 0.2, 0.2)
            tween.tween_callback(func(): mesh.material_override.albedo_color = original_color).set_delay(0.08)

func _die() -> void:
    current_state = AIState.DEAD
    velocity = Vector3.ZERO
    set_collision_layer_value(3, false)
    set_collision_mask_value(2, false)
    
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.enemy_killed.emit(enemy_name, score_value)
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx_3d("explosion", global_position, 40.0, 1.0)
    
    # Spawn death particles
    _spawn_death_explosion()
    
    # Death scale down and queue_free
    var tween = create_tween()
    tween.tween_property(visual_root, "scale", Vector3(0.01, 0.01, 0.01), 0.35)
    tween.tween_callback(func(): queue_free())

func _spawn_death_explosion() -> void:
    var sparks = CPUParticles3D.new()
    sparks.emitting = true
    sparks.one_shot = true
    sparks.explosiveness = 0.95
    sparks.amount = 25
    sparks.lifetime = 0.5
    sparks.initial_velocity_min = 4.0
    sparks.initial_velocity_max = 10.0
    sparks.spread = 180.0
    var mat = StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(1.0, 0.4, 0.1)
    sparks.material_override = mat
    
    get_tree().root.add_child(sparks)
    sparks.global_position = global_position + Vector3(0, 1.0, 0)
    get_tree().create_timer(0.6).timeout.connect(func(): if is_instance_valid(sparks): sparks.queue_free())
