extends Area2D
class_name BaseProjectile

signal projectile_hit(hurtbox: Hurtbox, applied_damage: float)

var travel_direction: Vector2 = Vector2.RIGHT
var speed: float = 720.0
var lifetime_remaining: float = 1.5
var damage: float = 10.0
var _hit_resolved: bool = false


func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func configure(
	direction: Vector2,
	p_speed: float,
	lifetime_seconds: float,
	p_damage: float = 10.0
) -> void:
	travel_direction = direction.normalized() if direction.length_squared() > 0.000001 else Vector2.RIGHT
	speed = maxf(0.0, p_speed)
	lifetime_remaining = maxf(0.0, lifetime_seconds)
	damage = maxf(0.0, p_damage)
	_hit_resolved = false


func _physics_process(delta: float) -> void:
	simulate(delta)


func simulate(delta: float) -> void:
	assert(delta >= 0.0, "Projectile simulation delta cannot be negative.")
	if _hit_resolved:
		return
	global_position += travel_direction * speed * delta
	lifetime_remaining -= delta
	if lifetime_remaining <= 0.0:
		queue_free()


func resolve_hit(hurtbox: Hurtbox) -> float:
	if _hit_resolved or hurtbox == null:
		return 0.0
	_hit_resolved = true
	var applied_damage := hurtbox.receive_damage(damage)
	projectile_hit.emit(hurtbox, applied_damage)
	queue_free()
	return applied_damage


func has_resolved_hit() -> bool:
	return _hit_resolved


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		resolve_hit(area as Hurtbox)
