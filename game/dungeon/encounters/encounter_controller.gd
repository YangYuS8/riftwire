extends Node
class_name EncounterController

signal encounter_started(remaining_enemies: int)
signal remaining_enemies_changed(remaining_enemies: int)
signal encounter_completed

@export var enemy_container_path: NodePath
@export var gate_paths: Array[NodePath] = []
@export var status_label_path: NodePath

var _initialized: bool = false
var _completed: bool = false
var _tracked_enemy_ids: Dictionary = {}
var _gates: Array[Node] = []
var _status_label: Label


func _ready() -> void:
	call_deferred("initialize_encounter")


func initialize_encounter() -> void:
	if _initialized:
		return
	_initialized = true
	_resolve_dependencies()
	_set_gates_locked(true)

	var enemy_container := get_node_or_null(enemy_container_path)
	assert(enemy_container != null, "EncounterController requires an enemy container.")
	for child in enemy_container.get_children():
		_track_enemy(child)

	_refresh_status()
	encounter_started.emit(_tracked_enemy_ids.size())
	remaining_enemies_changed.emit(_tracked_enemy_ids.size())
	if _tracked_enemy_ids.is_empty():
		_complete_encounter()


func get_remaining_enemy_count() -> int:
	return _tracked_enemy_ids.size()


func is_completed() -> bool:
	return _completed


func is_initialized() -> bool:
	return _initialized


func _track_enemy(enemy: Node) -> void:
	if enemy == null or not enemy.has_signal("destroyed"):
		return
	var enemy_id := enemy.get_instance_id()
	if _tracked_enemy_ids.has(enemy_id):
		return
	_tracked_enemy_ids[enemy_id] = true
	enemy.connect(
		"destroyed",
		Callable(self, "_on_enemy_destroyed").bind(enemy_id),
		CONNECT_ONE_SHOT
	)


func _on_enemy_destroyed(enemy_id: int) -> void:
	if not _tracked_enemy_ids.erase(enemy_id):
		return
	remaining_enemies_changed.emit(_tracked_enemy_ids.size())
	_refresh_status()
	if _tracked_enemy_ids.is_empty():
		_complete_encounter()


func _complete_encounter() -> void:
	if _completed:
		return
	_completed = true
	_set_gates_locked(false)
	_refresh_status()
	encounter_completed.emit()


func _resolve_dependencies() -> void:
	_gates.clear()
	for gate_path in gate_paths:
		var gate := get_node_or_null(gate_path)
		assert(gate != null, "EncounterController gate path must resolve.")
		assert(gate.has_method("set_locked"), "Encounter gates require set_locked().")
		_gates.append(gate)
	if not status_label_path.is_empty():
		_status_label = get_node_or_null(status_label_path) as Label
		assert(_status_label != null, "Encounter status label path must resolve.")


func _set_gates_locked(locked: bool) -> void:
	for gate in _gates:
		gate.call("set_locked", locked)


func _refresh_status() -> void:
	if _status_label == null:
		return
	if _completed:
		_status_label.text = "ROOM CLEAR — exits unlocked"
	else:
		_status_label.text = "HOSTILES: %d — exits locked" % _tracked_enemy_ids.size()
