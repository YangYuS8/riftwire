extends RefCounted
class_name PlayerInputFrame

var move_axis: float
var jump_pressed: bool
var jump_held: bool


func _init(
	p_move_axis: float = 0.0,
	p_jump_pressed: bool = false,
	p_jump_held: bool = false
) -> void:
	move_axis = clampf(p_move_axis, -1.0, 1.0)
	jump_pressed = p_jump_pressed
	jump_held = p_jump_held


func copy() -> PlayerInputFrame:
	return PlayerInputFrame.new(move_axis, jump_pressed, jump_held)


static func neutral() -> PlayerInputFrame:
	return PlayerInputFrame.new()
