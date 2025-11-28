extends Node2D

var blue_key = 0
var red_key = 0
var gold_key = 0

@onready var blue_key_img: Sprite2D = $BlueKeyImg
@onready var red_key_img: Sprite2D = $RedKeyImg
@onready var gold_key_img: Sprite2D = $GoldKeyImg




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if key_manager.blue_key >= 1:
		blue_key_img.visible = true
	if key_manager.red_key >= 1:
		red_key_img.visible = true
	if key_manager.gold_key >= 1:
		gold_key_img.visible = true


func add_blue_key():
	key_manager.blue_key += 1
	print(blue_key)

func add_red_key():
	key_manager.red_key += 1
	print(red_key)

func add_gold_key():
	key_manager.gold_key += 1
	print(gold_key)
