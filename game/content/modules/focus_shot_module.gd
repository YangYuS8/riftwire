extends WeaponModule
class_name FocusShotModule

@export_range(0.0, 1.0, 0.01) var strength: float = 0.5


func _init() -> void:
	module_id = &"focus"


func transform(shots: Array[ShotSpec]) -> Array[ShotSpec]:
	var valid_shots: Array[ShotSpec] = []
	var direction_sum := Vector2.ZERO
	for shot in shots:
		if shot == null:
			continue
		valid_shots.append(shot)
		direction_sum += shot.direction

	if valid_shots.is_empty():
		return []

	var center_direction := direction_sum.normalized()
	if center_direction.length_squared() <= 0.000001:
		center_direction = valid_shots[0].direction

	var focus_amount := clampf(strength, 0.0, 1.0)
	var output: Array[ShotSpec] = []
	for shot in valid_shots:
		var angle_delta := wrapf(
			center_direction.angle() - shot.direction.angle(),
			-PI,
			PI
		)
		var focused_direction := shot.direction.rotated(angle_delta * focus_amount)
		output.append(shot.with_direction(focused_direction, module_id))
	return output


func validation_errors() -> PackedStringArray:
	var errors := super.validation_errors()
	if strength < 0.0 or strength > 1.0:
		errors.append("strength must be between zero and one")
	return errors
