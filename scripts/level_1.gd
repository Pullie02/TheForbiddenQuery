extends Node2D
@onready var player: CharacterBody2D = $Player
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer
@onready var button: Button = $Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_physics_process(false)
	Dialogic.signal_event.connect(_start_game)
	Dialogic.start("lvl1")
	
func _start_game(argument: String):
	if argument == "inFrame":
		animation_player.play("inFrame")


func _on_button_pressed() -> void:
	Dialogic.start("leave")
	Dialogic.signal_event.connect(_to_hub)

func _to_hub(argument: String):
	get_tree().change_scene_to_file("res://scenes/hub.tscn")
