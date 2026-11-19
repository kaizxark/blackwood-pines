class_name SecurityConsole
extends StaticBody3D

@export var objective_id: String = "override_console"
@export var prompt_message: String = "OVERRIDE PROTOCOL"
@export var completes_level: bool = false
@export var is_activated: bool = false

@onready var screen_mesh: MeshInstance3D = $VisualRoot/ScreenMesh

func _ready() -> void:
    collision_layer = 1 | 8 # World & Interactable
    _update_visuals()

func interact(_player: Node3D) -> void:
    if is_activated:
        return
        
    is_activated = true
    _update_visuals()
    var sm = get_node_or_null("/root/SoundManager")
    if sm: sm.play_sfx("pickup", 0.05, 3.0)
    
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.objective_updated.emit(objective_id, "Security protocol overridden! Airlock unlocked.", true)
        eb.comms_transmission.emit("OVERSEER AI", "Warning: External containment security compromised.", "ai")
    
    if completes_level:
        get_tree().create_timer(1.5).timeout.connect(func():
            if eb: eb.level_completed.emit()
        )

func _update_visuals() -> void:
    if not screen_mesh:
        return
    var mat = StandardMaterial3D.new()
    var col = Color(0.1, 1.0, 0.3) if is_activated else Color(1.0, 0.15, 0.15)
    mat.albedo_color = col
    mat.emission_enabled = true
    mat.emission = col
    mat.emission_energy_multiplier = 3.0
    screen_mesh.material_override = mat
