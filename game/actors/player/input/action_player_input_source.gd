extends PlayerInputSource
class_name ActionPlayerInputSource

const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_JUMP: StringName = &"jump"
const ACTION_AIM_LEFT: StringName = &"aim_left"
const ACTION_AIM_RIGHT: StringName = &"aim_right"
const ACTION_AIM_UP: StringName = &"aim_up"
const ACTION_AIM_DOWN: StringName = &"aim_down"
const ACTION_FIRE: StringName = &"fire"
const AIM_STICK_THRESHOLD_SQUARED: float = 0.04

var _pointer_direction_provider: Callable


func _init(pointer_direction_provider: Callable = Callable()) -> void:
	_pointer_direction_provider = pointer_direction_provider
	_ensure_default_actions()


func sample() -> PlayerInputFrame:
	var aim_direction := Input.get_vector(
		ACTION_AIM_LEFT,
		ACTION_AIM_RIGHT,
		ACTION_AIM_UP,
		ACTION_AIM_DOWN
	)
	if aim_direction.length_squared() < AIM_STICK_THRESHOLD_SQUARED:
		aim_direction = _sample_pointer_direction()

	return PlayerInputFrame.new(
		Input.get_axis(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT),
		Input.is_action_just_pressed(ACTION_JUMP),
		Input.is_action_pressed(ACTION_JUMP),
		aim_direction,
		Input.is_action_just_pressed(ACTION_FIRE),
		Input.is_action_pressed(ACTION_FIRE)
	)


func _sample_pointer_direction() -> Vector2:
	if not _pointer_direction_provider.is_valid():
		return Vector2.RIGHT
	var sampled_direction: Variant = _pointer_direction_provider.call()
	if sampled_direction is Vector2:
		return sampled_direction
	return Vector2.RIGHT


static func _ensure_default_actions() -> void:
	_ensure_action(ACTION_MOVE_LEFT)
	_add_physical_key(ACTION_MOVE_LEFT, KEY_A)
	_add_physical_key(ACTION_MOVE_LEFT, KEY_LEFT)
	_add_joy_motion(ACTION_MOVE_LEFT, JOY_AXIS_LEFT_X, -1.0)

	_ensure_action(ACTION_MOVE_RIGHT)
	_add_physical_key(ACTION_MOVE_RIGHT, KEY_D)
	_add_physical_key(ACTION_MOVE_RIGHT, KEY_RIGHT)
	_add_joy_motion(ACTION_MOVE_RIGHT, JOY_AXIS_LEFT_X, 1.0)

	_ensure_action(ACTION_JUMP)
	_add_physical_key(ACTION_JUMP, KEY_SPACE)
	_add_joy_button(ACTION_JUMP, JOY_BUTTON_A)

	_ensure_action(ACTION_AIM_LEFT)
	_add_joy_motion(ACTION_AIM_LEFT, JOY_AXIS_RIGHT_X, -1.0)
	_ensure_action(ACTION_AIM_RIGHT)
	_add_joy_motion(ACTION_AIM_RIGHT, JOY_AXIS_RIGHT_X, 1.0)
	_ensure_action(ACTION_AIM_UP)
	_add_joy_motion(ACTION_AIM_UP, JOY_AXIS_RIGHT_Y, -1.0)
	_ensure_action(ACTION_AIM_DOWN)
	_add_joy_motion(ACTION_AIM_DOWN, JOY_AXIS_RIGHT_Y, 1.0)

	_ensure_action(ACTION_FIRE)
	_add_mouse_button(ACTION_FIRE, MOUSE_BUTTON_LEFT)
	_add_joy_button(ACTION_FIRE, JOY_BUTTON_RIGHT_SHOULDER)


static func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)
	else:
		InputMap.action_set_deadzone(action, 0.2)


static func _add_physical_key(action: StringName, physical_key: int) -> void:
	for existing_event in InputMap.action_get_events(action):
		if existing_event is InputEventKey and existing_event.physical_keycode == physical_key:
			return
	var event := InputEventKey.new()
	event.physical_keycode = physical_key
	InputMap.action_add_event(action, event)


static func _add_joy_motion(action: StringName, axis: int, axis_value: float) -> void:
	for existing_event in InputMap.action_get_events(action):
		if (
			existing_event is InputEventJoypadMotion
			and existing_event.axis == axis
			and is_equal_approx(existing_event.axis_value, axis_value)
		):
			return
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	InputMap.action_add_event(action, event)


static func _add_joy_button(action: StringName, button_index: int) -> void:
	for existing_event in InputMap.action_get_events(action):
		if existing_event is InputEventJoypadButton and existing_event.button_index == button_index:
			return
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action, event)


static func _add_mouse_button(action: StringName, button_index: int) -> void:
	for existing_event in InputMap.action_get_events(action):
		if existing_event is InputEventMouseButton and existing_event.button_index == button_index:
			return
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action, event)
