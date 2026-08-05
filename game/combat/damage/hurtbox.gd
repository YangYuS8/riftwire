extends Area2D
class_name Hurtbox

signal damage_received(requested_damage: float, applied_damage: float, remaining_health: float)

var _health_component: HealthComponent


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

	var applied_damage := _health_component.apply_damage(requested_damage)
	if applied_damage > 0.0:
		damage_received.emit(
			requested_damage,
			applied_damage,
			_health_component.current_health
		)
	return applied_damage
