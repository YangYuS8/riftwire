extends Node
class_name HealthComponent

signal health_changed(previous_health: float, current_health: float, maximum_health: float)
signal damage_applied(applied_damage: float, remaining_health: float)
signal health_restored(restored_amount: float, current_health: float)
signal depleted

@export_range(0.001, 1000000.0, 0.001, "or_greater") var maximum_health: float = 30.0

var current_health: float = 0.0
var _depletion_emitted: bool = false


func _ready() -> void:
	reset_to_maximum()


func configure(p_maximum_health: float, refill: bool = true) -> void:
	maximum_health = maxf(0.001, p_maximum_health)
	if refill:
		reset_to_maximum()
	else:
		set_current_health(current_health)


func reset_to_maximum() -> void:
	var previous_health := current_health
	current_health = maximum_health
	_depletion_emitted = false
	if not is_equal_approx(previous_health, current_health):
		health_changed.emit(previous_health, current_health, maximum_health)


func set_current_health(value: float) -> void:
	var previous_health := current_health
	current_health = clampf(value, 0.0, maximum_health)
	_depletion_emitted = current_health <= 0.0
	if not is_equal_approx(previous_health, current_health):
		health_changed.emit(previous_health, current_health, maximum_health)


func apply_damage(requested_damage: float) -> float:
	assert(requested_damage >= 0.0, "Damage cannot be negative.")
	if requested_damage <= 0.0 or current_health <= 0.0:
		return 0.0

	var previous_health := current_health
	var applied_damage := minf(requested_damage, current_health)
	current_health = maxf(0.0, current_health - applied_damage)
	damage_applied.emit(applied_damage, current_health)
	health_changed.emit(previous_health, current_health, maximum_health)

	if current_health <= 0.0 and not _depletion_emitted:
		_depletion_emitted = true
		depleted.emit()
	return applied_damage


func restore_health(requested_amount: float) -> float:
	assert(requested_amount >= 0.0, "Restored health cannot be negative.")
	if requested_amount <= 0.0 or current_health >= maximum_health:
		return 0.0

	var previous_health := current_health
	var restored_amount := minf(requested_amount, maximum_health - current_health)
	current_health = minf(maximum_health, current_health + restored_amount)
	_depletion_emitted = current_health <= 0.0
	health_restored.emit(restored_amount, current_health)
	health_changed.emit(previous_health, current_health, maximum_health)
	return restored_amount


func is_depleted() -> bool:
	return current_health <= 0.0
