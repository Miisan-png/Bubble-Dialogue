extends Panel

@onready var text_label = $TextLabel
@onready var character_name_label = $CharacterNameLabel
@onready var indicator_mesh = $IndicatorMesh
@onready var dialogue_manager = get_node("/root/DialogueManager")

var current_dialogue: DialogueResource = null
var tween: Tween
var current_text: String = ""
var displayed_text: String = ""
var char_index: int = 0
var waiting: bool = false
var current_effect: String = ""
var effect_strength: float = 0.0
var shake_tween: Tween
var default_text_color: Color

func _ready():
	dialogue_manager.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
	dialogue_manager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	dialogue_manager.connect("dialogue_text_changed", Callable(self, "_on_dialogue_text_changed"))
	default_text_color = text_label.get_theme_color("font_color")
	text_label.bbcode_enabled = true
	hide()

func play(dialogue_input):
	if dialogue_input is String:
		dialogue_manager.start_dialogue_by_name(dialogue_input)
	elif dialogue_input is DialogueResource:
		dialogue_manager.start_dialogue(dialogue_input)
	else:
		push_error("Invalid input for play function. Expected String or DialogueResource.")

func _on_dialogue_started():
	show()
	_animate_show_dialogue_box()

func _on_dialogue_text_changed(character: String, new_text: String):
	character_name_label.text = character + ":"
	current_text = new_text
	displayed_text = ""
	char_index = 0
	waiting = false
	current_effect = ""
	effect_strength = 0.0
	text_label.text = ""
	_stop_all_effects()
	_process_next_character()

func _process_next_character():
	if char_index >= current_text.length():
		_start_indicator_animation()
		return

	var tag_start = current_text.find("[", char_index)
	if tag_start == char_index:
		var tag_end = current_text.find("]", tag_start)
		if tag_end != -1:
			var tag = current_text.substr(tag_start + 1, tag_end - tag_start - 1)
			_process_tag(tag)
			char_index = tag_end + 1
		else:
			char_index += 1
	else:
		var new_char = current_text[char_index]
		displayed_text += new_char
		text_label.text = displayed_text
		char_index += 1

	if not waiting:
		_schedule_next_character()

func _schedule_next_character():
	tween = create_tween()
	tween.tween_callback(Callable(self, "_process_next_character")).set_delay(0.05)

func _process_tag(tag: String):
	if tag.begins_with("wait:"):
		var wait_time = float(tag.split(":")[1])
		waiting = true
		tween = create_tween()
		tween.tween_callback(Callable(self, "_resume_after_wait")).set_delay(wait_time)
	elif tag.begins_with("shake:"):
		effect_strength = float(tag.split(":")[1])
		_apply_shake_effect()
	elif tag.begins_with("color:"):
		var color = tag.split(":")[1]
		displayed_text += "[color=" + color + "]"
	elif tag == "/color":
		displayed_text += "[/color]"

func _resume_after_wait():
	waiting = false
	_schedule_next_character()

func _apply_shake_effect():
	if shake_tween:
		shake_tween.kill()
	
	var original_position = position
	shake_tween = create_tween()
	shake_tween.set_loops()
	shake_tween.tween_property(self, "position", original_position + Vector2(5, 0), 0.05 / effect_strength)
	shake_tween.tween_property(self, "position", original_position + Vector2(-5, 0), 0.1 / effect_strength)
	shake_tween.tween_property(self, "position", original_position, 0.05 / effect_strength)

func _stop_all_effects():
	if shake_tween:
		shake_tween.kill()
	position = Vector2.ZERO

func _on_dialogue_ended():
	_stop_all_effects()
	_animate_hide_dialogue_box()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and visible:
		dialogue_manager.show_next_dialogue()

func _animate_show_dialogue_box():
	self.modulate.a = 0
	self.scale = Vector2(0.5, 0.5)
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _animate_hide_dialogue_box():
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(Callable(self, "hide"))

func _start_indicator_animation():
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(indicator_mesh, "position:y", indicator_mesh.position.y - 5, 0.5)
	tween.tween_property(indicator_mesh, "position:y", indicator_mesh.position.y, 0.5)
