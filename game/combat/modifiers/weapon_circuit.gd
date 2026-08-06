extends RefCounted
class_name WeaponCircuit

signal changed(module_ids: PackedStringArray, selected_slot: int)

const MAX_SLOTS: int = WeaponShotPipeline.MAX_MODULES

var _modules: Array[WeaponModule] = []
var _selected_slot: int = 0


func _init(initial_modules: Array[WeaponModule] = []) -> void:
	set_modules(initial_modules)


func set_modules(next_modules: Array[WeaponModule]) -> void:
	assert(
		next_modules.size() <= MAX_SLOTS,
		"WeaponCircuit cannot exceed %d slots." % MAX_SLOTS
	)
	_modules.clear()
	for module in next_modules:
		assert(module != null, "WeaponCircuit modules cannot be null.")
		assert(
			module.is_configuration_valid(),
			"Invalid weapon module configuration: %s"
			% ", ".join(module.validation_errors())
		)
		_modules.append(module)

	if _modules.is_empty():
		_selected_slot = 0
	else:
		_selected_slot = clampi(_selected_slot, 0, _modules.size() - 1)
	_emit_changed()


func select_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _modules.size():
		return false
	if slot_index == _selected_slot:
		return true
	_selected_slot = slot_index
	_emit_changed()
	return true


func move_selected(offset: int) -> bool:
	if _modules.size() < 2 or offset == 0:
		return false
	var step := 1 if offset > 0 else -1
	var target_slot := _selected_slot + step
	if target_slot < 0 or target_slot >= _modules.size():
		return false

	var displaced_module := _modules[target_slot]
	_modules[target_slot] = _modules[_selected_slot]
	_modules[_selected_slot] = displaced_module
	_selected_slot = target_slot
	_emit_changed()
	return true


func get_selected_slot() -> int:
	return _selected_slot


func get_modules() -> Array[WeaponModule]:
	var copied_modules: Array[WeaponModule] = []
	for module in _modules:
		copied_modules.append(module)
	return copied_modules


func get_modules_as_resources() -> Array[Resource]:
	var copied_modules: Array[Resource] = []
	for module in _modules:
		copied_modules.append(module)
	return copied_modules


func get_module_ids() -> PackedStringArray:
	var module_ids := PackedStringArray()
	for module in _modules:
		module_ids.append(String(module.module_id))
	return module_ids


func _emit_changed() -> void:
	changed.emit(get_module_ids(), _selected_slot)
