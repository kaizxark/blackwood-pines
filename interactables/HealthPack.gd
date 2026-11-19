class_name HealthPack
extends Area3D

@export var heal_amount: int = 40
var rotation_speed: float = 2.0
var hover_timer: float = 0.0

@onready var visual_root: Node3D = $VisualRoot

func _ready() -> void:
    collision_layer = 8 # Pickups layer
    collision_mask = 2 # Player layer
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    hover_timer += delta * 2.5
    if visual_root:
        visual_root.rotate_y(rotation_speed * delta)
        visual_root.position.y = sin(hover_timer) * 0.12

func _on_body_entered(body: Node3D) -> void:
    if body.has_method("heal") and body.get("current_health") < body.get("max_health"):
        body.heal(heal_amount)
        queue_free()
