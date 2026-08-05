extends RefCounted
class_name PatrolMovementModel

var left_bound: float = -140.0
var right_bound: float = 140.0
var direction: float = 1.0


func _init(
	center_x: float = 0.0,
	half_width: float = 140.0,
	initial_direction: float = 1.0
) -> void:
	configure(center_x, half_width, initial_direction)


func configure(center_x: float, half_width: float, initial_direction: float = 1.0) -> void:
	assert(half_width > 0.0, "Patrol half-width must be greater than zero.")
	left_bound = center_x - maxf(0.001, half_width)
	right_bound = center_x + maxf(0.001, half_width)
	direction = -1.0 if initial_direction < 0.0 else 1.0


func step(current_x: float, speed: float, delta: float) -> float:
	assert(speed >= 0.0, "Patrol speed cannot be negative.")
	assert(delta >= 0.0, "Patrol simulation delta cannot be negative.")
	var next_x := clampf(current_x, left_bound, right_bound)
	if speed <= 0.0 or delta <= 0.0:
		return next_x

	next_x += direction * speed * delta
	var reflection_count := 0
	while (next_x < left_bound or next_x > right_bound) and reflection_count < 128:
		if next_x > right_bound:
			next_x = right_bound - (next_x - right_bound)
			direction = -1.0
		elif next_x < left_bound:
			next_x = left_bound + (left_bound - next_x)
			direction = 1.0
		reflection_count += 1

	return clampf(next_x, left_bound, right_bound)


func reverse_direction() -> void:
	direction *= -1.0


func get_bounds() -> Vector2:
	return Vector2(left_bound, right_bound)
