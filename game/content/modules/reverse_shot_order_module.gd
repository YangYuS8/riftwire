extends WeaponModule
class_name ReverseShotOrderModule


func _init() -> void:
	module_id = &"reverse_order"


func transform(shots: Array[ShotSpec]) -> Array[ShotSpec]:
	var output: Array[ShotSpec] = []
	for shot_index in range(shots.size() - 1, -1, -1):
		var shot := shots[shot_index]
		if shot != null:
			output.append(shot.with_direction(shot.direction, module_id))
	return output
