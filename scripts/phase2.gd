extends Control

var db: SQLite
var did_normal_search := false
var did_success := false

@onready var search: LineEdit = $LineEdit
@onready var search_button: Button = $Button
@onready var display_label: Label = $backEndCode
@onready var output: RichTextLabel = $Output
@onready var hackers_table_display: RichTextLabel = $HackersTable

@onready var login_focus: Control = $"../Focus/LoginFocus"
@onready var backend_focus: Control = $"../Focus/BackendFocus"
@onready var output_focus: Control = $"../Focus/OutputFocus"

func _ready() -> void:
	db = SQLite.new()

	var original_db = "res://Database/databaseLvl3.db"
	var temp_db = "user://level3_temp.db"

	var r = FileAccess.open(original_db, FileAccess.READ)
	if r == null:
		push_error("Could not open original DB: " + original_db)
		return
	var bytes = r.get_buffer(r.get_length())
	r.close()

	var w = FileAccess.open(temp_db, FileAccess.WRITE)
	if w == null:
		push_error("Could not write temp DB: " + temp_db)
		return
	w.store_buffer(bytes)
	w.close()

	db.path = temp_db
	db.open_db()

	search.text_changed.connect(_update_backend_preview)
	search_button.pressed.connect(_run_query)

	_update_backend_preview()
	_show_hackers_table()


func _run_query() -> void:
	var term := search.text.strip_edges()
	if term == "":
		output.text = "⚠ Enter a hacker name or ID."
		return

	var sql_update := ""
	var where_desc := ""

	if term.is_valid_int():
		sql_update = "UPDATE hackers SET power = 'Updated' WHERE id = " + term + ";"
		where_desc = "id = " + term
	else:
		# case-insensitive name match
		sql_update = "UPDATE hackers SET power = 'Updated' WHERE name = '" + term + "' COLLATE NOCASE;"
		where_desc = "name = '" + term + "' (no case)"

	db.query(sql_update)

	# Check how many rows were affected
	var check_sql := ""
	if term.is_valid_int():
		check_sql = "SELECT id, name, power FROM hackers WHERE id = " + term + ";"
	else:
		check_sql = "SELECT id, name, power FROM hackers WHERE name = '" + term + "' COLLATE NOCASE;"

	db.query(check_sql)

	if db.query_result.size() == 0:
		output.text = "No hacker found for " + where_desc + "."
	else:
		var row = db.query_result[0]
		output.
