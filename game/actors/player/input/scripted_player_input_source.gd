extends PlayerInputSource
class_name ScriptedPlayerInputSource

var _frames: Array[PlayerInputFrame] = []
var _cursor: int = 0


func _init(frames: Array[PlayerInputFrame] = []) -> void:
	set_frames(frames)


func set_frames(frames: Array[PlayerInputFrame]) -> void:
	_frames.clear()
	for frame in frames:
		_frames.append(frame.copy())
	_cursor = 0


func sample() -> PlayerInputFrame:
	if _cursor >= _frames.size():
		return PlayerInputFrame.neutral()
	var frame := _frames[_cursor].copy()
	_cursor += 1
	return frame


func rewind() -> void:
	_cursor = 0


func remaining_frames() -> int:
	return maxi(0, _frames.size() - _cursor)
