extends StaticBody2D
class_name EncounterGate

signal lock_state_changed(locked: bool)

@export var starts_locked: bool = true
@export var locked_color: Color = Color(0.92, 0.18, 0.34, 0.9)
@export var unlocked_color: Color = Color(0.18, 0.82, 0.72, 0.18)

@onready var _visual: Polygon2D = get_node_or_null("Visual") as Polygon2D
@onready var _status_label: Label = get_node_or_null("StatusLabel") as Label

var _locked: bool = true
var _blocking_collision_layer: int = 1


func _ready() -> void:
	_blocking_collision_layer = collision_layer
	if _blocking_collision_layer == 0:
		_blocking_collision_layer = 1
	set_locked(starts_locked, false)


func set_locked(value: bool, emit_change: bool = true) -> void:
	var changed := _locked != value
	_locked = value
	collision_layer = _blocking_collision_layer if _locked else 0
	if _visual != null:
		_visual.color = locked_color if _locked else unlocked_color
	if _status_label != null:
		_status_label.text = "LOCKED" if _locked else "CLEAR"
	if changed and emit_change:
		lock_state_changed.emit(_locked)


func is_locked() -> bool:
	return _locked


func get_visual_color() -> Color:
	return _visual.color if _visual != null else Color.TRANSPARENT
