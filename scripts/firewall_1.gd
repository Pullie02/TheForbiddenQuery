extends Control

@onready var input_box: LineEdit = $LineEdit
@onready var display_label: Label = $Label   # <-- The Label you added
var player_input: String = ""

func _ready() -> void:
	# This runs every time a letter is added or deleted
	input_box.text_changed.connect(_on_text_changed)

func _on_text_changed(new_text: String) -> void:
	player_input = new_text
	display_label.text = "Your name is: " + player_input
