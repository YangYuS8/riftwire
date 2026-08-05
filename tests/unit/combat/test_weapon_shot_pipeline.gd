extends GutTest


class AddDamageModule:
	extends WeaponModule

	var amount: float

	func _init(p_amount: float = 0.0) -> void:
		module_id = &"add"
		amount = p_amount

	func transform(shots: Array[ShotSpec]) -> Array[ShotSpec]:
		var output: Array[ShotSpec] = []
		for shot in shots:
			if shot != null:
				output.append(shot.with_damage(shot.damage + amount, module_id))
		return output


class MultiplyDamageModule:
	extends WeaponModule

	var multiplier: float

	func _init(p_multiplier: float = 1.0) -> void:
		module_id = &"multiply"
		multiplier = p_multiplier

	func transform(shots: Array[ShotSpec]) -> Array[ShotSpec]:
		var output: Array[ShotSpec] = []
		for shot in shots:
			if shot != null:
				output.append(shot.with_damage(shot.damage * multiplier, module_id))
		return output


func test_modules_execute_in_declared_order() -> void:
	var base_spec := ShotSpec.new(Vector2.RIGHT, 720.0, 1.5, 10.0)
	var add_then_multiply: Array[WeaponModule] = []
	add_then_multiply.append(AddDamageModule.new(5.0))
	add_then_multiply.append(MultiplyDamageModule.new(2.0))
	var multiply_then_add: Array[WeaponModule] = []
	multiply_then_add.append(MultiplyDamageModule.new(2.0))
	multiply_then_add.append(AddDamageModule.new(5.0))

	var first_result := WeaponShotPipeline.new(add_then_multiply).build(base_spec)
	var second_result := WeaponShotPipeline.new(multiply_then_add).build(base_spec)

	assert_eq(first_result.size(), 1)
	assert_eq(second_result.size(), 1)
	assert_almost_eq(first_result[0].damage, 30.0, 0.001)
	assert_almost_eq(second_result[0].damage, 25.0, 0.001)
	assert_eq(first_result[0].provenance, PackedStringArray(["add", "multiply"]))
	assert_eq(second_result[0].provenance, PackedStringArray(["multiply", "add"]))
	assert_almost_eq(base_spec.damage, 10.0, 0.001)
	assert_true(base_spec.provenance.is_empty())


func test_split_module_creates_even_fan_with_provenance() -> void:
	var split := SplitShotModule.new()
	split.projectile_count = 3
	split.spread_degrees = 30.0
	var modules: Array[WeaponModule] = []
	modules.append(split)

	var result := WeaponShotPipeline.new(modules).build(
		ShotSpec.new(Vector2.RIGHT, 720.0, 1.5, 10.0)
	)

	assert_eq(result.size(), 3)
	assert_almost_eq(result[0].direction.angle(), deg_to_rad(-15.0), 0.0001)
	assert_almost_eq(result[1].direction.angle(), 0.0, 0.0001)
	assert_almost_eq(result[2].direction.angle(), deg_to_rad(15.0), 0.0001)
	for shot in result:
		assert_eq(shot.generation_depth, 1)
		assert_eq(shot.provenance, PackedStringArray(["split"]))
		assert_almost_eq(shot.damage, 10.0, 0.001)


func test_pipeline_caps_output_at_thirty_two_specs() -> void:
	var modules: Array[WeaponModule] = []
	for _module_index in range(4):
		var split := SplitShotModule.new()
		split.projectile_count = 3
		split.spread_degrees = 12.0
		modules.append(split)

	var result := WeaponShotPipeline.new(modules).build(
		ShotSpec.new(Vector2.RIGHT, 720.0, 1.5, 10.0)
	)

	assert_eq(result.size(), WeaponShotPipeline.MAX_OUTPUT_SHOTS)
	for shot in result:
		assert_eq(shot.generation_depth, 4)
		assert_eq(shot.provenance.size(), 4)


func test_pipeline_processes_at_most_sixteen_modules() -> void:
	var modules: Array[WeaponModule] = []
	for _module_index in range(20):
		modules.append(AddDamageModule.new(1.0))
	var pipeline := WeaponShotPipeline.new(modules)

	var result := pipeline.build(ShotSpec.new(Vector2.RIGHT, 720.0, 1.5, 10.0))

	assert_eq(pipeline.get_effective_module_count(), WeaponShotPipeline.MAX_MODULES)
	assert_eq(result.size(), 1)
	assert_almost_eq(result[0].damage, 26.0, 0.001)
	assert_eq(result[0].provenance.size(), WeaponShotPipeline.MAX_MODULES)


func test_empty_module_chain_preserves_base_shot() -> void:
	var base_spec := ShotSpec.new(Vector2.UP, 500.0, 2.0, 7.5)
	var result := WeaponShotPipeline.new().build(base_spec)

	assert_eq(result.size(), 1)
	assert_eq(result[0].direction, Vector2.UP)
	assert_almost_eq(result[0].speed, 500.0, 0.001)
	assert_almost_eq(result[0].lifetime_seconds, 2.0, 0.001)
	assert_almost_eq(result[0].damage, 7.5, 0.001)
	assert_eq(result[0].generation_depth, 0)
	assert_true(result[0].provenance.is_empty())
