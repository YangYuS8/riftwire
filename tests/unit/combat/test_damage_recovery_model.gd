extends GutTest


func test_recovery_window_expires_on_exact_simulated_duration() -> void:
	var model := DamageRecoveryModel.new()
	model.start(0.6)

	assert_true(model.is_active())
	assert_almost_eq(model.get_remaining_seconds(), 0.6, 0.000001)
	assert_false(model.step(0.25))
	assert_almost_eq(model.get_remaining_seconds(), 0.35, 0.000001)
	assert_false(model.step(0.349))
	assert_true(model.is_active())
	assert_true(model.step(0.001))
	assert_false(model.is_active())
	assert_almost_eq(model.get_remaining_seconds(), 0.0, 0.000001)


func test_restart_replaces_remaining_duration_deterministically() -> void:
	var model := DamageRecoveryModel.new()
	model.start(1.0)
	model.step(0.75)
	model.start(0.5)

	assert_almost_eq(model.get_remaining_seconds(), 0.5, 0.000001)
	assert_false(model.step(0.25))
	assert_true(model.step(0.25))


func test_clear_ends_recovery_immediately() -> void:
	var model := DamageRecoveryModel.new()
	model.start(2.0)
	model.clear()

	assert_false(model.is_active())
	assert_almost_eq(model.get_remaining_seconds(), 0.0, 0.000001)
