extends WeaponModule
class_name SplitShotModule

@export_range(2, 8, 1) var projectile_count: int = 3
@export_range(0.0, 180.0, 0.1) var spread_degrees: float = 24.0


func _init() -> void:
	module_id = &"split"


func transform(shots: Array[ShotSpec]) -> Array[ShotSpec]:
	var output: Array[ShotSpec] = []
	var count := maxi(2, projectile_count)
	var spread := maxf(0.0, spread_degrees)
	var step_degrees := spread / float(count - 1)
	var start_degrees := -spread * 0.5

	for shot in shots:
		if shot == null:
			continue
		for projectile_index in range(count):
			var angle_degrees := start_degrees + step_degrees * float(projectile_index)
			output.append(
				shot.descended(
					shot.direction.rotated(deg_to_rad(angle_degrees)),
					module_id
				)
			)
	return output


func validation_errors() -> PackedStringArray:
	var errors := super.validation_errors()
	if projectile_count < 2:
		errors.append("projectile_count must be at least two")
	if spread_degrees < 0.0:
		errors.append("spread_degrees cannot be negative")
	return errors
