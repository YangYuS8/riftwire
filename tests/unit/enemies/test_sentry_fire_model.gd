extends GutTest


func test_initial_delay_and_repeat_interval_are_deterministic() -> void:
	var model := SentryFireModel.new(1.0, 0.5)

	assert_false(model.advance(0.25, true))
	assert_true(model.advance(0.25, true))
	assert_almost_eq(model.get_remaining_seconds(), 1.0, 0.000001)
	assert_false(model.advance(0.5, true))
	assert_true(model.advance(0.5, true))
	assert_almost_eq(model.get_remaining_seconds(), 1.0, 0.000001)


func test_inactive_target_resets_the_initial_telegraph_delay() -> void:
	var model := SentryFireModel.new(1.0, 0.5)

	assert_false(model.advance(0.4, true))
	assert_false(model.advance(0.1, false))
	assert_almost_eq(model.get_remaining_seconds(), 0.5, 0.000001)
	assert_false(model.advance(0.49, true))
	assert_true(model.advance(0.02, true))


func test_fixed_activity_sequence_repeats_exactly() -> void:
	var first := SentryFireModel.new(0.8, 0.3)
	var second := SentryFireModel.new(0.8, 0.3)
	var deltas := [0.1, 0.2, 0.4, 0.15, 0.25, 0.5, 0.1, 0.3]
	var active := [true, true, true, false, true, true, true, true]
	var first_fires: Array[bool] = []
	var second_fires: Array[bool] = []

	for index in range(deltas.size()):
		first_fires.append(first.advance(deltas[index], active[index]))
		second_fires.append(second.advance(deltas[index], active[index]))
		assert_almost_eq(
			first.get_remaining_seconds(),
			second.get_remaining_seconds(),
			0.000001
		)

	assert_eq(first_fires, second_fires)
