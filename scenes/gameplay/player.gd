class_name Player extends CharacterBody2D

@export_group("Movement")

@export var movement_speed := 500.0
@export var ground_acceleration := 5.0
@export var air_acceleration := 2.5
@export var deceleration_multiplier := 2.0

@export_group("Jump")
@export var jump_height := 200.0
@export var gravity := 2000.0
@export var jump_release_multiplier := 3.0

@export var fall_multiplier := 2.0
@export var fall_multiplier_threshold := 30.0
@export var max_fall_speed := 4000.0

@export var apex_threshold := 20.0
@export var apex_multiplier := 0.75
@export var apex_speed_boost := 5.0

@export var number_of_aerial_jumps := 1

@export var coyote_time := 0.1
@export var jump_buffer := 0.1

@onready var _aerial_jumps := number_of_aerial_jumps

var facing_right := true
var dash_direction := Vector2.ZERO
var is_dashing := false
var time_since_grounded := 0.0
var time_since_jump_press := 100.0

func calculate_jump_force() -> float:
	return -sqrt(2.0 * gravity * jump_height)

func is_at_jump_apex() -> bool:
	return not is_on_floor() and abs(velocity.y) < apex_threshold

func calculate_fall_multiplier() -> float:
	if is_at_jump_apex():
		return apex_multiplier
	if not Input.is_action_pressed("jump"):
		return jump_release_multiplier
	if velocity.y < fall_multiplier_threshold:
		return fall_multiplier
	return 1.0

func die():
	Game.restart_scene()

func _physics_process(delta: float) -> void:
	# Movement
	var horizontal_input := Input.get_axis("move_left","move_right")

	var acceleration := ground_acceleration if is_on_floor() else air_acceleration

	if horizontal_input < 0.0:
		# Move left
		update_facing()
		if velocity.x > 0.0:
			velocity.x = 0.0
		velocity.x = lerp(velocity.x, -movement_speed, acceleration * delta)
	elif horizontal_input > 0.0:
		# Move right
		update_facing()
		if velocity.x < 0.0:
			velocity.x = 0.0
		velocity.x = lerp(velocity.x, movement_speed, acceleration * delta)
	else:
		# Stop
		velocity.x = lerp(velocity.x, 0.0, acceleration * deceleration_multiplier * delta)
	velocity.x = clamp(velocity.x, -movement_speed,movement_speed)

	# Jump
	if (Input.is_action_just_pressed("jump") or time_since_jump_press < jump_buffer) and (is_on_floor() or time_since_grounded < coyote_time):
		velocity.y = calculate_jump_force()

	# Aerial Jumps
	if _aerial_jumps > 0\
	and Input.is_action_just_pressed("jump") and not is_on_floor():
		velocity.y = calculate_jump_force()
		_aerial_jumps -= 1

	time_since_grounded += delta
	if is_on_floor():
		_aerial_jumps = number_of_aerial_jumps
		time_since_grounded = 0.0

	time_since_jump_press+=delta
	if Input.is_action_just_pressed("jump"):
		time_since_jump_press = 0.0

	# Apex modifiers
	if is_at_jump_apex():
		var apex_point := inverse_lerp(apex_threshold,0,abs(velocity.y))
		velocity.x += sign(horizontal_input) * apex_speed_boost * apex_point

	# Gravity
	velocity.y += gravity * delta * calculate_fall_multiplier()
	velocity.y = min(velocity.y, max_fall_speed)

	move_and_slide()

func get_closest_axis(direction:Vector2) -> Vector2:
	return snapped(direction,Vector2.ONE).normalized()


func update_facing():
	facing_right = velocity.x > 0
