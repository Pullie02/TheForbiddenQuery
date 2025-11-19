extends Control

var db = SQLite
var qr

@onready var health_manager: Node = %HealthManager

@onready var search: LineEdit = $LineEdit
@onready var display_label: Label = $backEndCode
@onready var button: Button = $Button
@onready var output: RichTextLabel = $Output     # Make sure Output is RichTextLabel w/ BBCode
@onready var Animations: AnimationPlayer = $Animations
@onready var player: CharacterBody2D = $"../Player"

@onready var login_focus: Control = $"../Focus/LoginFocus"
@onready var backend_focus: Control = $"../Focus/BackendFocus"
@onready var output_focus: Control = $"../Focus/OutputFocus"
@onready var health_focus: Control = $"../Focus/HealthFocus"
@onready var return_focus: Control = $"../Focus/ReturnFocus"

var did_normal_search := false       # prevents repeat triggering of T2_AfterNormal
var did_success := false             # prevents repeat calls to T2_Success


# -----------------------------------------------------------------------------
# READY
# -----------------------------------------------------------------------------
func _ready() -> void:
	db = SQLite.new()
	db.path = "res://Database/database.db"
	db.open_db()

	Dialogic.signal_event.connect(_tutorial)

	search.text_changed.connect(_update_label)
	button.pressed.connect(_query)

	_update_label()


# -----------------------------------------------------------------------------
# STRING PADDING (Godot 4 safe)
# -----------------------------------------------------------------------------
func _pad(text: String, length: int) -> String:
	var result := text
	while result.length() < length:
		result += " "
	return result


# -----------------------------------------------------------------------------
# TABLE DISPLAY
# -----------------------------------------------------------------------------
func _display_table(data: Array) -> void:
	var text := "[b]Item Name                   Category[/b]\n"
	text += "-----------------------------------------------\n"

	for row in data:
		var name := str(row["name"])
		var category := str(row["category"])
		text += _pad(name, 28) + category + "\n"

	output.text = text


# -----------------------------------------------------------------------------
# UPDATE BACKEND PREVIEW
# -----------------------------------------------------------------------------
func _update_label(_new_text := "") -> void:
	display_label.text ="SELECT name\n" +"FROM products\n" +"WHERE category = '" + search.text + "'"


# -----------------------------------------------------------------------------
# MAIN QUERY LOGIC
# -----------------------------------------------------------------------------
func _query(_new_text := "") -> void:
	var term := search.text.strip_edges()

	# Detect UNION spell
	if term.to_lower().find("union select") != -1:
		_show_secret_items()
		return

	# Normal search query
	var sql := "SELECT name, category FROM products WHERE category = '" + term + "'"
	db.query(sql)

	# Display normal results or empty message
	if db.query_result.size() > 0:
		_display_table(db.query_result)

		# Trigger "T2_AfterNormal" only ONCE
		if not did_normal_search:
			did_normal_search = true
			Dialogic.start("T2_AfterNormal")
	else:
		output.text = "No items found in that category."


# -----------------------------------------------------------------------------
# SUCCESS — UNION SPELL
# -----------------------------------------------------------------------------
func _show_secret_items() -> void:
	if did_success:
		return

	did_success = true

	var items := [
		{"name": "Root Password USB", "category": "admin_items"},
		{"name": "Employee Badge Emulator", "category": "admin_items"},
		{"name": "CEO Keycard Clone", "category": "admin_items"}
	]

	_display_table(items)

	Dialogic.start("T2_Success")


# -----------------------------------------------------------------------------
# TUTORIAL SIGNAL HANDLER
# -----------------------------------------------------------------------------
func _tutorial(argument: String):
	match argument:

		"T2_Start":
			login_focus.visible = true

		"T2_Backend":
			login_focus.visible = false
			backend_focus.visible = true

		"T2_NormalSearch":
			backend_focus.visible = false
			output_focus.visible = true

		"T2_UnionIntro":
			output_focus.visible = false
			backend_focus.visible = true

		"T2_UnionHint":
			backend_focus.visible = false
			login_focus.visible = true

		"T2_Success":
			login_focus.visible = false
			output_focus.visible = true

		"T2_Done":
			output_focus.visible = false
			login_focus.visible = false
