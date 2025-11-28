extends Control

var db = SQLite
var qr
@onready var health_manager: Node = %HealthManager
@onready var email: LineEdit = $LineEdit
@onready var passw: LineEdit = $LineEdit2
@onready var display_label: Label = $backEndCode
@onready var button: Button = $Button
@onready var output: Label = $Output
@onready var Animations: AnimationPlayer = $Animations
@onready var animated_sprite: AnimatedSprite2D = $Player/AnimatedSprite2D
@onready var player: CharacterBody2D = $"../Player"
@onready var login_focus: Control = $"../Focus/LoginFocus"
@onready var backend_focus: Control = $"../Focus/BackendFocus"
@onready var output_focus: Control = $"../Focus/OutputFocus"
@onready var health_focus: Control = $"../Focus/HealthFocus"
@onready var return_focus: Control = $"../Focus/ReturnFocus"
@onready var website: Control = $"../website"

var wronganswer = false

func _ready() -> void:
	db = SQLite.new()
	
	var original_db_path = "res://Database/database.db"
	var temp_db_path = "user://level1_temp.db"

	# --- Copy DB every time using FileAccess (works in export) ---
	var read_file = FileAccess.open(original_db_path, FileAccess.READ)
	if read_file == null:
		push_error("ERROR: Could not read database at: " + original_db_path)
		return

	var data = read_file.get_buffer(read_file.get_length())
	read_file.close()

	var write_file = FileAccess.open(temp_db_path, FileAccess.WRITE)
	if write_file == null:
		push_error("ERROR: Could not write database to: " + temp_db_path)
		return

	write_file.store_buffer(data)
	write_file.close()
	# -------------------------------------------------------------

	# Open the fresh copied DB
	db.path = temp_db_path
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
		await get_tree().create_timer(0.5).timeout
		queue_free()
		website.visible = true
		Dialogic.start("T1_Done")
	else:
		Animations.play("damage")
		player.animated_sprite.play("damage")
		await get_tree().create_timer(0.5).timeout
		player.animated_sprite.play("idle")
		output.text = "No user found with that email and password."
		health_manager.less_health()
		if not wronganswer:
			Dialogic.start("T1_FirstWrong")
			wronganswer = true
		else:
			Dialogic.start("WrongAnswer")




func _tutorial(argument: String):
	if argument == "tutLogin":
		login_focus.visible = true
	if argument == "tutBackend":
		login_focus.visible = false
		backend_focus.visible = true
	if argument == "tutOutput":
		backend_focus.visible = false
		output_focus.visible = true
	if argument == "tutHealth":
		output_focus.visible = false
		health_focus.visible = true
	if argument == "tutReturn":
		health_focus.visible = false
		return_focus.visible = true
	if argument == "tutDone":
		return_focus.visible = false
