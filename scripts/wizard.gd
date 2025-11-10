extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var player: CharacterBody2D = $"../Characters/Player"

func _ready():
	interactable.interact = _on_interact
	
func _on_interact():
	player.set_physics_process(false)
	Dialogic.start("PortalTutor")
	Dialogic.signal_event.connect(_start_move)

func _start_move(argument: String):
	if argument == "move":
		player.set_physics_process(true)
