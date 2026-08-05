extends RefCounted
class_name EnemyEngagementModel

enum State {
	PATROL,
	CHASE,
	RETURN,
}

var state: State = State.PATROL
var spawn_x: float = 0.0
var engagement_range: float = 320.0
var disengagement_range: float = 420.0
var vertical_engagement_tolerance: float = 96.0
var vertical_disengagement_tolerance: float = 144.0


func _init(
	p_spawn_x: float = 0.0,
	p_engagement_range: float = 320.0,
	p_disengagement_range: float = 420.0,
	p_vertical_engagement_tolerance: float = 96.0,
	p_vertical_disengagement_tolerance: float = 144.0
) -> void:
	configure(
		p_spawn_x,
		p_engagement_range,
		p_disengagement_range,
		p_vertical_engagement_tolerance,
		p_vertical_disengagement_tolerance
	)


func configure(
	p_spawn_x: float,
	p_engagement_range: float,
	p_disengagement_range: float,
	p_vertical_engagement_tolerance: float,
	p_vertical_disengagement_tolerance: float
) -> void:
	assert(p_engagement_range > 0.0, "Engagement range must be greater than zero.")
	assert(
		p_disengagement_range >= p_engagement_range,
		"Disengagement range must be at least the engagement range."
	)
	assert(
		p_vertical_engagement_tolerance >= 0.0,
		"Vertical engagement tolerance cannot be negative."
	)
	assert(
		p_vertical_disengagement_tolerance >= p_vertical_engagement_tolerance,
		"Vertical disengagement tolerance must be at least the engagement tolerance."
	)
	spawn_x = p_spawn_x
	engagement_range = p_engagement_range
	disengagement_range = p_disengagement_range
	vertical_engagement_tolerance = p_vertical_engagement_tolerance
	vertical_disengagement_tolerance = p_vertical_disengagement_tolerance
	state = State.PATROL


func update(
	current_position: Vector2,
	target_position: Vector2,
	has_target: bool,
	patrol_bounds: Vector2
) -> State:
	assert(patrol_bounds.x <= patrol_bounds.y, "Patrol bounds must be ordered.")
	var horizontal_distance := absf(target_position.x - current_position.x)
	var vertical_distance := absf(target_position.y - current_position.y)
	var can_engage := (
		has_target
		and horizontal_distance <= engagement_range
		and vertical_distance <= vertical_engagement_tolerance
	)
	var should_disengage := (
		not has_target
		or horizontal_distance > disengagement_range
		or vertical_distance > vertical_disengagement_tolerance
	)

	match state:
		State.PATROL:
			if can_engage:
				state = State.CHASE
		State.CHASE:
			if should_disengage:
				state = State.RETURN
		State.RETURN:
			if can_engage:
				state = State.CHASE
			elif current_position.x >= patrol_bounds.x and current_position.x <= patrol_bounds.y:
				state = State.PATROL

	return state


func get_motion_direction(current_x: float, target_x: float) -> float:
	match state:
		State.CHASE:
			return _direction_toward(current_x, target_x)
		State.RETURN:
			return _direction_toward(current_x, spawn_x)
		_:
			return 0.0


func get_state_name() -> StringName:
	match state:
		State.CHASE:
			return &"CHASE"
		State.RETURN:
			return &"RETURN"
		_:
			return &"PATROL"


func _direction_toward(current_x: float, destination_x: float) -> float:
	if is_equal_approx(current_x, destination_x):
		return 0.0
	return -1.0 if destination_x < current_x else 1.0
