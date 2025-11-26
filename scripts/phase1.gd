extends Control
@onready var email: LineEdit = $LineEdit
@onready var password: LineEdit = $LineEdit2
@onready var button: Button = $Button
@onready var display_label: Label = $backEndCode
@onready var output: Label = $Output
@onready var health_manager: Node = %HealthManager
@onready var animations: AnimationPlayer = $"../../Animations"
@onready var player: CharacterBody2D = $"../../Player"
@onready var phase_2: Control = $"../Phase2"
@onready var level_4: Node2D = $"../.."

var db: SQLite

func _ready() -> void:
#Database connection part
#----------------------------------------------------------------#
	db = SQLite.new()
	db.path = "user://level4_temp.db"
	db.open_db()
#-----------------------------------------------------------------#
	email.text_changed.connect(_update_label)
	password.text_changed.connect(_update_label)
	button.pressed.connect(_query)
	
	_update_label()
	
func _update_label(_new_text := "") -> void:
	display_label.text = (
		"SELECT *\n" +
		"FROM users\n" +
		"WHERE email = '" + email.text + "'\n" +
		"AND pass = '" + password.text + "'"
	)

func _query(_new_text := "") -> void:
	var sql = "SELECT * FROM users WHERE user = '" + email.text + "' AND password = '" + password.text + "'"
	db.query(sql)
	
		# Check if any results were found
	if db.query_result.size() > 0:
		output.text = "Login successful!\n" + str(db.query_result)
		await get_tree().create_timer(0.5).timeout
		Dialogic.start("L4Phase1donee")
		Dialogic.signal_event.connect(_dialogic_signals)
	else:
		animations.play("damage")
		player.animated_sprite.play("damage")
		await get_tree().create_timer(0.5).timeout
		player.animated_sprite.play("idle")
		output.text = "No user found with that email and password."
		Dialogic.start("WrongAnswer")
		health_manager.less_health()


func _dialogic_signals(argument:String):
	match argument:
		"phase1done":
			visible = false
			phase_2.visible = true
