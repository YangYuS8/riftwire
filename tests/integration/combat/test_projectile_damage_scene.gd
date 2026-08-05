extends GutTest

const PROJECTILE_SCENE: PackedScene = preload(
	"res://game/combat/projectiles/base_projectile.tscn"
)
const TARGET_DUMMY_SCENE: PackedScene = preload(
	"res://game/actors/enemies/target_dummy/target_dummy.tscn"
)


func test_resolve_hit_applies_damage_only_once() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var target := TARGET_DUMMY_SCENE.instantiate() as TargetDummy
	fixture.add_child(target)
	var projectile := PROJECTILE_SCENE.instantiate() as BaseProjectile
	fixture.add_child(projectile)
	projectile.configure(Vector2.RIGHT, 0.0, 1.0, 10.0)

	var first_damage := projectile.resolve_hit(target.get_hurtbox())
	var second_damage := projectile.resolve_hit(target.get_hurtbox())

	assert_almost_eq(first_damage, 10.0, 0.001)
	assert_almost_eq(second_damage, 0.0, 0.001)
	assert_almost_eq(target.get_health_component().current_health, 20.0, 0.001)
	assert_true(projectile.has_resolved_hit())


func test_physics_collision_applies_damage_and_cleans_up_projectile() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var target := TARGET_DUMMY_SCENE.instantiate() as TargetDummy
	target.position = Vector2(100.0, 0.0)
	fixture.add_child(target)
	var projectile := PROJECTILE_SCENE.instantiate() as BaseProjectile
	fixture.add_child(projectile)
	projectile.position = Vector2.ZERO
	projectile.configure(Vector2.RIGHT, 300.0, 1.0, 10.0)

	await _wait_physics_frames(30)

	assert_almost_eq(target.get_health_component().current_health, 20.0, 0.001)
	assert_false(is_instance_valid(projectile))


func test_target_dummy_is_removed_after_lethal_damage() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var target := TARGET_DUMMY_SCENE.instantiate() as TargetDummy
	fixture.add_child(target)

	target.get_hurtbox().receive_damage(30.0)
	await get_tree().process_frame

	assert_false(is_instance_valid(target))


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame
