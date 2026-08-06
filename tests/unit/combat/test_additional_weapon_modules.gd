extends GutTest


func test_lifetime_gradient_assigns_ordered_lifetimes_without_generating_shots() -> void:
	var lifetime_gradient := LifetimeGradientShotModule.new()
	lifetime_gradient.minimum_multiplier = 0.6
	lifetime_gradient.maximum_multiplier = 1.4
	var shots: Array[ShotSpec] = [
		ShotSpec.new(Vector2.RIGHT.rotated(deg_to_rad(-6.0)), 720.0, 1.5, 10.0),
		ShotSpec.new(Vector2.RIGHT, 720.0, 1.5, 10.0),
		ShotSpec.new(Vector2.RIGHT.rotated(deg_to_rad(6.0)), 720.0, 1.5, 10.0),
	]

	var result := lifetime_gradient.transform(shots)

	assert_eq(result.size(), 3)
	assert_almost_eq(result[0].lifetime_seconds, 0.9, 0.001)
	assert_almost_eq(result[1].lifetime_seconds, 1.5, 0.001)
	assert_almost_eq(result[2].lifetime_seconds, 2.1, 0.001)
	for shot_index in range(result.size()):
		assert_eq(result[shot_index].direction, shots[shot_index].direction)
		assert_almost_eq(result[shot_index].speed, 720.0, 0.001)
		assert_eq(result[shot_index].generation_depth, 0)
		assert_eq(
			result[shot_index].provenance,
			PackedStringArray(["lifetime_gradient"])
		)
		assert_almost_eq(shots[shot_index].lifetime_seconds, 1.5, 0.001)


func test_lifetime_gradient_before_split_preserves_uniform_base_lifetime() -> void:
	var split := SplitShotModule.new()
	split.projectile_count = 3
	split.spread_degrees = 24.0
	var lifetime_gradient := LifetimeGradientShotModule.new()
	lifetime_gradient.minimum_multiplier = 0.6
	lifetime_gradient.maximum_multiplier = 1.4
	var layered_chain: Array[WeaponModule] = [split, lifetime_gradient]
	var uniform_chain: Array[WeaponModule] = [lifetime_gradient, split]
	var base_spec := ShotSpec.new(Vector2.RIGHT, 720.0, 1.5, 10.0)

	var layered_shots := WeaponShotPipeline.new(layered_chain).build(base_spec)
	var uniform_shots := WeaponShotPipeline.new(uniform_chain).build(base_spec)

	assert_eq(layered_shots.size(), 3)
	assert_eq(uniform_shots.size(), 3)
	assert_almost_eq(layered_shots[0].lifetime_seconds, 0.9, 0.001)
	assert_almost_eq(layered_shots[1].lifetime_seconds, 1.5, 0.001)
	assert_almost_eq(layered_shots[2].lifetime_seconds, 2.1, 0.001)
	for shot_index in range(uniform_shots.size()):
		assert_eq(layered_shots[shot_index].direction, uniform_shots[shot_index].direction)
		assert_almost_eq(uniform_shots[shot_index].lifetime_seconds, 1.5, 0.001)
	assert_eq(
		layered_shots[0].provenance,
		PackedStringArray(["split", "lifetime_gradient"])
	)
	assert_eq(
		uniform_shots[0].provenance,
		PackedStringArray(["lifetime_gradient", "split"])
	)


func test_reverse_order_changes_downstream_velocity_mapping() -> void:
	var split := SplitShotModule.new()
	split.projectile_count = 3
	split.spread_degrees = 24.0
	var reverse_order := ReverseShotOrderModule.new()
	var velocity_gradient := VelocityGradientShotModule.new()
	velocity_gradient.minimum_multiplier = 0.75
	velocity_gradient.maximum_multiplier = 1.25
	var reverse_then_gradient: Array[WeaponModule] = [
		split,
		reverse_order,
		velocity_gradient,
	]
	var gradient_then_reverse: Array[WeaponModule] = [
		split,
		velocity_gradient,
		reverse_order,
	]
	var base_spec := ShotSpec.new(Vector2.RIGHT, 720.0, 1.5, 10.0)

	var first_result := WeaponShotPipeline.new(reverse_then_gradient).build(base_spec)
	var second_result := WeaponShotPipeline.new(gradient_then_reverse).build(base_spec)

	assert_eq(first_result.size(), 3)
	assert_eq(second_result.size(), 3)
	for shot_index in range(first_result.size()):
		assert_eq(first_result[shot_index].direction, second_result[shot_index].direction)
	assert_almost_eq(first_result[0].direction.angle(), deg_to_rad(12.0), 0.0001)
	assert_almost_eq(first_result[0].speed, 540.0, 0.001)
	assert_almost_eq(second_result[0].speed, 900.0, 0.001)
	assert_almost_eq(first_result[2].direction.angle(), deg_to_rad(-12.0), 0.0001)
	assert_almost_eq(first_result[2].speed, 900.0, 0.001)
	assert_almost_eq(second_result[2].speed, 540.0, 0.001)
	assert_eq(
		first_result[0].provenance,
		PackedStringArray(["split", "reverse_order", "velocity_gradient"])
	)
	assert_eq(
		second_result[0].provenance,
		PackedStringArray(["split", "velocity_gradient", "reverse_order"])
	)
