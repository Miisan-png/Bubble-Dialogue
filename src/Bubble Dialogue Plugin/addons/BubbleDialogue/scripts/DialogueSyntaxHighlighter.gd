@tool
extends EditorSyntaxHighlighter

var character_color = Color(0.4, 0.6, 1.0)  # Light blue for character names
var dialogue_color = Color(1.0, 1.0, 1.0)   # White for dialogue text
var command_color = Color(1.0, 0.8, 0.2)    # Light yellow for commands

func _get_line_syntax_highlighting(line_number: int) -> Dictionary:
	var highlighting = {}
	var line = get_text_edit().get_line(line_number)
	
	var colon_pos = line.find(":")
	if colon_pos != -1:
		highlighting[0] = {
			"color": character_color,
			"end": colon_pos
		}
		if colon_pos + 1 < line.length():
			highlighting[colon_pos + 1] = {
				"color": dialogue_color,
				"end": line.length()
			}
	elif line.begins_with("[") and line.ends_with("]"):
		highlighting[0] = {
			"color": command_color,
			"end": line.length()
		}
	
	return highlighting

func _get_name() -> String:
	return "Dialogue"
