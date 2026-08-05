extends RefCounted
class_name WeaponShotPipeline

const MAX_MODULES: int = 16
const MAX_OUTPUT_SHOTS: int = 32

var _modules: Array[WeaponModule] = []


func _init(modules: Array[WeaponModule] = []) -> void:
	for module in modules:
		if module != null:
			_modules.append(module)


func build(base_spec: ShotSpec) -> Array[ShotSpec]:
	assert(base_spec != null, "WeaponShotPipeline requires a base ShotSpec.")
	var shots: Array[ShotSpec] = []
	shots.append(base_spec.duplicate_spec())

	var module_count := mini(_modules.size(), MAX_MODULES)
	for module_index in range(module_count):
		shots = _sanitize_and_bound(_modules[module_index].transform(shots))
		if shots.is_empty():
			break
	return shots


func get_effective_module_count() -> int:
	return mini(_modules.size(), MAX_MODULES)


func _sanitize_and_bound(candidates: Array[ShotSpec]) -> Array[ShotSpec]:
	var output: Array[ShotSpec] = []
	for candidate in candidates:
		if candidate == null:
			continue
		output.append(candidate)
		if output.size() >= MAX_OUTPUT_SHOTS:
			break
	return output
