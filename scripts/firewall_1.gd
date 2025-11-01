extends Control

@onready var email_field: LineEdit = $VBoxContainer/EmailField
@onready var password_field: LineEdit = $VBoxContainer/PasswordField
@onready var tmpl_edit: TextEdit = $VBoxContainer/BackendTemplate
@onready var preview_label: RichTextLabel = $VBoxContainer/BackendPreview


func _ready() -> void:
	# Make sure preview is plain text (and non-editable by nature)
	preview_label.bbcode_enabled = false

	# Starter template if empty
	if tmpl_edit.text.is_empty():
		tmpl_edit.text = """
SELECT *
FROM users
WHERE email = ''
AND pass = '' LIMIT 1
"""

	# Connect signals with the CORRECT signatures (no lambdas needed)
	email_field.text_changed.connect(_on_email_changed)        # (String)
	password_field.text_changed.connect(_on_password_changed)  # (String)
	tmpl_edit.text_changed.connect(_on_template_changed)       # ()

	_update_preview()  # initial render

func _on_email_changed(_t: String) -> void:
	_update_preview()

func _on_password_changed(_t: String) -> void:
	_update_preview()

func _on_template_changed() -> void:
	_update_preview()

func _update_preview() -> void:
	var email := _sanitize(email_field.text)
	var passw := _sanitize(password_field.text)

	var rendered := tmpl_edit.text

	# Replace the FIRST occurrence of:  email = ''   (case/space tolerant)
	rendered = _replace_first_regex(
		rendered,
		"(?i)\\bemail\\b\\s*=\\s*''",
		"email = '" + email + "'"    # replacement text
	)

	# Replace the FIRST occurrence of:  pass = ''
	rendered = _replace_first_regex(
		rendered,
		"(?i)\\bpass\\b\\s*=\\s*''",
		"pass = '" + passw + "'"
	)

	preview_label.text = rendered

func _replace_first_regex(text: String, pattern: String, replacement: String) -> String:
	var re := RegEx.new()
	var err := re.compile(pattern)
	if err != OK:
		return text
	# all=false -> replace ONLY FIRST match
	return re.sub(text, replacement, false)

# Only for visual correctness of quotes in the preview.
func _sanitize(s: String) -> String:
	return s.replace("'", "''")
