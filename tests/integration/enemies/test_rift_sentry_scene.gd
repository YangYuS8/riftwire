extends GutTest

const SENTRY_SCENE: PackedScene = preload(
	"res://game/actors/enemies/rift_sentry/rift_sentry.tscn"
)
const PLAYER_SCENE: PackedScene = preload(
	"res://game/actors/player/player.tscn"
)


func test_scene_composes_existing_health_and_hurtbox_contracts() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var sentry := SENTRY_SCENE.instantiate() as RiftSentry
	world.add_child(sentry)
	sentry.set_physics_process(false)

	assert_almost_eq(sentry.get_health_component().maximum_health, 40.0, 0.001)
	assert_eq(
		sentry.get_hurtbox().get_health_component(),
		sentry.get_health_component()
	)
	assert_false(sentry.is_destroyed())


func test_fire_once_spawns_player_hurtbox_projectile_and_applies_damage() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	player.position = Vector2(100, 100)
	world.add_child(player)
	player.set_physics_process(false)
	var sentry := SENTRY_SCENE.instantiate() as RiftSentry
	sentry.position = Vector2(300, 100)
	world.add_child(sentry)
	sentry.set_physics_process(false)
	sentry.set_target(player)

	var projectile := sentry.fire_once()
	assert_not_null(projectile)
	assert_eq(projectile.collision_mask, 4)
	assert_eq(projectile.travel_direction, Vector2.LEFT)
	assert_almost_eq(projectile.speed, 420.0, 0.001)
	assert_almost_eq(projectile.lifetime_remaining, 2.5, 0.001)
	assert_almost_eq(projectile.damage, 18.0, 0.001)

	var applied_damage := projectile.resolve_hit(player.get_hurtbox())
	assert_almost_eq(applied_damage, 18.0, 0.001)
	assert_almost_eq(player.get_health_component().current_health, 82.0, 0.001)


func test_sentry_does_not_fire_without_a_valid_in_range_target() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var sentry := SENTRY_SCENE.instantiate() as RiftSentry
	world.add_child(sentry)
	sentry.set_physics_process(false)
	var fired_projectiles: Array[BaseProjectile] = []
	sentry.projectile_fired.connect(
		func(projectile: BaseProjectile) -> void:
			fired_projectiles.append(projectile)
	)

	sentry.simulate_behavior(5.0)
	assert_eq(fired_projectiles.size(), 0)

	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	player.position = Vector2(2000, 0)
	world.add_child(player)
	player.set_physics_process(false)
	sentry.set_target(player)
	sentry.simulate_behavior(5.0)
	assert_eq(fired_projectiles.size(), 0)


func test_lethal_damage_emits_destroyed_once_and_queues_sentry_for_removal() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var sentry := SENTRY_SCENE.instantiate() as RiftSentry
	world.add_child(sentry)
	sentry.set_physics_process(false)
	var destroyed_events: Array[bool] = []
	sentry.destroyed.connect(
		func() -> void:
			destroyed_events.append(true)
	)

	sentry.get_health_component().apply_damage(1000.0)
	sentry.get_health_component().apply_damage(1000.0)
	assert_true(sentry.is_destroyed())
	assert_true(sentry.is_queued_for_deletion())
	assert_eq(destroyed_events.size(), 1)
