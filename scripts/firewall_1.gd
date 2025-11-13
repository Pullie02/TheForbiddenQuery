extends Control

var db = SQLite
var qr

@onready var email: LineEdit = $LineEdit
@onready var passw: LineEdit = $LineEdit2
@onready var display_label: Label = $backEndCode
@onready var button: Button = $Button
@onready var output: Label = $Output
@onready var damage: AnimationPlayer = $damage
@onready var animated_sprite: AnimatedSprite2D = $Player/AnimatedSprite2D
@onready var player: CharacterBody2D = $"../Player"
@onready var login_focus: Control = $"../Focus/LoginFocus"

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://Database/database.db"
	db.open_db()

	# Connect signals
	email.text_changed.connect(_update_label)
	passw.text_changed.connect(_update_label)
	button.pressed.connect(_query)

	_update_label()
	Dialogic.signal_event.connect(_tutorial)

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
	
		# Check if any results were found
	if db.query_result.size() > 0:
		output.text = "Login successful!\n" + str(db.query_result)
		Dialogic.start("FinishLvl1")
		Dialogic.signal_event.connect(_back_to_hub)
	else:
		damage.play("damage")
		player.animated_sprite.play("damage")
		await get_tree().create_timer(0.5).timeout
		player.animated_sprite.play("idle")
		output.text = "No user found with that email and password."
		Dialogic.start("WrongAnswer")

func _back_to_hub(argument: String):
	if argument == "BackToHub":
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	if argument == "again":
		get_tree().reload_current_scene()
		
		
func _tutorial(argument: String):
	if argument == "tutLogin":
		login_focus.visible = true
