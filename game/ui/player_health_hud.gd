extends CanvasLayer
class_name PlayerHealthHud

@export var player_path: NodePath

var _bound_player: RiftwirePlayer
var _health_component: HealthComponent

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_value: Label = %HealthValue


func _ready() -> void:
	if not player_path.is_empty():
		var player := get_node_or_null(player_path) as RiftwirePlayer
		assert(player != null, "PlayerHealthHud player_path must resolve to RiftwirePlayer.")
		bind_player(player)
	elif _health_component != null:
		_refresh_from_health()


func _exit_tree() -> void:
	_disconnect_health_component()


func bind_player(player: RiftwirePlayer) -> void:
	assert(player != null, "PlayerHealthHud cannot bind a null player.")
	_bound_player = player
	bind_health_component(player.get_health_component())


func bind_health_component(health_component: HealthComponent) -> void:
	assert(health_component != null, "PlayerHealthHud cannot bind a null HealthComponent.")
	if _health_component == health_component:
		_refresh_from_health()
		return
	_disconnect_health_component()
	_health_component = health_component
	if not _health_component.health_changed.is_connected(_on_health_changed):
		_health_component.health_changed.connect(_on_health_changed)
	_refresh_from_health()


func get_bound_player() -> RiftwirePlayer:
	return _bound_player


func get_bound_health_component() -> HealthComponent:
	return _health_component


func get_displayed_current_health() -> float:
	return _health_bar.value


func get_displayed_maximum_health() -> float:
	return _health_bar.max_value


func get_health_text() -> String:
	return _health_value.text


func _disconnect_health_component() -> void:
	if _health_component == null:
		return
	if _health_component.health_changed.is_connected(_on_health_changed):
		_health_component.health_changed.disconnect(_on_health_changed)
	_health_component = null


func _on_health_changed(
	_previous_health: float,
	current_health: float,
	maximum_health: float
) -> void:
	_refresh_values(current_health, maximum_health)


func _refresh_from_health() -> void:
	if _health_component == null:
		return
	_refresh_values(_health_component.current_health, _health_component.maximum_health)


func _refresh_values(current_health: float, maximum_health: float) -> void:
	var safe_maximum := maxf(0.001, maximum_health)
	var safe_current := clampf(current_health, 0.0, safe_maximum)
	_health_bar.min_value = 0.0
	_health_bar.max_value = safe_maximum
	_health_bar.value = safe_current
	_health_value.text = "HP %d / %d" % [
		int(round(safe_current)),
		int(round(safe_maximum)),
	]
