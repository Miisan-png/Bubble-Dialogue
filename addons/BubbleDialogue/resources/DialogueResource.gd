@tool
extends Resource
class_name DialogueResource

@export var dialogue_name: String = ""
@export var dialogue_content: String = ""

func set_dialogue_content(content: String):
	dialogue_content = content

func get_dialogue_content() -> String:
	return dialogue_content
