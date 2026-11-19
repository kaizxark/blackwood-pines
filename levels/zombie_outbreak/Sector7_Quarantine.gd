class_name Sector7Quarantine
extends Node3D

# PROJECT PROTO-BREACH / ZOMBIE OUTBREAK - Sector 7 Quarantine Outpost
# Handles intro radio transmission, atmospheric audio, and survival objectives.

func _ready() -> void:
	get_tree().create_timer(1.2).timeout.connect(_play_intro_transmission)

func _play_intro_transmission() -> void:
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.objective_updated.emit("survive", "REBUILD BARRICADES | BUY WEAPONS | SURVIVE WAVES", false)
		eb.comms_transmission.emit("OUTPOST RADIO", "MAYDAY! Sector 7 containment has failed. Rebuild window barricades, gear up at wall-buys, and survive the infected horde!", "radio")
