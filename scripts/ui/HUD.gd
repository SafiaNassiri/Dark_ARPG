extends Control

@onready var hp_bar: ProgressBar = $HPBar

var player: CharacterBody2D
var health: Node


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")
	print("Player: ", player)

	if player == null:
		push_error("HUD: No node found in group 'player'.")
		return

	health = player.get_node_or_null("Health")
	print("Health: ", health)

	if health == null:
		push_error("HUD: No Health node on Player.")
		return

	health.health_changed.connect(_on_health_changed)
	hp_bar.max_value = health.max_health
	hp_bar.value = health.current_health

	print("HUD connected successfully")


# SIGNAL HANDLERS 

func _on_health_changed(current: float, maximum: float) -> void:
	print("HP changed: ", current, " / ", maximum)
	hp_bar.max_value = maximum
	hp_bar.value = current
