extends PlayerInputSource
class_name ActionPlayerInputSource

const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_JUMP: StringName = &"jump"


func _init() -> void:
	_ensure_default_actions()


func sample() -> PlayerInputFrame:
	return PlayerInputFrame.new(
		Input.get_axis(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT),
		Input.is_action_just_pressed(ACTION_JUMP),
		Input.is_action_pressed(ACTION_JUMP)
	)


static func _ensure_default_actions() -> void:
	_ensure_action(ACTION_MOVE_LEFT, [KEY_A, KEY_LEFT])
	_ensure_action(ACTION_MOVE_RIGHT, [KEY_D, KEY_RIGHT])
	_ensure_action(ACTION_JUMP, [KEY_SPACE])


static func _ensure_action(action: StringName, physical_keys: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for physical_key in physical_keys:
		if _has_physical_key(action, physical_key):
			continue
		var event := InputEventKey.new()
		event.physical_keycode = physical_key
		InputMap.action_add_event(action, event)


static func _has_physical_key(action: StringName, physical_key: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == physical_key:
			return true
	return false
