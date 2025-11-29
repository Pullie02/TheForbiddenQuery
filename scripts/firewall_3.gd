extends Control

# -----------------------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------------------
var db: SQLite
var did_normal_search := false
var did_success := false

# UI
@onready var search: LineEdit = $LineEdit
@onready var search_button: Button = $Button
@onready var display_label: Label = $backEndCode
@onready var output: RichTextLabel = $Output
@onready var animations: AnimationPlayer = $Animations
@onready var hackers_table_display: RichTextLabel = $"../HackersTable"

# Focus nodes
@onready var login_focus: Control = $"../Focus/LoginFocus"
@onready var backend_focus: Control = $"../Focus/BackendFocus"
@onready var output_focus: Control = $"../Focus/OutputFocus"


# -----------------------------------------------------------------------------
# INIT
# -----------------------------------------------------------------------------
func _ready() -> void:
	db = SQLite.new()

	var original_db = "res://Database/databaseLvl3.db"
	var temp_db = "user://level3_temp.db"

	# Copy DB fresh
	var r = FileAccess.open(original_db, FileAccess.READ)
	var bytes = r.get_buffer(r.get_length())
	r.close()

	var w = FileAccess.open(temp_db, FileAccess.WRITE)
	w.store_buffer(bytes)
	w.close()

	db.path = temp_db
	db.open_db()

	# UI setup
	search.text_changed.connect(_update_backend_preview)
	search_button.pressed.connect(_run_query)
	_update_backend_preview()
	_show_hackers_table()


# -----------------------------------------------------------------------------
# MAIN LOGIC
# -----------------------------------------------------------------------------
func _run_query() -> void:
	var term := search.text.strip_edges()
	if term == "":
		output.text = "⚠ Enter a hacker name or ID."
		return

	# -------------------------
	# 1. TAKE BEFORE-SNAPSHOT
	# -------------------------
	var before_sql = "SELECT id, name, power FROM hackers ORDER BY id;"
	db.query(before_sql)
	var before_state = db.query_result.duplicate(true)

	# -------------------------
	# 2. BUILD UPDATE QUERY
	# -------------------------
	var sql_update := ""

	if term.is_valid_int():
		sql_update = "UPDATE hackers SET power = 'Updated' WHERE id = " + term + ";"
	else:
		sql_update = "UPDATE hackers SET power = 'Updated' WHERE name = '" + term + "' COLLATE NOCASE;"

	# RUN PLAYER QUERY
	db.query(sql_update)

	# -------------------------
	# 3. TAKE AFTER-SNAPSHOT
	# -------------------------
	db.query(before_sql)
	var after_state = db.query_result.duplicate(true)

	# -------------------------
	# 4. Detect which rows changed
	# -------------------------
	var changed_rows := []
	for i in range(before_state.size()):
		var old = before_state[i]
		var new = after_state[i]

		if old.get("power") != new.get("power"):
			changed_rows.append(new)

	# -------------------------
	# 5. Determine normal vs injection
	# -------------------------
	var normal_update := false

	# If input was ID and ID changed
	if term.is_valid_int():
		for row in changed_rows:
			if str(row.get("id")) == term:
				normal_update = true
	
	# If input was name and name changed (case-insensitive)
	else:
		for row in changed_rows:
			if str(row.get("name")).to_lower() == term.to_lower():
				normal_update = true

	# -------------------------
	# 6. Choose the right outcome
	# -------------------------

	if changed_rows.size() == 0:
		# Nothing happened
		output.text = "No hacker found for: " + term
		return

	if normal_update:
		# ✔ Normal edit
		output.text = "Normal update succeeded for: " + term
		Dialogic.start("T3_NormalUpdate")
	else:
		# ✔ Injection detected
		output.text = "SQL Injection detected!\nChanged rows:\n"

		for row in changed_rows:
			output.text += "%s | %s | %s\n" % [
				str(row.get("id")), str(row.get("name")), str(row.get("power"))
			]

		Dialogic.start("T3_SQLInjection")

	_show_hackers_table()



# -----------------------------------------------------------------------------
# LIVE TABLE VIEW
# -----------------------------------------------------------------------------
func _show_hackers_table():
	var sql = "SELECT id, name, power FROM hackers ORDER BY id ASC;"
	db.query(sql)

	var txt = "[b]Hackers Table[/b]\n"
	txt += "ID | Name | Power\n"
	txt += "-------------------------\n"

	for row in db.query_result:
		txt += str(row.get("id")) + " | " + str(row.get("name")) + " | " + str(row.get("power")) + "\n"

	hackers_table_display.text = txt


# -----------------------------------------------------------------------------
# UI PREVIEW
# -----------------------------------------------------------------------------
func _update_backend_preview(_t=""):
	var term := search.text
	var preview := ""

	if term.is_valid_int():
		preview = "UPDATE hackers\nSET power = 'Updated'\nWHERE id = " + term
	else:
		preview = "UPDATE hackers\nSET power = 'Updated'\nWHERE name = '" + term + "'"

	display_label.text = preview
