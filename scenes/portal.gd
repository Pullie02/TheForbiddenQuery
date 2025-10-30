extends Node2D

@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	get_tree().change_scene_to_file("res://scenes/hub.tscn")
