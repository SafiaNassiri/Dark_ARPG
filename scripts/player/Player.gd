extends CharacterBody2D

# STATS
@export var move_speed: float = 180.0
@export var dash_speed: float = 520.0
@export var dash_duration: float = 0.18 #seconds
@export var dash_cooldown: float = 0.65 #seconds

# STATE
enum State { IDLE, MOVE, DASH, HURT, DEAD }
var current_state: State = State.IDLE

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var is_dead: bool = false

# REFS
# Uncomment and assign these once the nodes are added:
# @onready var sprite = $Sprite2D
# @onready var anim = $AnimationPlayer

# SIGNALS
signal died

func _physics_process(delta: float) -> void:
	if is_dead:
		return
 
	_tick_timers(delta)
 
	match current_state:
		State.DASH:
			_process_dash(delta)
		State.HURT:
			pass  # knockback handled externally for now
		_:
			_process_move()
			_check_dash_input()
 
	move_and_slide()

# MOVEMENT
func _process_move() -> void:
	var input_dir := _get_input_dir()
 
	if input_dir != Vector2.ZERO:
		velocity = input_dir * move_speed
		current_state = State.MOVE
		_update_facing(input_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed)
		current_state = State.IDLE
 
 
func _get_input_dir() -> Vector2:
	return Input.get_vector(
		"move_left", "move_right",
		"move_up",   "move_down"
	).normalized()


# DASH
func _check_dash_input() -> void:
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
		_start_dash()
 
 
func _start_dash() -> void:
	# Dash in current input direction; if standing still, dash forward (last facing)
	var dir := _get_input_dir()
	if dir == Vector2.ZERO:
		dir = _get_facing_dir()
 
	dash_direction = dir
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	current_state = State.DASH
 
 
func _process_dash(delta: float) -> void:
	velocity = dash_direction * dash_speed
	if dash_timer <= 0.0:
		current_state = State.IDLE

# TIMERS
func _tick_timers(delta: float) -> void:
	if dash_timer > 0.0:
		dash_timer -= delta
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

# FACING
# Stores last movement direction for dash fallback
var _last_facing: Vector2 = Vector2.DOWN
 
func _update_facing(dir: Vector2) -> void:
	_last_facing = dir
	# Hook sprite flipping here once I have art:
	# if dir.x != 0:
	#     sprite.flip_h = dir.x < 0
 
func _get_facing_dir() -> Vector2:
	return _last_facing

# DAMAGE / DEATH
# Call this from Health system node or HurtBox
func take_hit(knockback_dir: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if is_dead or current_state == State.DASH:
		return  # invincible during dash
 
	current_state = State.HURT
	if knockback_dir != Vector2.ZERO:
		velocity = knockback_dir * knockback_force
 
	# Brief hurt state — reset after a short delay
	await get_tree().create_timer(0.2).timeout
	if not is_dead:
		current_state = State.IDLE
 
 
func die() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEAD
	velocity = Vector2.ZERO
	emit_signal("died")
	# anim.play("death")   # uncomment when I have animations
	# queue_free()         # or transition to death screen

# DEBUG
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):   # Enter — test damage
		$Health.take_damage(10.0, Vector2.RIGHT, 200.0)
	if event.is_action_pressed("ui_cancel"):   # Escape — test die
		$Health.take_damage(999.0)
