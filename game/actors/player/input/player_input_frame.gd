extends RefCounted
class_name PlayerInputFrame

var move_axis: float
var jump_pressed: bool
var jump_held: bool
var aim_direction: Vector2
var fire_pressed: bool
var fire_held: bool


func _init(
	p_move_axis: float = 0.0,
	p_jump_pressed: bool = false,
	p_jump_held: bool = false,
	p_aim_direction: Vector2 = Vector2.RIGHT,
	p_fire_pressed: bool = false,
	p_fire_held: bool = false
) -> void:
	move_axis = clampf(p_move_axis, -1.0, 1.0)
	jump_pressed = p_jump_pressed
	jump_held = p_jump_held
	aim_direction = _normalized_aim(p_aim_direction)
	fire_pressed = p_fire_pressed
	fire_held = p_fire_held


func copy() -> PlayerInputFrame:
	return PlayerInputFrame.new(
		move_axis,
		jump_pressed,
		jump_held,
		aim_direction,
		fire_pressed,
		fire_held
	)


static func neutral() -> PlayerInputFrame:
	return PlayerInputFrame.new()


static func _normalized_aim(direction: Vector2) -> Vector2:
	if direction.length_squared() <= 0.000001:
		return Vector2.RIGHT
	return direction.normalized()
