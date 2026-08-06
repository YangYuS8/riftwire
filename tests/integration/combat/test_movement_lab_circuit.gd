extends GutTest

const MOVEMENT_LAB_SCENE: PackedScene = preload(
	"res://game/actors/player/movement_lab.tscn"
)


func test_lab_reorders_the_live_five_slot_weapon_circuit() -> void:
	var lab := MOVEMENT_LAB_SCENE.instantiate() as MovementLab
	add_child_autofree(lab)
	await get_tree().process_frame
	var weapon := lab.get_player_weapon()
	weapon.simulate_input(
		PlayerInputFrame.new(0.0, false, false, Vector2.RIGHT),
		0.0
	)

	assert_eq(
		lab.get_module_ids(),
		PackedStringArray([
			"split",
			"focus",
			"reverse_order",
			"velocity_gradient",
			"lifetime_gradient",
		])
	)
	assert_eq(weapon.get_module_ids(), lab.get_module_ids())
	assert_eq(lab.get_selected_slot(), 0)
	assert_true(lab.get_circuit_status_text().contains("[Split]"))

	var default_shots := weapon.build_shot_specs()
	assert_eq(default_shots.size(), 3)
	assert_almost_eq(_fan_width_degrees(default_shots), 12.0, 0.001)
	assert_almost_eq(default_shots[0].direction.angle(), deg_to_rad(6.0), 0.0001)
	assert_almost_eq(default_shots[0].speed, 540.0, 0.001)
	assert_almost_eq(default_shots[1].speed, 720.0, 0.001)
	assert_almost_eq(default_shots[2].speed, 900.0, 0.001)
	assert_almost_eq(default_shots[0].lifetime_seconds, 0.9, 0.001)
	assert_almost_eq(default_shots[1].lifetime_seconds, 1.5, 0.001)
	assert_almost_eq(default_shots[2].lifetime_seconds, 2.1, 0.001)
	assert_eq(
		default_shots[0].provenance,
		PackedStringArray([
			"split",
			"focus",
			"reverse_order",
			"velocity_gradient",
			"lifetime_gradient",
		])
	)
	assert_true(lab.get_circuit_preview_text().contains("540 / 720 / 900"))
	assert_true(lab.get_circuit_preview_text().contains("0.90 / 1.50 / 2.10"))

	assert_true(lab.select_slot(2))
	assert_true(lab.move_selected_module(1))
	assert_eq(lab.get_selected_slot(), 3)
	assert_eq(
		lab.get_module_ids(),
		PackedStringArray([
			"split",
			"focus",
			"velocity_gradient",
			"reverse_order",
			"lifetime_gradient",
		])
	)
	assert_eq(weapon.get_module_ids(), lab.get_module_ids())
	assert_true(lab.get_circuit_status_text().contains("[Reverse Order]"))

	var reversed_after_speed := weapon.build_shot_specs()
	assert_eq(reversed_after_speed.size(), 3)
	assert_almost_eq(reversed_after_speed[0].direction.angle(), deg_to_rad(6.0), 0.0001)
	assert_almost_eq(reversed_after_speed[0].speed, 900.0, 0.001)
	assert_almost_eq(reversed_after_speed[1].speed, 720.0, 0.001)
	assert_almost_eq(reversed_after_speed[2].speed, 540.0, 0.001)
	assert_almost_eq(reversed_after_speed[0].lifetime_seconds, 0.9, 0.001)
	assert_almost_eq(reversed_after_speed[2].lifetime_seconds, 2.1, 0.001)
	assert_true(lab.get_circuit_preview_text().contains("900 / 720 / 540"))

	assert_true(lab.move_selected_module(1))
	assert_eq(lab.get_selected_slot(), 4)
	assert_eq(
		lab.get_module_ids(),
		PackedStringArray([
			"split",
			"focus",
			"velocity_gradient",
			"lifetime_gradient",
			"reverse_order",
		])
	)
	var reversed_after_both_gradients := weapon.build_shot_specs()
	assert_almost_eq(reversed_after_both_gradients[0].speed, 900.0, 0.001)
	assert_almost_eq(reversed_after_both_gradients[2].speed, 540.0, 0.001)
	assert_almost_eq(reversed_after_both_gradients[0].lifetime_seconds, 2.1, 0.001)
	assert_almost_eq(reversed_after_both_gradients[2].lifetime_seconds, 0.9, 0.001)
	assert_true(lab.get_circuit_preview_text().contains("2.10 / 1.50 / 0.90"))

	lab.reset_circuit()
	assert_eq(lab.get_selected_slot(), 0)
	assert_eq(
		lab.get_module_ids(),
		PackedStringArray([
			"split",
			"focus",
			"reverse_order",
			"velocity_gradient",
			"lifetime_gradient",
		])
	)
	assert_eq(weapon.get_module_ids(), lab.get_module_ids())
	assert_true(lab.get_circuit_status_text().contains("[Split]"))
	assert_true(lab.get_circuit_preview_text().contains("540 / 720 / 900"))


func _fan_width_degrees(shots: Array[ShotSpec]) -> float:
	assert(shots.size() >= 2)
	return absf(
		rad_to_deg(
			shots[0].direction.angle_to(shots[shots.size() - 1].direction)
		)
	)
