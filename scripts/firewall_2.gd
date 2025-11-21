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
@onready var answer_panel: Control = $"../Answer"
@onready var answer_input: LineEdit = $"../Answer/Ques_answer"
@onready var answer_button: Button = $"../Answer/Button"
@onready var animations: AnimationPlayer = $Animations

# Focus UI
@onready var login_focus: Control = $"../Focus/LoginFocus"
@onready var backend_focus: Control = $"../Focus/BackendFocus"
@onready var output_focus: Control = $"../Focus/OutputFocus"

# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void:
	# Database Setup
	db = SQLite.new()
	db.path = "res://Database/database.db"
	db.open_db()
	
	_update_backend_preview()

	# Signal Connections
	Dialogic.signal_event.connect(_tutorial_handler)
	
	search.text_changed.connect(_update_backend_preview)
	search_button.pressed.connect(_run_query)
	answer_button.pressed.connect(_check_final_answer)

# -----------------------------------------------------------------------------
# PHASE 1: EXECUTE QUERY LOGIC (Injection Works)
# -----------------------------------------------------------------------------
func _run_query() -> void:
	var term := search.text.strip_edges()
	var term_lower := term.to_lower()
	
	# This line uses the player's ENTIRE input ('term') to construct the SQL query.
	# This is the correct logic for teaching SQL injection.
	var sql := "SELECT name, category FROM products WHERE category = '" + term + "'"

	# Run Query
	db.query(sql)
	
	# Display Results
	if db.query_result.size() > 0:
		_display_table(db.query_result)
		
		# Now, check the keyword simply to trigger the dialogue/next stage
		if "union select" in term_lower and not did_success:
			animations.play("inFrame2")
			did_success = true
			Dialogic.start("T2_Success")
			
		elif not did_normal_search and "union select" not in term_lower:
			did_normal_search = true
			Dialogic.start("T2_AfterNormal")
			
	else:
		output.text = "No items found in that category."


# -----------------------------------------------------------------------------
# PHASE 2: FINAL ANSWER CHECK
# -----------------------------------------------------------------------------
func _check_final_answer() -> void:
	var user_answer := answer_input.text.strip_edges()
	
	# Query the DB to check if the typed item is one of the secret admin items
	var sql = "SELECT name FROM products WHERE category = 'admin_items' AND name = '" + user_answer + "' COLLATE NOCASE"
	db.query(sql)
	
	if db.query_result.size() > 0:
		key_manager.add_red_key()
		Dialogic.start("T2_RightAnswer")
		Dialogic.signal_event.connect(_back_to_hub)
		# TODO: Add your scene change code here
	else:
		answer_input.text = ""
		answer_input.placeholder_text = "Incorrect. Try an item from the list..."



func _back_to_hub(argument: String):
	if argument == "BackToHub":
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	if argument == "again":
		get_tree().reload_current_scene()




# -----------------------------------------------------------------------------
# VISUAL & OUTPUT HELPERS (Preserved Structure)
# -----------------------------------------------------------------------------
func _update_backend_preview(_text := "") -> void:
	# This preview shows the player how their input is inserted into the SQL
	display_label.text = "SELECT name\nFROM products\nWHERE category = '" + search.text + "'"

func _display_table(data: Array) -> void:
	var text := "[b]Item Name                    Category[/b]\n"
	text += "-----------------------------------------------\n"

	for row in data:
		var item_name := str(row["name"])
		var category := str(row["category"])
		while item_name.length() < 28:
			item_name += " "
		text += item_name + category + "\n"

	output.text = text

# -----------------------------------------------------------------------------
# TUTORIAL / FOCUS HANDLER
# -----------------------------------------------------------------------------
func _tutorial_handler(argument: String) -> void:
	match argument:
		"T2_Start":
			login_focus.visible = true
		"T2_Backend":
			login_focus.visible = false
			backend_focus.visible = true
		"T2_NormalSearch":
			backend_focus.visible = false
			output_focus.visible = true
		"T2_Done":
			output_focus.visible = false
			login_focus.visible = false
