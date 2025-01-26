class_name Player extends CharacterBody2D
@export var player_index := 0
@export var lives := 3
@export_group("Actions")
@export var move_left_action := "move_left"
@export var move_right_action := "move_right"
@export var move_down_action := "move_down"
@export var jump_action := "jump"
@export var gun_left_action := "gun_left"
@export var gun_right_action := "gun_right"
@export var gun_up_action := "gun_up"
@export var gun_down_action := "gun_down"
@export var shoot_action := "shoot"

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
@onready var state_chart: StateChart = $StateChart

var facing_right := true
var time_since_grounded := 0.0
var time_since_jump_press := 100.0

func calculate_jump_force() -> float:
	return -sqrt(2.0 * gravity * jump_height)

func is_at_jump_apex() -> bool:
	return not is_on_floor() and abs(velocity.y) < apex_threshold

func calculate_fall_multiplier() -> float:
	if is_at_jump_apex():
		return apex_multiplier
	if not Input.is_action_pressed(jump_action):
		return jump_release_multiplier
	if velocity.y < fall_multiplier_threshold:
		return fall_multiplier
	return 1.0

func _ready() -> void:
	var players := get_tree().get_nodes_in_group("player")
	for player: Player in players:
		self.add_collision_exception_with(player)

func reset() -> void:
	state_chart.send_event("reset")
	velocity = Vector2.ZERO
	_aerial_jumps = number_of_aerial_jumps
	facing_right = true
	time_since_grounded = 0.0
	time_since_jump_press = 100.0

@onready var lives_label: Label = $LivesLabel
@onready var spawn_point := global_position
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var invulnerability_flash_timer := 0.05

func _on_compound_state_state_processing(delta: float) -> void:
	if invulnerability_timer.is_stopped():
		if not visible: show()
		return
	invulnerability_flash_timer -= delta
	if invulnerability_flash_timer <= 0:
		if visible: hide()
		else: show()
		invulnerability_flash_timer = 0.05


func die() -> void:
	if lives == 1:
		Game.restart_scene()
		return
	lives -= 1
	global_position = spawn_point
	lives_label.text = "•".repeat(lives)
	reset()
	invulnerability_timer.start()


func bubbled(bubble: Bubble) -> void:
	if invulnerability_timer.is_stopped():
		state_chart.send_event("bubbled")
		velocity = bubble.direction * bubble.force + Vector2.UP * bubble.upward_force
		no_input_timer.start()

func get_closest_axis(direction: Vector2) -> Vector2:
	return direction.snapped(Vector2.ONE).normalized()
@onready var sprite: Sprite2D = $Sprite2D

func update_facing() -> void:
	facing_right = velocity.x > 0
	sprite.flip_h = !facing_right

@onready var gun_pivot: Node2D = $Pivot
@onready var gun: Node2D = $Pivot/Gun
@export var bubble: PackedScene
@onready var shooting_timer: Timer = $ShootingTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var keyboard:= false

func _on_normal_state_state_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		keyboard = true
	if event is InputEventJoypadMotion:
		keyboard = false
	if event.is_action_pressed(shoot_action):
		if shooting_timer.is_stopped():
			shooting_timer.start()
			var direction := Vector2.RIGHT.rotated(gun_pivot.rotation)
			var bub: Bubble = bubble.instantiate()
			velocity -= direction * bub.recoil
			bub.direction = direction
			bub.player_index = player_index
			bub.global_position = gun.global_position
			animation_player.stop()
			animation_player.play("shoot")
			get_tree().current_scene.add_child(bub)



@onready var gun_sprite: Sprite2D = $Pivot/Gun/Sprite2D
func _on_normal_state_state_processing(delta: float) -> void:
	var input := Input.get_vector(gun_left_action, gun_right_action, gun_up_action, gun_down_action).normalized()
	if input != Vector2.ZERO:
		gun_pivot.rotation = atan2(input.y, input.x)
		gun_sprite.flip_v = input.x < 0
	if keyboard:
		if player_index == 1:
			var mouse_pos := get_global_mouse_position()
			var direction := (mouse_pos - global_position).normalized()
			gun_pivot.rotation = atan2(direction.y, direction.x)



func accelerate(horizontal_input: float, acceleration: float, delta: float, max_speed: float) -> void:
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
	velocity.x = clamp(velocity.x, -movement_speed, movement_speed)

func handle_bouncy(delta:float)-> void:
	var collision := move_and_collide(velocity*delta,true)
	if collision:
		var bouncy :Bouncy= collision.get_collider() as Bouncy
		if bouncy:
			velocity = velocity.bounce(collision.get_normal())
			no_input_timer.start()

func _on_normal_state_state_physics_processing(delta: float) -> void:
	if not no_input_timer.is_stopped():
		velocity.y += gravity * delta * calculate_fall_multiplier()
		velocity.y = min(velocity.y, max_fall_speed)
		move_and_slide()
		return

	var horizontal_input := Input.get_axis(move_left_action, move_right_action)

	var acceleration := ground_acceleration if is_on_floor() else air_acceleration

	accelerate(horizontal_input, acceleration, delta, movement_speed)

	# Jump
	if (Input.is_action_just_pressed(jump_action) or time_since_jump_press < jump_buffer) and (is_on_floor() or time_since_grounded < coyote_time):
		velocity.y = calculate_jump_force()

	# Aerial Jumps
	if _aerial_jumps > 0 \
	and Input.is_action_just_pressed(jump_action) and not is_on_floor():
		velocity.y = calculate_jump_force()
		_aerial_jumps -= 1

	time_since_grounded += delta
	if is_on_floor():
		_aerial_jumps = number_of_aerial_jumps
		time_since_grounded = 0.0

	time_since_jump_press += delta
	if Input.is_action_just_pressed(jump_action):
		time_since_jump_press = 0.0

	# Apex modifiers
	if is_at_jump_apex():
		var apex_point := inverse_lerp(apex_threshold, 0, absf(velocity.y))
		velocity.x += sign(horizontal_input) * apex_speed_boost * apex_point

	if Input.is_action_pressed(move_down_action):
		var collision := move_and_collide(Vector2.DOWN,true)
		if collision:
			var shape :CollisionShape2D= collision.get_collider_shape()
			var body :Node= collision.get_collider()
			if shape.one_way_collision:
				add_collision_exception_with(body)
				await get_tree().create_timer(0.4).timeout
				remove_collision_exception_with(body)


	# Gravity

	velocity.y += gravity * delta * calculate_fall_multiplier()
	velocity.y = min(velocity.y, max_fall_speed)

	handle_bouncy(delta)

	move_and_slide()

@onready var bubble_shape: Sprite2D = $BubbleShape
@export_group("Bubble State")
@export var bubbled_up_speed := 1000.0
@export var bubbled_horizontal_speed := 1000.0
@onready var bubbled_timer: Timer = $BubbledTimer

func _on_bubbled_state_state_entered() -> void:
	bubbled_timer.start()
	bubble_shape.show()

func _on_bubbled_state_state_exited() -> void:
	bubble_shape.hide()

@onready var no_input_timer: Timer = $NoInputTimer

func _on_bubbled_state_state_physics_processing(delta: float) -> void:
	if not invulnerability_timer.is_stopped():
		return
	if not no_input_timer.is_stopped():
		move_and_slide()
		return
	var horizontal_input := Input.get_axis(move_left_action, move_right_action)
	var acceleration := air_acceleration
	accelerate(horizontal_input, acceleration, delta, bubbled_horizontal_speed)

	if invulnerability_timer.is_stopped():
		velocity.y = lerpf(velocity.y, -bubbled_up_speed, air_acceleration * delta)
	handle_bouncy(delta)
	move_and_slide()

func _on_bubbled_timer_timeout() -> void:
	state_chart.send_event("popped")

func is_in_bubble() -> bool:
	return not bubbled_timer.is_stopped()
