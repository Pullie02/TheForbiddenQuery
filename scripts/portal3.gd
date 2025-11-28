extends Node2D

@onready var interactable: Area2D = $Interactable

func _ready():
	interactable.interact = _on_interact
	
func _on_interact():
	if key_manager.blue_key >= 1 and key_manager.red_key>=1:
		get_tree().change_scene_to_file("res://scenes/lvls/lvl4/level_4.tscn")
	else:
		Dialogic.start("NoRedKey")
