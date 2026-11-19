class_name DroneEnemy
extends "res://entities/enemies/base/BaseEnemy.gd"

# DroneEnemy - Fast flying drone that hovers and weaves
var hover_phase: float = 0.0

func _ready() -> void:
    enemy_name = "Scout Drone"
    max_health = 45
    score_value = 100
    is_flying = true
    chase_speed = 7.5
    patrol_speed = 4.0
    attack_range = 14.0
    attack_cooldown = 1.0
    attack_damage = 10
    super._ready()

func _physics_process(delta: float) -> void:
    hover_phase += delta * 3.5
    # Sinusoidal hover bobbing
    if visual_root and current_state != AIState.DEAD:
        visual_root.position.y = sin(hover_phase) * 0.25
    super._physics_process(delta)

func _execute_attack() -> void:
    if not target_player:
        return
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx_3d("rifle_fire", global_position, 30.0, 1.0)
    
    # Spawn a physical glowing plasma projectile towards player
    var projectile = Area3D.new()
    projectile.name = "PlasmaProjectile"
    projectile.collision_layer = 16 # Projectile layer
    projectile.collision_mask = 1 | 2 # World and Player
    
    # Mesh
    var mi = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.12
    sphere.height = 0.24
    mi.mesh = sphere
    var mat = StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(1.0, 0.2, 0.2)
    mi.material_override = mat
    projectile.add_child(mi)
    
    # Light
    var light = OmniLight3D.new()
    light.light_color = Color(1.0, 0.2, 0.2)
    light.light_energy = 2.0
    light.omni_range = 4.0
    projectile.add_child(light)
    
    # Collider
    var cs = CollisionShape3D.new()
    var sph = SphereShape3D.new()
    sph.radius = 0.15
    cs.shape = sph
    projectile.add_child(cs)
    
    get_tree().root.add_child(projectile)
    projectile.global_position = global_position + Vector3(0, 0.2, 0)
    var dir = (target_player.global_position + Vector3(0, 1.2, 0) - projectile.global_position).normalized()
    
    # Movement loop via script or simple process script
    var proj_script = GDScript.new()
    proj_script.source_code = """
extends Area3D
var move_dir: Vector3
var damage: int = 10
var speed: float = 24.0
var life: float = 4.0

func _physics_process(delta: float):
    global_position += move_dir * speed * delta
    life -= delta
    if life <= 0:
        queue_free()

func _on_body_entered(body: Node):
    if body.has_method('take_damage'):
        body.take_damage(damage, global_position)
    queue_free()
"""
    proj_script.reload()
    projectile.set_script(proj_script)
    projectile.set("move_dir", dir)
    projectile.set("damage", attack_damage)
    projectile.connect("body_entered", Callable(projectile, "_on_body_entered"))
