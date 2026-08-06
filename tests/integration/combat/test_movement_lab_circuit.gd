extends GutTest

const MOVEMENT_LAB_SCENE: PackedScene = preload(
	"res://game/actors/player/movement_lab.tscn"
)


func test_lab_switches_between_real_module_orders() -> void:
	var lab := MOVEMENT_LAB_SCENE.instantiate() as MovementLab
	add_child_autofree(lab)
	await get_tree().process_frame
	var weapon := lab.get_player_weapon()
	weapon.simulate_input(
		PlayerInputFrame.new(0.0, false, false, Vector2.RIGHT),
		0.0
	)

	var focused_fan := weapon.build_shot_specs()

	assert_eq(lab.get_selected_circuit(), MovementLab.CircuitOrder.SPLIT_THEN_FOCUS)
	assert_eq(focused_fan.size(), 3)
	assert_almost_eq(_fan_width_degrees(focused_fan), 12.0, 0.001)
	assert_eq(
		focused_fan[0].provenance,
		PackedStringArray(["split", "focus"])
	)
	assert_true(lab.get_circuit_status_text().contains("Split -> Focus"))

	lab.select_circuit(MovementLab.CircuitOrder.FOCUS_THEN_SPLIT)
	var wide_fan := weapon.build_shot_specs()

	assert_eq(lab.get_selected_circuit(), MovementLab.CircuitOrder.FOCUS_THEN_SPLIT)
	assert_eq(wide_fan.size(), 3)
	assert_almost_eq(_fan_width_degrees(wide_fan), 24.0, 0.001)
	assert_true(_fan_width_degrees(wide_fan) > _fan_width_degrees(focused_fan))
	assert_eq(
		wide_fan[0].provenance,
		PackedStringArray(["focus", "split"])
	)
	assert_true(lab.get_circuit_status_text().contains("Focus -> Split"))

	lab.select_circuit(
		MovementLab.CircuitOrder.SPLIT_FOCUS_THEN_VELOCITY_GRADIENT
	)
	var layered_speed_fan := weapon.build_shot_specs()

	assert_eq(
		lab.get_selected_circuit(),
		MovementLab.CircuitOrder.SPLIT_FOCUS_THEN_VELOCITY_GRADIENT
	)
	assert_eq(layered_speed_fan.size(), 3)
	assert_almost_eq(_fan_width_degrees(layered_speed_fan), 12.0, 0.001)
	assert_almost_eq(layered_speed_fan[0].speed, 540.0, 0.001)
	assert_almost_eq(layered_speed_fan[1].speed, 720.0, 0.001)
	assert_almost_eq(layered_speed_fan[2].speed, 900.0, 0.001)
	assert_eq(
		layered_speed_fan[0].provenance,
		PackedStringArray(["split", "focus", "velocity_gradient"])
	)
	assert_true(lab.get_circuit_status_text().contains("540 / 720 / 900"))

	lab.select_circuit(
		MovementLab.CircuitOrder.VELOCITY_GRADIENT_THEN_SPLIT_FOCUS
	)
	var uniform_speed_fan := weapon.build_shot_specs()

	assert_eq(
		lab.get_selected_circuit(),
		MovementLab.CircuitOrder.VELOCITY_GRADIENT_THEN_SPLIT_FOCUS
	)
	assert_eq(uniform_speed_fan.size(), 3)
	assert_almost_eq(_fan_width_degrees(uniform_speed_fan), 12.0, 0.001)
	assert_eq(
		uniform_speed_fan[0].provenance,
		PackedStringArray(["velocity_gradient", "split", "focus"])
	)
	assert_true(lab.get_circuit_status_text().contains("uniform 720"))
	for shot_index in range(uniform_speed_fan.size()):
		assert_eq(
			uniform_speed_fan[shot_index].direction,
			layered_speed_fan[shot_index].direction
		)
		assert_almost_eq(uniform_speed_fan[shot_index].speed, 720.0, 0.001)
		assert_eq(layered_speed_fan[shot_index].generation_depth, 1)
		assert_eq(uniform_speed_fan[shot_index].generation_depth, 1)

	for shot in focused_fan:
		assert_eq(shot.generation_depth, 1)
	for shot in wide_fan:
		assert_eq(shot.generation_depth, 1)


func _fan_width_degrees(shots: Array[ShotSpec]) -> float:
	assert(shots.size() >= 2)
	return absf(rad_to_deg(shots[0].direction.angle_to(shots[shots.size() - 1].direction)))
