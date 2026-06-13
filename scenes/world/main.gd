extends Node2D

func _ready() -> void:
	var player_tags = $Player/TagComponent
	PassiveGraph.set_player_tags(player_tags)
	PassiveGraph.all_nodes["entropy_001"].is_available = true
	PassiveGraph.allocate_node("entropy_001")
	print("Has entropy tag: ", player_tags.has_tag("cluster:entropy"))
	print("Corruption level: ", PassiveGraph.get_corruption_level())
	player_tags.debug_print()

	Dialogue.set_player_tags(player_tags)

	var npc_lines = [
		{
			"text": "Move along, stranger.",
			"priority": 1,
			"conditions": {}
		},
		{
			"text": "I can feel something wrong about you. Stay back.",
			"priority": 10,
			"conditions": { "requires": ["cluster:entropy"] }
		},
		{
			"text": "You reek of corruption. The guard has been called.",
			"priority": 20,
			"conditions": { "requires": ["cluster:entropy"], "requires_level": { "corruption": 2 } }
		}
	]

	print("NPC says: ", Dialogue.get_line(npc_lines))
