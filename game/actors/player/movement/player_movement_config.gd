extends Resource
class_name PlayerMovementConfig

@export_category("Horizontal")
@export_range(1.0, 1200.0, 1.0) var max_run_speed: float = 320.0
@export_range(1.0, 6000.0, 1.0) var ground_acceleration: float = 2400.0
@export_range(1.0, 6000.0, 1.0) var ground_deceleration: float = 3000.0
@export_range(1.0, 6000.0, 1.0) var air_acceleration: float = 1500.0
@export_range(0.0, 6000.0, 1.0) var air_deceleration: float = 450.0

@export_category("Vertical")
@export_range(1.0, 6000.0, 1.0) var gravity: float = 1800.0
@export_range(-2000.0, -1.0, 1.0) var jump_velocity: float = -620.0
@export_range(1.0, 3000.0, 1.0) var max_fall_speed: float = 1100.0
@export_range(0.05, 1.0, 0.01) var jump_release_velocity_multiplier: float = 0.45

@export_category("Forgiveness")
@export_range(0.0, 0.5, 0.005) var coyote_time: float = 0.10
@export_range(0.0, 0.5, 0.005) var jump_buffer_time: float = 0.12


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if max_run_speed <= 0.0:
		errors.append("max_run_speed must be greater than zero.")
	if ground_acceleration <= 0.0:
		errors.append("ground_acceleration must be greater than zero.")
	if ground_deceleration <= 0.0:
		errors.append("ground_deceleration must be greater than zero.")
	if air_acceleration <= 0.0:
		errors.append("air_acceleration must be greater than zero.")
	if air_deceleration < 0.0:
		errors.append("air_deceleration cannot be negative.")
	if gravity <= 0.0:
		errors.append("gravity must be greater than zero.")
	if jump_velocity >= 0.0:
		errors.append("jump_velocity must be negative.")
	if max_fall_speed <= 0.0:
		errors.append("max_fall_speed must be greater than zero.")
	if jump_release_velocity_multiplier <= 0.0 or jump_release_velocity_multiplier > 1.0:
		errors.append("jump_release_velocity_multiplier must be within (0, 1].")
	if coyote_time < 0.0:
		errors.append("coyote_time cannot be negative.")
	if jump_buffer_time < 0.0:
		errors.append("jump_buffer_time cannot be negative.")
	return errors


func is_valid() -> bool:
	return validation_errors().is_empty()
