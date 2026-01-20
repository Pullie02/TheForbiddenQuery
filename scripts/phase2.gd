extends Control

var db = SQLite

var did_success := false

@onready var search: LineEdit = $LineEdit
@onready var display_label: Label = $backEndCode
@onready var search_button: Button = $Button
@onready var output: RichTextLabel = $Output
@onready var health_manager: Node = %HealthManager
@onready var animations: AnimationPlayer = $"../../Animations"
@onready var player: CharacterBody2D = $"../../Player"
@onready var animated_sprite: AnimatedSprite2D = $"../../Player/AnimatedSprite2D"

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
	animated_sprite.play("attack")
	await await get_tree().create_timer(1.9).timeout
	animated_sprite.play("idle")
	
	var term := search.text.strip_edges()
	var sql := "SELECT name, category FROM products WHERE category = '" + term + "'"

	# Run SELECT
	db.query(sql)

	# SAVE RESULT BEFORE IT GETS OVERWRITTEN
	var select_result: Array[Dictionary] = db.query_result.duplicate(true)

	# --- INJECTION CHECK ---
	var verify := "SELECT status FROM powers WHERE power_name = 'SQLariusPowers'"
	db.query(verify)

	if db.query_result.size() > 0:
		var s := str(db.query_result[0].get("status"))
		if s == "returned":
			output.text = "[color=green][b]STATUS UPDATE SUCCESSFUL[/b][/color]\nSQLarius's powers are restored."
			did_success = true
			Dialogic.start("L4_Finish")
			return
	# -------------------------

	# USE select_result INSTEAD OF db.query_result
	if select_result.size() > 0:
		
		var schema_found := false
		var table_found := false
		for row in select_result:
			if row.get("name") == "products" and len(str(row.get("category"))) > 10:
				schema_found = true
				
		# OUTPUT DISPLAY
		if schema_found:
			_display_schema_table(select_result)
		else:
			_display_table(select_result)
			if not table_found:
				table_found = true
				Dialogic.start("L4_Phase2Done1")
		if schema_found and not did_success:
			did_success = true
			Dialogic.start("L4Phase2")

	else:
		output.text = "No items found in that category."
		animations.play("damage")
		player.animated_sprite.play("damage")
		await get_tree().create_timer(0.5).timeout
		player.animated_sprite.play("idle")
		output.text = "No user found with that email and password."
		Dialogic.start("WrongAnswer")
		health_manager.less_health()
		


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
	var text := "[b]Item Name                    Category[/b]\n"
	text += "-----------------------------------------------\n"

	for row in data:
		var item_name := str(row["name"])
		var category := str(row["category"])
		while item_name.length() < 28:
			item_name += " "
		text += item_name + category + "\n"

	output.text = text
