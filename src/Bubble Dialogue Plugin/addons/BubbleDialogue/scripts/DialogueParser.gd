extends RefCounted

class_name DialogueParser

static func parse_dialogue_file(file_path: String) -> Array:
	var dialogue_entries = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line.length() > 0:
				var parts = line.split(":", true, 1)
				if parts.size() == 2:
					var character = parts[0].strip_edges()
					var text = parts[1].strip_edges()
					var tags = []
					
					# Parse tags
					var tag_start = text.find("[")
					while tag_start != -1:
						var tag_end = text.find("]", tag_start)
						if tag_end != -1:
							var tag = text.substr(tag_start + 1, tag_end - tag_start - 1)
							tags.append(tag)
							tag_start = text.find("[", tag_end)
						else:
							break
					
					dialogue_entries.append({
						"character": character,
						"text": text,
						"tags": tags
					})
	
	return dialogue_entries
