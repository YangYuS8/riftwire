extends Area2D
class_name BaseProjectile

var travel_direction: Vector2 = Vector2.RIGHT
var speed: float = 720.0
var lifetime_remaining: float = 1.5


func configure(direction: Vector2, p_speed: float, lifetime_seconds: float) -> void:
	travel_direction = direction.normalized() if direction.length_squared() > 0.000001 else Vector2.RIGHT
	speed = maxf(0.0, p_speed)
	lifetime_remaining = maxf(0.0, lifetime_seconds)


func _physics_process(delta: float) -> void:
	global_position += travel_direction * speed * delta
	lifetime_remaining -= delta
	if lifetime_remaining <= 0.0:
		queue_free()
