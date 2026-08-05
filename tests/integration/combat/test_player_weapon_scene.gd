extends GutTest

const PLAYER_SCENE: PackedScene = preload("res://game/actors/player/player.tscn")


func test_scripted_held_fire_spawns_repeatable_split_projectile_count() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	fixture.add_child(player)

	var frames: Array[PlayerInputFrame] = []
	for _frame in range(30):
		frames.append(
			PlayerInputFrame.new(
				0.0,
				false,
				false,
				Vector2.RIGHT,
				false,
				true
			)
		)
	player.set_input_source(ScriptedPlayerInputSource.new(frames))

	await _wait_physics_frames(30)

	var projectiles := _projectiles_in(fixture)
	assert_eq(projectiles.size(), 12)
	var upward_count := 0
	var straight_count := 0
	var downward_count := 0
	for projectile in projectiles:
		assert_true(projectile.global_position.x > player.global_position.x)
		if projectile.travel_direction.y < -0.001:
			upward_count += 1
		elif projectile.travel_direction.y > 0.001:
			downward_count += 1
		else:
			straight_count += 1
	assert_eq(upward_count, 4)
	assert_eq(straight_count, 4)
	assert_eq(downward_count, 4)


func test_scripted_aim_rotates_weapon_without_physical_input() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	fixture.add_child(player)
	player.set_input_source(
		ScriptedPlayerInputSource.new(
			[PlayerInputFrame.new(0.0, false, false, Vector2.UP)]
		)
	)

	await _wait_physics_frames(2)

	assert_eq(player.get_weapon().get_aim_direction(), Vector2.UP)
	assert_almost_eq(player.get_weapon().rotation, -PI / 2.0, 0.001)


func test_weapon_scene_exposes_split_specs_before_spawning() -> void:
	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	add_child_autofree(player)
	await get_tree().process_frame
	player.get_weapon().simulate_input(
		PlayerInputFrame.new(0.0, false, false, Vector2.RIGHT),
		0.0
	)

	var specs := player.get_weapon().build_shot_specs()

	assert_eq(specs.size(), 3)
	assert_true(specs[0].direction.y < 0.0)
	assert_almost_eq(specs[1].direction.angle(), 0.0, 0.0001)
	assert_true(specs[2].direction.y > 0.0)
	for spec in specs:
		assert_eq(spec.generation_depth, 1)
		assert_eq(spec.provenance, PackedStringArray(["split"]))


func _projectiles_in(parent: Node) -> Array[BaseProjectile]:
	var projectiles: Array[BaseProjectile] = []
	for child in parent.get_children():
		if child is BaseProjectile:
			projectiles.append(child)
	return projectiles


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame
