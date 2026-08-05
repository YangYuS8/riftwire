extends GutTest


func test_patrol_reflects_at_both_bounds() -> void:
	var right_model := PatrolMovementModel.new(100.0, 10.0, 1.0)
	var right_reflection := right_model.step(109.0, 4.0, 1.0)

	assert_almost_eq(right_reflection, 107.0, 0.001)
	assert_almost_eq(right_model.direction, -1.0, 0.001)

	var left_model := PatrolMovementModel.new(100.0, 10.0, -1.0)
	var left_reflection := left_model.step(91.0, 4.0, 1.0)

	assert_almost_eq(left_reflection, 93.0, 0.001)
	assert_almost_eq(left_model.direction, 1.0, 0.001)


func test_fixed_step_patrol_sequence_is_repeatable_and_bounded() -> void:
	var first_model := PatrolMovementModel.new(0.0, 30.0, 1.0)
	var second_model := PatrolMovementModel.new(0.0, 30.0, 1.0)
	var first_x := 0.0
	var second_x := 0.0

	for _step in range(240):
		first_x = first_model.step(first_x, 90.0, 1.0 / 60.0)
		second_x = second_model.step(second_x, 90.0, 1.0 / 60.0)
		assert_almost_eq(first_x, second_x, 0.000001)
		assert_almost_eq(first_model.direction, second_model.direction, 0.000001)
		assert_between(first_x, -30.000001, 30.000001)
