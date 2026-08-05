extends Resource
class_name BaseWeaponConfig

@export_range(0.016, 10.0, 0.001, "or_greater") var fire_interval_seconds: float = 0.15
@export_range(1.0, 5000.0, 1.0, "or_greater") var projectile_speed: float = 720.0
@export_range(0.016, 30.0, 0.001, "or_greater") var projectile_lifetime_seconds: float = 1.5


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if fire_interval_seconds <= 0.0:
		errors.append("fire_interval_seconds must be greater than zero")
	if projectile_speed <= 0.0:
		errors.append("projectile_speed must be greater than zero")
	if projectile_lifetime_seconds <= 0.0:
		errors.append("projectile_lifetime_seconds must be greater than zero")
	return errors


func is_configuration_valid() -> bool:
	return validation_errors().is_empty()
