extends StaticBody2D
class_name RiftSentry

signal destroyed
signal projectile_fired(projectile: BaseProjectile)

@export_range(1.0, 1000000.0, 1.0, "or_greater") var maximum_health: float = 40.0
@export_range(1.0, 5000.0, 1.0, "or_greater") var engagement_range: float = 760.0
@export_range(0.05, 30.0, 0.01, "or_greater") var fire_interval_seconds: float = 1.4
@export_range(0.0, 30.0, 0.01, "or_greater") var initial_fire_delay_seconds: float = 0.7
@export_range(0.0, 5000.0, 1.0, "or_greater") var projectile_speed: float = 420.0
@export_range(0.0, 30.0, 0.01, "or_greater") var projectile_lifetime_seconds: float = 2.5
@export_range(0.0, 1000000.0, 0.1, "or_greater") var projectile_damage: float = 18.0
@export var projectile_scene: PackedScene = preload(
	"res://game/combat/projectiles/enemy_projectile.tscn"
)

@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _barrel: Node2D = $Barrel
@onready var _muzzle: Marker2D = $Barrel/Muzzle
@onready var _health_label: Label = $HealthLabel

var _fire_model: SentryFireModel
var _target: Node2D
var _destroyed: bool = false


func _ready() -> void:
	_health_component.configure(maximum_health)
	_hurtbox.set_health_component(_health_component)
	_health_component.health_changed.connect(_on_health_changed)
	_health_component.depleted.connect(_on_depleted)
	_fire_model = SentryFireModel.new(
		fire_interval_seconds,
		initial_fire_delay_seconds
	)
	_acquire_player_target()
	_update_health_label()
	_update_aim()


func _physics_process(delta: float) -> void:
	simulate_behavior(delta)


func simulate_behavior(delta: float) -> void:
	assert(delta >= 0.0, "Rift sentry simulation delta cannot be negative.")
	if _destroyed:
		return
	_ensure_fire_model()
	if not _has_valid_target():
		_acquire_player_target()

	var target_active := _is_target_in_range()
	if target_active:
		_update_aim()
	if _fire_model.advance(delta, target_active):
		fire_once()


func fire_once() -> BaseProjectile:
	if _destroyed or projectile_scene == null or not _is_target_in_range():
		return null
	var direction := _target.global_position - _muzzle.global_position
	if direction.length_squared() <= 0.000001:
		return null

	var projectile := projectile_scene.instantiate() as BaseProjectile
	if projectile == null:
		return null
	var projectile_parent := get_parent()
	if projectile_parent == null:
		projectile.free()
		return null

	projectile_parent.add_child(projectile)
	projectile.global_position = _muzzle.global_position
	projectile.rotation = direction.angle()
	projectile.configure(
		direction,
		projectile_speed,
		projectile_lifetime_seconds,
		projectile_damage
	)
	projectile_fired.emit(projectile)
	return projectile


func set_target(target: Node2D) -> void:
	_target = target
	_ensure_fire_model()
	_fire_model.reset()
	_update_aim()


func get_target() -> Node2D:
	return _target


func get_health_component() -> HealthComponent:
	return _health_component


func get_hurtbox() -> Hurtbox:
	return _hurtbox


func get_fire_model() -> SentryFireModel:
	_ensure_fire_model()
	return _fire_model


func is_destroyed() -> bool:
	return _destroyed


func _ensure_fire_model() -> void:
	if _fire_model == null:
		_fire_model = SentryFireModel.new(
			fire_interval_seconds,
			initial_fire_delay_seconds
		)


func _acquire_player_target() -> void:
	if not is_inside_tree():
		return
	var candidate := get_tree().get_first_node_in_group("player")
	if candidate is Node2D:
		_target = candidate as Node2D


func _has_valid_target() -> bool:
	if _target == null or not is_instance_valid(_target) or not _target.is_inside_tree():
		return false
	if _target is RiftwirePlayer and (_target as RiftwirePlayer).is_defeated():
		return false
	return true


func _is_target_in_range() -> bool:
	if not _has_valid_target():
		return false
	return global_position.distance_to(_target.global_position) <= engagement_range


func _update_aim() -> void:
	if _barrel == null or _muzzle == null or not _has_valid_target():
		return
	var direction := _target.global_position - global_position
	if direction.length_squared() <= 0.000001:
		return
	_barrel.rotation = direction.angle()


func _on_health_changed(
	_previous_health: float,
	_current_health: float,
	_maximum_health: float
) -> void:
	_update_health_label()


func _on_depleted() -> void:
	if _destroyed:
		return
	_destroyed = true
	set_physics_process(false)
	_hurtbox.set_deferred("monitorable", false)
	destroyed.emit()
	queue_free()


func _update_health_label() -> void:
	if _health_label == null:
		return
	_health_label.text = "%d / %d HP" % [
		int(round(_health_component.current_health)),
		int(round(_health_component.maximum_health)),
	]
