extends GutTest

const TICK: float = 1.0 / 60.0

var config: PlayerMovementConfig


func before_each() -> void:
	config = PlayerMovementConfig.new()


func test_ground_acceleration_uses_fixed_tick_delta() -> void:
	var model := PlayerMovementModel.new(config)
	model.step(PlayerInputFrame.new(1.0), TICK, true)
	var expected := config.ground_acceleration * TICK
	assert_true(absf(model.velocity.x - expected) < 0.001)


func test_coyote_time_allows_jump_after_leaving_floor() -> void:
	var model := PlayerMovementModel.new(config)
	model.step(PlayerInputFrame.neutral(), TICK, true)
	for _frame in range(3):
		model.step(PlayerInputFrame.neutral(), TICK, false)
	model.step(PlayerInputFrame.new(0.0, true, true), TICK, false)
	assert_true(model.did_jump_this_step)
	assert_true(absf(model.velocity.y - config.jump_velocity) < 0.001)


func test_jump_fails_after_coyote_window_expires() -> void:
	config.coyote_time = 0.03
	var model := PlayerMovementModel.new(config)
	model.step(PlayerInputFrame.neutral(), TICK, true)
	for _frame in range(4):
		model.step(PlayerInputFrame.neutral(), TICK, false)
	model.step(PlayerInputFrame.new(0.0, true, true), TICK, false)
	assert_false(model.did_jump_this_step)


func test_jump_buffer_is_consumed_on_landing_tick() -> void:
	var model := PlayerMovementModel.new(config)
	model.step(PlayerInputFrame.new(0.0, true, true), TICK, false)
	assert_false(model.did_jump_this_step)
	model.step(PlayerInputFrame.new(0.0, false, true), TICK, true)
	assert_true(model.did_jump_this_step)


func test_releasing_jump_reduces_upward_velocity() -> void:
	var model := PlayerMovementModel.new(config)
	model.step(PlayerInputFrame.new(0.0, true, true), TICK, true)
	var held_velocity := model.velocity.y
	model.step(PlayerInputFrame.new(0.0, false, false), TICK, false)
	assert_true(model.velocity.y > held_velocity)
	assert_true(model.velocity.y < 0.0)


func test_fixed_input_sequence_is_repeatable() -> void:
	var first := PlayerMovementModel.new(config)
	var second := PlayerMovementModel.new(config)
	var sequence: Array[PlayerInputFrame] = []
	for frame_index in range(90):
		sequence.append(PlayerInputFrame.new(
			1.0 if frame_index < 60 else 0.0,
			frame_index == 5,
			frame_index >= 5 and frame_index < 18
		))

	for frame in sequence:
		var grounded := frame == sequence[0]
		first.step(frame, TICK, grounded)
		second.step(frame, TICK, grounded)
		assert_true(first.velocity.is_equal_approx(second.velocity))
