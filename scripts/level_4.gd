class_name Level4
extends Node2D
@onready var player: CharacterBody2D = $Player
@onready var animations: AnimationPlayer = $Animations

var db: SQLite

func _ready() -> void:
	player.set_physics_process(false)
	Dialogic.start("T4_Start")
	Dialogic.signal_event.connect(_start_game)
#--------------------------------------------------------------------
	db = SQLite.new()
	
	var original_db_path = "res://Database/databaseLvl4.db"
	var temp_db_path = "user://level4_temp.db" 
	
	# 1. Ensure user:// directory exists
	var dir = DirAccess.open("user://")
	if not dir:
		push_error("Could not open user:// directory!")
		return
	
	# 2. Copy the pristine database to user data (This handles the reset)
	var error = dir.copy(original_db_path, temp_db_path)
	if error != OK:
		push_error("Failed to copy database: ", error)
		return
		
	db.path = temp_db_path # Use the copied, writable database
	db.open_db()
#--------------------------------------------------------------------

func _start_game(argument : String):
	match argument:
		"inFrame":
			animations.play("inFrame")
			 
