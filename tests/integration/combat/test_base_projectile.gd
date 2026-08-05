extends GutTest

const PROJECTILE_SCENE: PackedScene = preload(
	"res://game/combat/projectiles/base_projectile.tscn"
)


func test_projectile_moves_in_configured_direction() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var projectile := PROJECTILE_SCENE.instantiate() as BaseProjectile
	fixture.add_child(projectile)
	projectile.configure(Vector2.RIGHT, 120.0, 1.0)
	var start_x := projectile.position.x

	await _wait_physics_frames(3)

	assert_almost_eq(projectile.position.x, start_x + 6.0, 1.0)
	assert_almost_eq(projectile.position.y, 0.0, 0.1)


func test_projectile_expires_after_configured_lifetime() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var projectile := PROJECTILE_SCENE.instantiate() as BaseProjectile
	fixture.add_child(projectile)
	projectile.configure(Vector2.RIGHT, 120.0, 0.05)

	await _wait_physics_frames(5)

	assert_false(is_instance_valid(projectile))


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame
