extends CharacterBody2D
class_name RiftwirePlayer

const DEFAULT_MOVEMENT_CONFIG: PlayerMovementConfig = preload(
	"res://game/actors/player/default_player_movement_config.tres"
)

@export var movement_config: PlayerMovementConfig

var _input_source: PlayerInputSource
var _movement_model: PlayerMovementModel
var _weapon: PlayerWeapon


func _ready() -> void:
	_ensure_dependencies()


func _physics_process(delta: float) -> void:
	_ensure_dependencies()
	simulate_input(_input_source.sample(), delta)


func set_input_source(input_source: PlayerInputSource) -> void:
	assert(input_source != null, "Player input source cannot be null.")
	_input_source = input_source


func get_movement_model() -> PlayerMovementModel:
	_ensure_dependencies()
	return _movement_model


func get_weapon() -> PlayerWeapon:
	_ensure_dependencies()
	assert(_weapon != null, "Player scene must provide a PlayerWeapon child named Weapon.")
	return _weapon


func simulate_input(input_frame: PlayerInputFrame, delta: float) -> void:
	_ensure_dependencies()
	_movement_model.velocity = velocity
	velocity = _movement_model.step(input_frame, delta, is_on_floor())
	move_and_slide()
	_movement_model.reconcile_after_move(is_on_floor(), velocity)
	velocity = _movement_model.velocity
	if _weapon != null:
		_weapon.simulate_input(input_frame, delta)


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
