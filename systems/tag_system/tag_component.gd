class_name TagComponent
extends Node

var _tags: Dictionary = {}

signal tags_changed(tag: String, level: int, added: bool)

func add_tag(tag: String, level: int = 1) -> void:
	_tags[tag] = level
	emit_signal("tags_changed", tag, level, true)

func add_tag_once(tag: String, level: int = 1) -> void:
	if not has_tag(tag):
		add_tag(tag, level)

func stack_tag(tag: String, amount: int = 1) -> void:
	var current: int = _tags.get(tag, 0)
	add_tag(tag, current + amount)

func remove_tag(tag: String) -> void:
	if _tags.has(tag):
		var level: int = _tags[tag]
		_tags.erase(tag)
		emit_signal("tags_changed", tag, level, false)

func clear_all_tags() -> void:
	for tag in _tags.keys():
		_tags.erase(tag)

func has_tag(tag: String, min_level: int = 1) -> bool:
	return _tags.get(tag, 0) >= min_level

func has_all_tags(tags: Array) -> bool:
	for tag in tags:
		if not has_tag(tag):
			return false
	return true

func has_any_tag(tags: Array) -> bool:
	for tag in tags:
		if has_tag(tag):
			return true
	return false

func get_level(tag: String) -> int:
	return _tags.get(tag, 0)

func get_all_tags() -> Dictionary:
	return _tags.duplicate()

func get_tags_by_prefix(prefix: String) -> Array:
	var result: Array = []
	for tag in _tags.keys():
		if tag.begins_with(prefix):
			result.append(tag)
	return result

func evaluate_conditions(conditions: Dictionary) -> bool:
	var requires: Array = conditions.get("requires", [])
	if not has_all_tags(requires):
		return false
	var requires_level: Dictionary = conditions.get("requires_level", {})
	for tag in requires_level.keys():
		if get_level(tag) < requires_level[tag]:
			return false
	var excludes: Array = conditions.get("excludes", [])
	if has_any_tag(excludes):
		return false
	return true

func debug_print() -> void:
	print("[TagComponent] Tags:")
	for tag in _tags.keys():
		print("  %s (level %d)" % [tag, _tags[tag]])
