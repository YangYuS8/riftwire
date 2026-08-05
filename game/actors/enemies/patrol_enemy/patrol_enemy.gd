extends CharacterBody2D
class_name PatrolEnemy

signal destroyed

@export_range(1.0, 1000000.0, 1.0, "or_greater") var maximum_health: float = 30.0
@export_range(0.0, 2000.0, 1.0, "or_greater") var patrol_speed: float = 90.0
@export_range(1.0, 5000.0, 1.0, "or_greater") var patrol_half_width: float = 140.0
@export_range(0.0, 6000.0, 1.0, "or_greater") var gravity: float = 1800.0
@export_range(1.0, 3000.0, 1.0, "or_greater") var max_fall_speed: float = 1100.0
@export_range(0.0, 1000000.0, 0.1, "or_greater") var contact_damage: float = 25.0
@export_range(0.016, 30.0, 0.001, "or_greater") var contact_repeat_interval_seconds: float = 0.75
@export_enum("Left:-1", "Right:1") var initial_direction: int = 1

@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _contact_damage_area: ContactDamageArea = $ContactDamageArea
@onready var _visual: Polygon2D = $Visual
@onready var _health_label: Label = $HealthLabel

var _patrol_model: PatrolMovementModel
var _spawn_x: float = 0.0
var _destroyed: bool = false


func _ready() -> void:
	_spawn_x = global_position.x
	_patrol_model = PatrolMovementModel.new(
		_spawn_x,
		patrol_half_width,
		float(initial_direction)
	)
	_health_component.configure(maximum_health)
	_hurtbox.set_health_component(_health_component)
	_contact_damage_area.damage = maxf(0.0, contact_damage)
	_contact_damage_area.repeat_interval_seconds = maxf(
		0.001,
		contact_repeat_interval_seconds
	)
	_health_component.health_changed.connect(_on_health_changed)
	_health_component.depleted.connect(_on_depleted)
	_update_presentation()


func _physics_process(delta: float) -> void:
	simulate_patrol(delta)


func simulate_patrol(delta: float) -> void:
	assert(delta >= 0.0, "Patrol enemy simulation delta cannot be negative.")
	if _destroyed or delta <= 0.0:
		return
	_ensure_patrol_model()

	var desired_x := _patrol_model.step(global_position.x, patrol_speed, delta)
	velocity.x = (desired_x - global_position.x) / delta
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
	else:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	move_and_slide()
	if is_on_wall():
		_patrol_model.reverse_direction()
	global_position.x = clampf(
		global_position.x,
		_patrol_model.left_bound,
		_patrol_model.right_bound
	)
	_update_facing()


func get_health_component() -> HealthComponent:
	return _health_component


func get_hurtbox() -> Hurtbox:
	return _hurtbox


func get_contact_damage_area() -> ContactDamageArea:
	return _contact_damage_area


func get_patrol_direction() -> float:
	_ensure_patrol_model()
	return _patrol_model.direction


func get_patrol_bounds() -> Vector2:
	_ensure_patrol_model()
	return _patrol_model.get_bounds()


func get_spawn_x() -> float:
	return _spawn_x


func _ensure_patrol_model() -> void:
	if _patrol_model == null:
		_spawn_x = global_position.x
		_patrol_model = PatrolMovementModel.new(
			_spawn_x,
			patrol_half_width,
			float(initial_direction)
		)


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
	velocity = Vector2.ZERO
	set_physics_process(false)
	_contact_damage_area.deactivate()
	_hurtbox.set_deferred("monitorable", false)
	destroyed.emit()
	queue_free()


func _update_presentation() -> void:
	_update_facing()
	_update_health_label()


func _update_facing() -> void:
	if _visual == null or _patrol_model == null:
		return
	_visual.scale.x = _patrol_model.direction


func _update_health_label() -> void:
	if _health_label == null:
		return
	_health_label.text = "%d / %d HP" % [
		int(round(_health_component.current_health)),
		int(round(_health_component.maximum_health)),
	]