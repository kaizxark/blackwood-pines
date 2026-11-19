extends Node3D

# Level01 Controller for PROJECT PROTO-BREACH
# Manages intro briefing, mission objectives, and ambient sound cues

func _ready() -> void:
    # Trigger introductory mission briefing transmission
    get_tree().create_timer(1.0).timeout.connect(_play_intro_briefing)

func _play_intro_briefing() -> void:
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.objective_updated.emit("initial", "Infiltrate Hangar & Override Security Terminal", false)
        eb.comms_transmission.emit("COMMAND HQ", "Operative: Lockdown protocol confirmed. Infiltrate the hangar, neutralize threats, and override the terminal.", "hq")
