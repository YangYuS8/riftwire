extends GutTest

const MOVEMENT_LAB_SCENE: PackedScene = preload(
	"res://game/actors/player/movement_lab.tscn"
)


func test_bound_key_events_change_the_live_circuit_once_per_press() -> void:
	var lab := MOVEMENT_LAB_SCENE.instantiate() as MovementLab
	add_child_autofree(lab)
	await get_tree().process_frame

	assert_true(lab.handle_circuit_key_event(_key_event(KEY_3)))
	assert_eq(lab.get_selected_slot(), 2)

	assert_true(lab.handle_circuit_key_event(_key_event(KEY_E)))
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
	assert_eq(lab.get_player_weapon().get_module_ids(), lab.get_module_ids())

	var chain_after_press := lab.get_module_ids()
	assert_false(lab.handle_circuit_key_event(_key_event(KEY_E, true, true)))
	assert_eq(lab.get_module_ids(), chain_after_press)
	assert_false(lab.handle_circuit_key_event(_key_event(KEY_E, false)))
	assert_eq(lab.get_module_ids(), chain_after_press)
	assert_false(lab.handle_circuit_key_event(_key_event(KEY_F)))
	assert_eq(lab.get_module_ids(), chain_after_press)

	assert_true(lab.handle_circuit_key_event(_key_event(KEY_R)))
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


func test_reordered_live_weapon_spawns_the_specs_shown_in_preview() -> void:
	var lab := MOVEMENT_LAB_SCENE.instantiate() as MovementLab
	add_child_autofree(lab)
	await get_tree().process_frame
	var weapon := lab.get_player_weapon()

	lab.select_slot(2)
	lab.move_selected_module(1)
	lab.move_selected_module(1)
	weapon.simulate_input(
		PlayerInputFrame.new(0.0, false, false, Vector2.RIGHT, false, false),
		0.0
	)
	var expected_specs := weapon.build_shot_specs()
	assert_eq(expected_specs.size(), 3)
	assert_true(lab.get_circuit_preview_text().contains("speed 900 / 720 / 540"))
	assert_true(lab.get_circuit_preview_text().contains("lifetime 2.10 / 1.50 / 0.90 s"))

	var fired_projectiles: Array[BaseProjectile] = []
	weapon.projectile_fired.connect(
		func(projectile: BaseProjectile) -> void:
			fired_projectiles.append(projectile)
	)
	weapon.get_fire_model().reset()
	weapon.simulate_input(
		PlayerInputFrame.new(0.0, false, false, Vector2.RIGHT, true, true),
		0.0
	)

	assert_eq(fired_projectiles.size(), expected_specs.size())
	for shot_index in range(expected_specs.size()):
		var projectile := fired_projectiles[shot_index]
		var expected := expected_specs[shot_index]
		assert_eq(projectile.travel_direction, expected.direction)
		assert_almost_eq(projectile.speed, expected.speed, 0.001)
		assert_almost_eq(
			projectile.lifetime_remaining,
			expected.lifetime_seconds,
			0.001
		)
		assert_almost_eq(projectile.damage, expected.damage, 0.001)


func _key_event(
	physical_keycode: Key,
	pressed: bool = true,
	echo: bool = false
) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	event.pressed = pressed
	event.echo = echo
	return event
