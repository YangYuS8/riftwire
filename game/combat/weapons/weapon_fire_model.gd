extends RefCounted
class_name WeaponFireModel

var config: BaseWeaponConfig
var cooldown_remaining: float = 0.0


func _init(p_config: BaseWeaponConfig = null) -> void:
	config = p_config if p_config != null else BaseWeaponConfig.new()
	assert(config.is_configuration_valid(), "Weapon fire model requires a valid configuration.")


func step(fire_requested: bool, delta: float) -> bool:
	assert(delta >= 0.0, "Weapon simulation delta cannot be negative.")
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	if not fire_requested:
		return false
	if cooldown_remaining > 0.000001:
		return false
	cooldown_remaining = config.fire_interval_seconds
	return true


func reset() -> void:
	cooldown_remaining = 0.0
