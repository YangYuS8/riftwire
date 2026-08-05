extends GutTest


func test_default_config_is_valid() -> void:
	var config := PlayerMovementConfig.new()
	assert_true(config.is_valid(), "Default movement configuration should be valid.")


func test_validation_reports_invalid_core_values() -> void:
	var config := PlayerMovementConfig.new()
	config.max_run_speed = 0.0
	config.jump_velocity = 1.0
	var errors := config.validation_errors()
	assert_true(errors.has("max_run_speed must be greater than zero."))
	assert_true(errors.has("jump_velocity must be negative."))


func test_jump_release_multiplier_is_bounded() -> void:
	var config := PlayerMovementConfig.new()
	config.jump_release_velocity_multiplier = 0.0
	assert_false(config.is_valid())
	assert_true(
		config.validation_errors().has(
			"jump_release_velocity_multiplier must be within (0, 1]."
		)
	)
