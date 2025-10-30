extends Node2D

@onready var animation_player: AnimationPlayer = $Characters/Player/opening/AnimationPlayer
@onready var opening: Node2D = $Characters/Player/opening


@onready var player: CharacterBody2D = $Characters/Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_physics_process(false)
	Dialogic.signal_event.connect(_start_game)
	Dialogic.start("Intro")
	Dialogic.signal_event.connect(_begin_game)

#Start the game for the first time, dialogue plus dramatic scene thing
func _start_game(arguent: String):
	if arguent =="start":
		animation_player.play("reveal")
		player.animated_sprite.play("wakeup")
		await get_tree().create_timer(4.3).timeout
		player.animated_sprite.play("idle")
		Dialogic.start("wakeup")



#make the movement on again after the dialogic signal
func _begin_game(argument: String):
	if argument == "begin":
		player.set_physics_process(true)

#go to the hub area.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
