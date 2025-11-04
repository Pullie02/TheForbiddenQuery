extends Control

var db = SQLite
var qr

@onready var email: LineEdit = $LineEdit
@onready var passw: LineEdit = $LineEdit2
@onready var display_label: Label = $Label
@onready var button: Button = $Button

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://Database/database.db"
	db.open_db()

	# Connect signals
	email.text_changed.connect(_update_label)
	passw.text_changed.connect(_update_label)
	button.pressed.connect(_query)

	_update_label()

func _update_label(_new_text := "") -> void:
	display_label.text = (
		"SELECT *\n" +
		"FROM users\n" +
		"WHERE email = '" + email.text + "'\n" +
		"AND pass = '" + passw.text + "'"
	)

func _query(_new_text := "") -> void:
	var sql = "SELECT * FROM users WHERE email = '" + email.text + "' AND pass = '" + passw.text + "'"
	db.query(sql)
	print(db.query_result)
