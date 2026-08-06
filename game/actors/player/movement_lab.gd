extends Node2D
class_name MovementLab

signal circuit_changed(module_ids: PackedStringArray, selected_slot: int)

const SPLIT_MODULE: Resource = preload(
	"res://game/content/modules/default_split_module.tres"
)
const FOCUS_MODULE: Resource = preload(
	"res://game/content/modules/default_focus_module.tres"
)
const REVERSE_ORDER_MODULE: Resource = preload(
	"res://game/content/modules/default_reverse_order_module.tres"
)
const VELOCITY_GRADIENT_MODULE: Resource = preload(
	"res://game/content/modules/default_velocity_gradient_module.tres"
)
const LIFETIME_GRADIENT_MODULE: Resource = preload(
	"res://game/content/modules/default_lifetime_gradient_module.tres"
)

var _circuit: WeaponCircuit
var _weapon: PlayerWeapon
var _circuit_status: Label
var _circuit_preview: Label


func _ready() -> void:
	_resolve_dependencies()
	_circuit = WeaponCircuit.new(_default_modules())
	_apply_circuit()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if handle_circuit_key_event(event as InputEventKey):
		get_viewport().set_input_as_handled()


func handle_circuit_key_event(key_event: InputEventKey) -> bool:
	if key_event == null or not key_event.pressed or key_event.echo:
		return false
	var pressed_key := (
		key_event.physical_keycode
		if key_event.physical_keycode != 0
		else key_event.keycode
	)
	match pressed_key:
		KEY_1:
			select_slot(0)
		KEY_2:
			select_slot(1)
		KEY_3:
			select_slot(2)
		KEY_4:
			select_slot(3)
		KEY_5:
			select_slot(4)
		KEY_Q:
			move_selected_module(-1)
		KEY_E:
			move_selected_module(1)
		KEY_R:
			reset_circuit()
		_:
			return false
	return true


func select_slot(slot_index: int) -> bool:
	_ensure_circuit()
	var selected := _circuit.select_slot(slot_index)
	if selected:
		_refresh_status()
	return selected


func move_selected_module(offset: int) -> bool:
	_ensure_circuit()
	if not _circuit.move_selected(offset):
		return false
	_apply_circuit()
	return true


func reset_circuit() -> void:
	_ensure_circuit()
	_circuit.set_modules(_default_modules())
	_circuit.select_slot(0)
	_apply_circuit()


func get_selected_slot() -> int:
	_ensure_circuit()
	return _circuit.get_selected_slot()


func get_module_ids() -> PackedStringArray:
	_ensure_circuit()
	return _circuit.get_module_ids()


func get_player_weapon() -> PlayerWeapon:
	_resolve_dependencies()
	return _weapon


func get_circuit_status_text() -> String:
	_resolve_dependencies()
	return _circuit_status.text


func get_circuit_preview_text() -> String:
	_resolve_dependencies()
	return _circuit_preview.text


func _apply_circuit() -> void:
	_resolve_dependencies()
	_weapon.set_modules(_circuit.get_modules_as_resources())
	_refresh_status()


func _refresh_status() -> void:
	var module_ids := _circuit.get_module_ids()
	var selected_labels := PackedStringArray()
	for slot_index in range(module_ids.size()):
		var label := _module_label(module_ids[slot_index])
		if slot_index == _circuit.get_selected_slot():
			label = "[%s]" % label
		selected_labels.append(label)

	_circuit_status.text = "Circuit: %s" % " -> ".join(selected_labels)
	_circuit_preview.text = _build_preview_text(_weapon.build_shot_specs())
	circuit_changed.emit(module_ids, _circuit.get_selected_slot())


func _build_preview_text(shots: Array[ShotSpec]) -> String:
	if shots.is_empty():
		return "Preview: no projectiles"

	var fan_width_degrees := 0.0
	if shots.size() > 1:
		fan_width_degrees = absf(
			rad_to_deg(
				shots[0].direction.angle_to(shots[shots.size() - 1].direction)
			)
		)

	var speeds := PackedStringArray()
	var lifetimes := PackedStringArray()
	for shot in shots:
		speeds.append("%.0f" % shot.speed)
		lifetimes.append("%.2f" % shot.lifetime_seconds)

	return (
		"Preview: %d shots | %.1f-degree fan | speed %s | lifetime %s s"
		% [
			shots.size(),
			fan_width_degrees,
			" / ".join(speeds),
			" / ".join(lifetimes),
		]
	)


func _module_label(module_id: String) -> String:
	match module_id:
		"split":
			return "Split"
		"focus":
			return "Focus"
		"reverse_order":
			return "Reverse Order"
		"velocity_gradient":
			return "Velocity Gradient"
		"lifetime_gradient":
			return "Lifetime Gradient"
		_:
			return module_id.capitalize()


func _default_modules() -> Array[WeaponModule]:
	var default_modules: Array[WeaponModule] = []
	default_modules.append(SPLIT_MODULE as WeaponModule)
	default_modules.append(FOCUS_MODULE as WeaponModule)
	default_modules.append(REVERSE_ORDER_MODULE as WeaponModule)
	default_modules.append(VELOCITY_GRADIENT_MODULE as WeaponModule)
	default_modules.append(LIFETIME_GRADIENT_MODULE as WeaponModule)
	return default_modules


func _ensure_circuit() -> void:
	if _circuit == null:
		_circuit = WeaponCircuit.new(_default_modules())


func _resolve_dependencies() -> void:
	if _weapon == null:
		_weapon = get_node_or_null("Player/Weapon") as PlayerWeapon
	if _circuit_status == null:
		_circuit_status = get_node_or_null(
			"CircuitHud/Root/CircuitStatus"
		) as Label
	if _circuit_preview == null:
		_circuit_preview = get_node_or_null(
			"CircuitHud/Root/CircuitPreview"
		) as Label
	assert(_weapon != null, "MovementLab requires Player/Weapon.")
	assert(_circuit_status != null, "MovementLab requires CircuitStatus.")
	assert(_circuit_preview != null, "MovementLab requires CircuitPreview.")
