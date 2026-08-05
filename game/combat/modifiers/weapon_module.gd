extends Resource
class_name WeaponModule

@export var module_id: StringName = &""


func transform(shots: Array[ShotSpec]) -> Array[ShotSpec]:
	var output: Array[ShotSpec] = []
	for shot in shots:
		if shot != null:
			output.append(shot.duplicate_spec())
	return output


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(module_id).is_empty():
		errors.append("module_id cannot be empty")
	return errors


func is_configuration_valid() -> bool:
	return validation_errors().is_empty()
