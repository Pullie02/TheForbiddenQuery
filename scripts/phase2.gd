extends Control

var db = SQLite
var did_success := false

@onready var search: LineEdit = $LineEdit
@onready var display_label: Label = $backEndCode
@onready var search_button: Button = $Button
@onready var output: RichTextLabel = $Output
@onready var phase_3: Control = $"../Phase3"


	
func _ready() -> void:

	db = SQLite.new()
	db.path = "user://level4_temp.db"
	db.open_db()
	
	
	_update_backend_preview()

	search.text_changed.connect(_update_backend_preview)
	search_button.pressed.connect(_run_query)

# -----------------------------------------------------------------------------
# PHASE 1: EXECUTE QUERY LOGIC
# -----------------------------------------------------------------------------
func _run_query() -> void:
	var term := search.text.strip_edges()
	var sql := "SELECT name, category FROM products WHERE category = '" + term + "'"

	db.query(sql)
	
	if db.query_result.size() > 0:
		
		var schema_found := false
		
		for row in db.query_result:
			# Check Schema Found (using 'products' table name and long SQL definition)
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
			Dialogic.start("L4_Phase2")
			Dialogic.signal_event.connect(_p2_done)
			queue_free()
	else:
		output.text = "No items found in that category."


# -----------------------------------------------------------------------------
# REALISTIC SCHEMA OUTPUT
# -----------------------------------------------------------------------------
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
		
		elif name == "powers":
			text += "\n[color=#ffa500]TABLE: powers[/color]\n"
			# Columns for users are email, pass
			text += "  > Columns: [b]power_name[/b], [b]status[/b]\n"
			
		elif name == "users":
			text += "\n[color=#ffa500]TABLE: users[/color]\n"
			# Columns for users are email, pass
			text += "  > Columns: [b]user[/b], [b]password[/b]\n"
	output.text = text


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


func _p2_done(argument : String):
	match argument:
		"P2Done":
			phase_3.visible = true
