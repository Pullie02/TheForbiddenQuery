extends Control

# -----------------------------------------------------------------------------
# CONFIGURATION & STATE
# -----------------------------------------------------------------------------
var db: SQLite
var did_normal_search := false
var did_success := false

# Search Phase UI
@onready var search: LineEdit = $LineEdit
@onready var display_label: Label = $backEndCode
@onready var search_button: Button = $Button
@onready var output: RichTextLabel = $Output
@onready var animations: AnimationPlayer = $Animations

# Focus UI
@onready var login_focus: Control = $"../Focus/LoginFocus"
@onready var backend_focus: Control = $"../Focus/BackendFocus"
@onready var output_focus: Control = $"../Focus/OutputFocus"

# -----------------------------------------------------------------------------
# INITIALIZATION (Seamless Database Reset)
# -----------------------------------------------------------------------------
func _ready() -> void:
	db = SQLite.new()
	
	var original_db_path = "res://Database/databaseLvl3.db"
	var temp_db_path = "user://level3_temp.db" 
	
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
	# --------------------------------------------------
	
	_update_backend_preview()

	# Signal Connections
	Dialogic.signal_event.connect(_tutorial_handler)
	
	search.text_changed.connect(_update_backend_preview)
	search_button.pressed.connect(_run_query)

# -----------------------------------------------------------------------------
# PHASE 1: EXECUTE QUERY LOGIC (UPDATE VULNERABILITY)
# -----------------------------------------------------------------------------
func _run_query() -> void:
	var term := search.text.strip_edges()
	
	# VULNERABLE QUERY: Player input is incorrectly inserted into the WHERE clause
	var sql := "UPDATE powers SET status = 'pending' WHERE power_name = '" + term + "';"

	# Run the query (will execute the vulnerable UPDATE, plus any injected queries)
	db.query(sql)
	
	# --- SUCCESS CHECK: Verify the injection worked by querying the database ---
	
	# We check the final status of the target item ('SQLariusPowers')
	var success_check_sql = "SELECT status FROM powers WHERE power_name = 'SQLariusPowers'"
	db.query(success_check_sql)
	
	var power_status = ""
	if db.query_result.size() > 0:
		power_status = str(db.query_result[0].get("status"))
	
	
	if power_status == "returned":
		# Level 3 Success! The injection updated the status.
		if not did_success:
			did_success = true
			output.text = "[color=#00ff00][b]STATUS UPDATE SUCCESSFUL.[/b][/color]\nSQLarius's powers have been restored to the mainframe."
			Dialogic.start("T3_RightAnswer")
			Dialogic.signal_event.connect(_back_to_hub)
			key_manager.add_gold_key()
	else:
		# Output for a failed or benign query
		output.text = "Attempted to update status for item: " + term + "\nStatus check: Not yet returned."
		
		# Dialogue logic (for hints)
		if not did_normal_search:
			did_normal_search = true
			Dialogic.start("T3_AfterNormal")


func _back_to_hub(argument: String):
	if argument == "BackToHub":
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	if argument == "again":
		get_tree().reload_current_scene()


# -----------------------------------------------------------------------------
# VISUAL & OUTPUT HELPERS
# -----------------------------------------------------------------------------
func _update_backend_preview(_text := "") -> void:
	# Preview the vulnerable UPDATE statement
	display_label.text = "UPDATE powers\nSET status = 'pending'\nWHERE power_name = '" + search.text + "'"

func _display_table(data: Array) -> void:
	# This function is not primarily used for UPDATE success, but kept for structure
	output.text = "Query executed. Checking database status..."

# -----------------------------------------------------------------------------
# TUTORIAL / FOCUS HANDLER
# -----------------------------------------------------------------------------
func _tutorial_handler(argument: String) -> void:
	match argument:
		"T3_Start":
			login_focus.visible = true
		"T3_Backend":
			login_focus.visible = false
			backend_focus.visible = true
		"T3_Done":
			output_focus.visible = false
			login_focus.visible = false
			backend_focus.visible = false
