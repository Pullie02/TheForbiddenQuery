extends Node2D
@onready var player: CharacterBody2D = $Player
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_physics_process(false)
	Dialogic.signal_event.connect(_start_game)
	Dialogic.start("lvl1")
	
func _start_game(argument: String):
	if argument == "inFrame":
		animation_player.play("inFrame")
