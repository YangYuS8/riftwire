extends RefCounted
class_name PlayerMovementModel

var config: PlayerMovementConfig
var velocity: Vector2 = Vector2.ZERO
var coyote_time_remaining: float = 0.0
var jump_buffer_time_remaining: float = 0.0
var did_jump_this_step: bool = false


func _init(p_config: PlayerMovementConfig) -> void:
	assert(p_config != null, "PlayerMovementModel requires a movement config.")
	config = p_config


func reset(initial_velocity: Vector2 = Vector2.ZERO) -> void:
	velocity = initial_velocity
	coyote_time_remaining = 0.0
	jump_buffer_time_remaining = 0.0
	did_jump_this_step = false


func step(input_frame: PlayerInputFrame, delta: float, grounded: bool) -> Vector2:
	did_jump_this_step = false
	if delta <= 0.0:
		return velocity

	_update_forgiveness_windows(input_frame, delta, grounded)
	_update_horizontal_velocity(input_frame.move_axis, delta, grounded)
	_update_vertical_velocity(delta, grounded)
	_try_jump(input_frame, grounded)
	_apply_variable_jump(input_frame)
	return velocity


func reconcile_after_move(grounded_after_move: bool, resolved_velocity: Vector2) -> void:
	velocity = resolved_velocity
	if grounded_after_move and velocity.y > 0.0:
		velocity.y = 0.0


func _update_forgiveness_windows(
	input_frame: PlayerInputFrame,
	delta: float,
	grounded: bool
) -> void:
	if grounded:
		coyote_time_remaining = config.coyote_time
	else:
		coyote_time_remaining = maxf(0.0, coyote_time_remaining - delta)

	if input_frame.jump_pressed:
		jump_buffer_time_remaining = config.jump_buffer_time
	else:
		jump_buffer_time_remaining = maxf(0.0, jump_buffer_time_remaining - delta)


func _update_horizontal_velocity(move_axis: float, delta: float, grounded: bool) -> void:
	var normalized_axis := clampf(move_axis, -1.0, 1.0)
	if not is_zero_approx(normalized_axis):
		var acceleration := config.ground_acceleration if grounded else config.air_acceleration
		velocity.x = move_toward(
			velocity.x,
			normalized_axis * config.max_run_speed,
			acceleration * delta
		)
		return

	var deceleration := config.ground_deceleration if grounded else config.air_deceleration
	velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)


func _update_vertical_velocity(delta: float, grounded: bool) -> void:
	if grounded and velocity.y > 0.0:
		velocity.y = 0.0
	else:
		velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)


func _try_jump(input_frame: PlayerInputFrame, grounded: bool) -> void:
	var wants_jump := input_frame.jump_pressed or jump_buffer_time_remaining > 0.0
	var can_jump := grounded or coyote_time_remaining > 0.0
	if not wants_jump or not can_jump:
		return

	velocity.y = config.jump_velocity
	jump_buffer_time_remaining = 0.0
	coyote_time_remaining = 0.0
	did_jump_this_step = true


func _apply_variable_jump(input_frame: PlayerInputFrame) -> void:
	if input_frame.jump_held or velocity.y >= 0.0:
		return
	velocity.y = maxf(
		velocity.y,
		config.jump_velocity * config.jump_release_velocity_multiplier
	)
