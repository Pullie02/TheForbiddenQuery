extends Node2D
@onready var player: CharacterBody2D = $Player
@onready var button: Button = $Button
@onready var animations: AnimationPlayer = $Control/Animations


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_physics_process(false)
	Dialogic.signal_event.connect(_start_game)
	Dialogic.start("T3_Start")
	
func _start_game(argument: String):
	if argument == "inFrame":
		animations.play("inFrame")


func _on_button_pressed() -> void:
	Dialogic.start("leave")
	Dialogic.signal_event.connect(_to_hub)

func _to_hub(argument: String):
	get_tree().change_scene_to_file("res://scenes/hub.tscn")


func _on_button_2_pressed() -> void:
	Dialogic.start("T2_Hint")
