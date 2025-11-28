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
	db = SQLite.new()

	# Paths
	var original_db_path = "res://Database/database.db"
	var temp_db_path = "user://level2_temp.db"

	# --- Copy DB every time using FileAccess (works in export) ---
	var read_file = FileAccess.open(original_db_path, FileAccess.READ)
	if read_file == null:
		push_error("ERROR: Could not read database at: " + original_db_path)
		return

	var bytes = read_file.get_buffer(read_file.get_length())
	read_file.close()

	var write_file = FileAccess.open(temp_db_path, FileAccess.WRITE)
	if write_file == null:
		push_error("ERROR: Could not write temporary DB to: " + temp_db_path)
		return

	write_file.store_buffer(bytes)
	write_file.close()
	# -------------------------------------------------------------

	# Open the fresh copied DB
	db.path = temp_db_path
	db.open_db()

	# Update UI preview initially
	_update_backend_preview()

	# Connect Dialogue signals
	Dialogic.signal_event.connect(_tutorial_handler)

	# Connect search field + button
	search.text_changed.connect(_update_backend_preview)
	search_button.pressed.connect(_run_query)

	# Connect final answer button
	answer_button.pressed.connect(_check_final_answer)


# -----------------------------------------------------------------------------
# PHASE 1: EXECUTE QUERY LOGIC
# -----------------------------------------------------------------------------
func _run_query() -> void:
	var term := search.text.strip_edges()
	var sql := "SELECT name, category FROM products WHERE category = '" + term + "'"

	db.query(sql)
	
	if db.query_result.size() > 0:
		
		var admin_items_found := false
		var schema_found := false
		
		for row in db.query_result:
			if row.get("category") == "admin_items":
				admin_items_found = true
			
			# Check 2: Schema Found (using 'products' table name and long SQL definition)
			if row.get("name") == "products" and len(str(row.get("category"))) > 10:
				schema_found = true
				
		# --- OUTPUT DISPLAY ---
		if schema_found:
			# FIX: Use the realistic, column-summarized schema display
			_display_schema_table(db.query_result)
		else:
			_display_table(db.query_result)
		
		# --- DIALOGUE AND ACTION LOGIC ---
		
		if schema_found and not did_success:
			did_success = true
			# The success dialogue will trigger the animation via the handler
			Dialogic.start("T2_Success")
			
		elif admin_items_found and not did_success:
			Dialogic.start("T2_Loot_Hint") 
			
		elif not did_normal_search and "union select" not in term.to_lower():
			did_normal_search = true
			Dialogic.start("T2_AfterNormal")
			
	else:
		output.text = "No items found in that category."


# -----------------------------------------------------------------------------
# FIXED HELPER: REALISTIC SCHEMA OUTPUT
# -----------------------------------------------------------------------------

# FIX: Rewritten to extract table names and columns from the SQL definitions.
func _display_schema_table(data: Array) -> void:
	var text := "[b]SQL Database Schema Discovery[/b]\n"
	text += "-----------------------------------------------\n"

	for row in data:
		var name := str(row.get("name"))
		var sql_def := str(row.get("category")).to_lower()
		
		# We only care about the main data tables, not indices or sequences
		if name == "products":
			text += "\n[color=#ffa500]TABLE: products[/color]\n"
			# Columns for products are name, category
			text += "  > Columns: [b]name[/b], [b]category[/b]\n"
		
		elif name == "users":
			text += "\n[color=#ffa500]TABLE: users[/color]\n"
			# Columns for users are email, pass
			text += "  > Columns: [b]email[/b], [b]pass[/b]\n"
	
	# Add a hint for the user based on the realistic output
	text += "\n[color=gray]Look at those columns! The 'users' table is the real prize.[/color]"
	output.text = text


# -----------------------------------------------------------------------------
# PHASE 2: FINAL ANSWER CHECK (CHECKING FOR TABLE NAMES)
# -----------------------------------------------------------------------------
func _check_final_answer() -> void:
	var user_answer := answer_input.text.strip_edges()
	
	# NEW SQL: Query the master list to check if the user's answer is a valid table name.
	# This accepts table names like 'users', 'products', 'sqlite_sequence', etc.
	# COLLATE NOCASE makes the check case-insensitive (accepts 'users' or 'USERS').
	var sql = "SELECT name FROM sqlite_master WHERE type='table' AND name = '" + user_answer + "' COLLATE NOCASE"
	db.query(sql)
	
	if db.query_result.size() > 0:
		# Success! The user found a table name.
		Dialogic.start("T2_RightAnswer")
		Dialogic.signal_event.connect(_back_to_hub)
		key_manager.add_red_key()
	else:
		answer_input.text = ""
		# Updated placeholder text for the new question
		answer_input.placeholder_text = "Incorrect. Try the name of a discovered table..."

func _back_to_hub(argument: String):
	if argument == "BackToHub":
		get_tree().change_scene_to_file("res://scenes/hub.tscn")
	if argument == "again":
		get_tree().reload_current_scene()


# -----------------------------------------------------------------------------
# VISUAL & OUTPUT HELPERS
# -----------------------------------------------------------------------------
func _update_backend_preview(_text := "") -> void:
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
# TUTORIAL / FOCUS HANDLER (Animation Trigger)
# -----------------------------------------------------------------------------
func _tutorial_handler(argument: String) -> void:
	match argument:
		"T2_Start":
			login_focus.visible = true
		"T2_Backend":
			login_focus.visible = false
			backend_focus.visible = true
		"T2_Success_Finished":
			if is_instance_valid(answer_panel) and is_instance_valid(animations):
				answer_panel.visible = true
				animations.play("inFrame2")
		"T2_Done":
			output_focus.visible = false
			login_focus.visible = false
			backend_focus.visible = false
