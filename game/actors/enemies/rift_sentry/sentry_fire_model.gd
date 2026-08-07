extends RefCounted
class_name SentryFireModel

var fire_interval_seconds: float = 1.4
var initial_delay_seconds: float = 0.7
var _cooldown_remaining_seconds: float = 0.7


func _init(
	p_fire_interval_seconds: float = 1.4,
	p_initial_delay_seconds: float = 0.7
) -> void:
	configure(p_fire_interval_seconds, p_initial_delay_seconds)


func configure(
	p_fire_interval_seconds: float,
	p_initial_delay_seconds: float
) -> void:
	assert(p_fire_interval_seconds > 0.0, "Sentry fire interval must be positive.")
	assert(p_initial_delay_seconds >= 0.0, "Sentry initial fire delay cannot be negative.")
	fire_interval_seconds = maxf(0.001, p_fire_interval_seconds)
	initial_delay_seconds = maxf(0.0, p_initial_delay_seconds)
	reset()


func advance(delta: float, target_active: bool) -> bool:
	assert(delta >= 0.0, "Sentry fire simulation delta cannot be negative.")
	if not target_active:
		reset()
		return false
	if delta <= 0.0:
		return false

	_cooldown_remaining_seconds -= delta
	if _cooldown_remaining_seconds > 0.0:
		return false

	_cooldown_remaining_seconds += fire_interval_seconds
	if _cooldown_remaining_seconds <= 0.0:
		_cooldown_remaining_seconds = fire_interval_seconds
	return true


func reset() -> void:
	_cooldown_remaining_seconds = initial_delay_seconds


func get_remaining_seconds() -> float:
	return maxf(0.0, _cooldown_remaining_seconds)
