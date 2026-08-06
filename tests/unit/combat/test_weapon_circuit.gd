extends GutTest


func test_selection_and_adjacent_moves_follow_the_selected_module() -> void:
	var circuit := WeaponCircuit.new(_five_modules())

	assert_eq(
		circuit.get_module_ids(),
		PackedStringArray([
			"split",
			"focus",
			"reverse_order",
			"velocity_gradient",
			"lifetime_gradient",
		])
	)
	assert_eq(circuit.get_selected_slot(), 0)
	assert_true(circuit.select_slot(2))
	assert_true(circuit.move_selected(1))
	assert_eq(circuit.get_selected_slot(), 3)
	assert_eq(
		circuit.get_module_ids(),
		PackedStringArray([
			"split",
			"focus",
			"velocity_gradient",
			"reverse_order",
			"lifetime_gradient",
		])
	)
	assert_true(circuit.move_selected(-1))
	assert_eq(circuit.get_selected_slot(), 2)
	assert_eq(circuit.get_module_ids()[2], "reverse_order")


func test_invalid_selection_and_edge_moves_are_no_ops() -> void:
	var circuit := WeaponCircuit.new(_five_modules())

	assert_false(circuit.select_slot(-1))
	assert_false(circuit.select_slot(5))
	assert_false(circuit.move_selected(-1))
	assert_eq(circuit.get_selected_slot(), 0)
	assert_eq(circuit.get_module_ids()[0], "split")

	assert_true(circuit.select_slot(4))
	assert_false(circuit.move_selected(1))
	assert_eq(circuit.get_selected_slot(), 4)
	assert_eq(circuit.get_module_ids()[4], "lifetime_gradient")


func test_exported_module_arrays_do_not_mutate_the_circuit() -> void:
	var circuit := WeaponCircuit.new(_five_modules())
	var modules_copy := circuit.get_modules()
	var resources_copy := circuit.get_modules_as_resources()

	modules_copy.clear()
	resources_copy.clear()

	assert_eq(circuit.get_module_ids().size(), 5)
	assert_eq(circuit.get_module_ids()[0], "split")
	assert_eq(circuit.get_module_ids()[4], "lifetime_gradient")


func _five_modules() -> Array[WeaponModule]:
	var modules: Array[WeaponModule] = []
	modules.append(SplitShotModule.new())
	modules.append(FocusShotModule.new())
	modules.append(ReverseShotOrderModule.new())
	modules.append(VelocityGradientShotModule.new())
	modules.append(LifetimeGradientShotModule.new())
	return modules
