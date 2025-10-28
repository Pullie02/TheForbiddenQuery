extends Node2D

@onready var animation_player: AnimationPlayer = $opening/AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(_start_game)
	Dialogic.start("Intro")


#Start the game for the first time, dialogue plus dramatic scene thing
func _start_game(arguent: String):
	if arguent =="start":
		animation_player.play("reveal")
