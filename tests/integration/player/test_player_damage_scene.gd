extends GutTest

const PLAYER_SCENE: PackedScene = preload("res://game/actors/player/player.tscn")
const HAZARD_SCENE: PackedScene = preload(
	"res://game/combat/damage/contact_damage_area.tscn"
)


func test_actual_area_overlap_applies_one_contact_hit() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	var hazard := HAZARD_SCENE.instantiate() as ContactDamageArea
	player.position = Vector2(120.0, 120.0)
	hazard.position = player.position
	fixture.add_child(player)
	fixture.add_child(hazard)
	player.set_input_source(ScriptedPlayerInputSource.new())

	await _wait_physics_frames(4)

	assert_almost_eq(player.get_health_component().current_health, 75.0, 0.001)
	assert_false(player.is_defeated())


func test_lethal_contact_damage_respawns_player_at_spawn_with_full_health() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	var hazard := HAZARD_SCENE.instantiate() as ContactDamageArea
	var movement_config := PlayerMovementConfig.new()
	movement_config.gravity = 1.0
	player.movement_config = movement_config
	player.maximum_health = 20.0
	player.respawn_delay_seconds = 0.1
	player.position = Vector2(100.0, 100.0)
	hazard.position = Vector2(320.0, 100.0)
	hazard.damage = 25.0
	fixture.add_child(player)
	fixture.add_child(hazard)
	player.set_input_source(ScriptedPlayerInputSource.new())
	var respawn_positions: Array[Vector2] = []
	var respawn_velocities: Array[Vector2] = []
	player.respawned.connect(func(spawn_position: Vector2) -> void:
		respawn_positions.append(spawn_position)
		respawn_velocities.append(player.velocity)
	)

	await _wait_physics_frames(2)
	player.global_position = hazard.global_position
	await _wait_physics_frames(4)

	assert_true(player.is_defeated())
	assert_almost_eq(player.get_health_component().current_health, 0.0, 0.001)

	await _wait_physics_frames(10)

	assert_false(player.is_defeated())
	assert_eq(respawn_positions.size(), 1)
	assert_eq(respawn_velocities.size(), 1)
	assert_eq(respawn_velocities[0], Vector2.ZERO)
	assert_almost_eq(player.global_position.x, 100.0, 0.001)
	assert_almost_eq(player.global_position.y, 100.0, 1.0)
	assert_almost_eq(player.get_health_component().current_health, 20.0, 0.001)


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame
