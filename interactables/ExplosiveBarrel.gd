class_name ExplosiveBarrel
extends StaticBody3D

@export var max_health: int = 25
@export var explosion_damage: int = 85
@export var explosion_radius: float = 6.5

var current_health: int
var has_exploded: bool = false

@onready var visual_root: Node3D = $VisualRoot

func _ready() -> void:
    current_health = max_health
    collision_layer = 1 | 4 # World and targetable as damageable
    collision_mask = 0

func take_damage(amount: int, _hit_normal: Vector3 = Vector3.ZERO, _is_headshot: bool = false) -> void:
    if has_exploded:
        return
    current_health -= amount
    if current_health <= 0:
        _explode()

func _explode() -> void:
    has_exploded = true
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx_3d("explosion", global_position, 50.0, 3.0)
    var eb = get_node_or_null("/root/EventBus")
    if eb: eb.camera_shake_requested.emit(0.7)
    
    # Area splash damage query
    var space = get_world_3d().direct_space_state
    var shape = SphereShape3D.new()
    shape.radius = explosion_radius
    var query = PhysicsShapeQueryParameters3D.new()
    query.shape = shape
    query.transform = global_transform
    query.collision_mask = 2 | 4 # Player and Enemies
    
    var results = space.intersect_shape(query)
    for res in results:
        var collider = res.collider
        if collider != self and collider.has_method("take_damage"):
            var dist = global_position.distance_to(collider.global_position)
            var falloff = clamp(1.0 - (dist / explosion_radius), 0.2, 1.0)
            collider.take_damage(int(explosion_damage * falloff), (collider.global_position - global_position).normalized())
            
    # Visual explosion effect
    _spawn_explosion_vfx()
    queue_free()

func _spawn_explosion_vfx() -> void:
    var sparks = CPUParticles3D.new()
    sparks.emitting = true
    sparks.one_shot = true
    sparks.explosiveness = 0.95
    sparks.amount = 35
    sparks.lifetime = 0.6
    sparks.initial_velocity_min = 6.0
    sparks.initial_velocity_max = 14.0
    sparks.spread = 180.0
    var mat = StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(1.0, 0.45, 0.1)
    sparks.material_override = mat
    
    get_tree().root.add_child(sparks)
    sparks.global_position = global_position + Vector3(0, 0.6, 0)
    get_tree().create_timer(0.8).timeout.connect(func(): if is_instance_valid(sparks): sparks.queue_free())
