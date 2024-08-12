@tool
extends EditorPlugin

const DialogueScriptEditor = preload("res://addons/BubbleDialogue/scenes/dialogue_script_editor.tscn")
const DialogueResource = preload("res://addons/BubbleDialogue/resources/DialogueResource.gd")

var dialogue_editor_instance

func _enter_tree():
	add_custom_type("DialogueResource", "Resource", DialogueResource, null)
	
	dialogue_editor_instance = DialogueScriptEditor.instantiate()
	dialogue_editor_instance.connect("save_requested", Callable(self, "_on_save_requested"))
	
	if dialogue_editor_instance.has_signal("new_dialogue_requested"):
		dialogue_editor_instance.connect("new_dialogue_requested", Callable(self, "_on_new_dialogue_requested"))
	
	add_control_to_bottom_panel(dialogue_editor_instance, "Dialogue")

func _exit_tree():
	remove_custom_type("DialogueResource")
	
	if dialogue_editor_instance:
		remove_control_from_bottom_panel(dialogue_editor_instance)
		dialogue_editor_instance.queue_free()

func _handles(object):
	return object is DialogueResource

func _edit(object):
	if object is DialogueResource:
		dialogue_editor_instance.load_dialogue(object)
		make_bottom_panel_item_visible(dialogue_editor_instance)
		return true
	return false

func _on_save_requested(resource: DialogueResource):
	ResourceSaver.save(resource, resource.resource_path)
	EditorInterface.get_resource_filesystem().scan()

func _on_new_dialogue_requested():
	var new_dialogue = DialogueResource.new()
	dialogue_editor_instance.load_dialogue(new_dialogue)
	make_bottom_panel_item_visible(dialogue_editor_instance)
