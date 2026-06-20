extends Node

# STATS 
@export var max_health: float = 100.0
@export var invincibility_duration: float = 0.5   # seconds of iframes after hit

# STATE 
var current_health: float = max_health
var is_dead: bool = false
var is_invincible: bool = false

# SIGNALS 
signal health_changed(current: float, maximum: float)
signal died
signal hit_taken(amount: float)


func _ready() -> void:
	current_health = max_health


# PUBLIC API 

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if is_dead or is_invincible:
		return

	current_health = clamp(current_health - amount, 0.0, max_health)
	emit_signal("health_changed", current_health, max_health)
	emit_signal("hit_taken", amount)

	# Tell the parent to play hurt reaction + knockback
	var parent = get_parent()
	if parent.has_method("take_hit"):
		parent.take_hit(knockback_dir, knockback_force)

	if current_health <= 0.0:
		_die()
	else:
		_start_invincibility()


func heal(amount: float) -> void:
	if is_dead:
		return
	current_health = clamp(current_health + amount, 0.0, max_health)
	emit_signal("health_changed", current_health, max_health)


func get_health_percent() -> float:
	return current_health / max_health


func is_alive() -> bool:
	return not is_dead


# INTERNAL 

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	emit_signal("died")

	var parent = get_parent()
	if parent.has_method("die"):
		parent.die()


func _start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false
