extends Node2D

var blue_key = 0
var red_key = 0
@onready var blue_key_img: Sprite2D = $BlueKeyImg
@onready var red_key_img: Sprite2D = $RedKeyImg




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if key_manager.blue_key >= 1:
		blue_key_img.visible = true
	if key_manager.red_key >= 1:
		red_key_img.visible = true


func add_blue_key():
	blue_key+=1
	print(blue_key)
