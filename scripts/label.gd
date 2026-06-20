extends Label

@onready var player = get_tree().get_first_node_in_group("player")
@onready var health = get_tree().get_first_node_in_group("player").get_node("Health")

func _process(_delta):
	text = "State: %s\nVelocity: %s\nHP: %s / %s" % [
		player.State.keys()[player.current_state],
		str(player.velocity.round()),
		health.current_health,
		health.max_health
	]
