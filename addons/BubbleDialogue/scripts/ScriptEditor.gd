@tool
extends VBoxContainer

signal save_requested(resource: DialogueResource)
signal dialogue_folder_changed(path: String)

@onready var dialogue_edit: CodeEdit = $DialogueEdit
@onready var new_dialogue_button: Button = $HBoxContainer/NewDialogueButton
@onready var load_dialogue_button: Button = $HBoxContainer/LoadDialogueButton
@onready var save_dialogue_button: Button = $HBoxContainer/SaveDialogueButton
@onready var dialogue_name_input: LineEdit = $DialogueName
@onready var dialogue_folder_path_button: Button = $HBoxContainer/DialogueFolderPathButton

var current_resource: DialogueResource = null
var base_font_size: int = 16
var current_font_size: int = base_font_size
var dialogue_folder_path: String = "res://dialogues"

func _ready():
	dialogue_edit.syntax_highlighter = load("res://addons/BubbleDialogue/scripts/DialogueSyntaxHighlighter.gd").new()
	dialogue_edit.set_draw_tabs(true)
	dialogue_edit.set_draw_spaces(true)
	
	update_font_size()
	apply_editor_theme()
	
	new_dialogue_button.connect("pressed", Callable(self, "_on_new_dialogue_pressed"))
	load_dialogue_button.connect("pressed", Callable(self, "_on_load_dialogue_pressed"))
	save_dialogue_button.connect("pressed", Callable(self, "save_dialogue"))
	dialogue_folder_path_button.connect("pressed", Callable(self, "_on_dialogue_folder_path_pressed"))
	
	save_dialogue_button.hide()
	
	# Load the saved dialogue folder path
	var config = ConfigFile.new()
	var err = config.load("user://dialogue_settings.cfg")
	if err == OK:
		dialogue_folder_path = config.get_value("settings", "dialogue_folder_path", "res://dialogues")
	
	# Update DialogueManager with the loaded path
	DialogueManager.set_dialogue_folder_path(dialogue_folder_path)

func apply_editor_theme():
	var editor_settings = EditorInterface.get_editor_settings()
	
	var base_color = editor_settings.get_setting("interface/theme/base_color")
	var accent_color = editor_settings.get_setting("interface/theme/accent_color")
	var background_color = base_color.darkened(0.1)
	
	var text_color = editor_settings.get_setting("text_editor/theme/highlighting/text_color")
	var line_number_color = editor_settings.get_setting("text_editor/theme/highlighting/line_number_color")
	
	dialogue_edit.add_theme_color_override("background_color", background_color)
	dialogue_edit.add_theme_color_override("current_line_color", base_color.lightened(0.1))
	dialogue_edit.add_theme_color_override("font_color", text_color)
	dialogue_edit.add_theme_color_override("font_selected_color", text_color)
	dialogue_edit.add_theme_color_override("font_readonly_color", text_color.darkened(0.2))
	dialogue_edit.add_theme_color_override("line_number_color", line_number_color)
	dialogue_edit.add_theme_color_override("caret_color", accent_color)

func load_dialogue(resource: DialogueResource):
	current_resource = resource
	dialogue_edit.text = resource.get_dialogue_content()
	dialogue_name_input.text = resource.dialogue_name
	save_dialogue_button.show()

func save_dialogue():
	if current_resource == null:
		return
	
	current_resource.dialogue_name = dialogue_name_input.text
	current_resource.set_dialogue_content(dialogue_edit.text)
	
	if current_resource.resource_path.is_empty():
		_on_new_dialogue_pressed()  # Open file dialog to save new dialogue
	else:
		emit_signal("save_requested", current_resource)

func _input(event):
	if event is InputEventMouseButton and (dialogue_edit.has_focus() or dialogue_name_input.has_focus()):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.ctrl_pressed:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.ctrl_pressed:
			zoom_out()

func zoom_in():
	if current_font_size < 72:  # Max font size
		current_font_size += 2
		update_font_size()

func zoom_out():
	if current_font_size > 8:  # Min font size
		current_font_size -= 2
		update_font_size()

func update_font_size():
	dialogue_edit.add_theme_font_size_override("font_size", current_font_size)
	dialogue_name_input.add_theme_font_size_override("font_size", current_font_size)

func _on_new_dialogue_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.tres ; Dialogue Resources"]
	file_dialog.current_path = dialogue_folder_path.path_join("new_dialogue.tres")
	file_dialog.connect("file_selected", Callable(self, "_on_new_dialogue_file_selected"))
	
	EditorInterface.get_base_control().add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_new_dialogue_file_selected(path):
	var file_name = path.get_file().get_basename()  # Get the file name without extension
	var new_resource = DialogueResource.new()
	new_resource.dialogue_name = file_name  # Set the dialogue_name to the file name
	new_resource.set_dialogue_content("#this is a new dialogue file "+"\n\nMiisan: Hello, how are you?\nRafaya: I'm doing great, thanks!")
	
	ResourceSaver.save(new_resource, path)
	EditorInterface.get_resource_filesystem().scan()
	load_dialogue(new_resource)

func _on_load_dialogue_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.tres ; Dialogue Resources"]
	file_dialog.current_path = dialogue_folder_path
	file_dialog.connect("file_selected", Callable(self, "_on_load_dialogue_file_selected"))
	
	EditorInterface.get_base_control().add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_load_dialogue_file_selected(path):
	var loaded_resource = load(path) as DialogueResource
	if loaded_resource:
		load_dialogue(loaded_resource)
	else:
		print("Failed to load dialogue resource")

func _on_dialogue_folder_path_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.current_path = dialogue_folder_path
	file_dialog.connect("dir_selected", Callable(self, "_on_dialogue_folder_selected"))
	
	EditorInterface.get_base_control().add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_dialogue_folder_selected(path: String):
	dialogue_folder_path = path
	emit_signal("dialogue_folder_changed", path)
	print("Dialogue folder set to: " + path)
	
	DialogueManager.set_dialogue_folder_path(path)
	
	var config = ConfigFile.new()
	config.set_value("settings", "dialogue_folder_path", path)
	config.save("user://dialogue_settings.cfg")
