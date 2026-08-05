extends GutTest

const PATROL_ENEMY_SCENE: PackedScene = preload(
	"res://game/actors/enemies/patrol_enemy/patrol_enemy.tscn"
)
const BASE_PROJECTILE_SCENE: PackedScene = preload(
	"res://game/combat/projectiles/base_projectile.tscn"
)


func test_scene_composes_existing_combat_components() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var enemy := PATROL_ENEMY_SCENE.instantiate() as PatrolEnemy
	enemy.position = Vector2(200.0, 100.0)
	fixture.add_child(enemy)
	await get_tree().process_frame

	assert_almost_eq(enemy.get_health_component().current_health, 30.0, 0.001)
	assert_eq(enemy.get_hurtbox().get_health_component(), enemy.get_health_component())
	assert_almost_eq(enemy.get_contact_damage_area().damage, 25.0, 0.001)
	assert_almost_eq(
		enemy.get_contact_damage_area().repeat_interval_seconds,
		0.75,
		0.001
	)
	assert_eq(enemy.get_patrol_bounds(), Vector2(60.0, 340.0))


func test_enemy_moves_horizontally_and_stays_inside_patrol_bounds() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var enemy := PATROL_ENEMY_SCENE.instantiate() as PatrolEnemy
	enemy.gravity = 0.0
	enemy.patrol_speed = 120.0
	enemy.patrol_half_width = 20.0
	enemy.position = Vector2(100.0, 100.0)
	fixture.add_child(enemy)
	await _wait_physics_frames(1)
	var start_x := enemy.global_position.x

	await _wait_physics_frames(5)

	assert_gt(enemy.global_position.x, start_x)
	assert_between(enemy.global_position.x, 79.999, 120.001)

	await _wait_physics_frames(20)

	assert_between(enemy.global_position.x, 79.999, 120.001)
	assert_almost_eq(enemy.get_patrol_direction(), -1.0, 0.001)


func test_three_default_projectiles_destroy_enemy_once() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var enemy := PATROL_ENEMY_SCENE.instantiate() as PatrolEnemy
	enemy.gravity = 0.0
	fixture.add_child(enemy)
	await get_tree().process_frame
	var destroyed_count := 0
	enemy.destroyed.connect(func() -> void: destroyed_count += 1)

	for _shot in range(3):
		var projectile := BASE_PROJECTILE_SCENE.instantiate() as BaseProjectile
		fixture.add_child(projectile)
		projectile.configure(Vector2.RIGHT, 0.0, 1.0, 10.0)
		projectile.resolve_hit(enemy.get_hurtbox())

	await get_tree().process_frame

	assert_eq(destroyed_count, 1)
	assert_false(is_instance_valid(enemy))


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame
