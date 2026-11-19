class_name EnforcerEnemy
extends "res://entities/enemies/base/BaseEnemy.gd"

# EnforcerEnemy - Heavy ground trooper firing 3-round bursts

var is_bursting: bool = false
var burst_count: int = 0

func _ready() -> void:
    enemy_name = "Security Enforcer"
    max_health = 110
    score_value = 250
    is_flying = false
    chase_speed = 5.2
    patrol_speed = 2.8
    attack_range = 20.0
    attack_cooldown = 1.8
    attack_damage = 12
    super._ready()

func _execute_attack() -> void:
    if is_bursting or not target_player:
        return
        
    is_bursting = true
    burst_count = 0
    _fire_burst_shot()

func _fire_burst_shot() -> void:
    if current_state == AIState.DEAD or not target_player:
        is_bursting = false
        return
        
    burst_count += 1
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx_3d("rifle_fire", global_position, 35.0, 0.0)
    
    # Raycast hit check with subtle spread
    var space = get_world_3d().direct_space_state
    var eye_pos = global_position + Vector3(0, 1.5, 0)
    var target_pos = target_player.global_position + Vector3(0, 1.2, 0)
    
    var spread = Vector3(randf_range(-0.5, 0.5), randf_range(-0.3, 0.3), randf_range(-0.5, 0.5))
    var query = PhysicsRayQueryParameters3D.create(eye_pos, target_pos + spread)
    query.collision_mask = 1 | 2 # World and Player
    
    var hit = space.intersect_ray(query)
    if hit and hit.collider == target_player:
        target_player.take_damage(attack_damage, global_position)
        
    if burst_count < 3:
        get_tree().create_timer(0.12).timeout.connect(_fire_burst_shot)
    else:
        is_bursting = false

# Cyber-trooper tactical behavior: seeks cover and discharges 3-round rifle bursts
