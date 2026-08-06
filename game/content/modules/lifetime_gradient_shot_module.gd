extends WeaponModule
class_name LifetimeGradientShotModule

@export_range(0.1, 4.0, 0.01) var minimum_multiplier: float = 0.6
@export_range(0.1, 4.0, 0.01) var maximum_multiplier: float = 1.4


func _init() -> void:
	module_id = &"lifetime_gradient"


func transform(shots: Array[ShotSpec]) -> Array[ShotSpec]:
	var valid_shots: Array[ShotSpec] = []
	for shot in shots:
		if shot != null:
			valid_shots.append(shot)

	if valid_shots.is_empty():
		return []

	var output: Array[ShotSpec] = []
	for shot_index in range(valid_shots.size()):
		var interpolation_weight := 0.5
		if valid_shots.size() > 1:
			interpolation_weight = (
				float(shot_index) / float(valid_shots.size() - 1)
			)
		var lifetime_multiplier := lerpf(
			minimum_multiplier,
			maximum_multiplier,
			interpolation_weight
		)
		var shot := valid_shots[shot_index]
		output.append(
			shot.with_lifetime(
				shot.lifetime_seconds * lifetime_multiplier,
				module_id
			)
		)
	return output


func validation_errors() -> PackedStringArray:
	var errors := super.validation_errors()
	if minimum_multiplier <= 0.0:
		errors.append("minimum_multiplier must be greater than zero")
	if maximum_multiplier <= 0.0:
		errors.append("maximum_multiplier must be greater than zero")
	if minimum_multiplier > maximum_multiplier:
		errors.append("minimum_multiplier cannot exceed maximum_multiplier")
	return errors
