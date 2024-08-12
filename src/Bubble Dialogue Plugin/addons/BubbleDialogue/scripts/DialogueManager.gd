extends Node

signal dialogue_started
signal dialogue_ended
signal dialogue_text_changed(character, text)

var current_dialogue: Array = []
var current_index: int = 0
var dialogue_folder_path: String = "res://dialogues"

func set_dialogue_folder_path(path: String):
	dialogue_folder_path = path

func start_dialogue(dialogue_resource: DialogueResource) -> void:
	current_dialogue = dialogue_resource.get_dialogue_content().split("\n")
	current_index = 0
	emit_signal("dialogue_started")
	show_next_dialogue()

func start_dialogue_by_name(dialogue_name: String) -> void:
	var dialogue_resources = load_all_dialogue_resources()
	for resource in dialogue_resources:
		if resource.dialogue_name == dialogue_name:
			start_dialogue(resource)
			return
	push_error("Dialogue not found: " + dialogue_name)

func show_next_dialogue() -> void:
	if current_index < current_dialogue.size():
		var dialogue_entry = current_dialogue[current_index]
		var parts = dialogue_entry.split(":", true, 1)
		if parts.size() == 2:
			emit_signal("dialogue_text_changed", parts[0].strip_edges(), parts[1].strip_edges())
		current_index += 1
	else:
		end_dialogue()

func end_dialogue() -> void:
	current_dialogue = []
	current_index = 0
	emit_signal("dialogue_ended")

func load_all_dialogue_resources() -> Array:
	var resources = []
	var dir = DirAccess.open(dialogue_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(dialogue_folder_path.path_join(file_name))
				if resource is DialogueResource:
					resources.append(resource)
			file_name = dir.get_next()
	return resources
