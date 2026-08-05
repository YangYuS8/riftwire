extends CharacterBody2D
class_name PatrolEnemy

signal destroyed
signal behavior_state_changed(previous_state: int, current_state: int)

@export_range(1.0, 1000000.0, 1.0, "or_greater") var maximum_health: float = 30.0
@export_range(0.0, 2000.0, 1.0, "or_greater") var patrol_speed: float = 90.0
@export_range(0.0, 2000.0, 1.0, "or_greater") var chase_speed: float = 140.0
@export_range(1.0, 5000.0, 1.0, "or_greater") var patrol_half_width: float = 140.0
@export_range(1.0, 5000.0, 1.0, "or_greater") var engagement_range: float = 320.0
@export_range(1.0, 5000.0, 1.0, "or_greater") var disengagement_range: float = 420.0
@export_range(0.0, 2000.0, 1.0, "or_greater") var vertical_engagement_tolerance: float = 96.0
@export_range(0.0, 2000.0, 1.0, "or_greater") var vertical_disengagement_tolerance: float = 144.0
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
var _engagement_model: EnemyEngagementModel
var _target: Node2D
var _spawn_x: float = 0.0
var _facing_direction: float = 1.0
var _destroyed: bool = false


func _ready() -> void:
	_spawn_x = global_position.x
	_facing_direction = -1.0 if initial_direction < 0 else 1.0
	_patrol_model = PatrolMovementModel.new(
		_spawn_x,
		patrol_half_width,
		float(initial_direction)
	)
	_engagement_model = EnemyEngagementModel.new(
		_spawn_x,
		engagement_range,
		disengagement_range,
		vertical_engagement_tolerance,
		vertical_disengagement_tolerance
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
	_acquire_player_target()
	_update_presentation()


func _physics_process(delta: float) -> void:
	simulate_behavior(delta)


func simulate_behavior(delta: float) -> void:
	assert(delta >= 0.0, "Patrol enemy simulation delta cannot be negative.")
	if _destroyed or delta <= 0.0:
		return
	_ensure_models()
	if not _has_valid_target():
		_acquire_player_target()

	var has_target := _has_valid_target()
	var target_position := _target.global_position if has_target else Vector2.ZERO
	var previous_state := int(_engagement_model.state)
	var behavior_state := _engagement_model.update(
		global_position,
		target_position,
		has_target,
		_patrol_model.get_bounds()
	)
	if previous_state != int(behavior_state):
		behavior_state_changed.emit(previous_state, int(behavior_state))

	var desired_x := global_position.x
	match behavior_state:
		EnemyEngagementModel.State.PATROL:
			desired_x = _patrol_model.step(global_position.x, patrol_speed, delta)
		EnemyEngagementModel.State.CHASE:
			var chase_direction := _engagement_model.get_motion_direction(
				global_position.x,
				target_position.x
			)
			desired_x += chase_direction * chase_speed * delta
		EnemyEngagementModel.State.RETURN:
			var return_direction := _engagement_model.get_motion_direction(
				global_position.x,
				target_position.x
			)
			var return_distance := absf(_spawn_x - global_position.x)
			if return_distance <= chase_speed * delta:
				desired_x = _spawn_x
			else:
				desired_x += return_direction * chase_speed * delta

	velocity.x = (desired_x - global_position.x) / delta
	if absf(velocity.x) > 0.001:
		_facing_direction = -1.0 if velocity.x < 0.0 else 1.0
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
	else:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	move_and_slide()
	if behavior_state == EnemyEngagementModel.State.PATROL:
		if is_on_wall():
			_patrol_model.reverse_direction()
		global_position.x = clampf(
			global_position.x,
			_patrol_model.left_bound,
			_patrol_model.right_bound
		)
	_update_facing()


func simulate_patrol(delta: float) -> void:
	simulate_behavior(delta)


func set_target(target: Node2D) -> void:
	_target = target


func get_target() -> Node2D:
	return _target


func get_health_component() -> HealthComponent:
	return _health_component


func get_hurtbox() -> Hurtbox:
	return _hurtbox


func get_contact_damage_area() -> ContactDamageArea:
	return _contact_damage_area


func get_patrol_direction() -> float:
	_ensure_models()
	return _patrol_model.direction


func get_patrol_bounds() -> Vector2:
	_ensure_models()
	return _patrol_model.get_bounds()


func get_behavior_state() -> int:
	_ensure_models()
	return int(_engagement_model.state)


func get_behavior_state_name() -> StringName:
	_ensure_models()
	return _engagement_model.get_state_name()


func get_spawn_x() -> float:
	return _spawn_x


func _ensure_models() -> void:
	if _patrol_model == null:
		_spawn_x = global_position.x
		_patrol_model = PatrolMovementModel.new(
			_spawn_x,
			patrol_half_width,
			float(initial_direction)
		)
	if _engagement_model == null:
		_engagement_model = EnemyEngagementModel.new(
			_spawn_x,
			engagement_range,
			disengagement_range,
			vertical_engagement_tolerance,
			vertical_disengagement_tolerance
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
	if _visual == null:
		return
	_visual.scale.x = _facing_direction


func _update_health_label() -> void:
	if _health_label == null:
		return
	_health_label.text = "%d / %d HP" % [
		int(round(_health_component.current_health)),
		int(round(_health_component.maximum_health)),
	]
