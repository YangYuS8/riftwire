extends RefCounted
class_name ShotSpec

var direction: Vector2:
	get:
		return _direction

var speed: float:
	get:
		return _speed

var lifetime_seconds: float:
	get:
		return _lifetime_seconds

var damage: float:
	get:
		return _damage

var generation_depth: int:
	get:
		return _generation_depth

var provenance: PackedStringArray:
	get:
		return _provenance.duplicate()

var _direction: Vector2
var _speed: float
var _lifetime_seconds: float
var _damage: float
var _generation_depth: int
var _provenance: PackedStringArray


func _init(
	p_direction: Vector2 = Vector2.RIGHT,
	p_speed: float = 0.0,
	p_lifetime_seconds: float = 0.0,
	p_damage: float = 0.0,
	p_generation_depth: int = 0,
	p_provenance: PackedStringArray = PackedStringArray()
) -> void:
	_direction = (
		p_direction.normalized()
		if p_direction.length_squared() > 0.000001
		else Vector2.RIGHT
	)
	_speed = maxf(0.0, p_speed)
	_lifetime_seconds = maxf(0.0, p_lifetime_seconds)
	_damage = maxf(0.0, p_damage)
	_generation_depth = maxi(0, p_generation_depth)
	_provenance = p_provenance.duplicate()


func duplicate_spec() -> ShotSpec:
	return ShotSpec.new(
		_direction,
		_speed,
		_lifetime_seconds,
		_damage,
		_generation_depth,
		_provenance
	)


func with_damage(p_damage: float, module_id: StringName = &"") -> ShotSpec:
	return ShotSpec.new(
		_direction,
		_speed,
		_lifetime_seconds,
		p_damage,
		_generation_depth,
		_provenance_with(module_id)
	)


func descended(p_direction: Vector2, module_id: StringName) -> ShotSpec:
	return ShotSpec.new(
		p_direction,
		_speed,
		_lifetime_seconds,
		_damage,
		_generation_depth + 1,
		_provenance_with(module_id)
	)


func _provenance_with(module_id: StringName) -> PackedStringArray:
	var next_provenance := _provenance.duplicate()
	var module_name := String(module_id)
	if not module_name.is_empty():
		next_provenance.append(module_name)
	return next_provenance
