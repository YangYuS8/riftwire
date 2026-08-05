extends GutTest


func test_aim_direction_is_normalized_with_right_fallback() -> void:
	var aimed_frame := PlayerInputFrame.new(0.0, false, false, Vector2(4.0, 0.0))
	var neutral_aim_frame := PlayerInputFrame.new(0.0, false, false, Vector2.ZERO)

	assert_eq(aimed_frame.aim_direction, Vector2.RIGHT)
	assert_eq(neutral_aim_frame.aim_direction, Vector2.RIGHT)


func test_copy_preserves_aim_and_fire_state() -> void:
	var source := PlayerInputFrame.new(
		-0.5,
		true,
		true,
		Vector2.UP,
		true,
		true
	)
	var copied := source.copy()

	assert_ne(copied, source)
	assert_eq(copied.move_axis, -0.5)
	assert_true(copied.jump_pressed)
	assert_eq(copied.aim_direction, Vector2.UP)
	assert_true(copied.fire_pressed)
	assert_true(copied.fire_held)
