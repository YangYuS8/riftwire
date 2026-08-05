extends RefCounted
class_name DamageRecoveryModel

const EXPIRY_EPSILON_SECONDS: float = 0.000001

var _remaining_seconds: float = 0.0


func start(duration_seconds: float) -> void:
	assert(duration_seconds >= 0.0, "Damage recovery duration cannot be negative.")
	_remaining_seconds = maxf(0.0, duration_seconds)


func step(delta: float) -> bool:
	assert(delta >= 0.0, "Damage recovery simulation delta cannot be negative.")
	var was_active := is_active()
	_remaining_seconds = maxf(0.0, _remaining_seconds - delta)
	if _remaining_seconds <= EXPIRY_EPSILON_SECONDS:
		_remaining_seconds = 0.0
	return was_active and not is_active()


func clear() -> void:
	_remaining_seconds = 0.0


func is_active() -> bool:
	return _remaining_seconds > 0.0


func get_remaining_seconds() -> float:
	return _remaining_seconds
