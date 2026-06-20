extends Label

@onready var player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player:
		text = "State: %s\nVelocity: %s\nDash CD: %.2f" % [
			player.State.keys()[player.current_state],
			str(player.velocity.round()),
			player.dash_cooldown_timer
		]
