@tool
extends EditorSyntaxHighlighter

var character_color = Color(0.4, 0.6, 1.0)  # Light blue for character names
var dialogue_color = Color(1.0, 1.0, 1.0)   # White for dialogue text
var command_color = Color(1.0, 0.8, 0.2)    # Light yellow for commands
var tag_color = Color(0.2, 1.0, 0.2)        # Light green for tags

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
			
			var tag_start = line.find("[", colon_pos)
			while tag_start != -1:
				var tag_end = line.find("]", tag_start)
				if tag_end != -1:
					highlighting[tag_start] = {
						"color": tag_color,
						"end": tag_end + 1
					}
					# Reset the color after the tag
					if tag_end + 1 < line.length():
						highlighting[tag_end + 1] = {
							"color": dialogue_color,
							"end": line.length()
						}
					tag_start = line.find("[", tag_end)
				else:
					break
	elif line.begins_with("[") and line.ends_with("]"):
		highlighting[0] = {
			"color": command_color,
			"end": line.length()
		}
	
	return highlighting

func _get_name() -> String:
	return "Dialogue"

func _get_text_edit() -> TextEdit:
	return get_text_edit()

func _get_line_syntax_highlighting_forwarded() -> Dictionary:
	return {}

func _get_string_delimiters() -> PackedStringArray:
	return PackedStringArray([])

func _get_comment_delimiters() -> PackedStringArray:
	return PackedStringArray(["#"])

func _get_comment_delimiters_forwarded() -> PackedStringArray:
	return PackedStringArray([])

func _get_keyword_colors() -> Dictionary:
	return {}

func _get_member_keyword_colors() -> Dictionary:
	return {}

func _get_number_color() -> Color:
	return Color.WHITE

func _get_function_color() -> Color:
	return Color.WHITE

func _get_member_color() -> Color:
	return Color.WHITE
