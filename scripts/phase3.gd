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

# Answer Phase UI
@onready var answer_button: Button = $"../Answer/Button"
@onready var animations: AnimationPlayer = $"../../Animations"

# Focus UI
@onready var login_focus: Control = $"../Focus/LoginFocus"
@onready var backend_focus: Control = $"../Focus/BackendFocus"
@onready var output_focus: Control = $"../Focus/OutputFocus"

# -----------------------------------------------------------------------------
# INITIALIZATION (Seamless Database Reset)
# -----------------------------------------------------------------------------
func _ready() -> void:
	db = SQLite.new()
	db.path = "user://level4_temp.db"
	db.open_db()
	# --------------------------------------------------
	
	_update_backend_preview()
	
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
			Dialogic.start("T3_Success") # Requires a T3_Success dialogue event
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
