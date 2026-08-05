extends Node2D
class_name MovementLab

signal circuit_changed(order: int, display_name: String)

enum CircuitOrder {
	SPLIT_THEN_FOCUS,
	FOCUS_THEN_SPLIT,
}

const SPLIT_MODULE: Resource = preload(
	"res://game/content/modules/default_split_module.tres"
)
const FOCUS_MODULE: Resource = preload(
	"res://game/content/modules/default_focus_module.tres"
)
const SPLIT_THEN_FOCUS_LABEL: String = (
	"Circuit 1: Split -> Focus | 3 shots, 12-degree focused fan"
)
const FOCUS_THEN_SPLIT_LABEL: String = (
	"Circuit 2: Focus -> Split | 3 shots, 24-degree wide fan"
)

var _selected_circuit: int = CircuitOrder.SPLIT_THEN_FOCUS
var _weapon: PlayerWeapon
var _circuit_status: Label


func _ready() -> void:
	_resolve_dependencies()
	select_circuit(CircuitOrder.SPLIT_THEN_FOCUS)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var pressed_key := (
		key_event.physical_keycode
		if key_event.physical_keycode != 0
		else key_event.keycode
	)
	match pressed_key:
		KEY_1:
			select_circuit(CircuitOrder.SPLIT_THEN_FOCUS)
		KEY_2:
			select_circuit(CircuitOrder.FOCUS_THEN_SPLIT)


func select_circuit(order: int) -> void:
	_resolve_dependencies()
	match order:
		CircuitOrder.SPLIT_THEN_FOCUS:
			_apply_circuit(
				order,
				SPLIT_THEN_FOCUS_LABEL,
				SPLIT_MODULE,
				FOCUS_MODULE
			)
		CircuitOrder.FOCUS_THEN_SPLIT:
			_apply_circuit(
				order,
				FOCUS_THEN_SPLIT_LABEL,
				FOCUS_MODULE,
				SPLIT_MODULE
			)
		_:
			assert(false, "Unknown movement-lab circuit order: %s" % order)


func get_selected_circuit() -> int:
	return _selected_circuit


func get_player_weapon() -> PlayerWeapon:
	_resolve_dependencies()
	return _weapon


func get_circuit_status_text() -> String:
	_resolve_dependencies()
	return _circuit_status.text


func _apply_circuit(
	order: int,
	display_name: String,
	first_module: Resource,
	second_module: Resource
) -> void:
	var configured_modules: Array[Resource] = []
	configured_modules.append(first_module)
	configured_modules.append(second_module)
	_weapon.modules = configured_modules
	_selected_circuit = order
	_circuit_status.text = display_name
	circuit_changed.emit(order, display_name)


func _resolve_dependencies() -> void:
	if _weapon == null:
		_weapon = get_node_or_null("Player/Weapon") as PlayerWeapon
	if _circuit_status == null:
		_circuit_status = get_node_or_null("CircuitStatus") as Label
	assert(_weapon != null, "MovementLab requires Player/Weapon.")
	assert(_circuit_status != null, "MovementLab requires CircuitStatus.")
