class_name AmmoBox
extends Area3D

@export var ammo_amount: int = 40
var rotation_speed: float = 2.0
var hover_timer: float = 0.0

@onready var visual_root: Node3D = $VisualRoot

func _ready() -> void:
    collision_layer = 8
    collision_mask = 2
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    hover_timer += delta * 2.5
    if visual_root:
        visual_root.rotate_y(rotation_speed * delta)
        visual_root.position.y = sin(hover_timer) * 0.12

func _on_body_entered(body: Node3D) -> void:
    var wm = body.get_node_or_null("CameraPivot/WeaponHolder/WeaponManager")
    if wm and wm.has_method("get_current_weapon"):
        for res in wm.weapon_resources:
            res.reserve_ammo = min(res.max_reserve_ammo, res.reserve_ammo + ammo_amount)
        var cur = wm.get_current_weapon()
        if cur:
            var eb = get_node_or_null("/root/EventBus")
            if eb: eb.weapon_switched.emit(cur.weapon_name, cur.current_ammo_in_mag, cur.reserve_ammo)
        var sm = get_node_or_null("/root/SoundManager")
        if sm: sm.play_sfx("pickup", 0.05, 0.0)
        queue_free()
