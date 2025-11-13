extends Node

@onready var healthpic: AnimatedSprite2D = $Healthpic

var health = 4

func less_health():
	health -= 1
	_img_change()
	print(health)
func _img_change():
	if health == 4:
		healthpic.play("4")
	if health == 3:
		healthpic.play("3")
	if health == 2:
		healthpic.play("2")
	if health == 1:
		healthpic.play("1")
	if health <= 0:
		healthpic.play("0")
		Dialogic.start("Death")
		Dialogic.signal_event.connect(_back_to_courtyard)

func _back_to_courtyard(argument: String):
	get_tree().change_scene_to_file("res://scenes/hub.tscn")
