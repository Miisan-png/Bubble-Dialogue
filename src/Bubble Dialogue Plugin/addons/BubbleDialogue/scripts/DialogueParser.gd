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
					dialogue_entries.append({
						"character": parts[0].strip_edges(),
						"text": parts[1].strip_edges()
					})
	
	return dialogue_entries
