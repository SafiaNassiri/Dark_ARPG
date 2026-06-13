class_name PassiveNode
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var cluster: String = ""
@export var lore_text: String = ""
@export var connected_ids: Array = []
@export var contradiction_ids: Array = []
@export var position: Vector2 = Vector2.ZERO
@export var stat_modifiers: Array = []
@export var tags_granted: Array = []
@export var tags_removed: Array = []
@export var corruption_weight: float = 0.0

var is_allocated: bool = false
var is_available: bool = false
var is_locked: bool = false

static func from_dict(data: Dictionary) -> PassiveNode:
	var node = PassiveNode.new()
	node.id                = data.get("id", "")
	node.display_name      = data.get("display_name", "")
	node.cluster           = data.get("cluster", "")
	node.lore_text         = data.get("lore_text", "")
	node.connected_ids     = data.get("connected_ids", [])
	node.contradiction_ids = data.get("contradiction_ids", [])
	node.stat_modifiers    = data.get("stat_modifiers", [])
	node.tags_granted      = data.get("tags_granted", [])
	node.tags_removed      = data.get("tags_removed", [])
	node.corruption_weight = data.get("corruption_weight", 0.0)
	var pos = data.get("position", {"x": 0, "y": 0})
	node.position = Vector2(pos.get("x", 0), pos.get("y", 0))
	return node
