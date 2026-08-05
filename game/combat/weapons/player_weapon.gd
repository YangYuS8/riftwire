extends Node2D
class_name PlayerWeapon

signal projectile_fired(projectile: BaseProjectile)

const DEFAULT_CONFIG: BaseWeaponConfig = preload(
	"res://game/combat/weapons/default_base_weapon_config.tres"
)
const DEFAULT_PROJECTILE_SCENE: PackedScene = preload(
	"res://game/combat/projectiles/base_projectile.tscn"
)

@export var config: BaseWeaponConfig
@export var projectile_scene: PackedScene

var _fire_model: WeaponFireModel
var _aim_direction: Vector2 = Vector2.RIGHT
var _muzzle: Marker2D


func _ready() -> void:
	_ensure_dependencies()


func simulate_input(input_frame: PlayerInputFrame, delta: float) -> void:
	_ensure_dependencies()
	_aim_direction = input_frame.aim_direction
	rotation = _aim_direction.angle()
	if _fire_model.step(input_frame.fire_pressed or input_frame.fire_held, delta):
		_spawn_projectile()


func get_aim_direction() -> Vector2:
	return _aim_direction


func get_fire_model() -> WeaponFireModel:
	_ensure_dependencies()
	return _fire_model


func _spawn_projectile() -> void:
	var projectile := projectile_scene.instantiate() as BaseProjectile
	assert(projectile != null, "Configured projectile scene must instantiate BaseProjectile.")
	projectile.configure(
		_aim_direction,
		config.projectile_speed,
		config.projectile_lifetime_seconds,
		config.projectile_damage
	)

	var player := get_parent()
	var spawn_parent := player.get_parent() if player != null else null
	assert(spawn_parent != null, "PlayerWeapon requires a parent scene for projectile spawning.")
	spawn_parent.add_child(projectile)
	projectile.global_position = _muzzle.global_position if _muzzle != null else global_position
	projectile_fired.emit(projectile)


func _ensure_dependencies() -> void:
	if config == null:
		config = DEFAULT_CONFIG
	if projectile_scene == null:
		projectile_scene = DEFAULT_PROJECTILE_SCENE
	if _fire_model == null:
		_fire_model = WeaponFireModel.new(config)
	if _muzzle == null:
		_muzzle = get_node_or_null("Muzzle") as Marker2D
