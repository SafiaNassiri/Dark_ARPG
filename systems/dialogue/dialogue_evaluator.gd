class_name DialogueEvaluator
extends Node

# Pass in the player's TagComponent on game start
var player_tags: TagComponent = null

func set_player_tags(tags: TagComponent) -> void:
	player_tags = tags

# Given an array of dialogue lines, returns the best one for the current player.
# Each line is a Dictionary:
# {
#   "text": "I don't trust you.",
#   "priority": 10,
#   "conditions": {
#     "requires": ["cluster:entropy"],
#     "excludes": ["cluster:order"],
#     "requires_level": { "corruption": 2 }
#   }
# }
func get_line(lines: Array) -> String:
	if player_tags == null:
		push_error("DialogueEvaluator: no player_tags set.")
		return ""

	var best_text := ""
	var best_priority := -1

	for line in lines:
		var conditions = line.get("conditions", {})
		var priority = line.get("priority", 0)
		if player_tags.evaluate_conditions(conditions) and priority > best_priority:
			best_priority = priority
			best_text = line.get("text", "")

	return best_text
