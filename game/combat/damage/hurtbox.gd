extends Area2D
class_name Hurtbox

signal damage_received(requested_damage: float, applied_damage: float, remaining_health: float)
signal damage_blocked(requested_damage: float, invulnerability_remaining_seconds: float)
signal invulnerability_started(duration_seconds: float)
signal invulnerability_ended

var _health_component: HealthComponent
var _recovery_model := DamageRecoveryModel.new()


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	simulate_invulnerability(delta)


func set_health_component(health_component: HealthComponent) -> void:
	assert(health_component != null, "Hurtbox health component cannot be null.")
	_health_component = health_component


func get_health_component() -> HealthComponent:
	return _health_component


func receive_damage(requested_damage: float) -> float:
	assert(requested_damage >= 0.0, "Hurtbox damage cannot be negative.")
	assert(_health_component != null, "Hurtbox must be configured with a HealthComponent.")
	if _health_component == null:
		return 0.0
	if is_invulnerable():
		damage_blocked.emit(requested_damage, get_invulnerability_remaining_seconds())
		return 0.0

	var applied_damage := _health_component.apply_damage(requested_damage)
	if applied_damage > 0.0:
		damage_received.emit(
			requested_damage,
			applied_damage,
			_health_component.current_health
		)
	return applied_damage


func start_invulnerability(duration_seconds: float) -> void:
	assert(duration_seconds >= 0.0, "Hurtbox invulnerability duration cannot be negative.")
	if duration_seconds <= 0.0:
		clear_invulnerability()
		return
	_recovery_model.start(duration_seconds)
	set_physics_process(true)
	invulnerability_started.emit(duration_seconds)


func simulate_invulnerability(delta: float) -> void:
	if not _recovery_model.is_active():
		set_physics_process(false)
		return
	if _recovery_model.step(delta):
		set_physics_process(false)
		invulnerability_ended.emit()


func clear_invulnerability() -> void:
	var was_active := _recovery_model.is_active()
	_recovery_model.clear()
	set_physics_process(false)
	if was_active:
		invulnerability_ended.emit()


func is_invulnerable() -> bool:
	return _recovery_model.is_active()


func get_invulnerability_remaining_seconds() -> float:
	return _recovery_model.get_remaining_seconds()
