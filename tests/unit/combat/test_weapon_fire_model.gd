extends GutTest

const FIXED_DELTA: float = 1.0 / 60.0


func test_held_fire_repeats_at_configured_interval() -> void:
	var config := BaseWeaponConfig.new()
	config.fire_interval_seconds = 0.2
	var model := WeaponFireModel.new(config)
	var shot_count := 0

	for _frame in range(60):
		if model.step(true, FIXED_DELTA):
			shot_count += 1

	assert_eq(shot_count, 5)


func test_release_does_not_create_a_shot() -> void:
	var model := WeaponFireModel.new(BaseWeaponConfig.new())

	assert_false(model.step(false, FIXED_DELTA))
	assert_true(model.step(true, FIXED_DELTA))
	assert_false(model.step(false, FIXED_DELTA))


func test_reset_allows_an_immediate_shot() -> void:
	var model := WeaponFireModel.new(BaseWeaponConfig.new())
	assert_true(model.step(true, FIXED_DELTA))
	assert_false(model.step(true, FIXED_DELTA))

	model.reset()

	assert_true(model.step(true, FIXED_DELTA))
