extends Control

@onready var ques_answer: LineEdit = $Ques_answer

func _on_button_pressed() -> void:
	var answer = ques_answer.text
	if answer.to_int() == 8325:
		key_manager.add_blue_key()
		Dialogic.start("FinishLvl1")
		Dialogic.signal_event.connect(_back_to_hub)


func _back_to_hub(argument: String):
	if argument == "BackToHub":
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	if argument == "again":
		get_tree().reload_current_scene()
