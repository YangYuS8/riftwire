extends GutTest


func test_no_target_remains_in_patrol() -> void:
	var model := EnemyEngagementModel.new(0.0, 320.0, 420.0, 96.0, 144.0)

	var state := model.update(
		Vector2.ZERO,
		Vector2(100.0, 0.0),
		false,
		Vector2(-140.0, 140.0)
	)

	assert_eq(state, EnemyEngagementModel.State.PATROL)
	assert_eq(model.get_state_name(), &"PATROL")


func test_horizontal_hysteresis_prevents_boundary_flicker() -> void:
	var model := EnemyEngagementModel.new(0.0, 320.0, 420.0, 96.0, 144.0)
	var bounds := Vector2(-140.0, 140.0)

	assert_eq(
		model.update(Vector2.ZERO, Vector2(300.0, 0.0), true, bounds),
		EnemyEngagementModel.State.CHASE
	)
	assert_eq(
		model.update(Vector2.ZERO, Vector2(380.0, 0.0), true, bounds),
		EnemyEngagementModel.State.CHASE
	)
	assert_eq(
		model.update(Vector2.ZERO, Vector2(421.0, 0.0), true, bounds),
		EnemyEngagementModel.State.RETURN
	)


func test_vertical_hysteresis_ignores_unreachable_targets() -> void:
	var model := EnemyEngagementModel.new(0.0, 320.0, 420.0, 96.0, 144.0)
	var bounds := Vector2(-140.0, 140.0)

	assert_eq(
		model.update(Vector2.ZERO, Vector2(100.0, 100.0), true, bounds),
		EnemyEngagementModel.State.PATROL
	)
	assert_eq(
		model.update(Vector2.ZERO, Vector2(100.0, 80.0), true, bounds),
		EnemyEngagementModel.State.CHASE
	)
	assert_eq(
		model.update(Vector2.ZERO, Vector2(100.0, 130.0), true, bounds),
		EnemyEngagementModel.State.CHASE
	)
	assert_eq(
		model.update(Vector2.ZERO, Vector2(100.0, 145.0), true, bounds),
		EnemyEngagementModel.State.RETURN
	)


func test_return_state_resumes_patrol_inside_authored_bounds() -> void:
	var model := EnemyEngagementModel.new(0.0, 320.0, 420.0, 96.0, 144.0)
	var bounds := Vector2(-140.0, 140.0)
	model.update(Vector2.ZERO, Vector2(100.0, 0.0), true, bounds)
	model.update(Vector2(500.0, 0.0), Vector2(1000.0, 0.0), false, bounds)

	var state := model.update(
		Vector2(140.0, 0.0),
		Vector2(1000.0, 0.0),
		false,
		bounds
	)

	assert_eq(state, EnemyEngagementModel.State.PATROL)


func test_motion_direction_tracks_target_or_spawn_by_state() -> void:
	var model := EnemyEngagementModel.new(0.0, 320.0, 420.0, 96.0, 144.0)
	var bounds := Vector2(-140.0, 140.0)
	model.update(Vector2.ZERO, Vector2(100.0, 0.0), true, bounds)
	assert_almost_eq(model.get_motion_direction(0.0, -100.0), -1.0, 0.001)

	model.update(Vector2(500.0, 0.0), Vector2(1000.0, 0.0), false, bounds)
	assert_almost_eq(model.get_motion_direction(500.0, 1000.0), -1.0, 0.001)
