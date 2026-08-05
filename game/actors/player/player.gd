extends CharacterBody2D
class_name RiftwirePlayer

signal defeated
signal respawned(spawn_position: Vector2)

const DEFAULT_MOVEMENT_CONFIG: PlayerMovementConfig = preload(
	"res://game/actors/player/default_player_movement_config.tres"
)

@export var movement_config: PlayerMovementConfig
@export_range(1.0, 1000000.0, 1.0, "or_greater") var maximum_health: float = 100.0
@export_range(0.0, 5.0, 0.01, "or_greater") var respawn_delay_seconds: float = 0.5

var _input_source: PlayerInputSource
var _movement_model: PlayerMovementModel
var _weapon: PlayerWeapon
var _health_component: HealthComponent
var _hurtbox: Hurtbox
var _health_label: Label
var _spawn_global_position: Vector2
var _respawn_remaining_seconds: float = 0.0
var _is_defeated: bool = false
var _active_collision_layer: int = 0
var _active_collision_mask: int = 0


func _ready() -> void:
	_ensure_dependencies()
	_spawn_global_position = global_position
	_active_collision_layer = collision_layer
	_active_collision_mask = collision_mask
	_configure_health()


func _physics_process(delta: float) -> void:
	_ensure_dependencies()
	if _is_defeated:
		simulate_respawn(delta)
		return
	simulate_input(_input_source.sample(), delta)


func set_input_source(input_source: PlayerInputSource) -> void:
	assert(input_source != null, "Player input source cannot be null.")
	_input_source = input_source


func set_spawn_position(spawn_position: Vector2) -> void:
	_spawn_global_position = spawn_position


func get_movement_model() -> PlayerMovementModel:
	_ensure_dependencies()
	return _movement_model


func get_weapon() -> PlayerWeapon:
	_ensure_dependencies()
	assert(_weapon != null, "Player scene must provide a PlayerWeapon child named Weapon.")
	return _weapon


func get_health_component() -> HealthComponent:
	_ensure_dependencies()
	assert(_health_component != null, "Player scene must provide a HealthComponent child.")
	return _health_component


func get_hurtbox() -> Hurtbox:
	_ensure_dependencies()
	assert(_hurtbox != null, "Player scene must provide a Hurtbox child.")
	return _hurtbox


func is_defeated() -> bool:
	return _is_defeated


func get_respawn_remaining_seconds() -> float:
	return _respawn_remaining_seconds


func simulate_input(input_frame: PlayerInputFrame, delta: float) -> void:
	if _is_defeated:
		return
	_ensure_dependencies()
	_movement_model.velocity = velocity
	velocity = _movement_model.step(input_frame, delta, is_on_floor())
	move_and_slide()
	_movement_model.reconcile_after_move(is_on_floor(), velocity)
	velocity = _movement_model.velocity
	if _weapon != null:
		_weapon.simulate_input(input_frame, delta)


func simulate_respawn(delta: float) -> void:
	assert(delta >= 0.0, "Respawn simulation delta cannot be negative.")
	if not _is_defeated:
		return
	_respawn_remaining_seconds = maxf(0.0, _respawn_remaining_seconds - delta)
	if _respawn_remaining_seconds <= 0.0:
		_finish_respawn()


func _sample_pointer_direction() -> Vector2:
	return get_global_mouse_position() - global_position


func _ensure_dependencies() -> void:
	if movement_config == null:
		movement_config = DEFAULT_MOVEMENT_CONFIG
	if _input_source == null:
		_input_source = ActionPlayerInputSource.new(Callable(self, "_sample_pointer_direction"))
	if _movement_model == null:
		_movement_model = PlayerMovementModel.new(movement_config)
	if _weapon == null:
		_weapon = get_node_or_null("Weapon") as PlayerWeapon
	if _health_component == null:
		_health_component = get_node_or_null("HealthComponent") as HealthComponent
	if _hurtbox == null:
		_hurtbox = get_node_or_null("Hurtbox") as Hurtbox
	if _health_label == null:
		_health_label = get_node_or_null("HealthLabel") as Label


func _configure_health() -> void:
	assert(_health_component != null, "Player requires a HealthComponent child.")
	assert(_hurtbox != null, "Player requires a Hurtbox child.")
	_hurtbox.set_health_component(_health_component)
	if not _health_component.health_changed.is_connected(_on_health_changed):
		_health_component.health_changed.connect(_on_health_changed)
	if not _health_component.depleted.is_connected(_on_health_depleted):
		_health_component.depleted.connect(_on_health_depleted)
	_health_component.configure(maximum_health)
	_update_health_label()


func _on_health_changed(
	_previous_health: float,
	_current_health: float,
	_maximum_health: float
) -> void:
	_update_health_label()


func _on_health_depleted() -> void:
	if _is_defeated:
		return
	_is_defeated = true
	_respawn_remaining_seconds = maxf(0.0, respawn_delay_seconds)
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	visible = false
	defeated.emit()
	if _respawn_remaining_seconds <= 0.0:
		_finish_respawn()


func _finish_respawn() -> void:
	global_position = _spawn_global_position
	velocity = Vector2.ZERO
	_movement_model.velocity = Vector2.ZERO
	_health_component.reset_to_maximum()
	collision_layer = _active_collision_layer
	collision_mask = _active_collision_mask
	visible = true
	_is_defeated = false
	_respawn_remaining_seconds = 0.0
	respawned.emit(_spawn_global_position)


func _update_health_label() -> void:
	if _health_label == null or _health_component == null:
		return
	_health_label.text = "%d / %d HP" % [
		int(round(_health_component.current_health)),
		int(round(_health_component.maximum_health)),
	]
