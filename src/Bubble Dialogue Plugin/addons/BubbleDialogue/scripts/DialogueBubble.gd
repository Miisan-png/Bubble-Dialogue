extends Panel

@onready var text_label = $TextLabel
@onready var character_name_label = $CharacterNameLabel
@onready var indicator_mesh = $IndicatorMesh
@onready var dialogue_manager = get_node("/root/DialogueManager")

var current_dialogue: DialogueResource = null
var tween: Tween
var shake_tween: Tween

func _ready():
	dialogue_manager.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
	dialogue_manager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	dialogue_manager.connect("dialogue_text_changed", Callable(self, "_on_dialogue_text_changed"))
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

func _on_dialogue_ended():
	_animate_hide_dialogue_box()
	if shake_tween:
		shake_tween.kill()

func _on_dialogue_text_changed(character: String, new_text: String):
	character_name_label.text = character + ":"
	_animate_text_appearance(new_text)
	
	var shake_start = new_text.find("[shake:")
	if shake_start != -1:
		var shake_end = new_text.find("]", shake_start)
		if shake_end != -1:
			var shake_value = new_text.substr(shake_start + 7, shake_end - shake_start - 7)
			var shake_speed = float(shake_value)
			_apply_shake_effect(shake_speed)
		
		new_text = new_text.substr(0, shake_start) + new_text.substr(shake_end + 1)
	
	text_label.text = new_text

func _apply_shake_effect(speed: float):
	if shake_tween:
		shake_tween.kill()
	
	var original_position = position
	shake_tween = create_tween()
	shake_tween.set_loops()
	shake_tween.tween_property(self, "position:y", original_position.y - 5, 0.05 / speed)
	shake_tween.tween_property(self, "position:y", original_position.y, 0.05 / speed)



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

func _animate_text_appearance(new_text: String):
	text_label.visible_characters = 0
	text_label.text = new_text
	
	tween = create_tween()
	tween.tween_property(text_label, "visible_characters", new_text.length(), 0.5)
	tween.tween_callback(Callable(self, "_start_indicator_animation"))

func _start_indicator_animation():
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(indicator_mesh, "position:y", indicator_mesh.position.y - 5, 0.5)
	tween.tween_property(indicator_mesh, "position:y", indicator_mesh.position.y, 0.5)
