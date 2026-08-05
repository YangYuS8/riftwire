extends GutTest

const PLAYER_SCENE: PackedScene = preload("res://game/actors/player/player.tscn")
const TICK_FRAMES_TO_SETTLE: int = 45


func test_scripted_horizontal_input_moves_player_repeatably() -> void:
	var fixture := _create_fixture()
	var player: RiftwirePlayer = fixture.get_node("Player")
	await _wait_physics_frames(TICK_FRAMES_TO_SETTLE)
	var start_position := player.position

	var frames: Array[PlayerInputFrame] = []
	for _frame in range(60):
		frames.append(PlayerInputFrame.new(1.0))
	player.set_input_source(ScriptedPlayerInputSource.new(frames))
	await _wait_physics_frames(60)

	assert_true(player.position.x > start_position.x + 150.0)
	assert_true(absf(player.position.y - start_position.y) < 1.0)


func test_scripted_jump_reaches_apex_and_returns_to_floor() -> void:
	var fixture := _create_fixture()
	var player: RiftwirePlayer = fixture.get_node("Player")
	await _wait_physics_frames(TICK_FRAMES_TO_SETTLE)
	var floor_position_y := player.position.y

	var frames: Array[PlayerInputFrame] = [PlayerInputFrame.new(0.0, true, true)]
	for _frame in range(11):
		frames.append(PlayerInputFrame.new(0.0, false, true))
	for _frame in range(90):
		frames.append(PlayerInputFrame.neutral())
	player.set_input_source(ScriptedPlayerInputSource.new(frames))

	var apex_y := floor_position_y
	for _frame in range(frames.size()):
		await get_tree().physics_frame
		apex_y = minf(apex_y, player.position.y)

	assert_true(apex_y < floor_position_y - 70.0)
	assert_true(absf(player.position.y - floor_position_y) < 1.0)
	assert_true(player.is_on_floor())


func _create_fixture() -> Node2D:
	var fixture := Node2D.new()
	fixture.name = "MovementFixture"
	add_child_autofree(fixture)

	var floor := StaticBody2D.new()
	floor.position = Vector2(320.0, 500.0)
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(640.0, 40.0)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)
	fixture.add_child(floor)

	var player: RiftwirePlayer = PLAYER_SCENE.instantiate()
	player.name = "Player"
	player.position = Vector2(100.0, 300.0)
	fixture.add_child(player)
	return fixture


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame
