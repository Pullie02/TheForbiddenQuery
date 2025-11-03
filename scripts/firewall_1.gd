extends Control

@onready var email: LineEdit = $LineEdit
@onready var passw: LineEdit = $LineEdit2
@onready var display_label: Label = $Label

func _ready() -> void:
	# Connect both signals
	email.text_changed.connect(_update_label)
	passw.text_changed.connect(_update_label)
	
	# Initialize the label right away
	_update_label()

func _update_label(_new_text := "") -> void:
	display_label.text = (
		"SELECT *\n"+
		"FROM users\n"+
		"WHERE email = '" + email.text + "'\n"+
		"AND pass = '" + passw.text + "'"
	)
