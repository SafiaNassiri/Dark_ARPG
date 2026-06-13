class_name PassiveGraphSystem
extends Node

const NODES_PATH := "res://data/nodes/"
const CONTRADICTION_MODE := "soft"
const SOFT_LOCK_COST_MULTIPLIER := 3

var all_nodes: Dictionary = {}
var allocated_ids: Array = []
var player_tags: TagComponent = null

signal node_allocated(node: PassiveNode)
signal node_deallocated(node: PassiveNode)
signal corruption_changed(new_level: int)

func _ready() -> void:
	load_all_nodes()

func set_player_tags(tag_component: TagComponent) -> void:
	player_tags = tag_component

func load_all_nodes() -> void:
	all_nodes.clear()
	var dir := DirAccess.open(NODES_PATH)
	if dir == null:
		push_error("PassiveGraph: Cannot open: " + NODES_PATH)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			_load_node_file(NODES_PATH + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	print("PassiveGraph: Loaded %d nodes." % all_nodes.size())

func _load_node_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("PassiveGraph: Failed to open " + path)
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("PassiveGraph: JSON error in " + path)
		return
	var node := PassiveNode.from_dict(json.data)
	if node.id == "":
		return
	all_nodes[node.id] = node
	_refresh_availability()

func can_allocate(node_id: String) -> Dictionary:
	if not all_nodes.has(node_id):
		return {"allowed": false, "reason": "Not found."}
	var node: PassiveNode = all_nodes[node_id]
	if node.is_allocated:
		return {"allowed": false, "reason": "Already allocated."}
	if not node.is_available:
		return {"allowed": false, "reason": "Not adjacent."}
	var contradicting := _get_active_contradictions(node)
	if contradicting.size() > 0 and CONTRADICTION_MODE == "hard":
		return {"allowed": false, "reason": "Contradicts allocated node."}
	return {"allowed": true, "reason": ""}

func allocate_node(node_id: String) -> bool:
	var check := can_allocate(node_id)
	if not check["allowed"]:
		push_warning("PassiveGraph: " + check["reason"])
		return false
	var node: PassiveNode = all_nodes[node_id]
	node.is_allocated = true
	allocated_ids.append(node_id)
	if player_tags:
		for tag in node.tags_granted:
			player_tags.add_tag(tag)
		for tag in node.tags_removed:
			player_tags.remove_tag(tag)
	_refresh_availability()
	_update_corruption()
	emit_signal("node_allocated", node)
	return true

func get_corruption() -> float:
	var total: float = 0.0
	for id in allocated_ids:
		total += all_nodes[id].corruption_weight
	return total

func get_corruption_level() -> int:
	var c := get_corruption()
	if c >= 6.0: return 3
	if c >= 3.0: return 2
	if c >= 1.0: return 1
	return 0

func get_save_data() -> Dictionary:
	return {"allocated_ids": allocated_ids.duplicate()}

func load_save_data(data: Dictionary) -> void:
	for id in allocated_ids.duplicate():
		if all_nodes.has(id):
			all_nodes[id].is_allocated = false
	allocated_ids.clear()
	for id in data.get("allocated_ids", []):
		if all_nodes.has(id):
			all_nodes[id].is_allocated = true
			allocated_ids.append(id)
	_recompute_tags()
	_refresh_availability()
	_update_corruption()

func _get_active_contradictions(node: PassiveNode) -> Array:
	var active: Array = []
	for cid in node.contradiction_ids:
		if allocated_ids.has(cid):
			active.append(cid)
	return active

func _refresh_availability() -> void:
	for id in all_nodes.keys():
		var node: PassiveNode = all_nodes[id]
		if node.is_allocated:
			node.is_available = true
			continue
		var available := false
		for cid in node.connected_ids:
			if allocated_ids.has(cid):
				available = true
				break
		if not available:
			for oid in allocated_ids:
				if all_nodes[oid].connected_ids.has(id):
					available = true
					break
		node.is_available = available

func _recompute_tags() -> void:
	if not player_tags:
		return
	player_tags.clear_all_tags()
	for id in allocated_ids:
		for tag in all_nodes[id].tags_granted:
			player_tags.add_tag(tag)

func _update_corruption() -> void:
	var level := get_corruption_level()
	if player_tags:
		player_tags.remove_tag("corruption")
		if level > 0:
			player_tags.add_tag("corruption", level)
	emit_signal("corruption_changed", level)
