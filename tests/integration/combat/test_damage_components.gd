extends GutTest


func test_hurtbox_delegates_damage_to_configured_health() -> void:
	var fixture := Node.new()
	add_child_autofree(fixture)
	var health := HealthComponent.new()
	var hurtbox := Hurtbox.new()
	fixture.add_child(health)
	fixture.add_child(hurtbox)
	health.configure(12.0)
	hurtbox.set_health_component(health)

	var applied_damage := hurtbox.receive_damage(4.5)

	assert_almost_eq(applied_damage, 4.5, 0.001)
	assert_almost_eq(health.current_health, 7.5, 0.001)
	assert_eq(hurtbox.get_health_component(), health)


func test_invulnerability_blocks_damage_until_simulated_window_expires() -> void:
	var fixture := Node.new()
	add_child_autofree(fixture)
	var health := HealthComponent.new()
	var hurtbox := Hurtbox.new()
	fixture.add_child(health)
	fixture.add_child(hurtbox)
	health.configure(20.0)
	hurtbox.set_health_component(health)
	var blocked_events: Array[float] = []
	hurtbox.damage_blocked.connect(func(
		_requested_damage: float,
		remaining_seconds: float
	) -> void:
		blocked_events.append(remaining_seconds)
	)
	hurtbox.start_invulnerability(0.25)

	var blocked_damage := hurtbox.receive_damage(5.0)

	assert_almost_eq(blocked_damage, 0.0, 0.001)
	assert_almost_eq(health.current_health, 20.0, 0.001)
	assert_eq(blocked_events.size(), 1)
	assert_true(hurtbox.is_invulnerable())

	hurtbox.simulate_invulnerability(0.25)
	var applied_damage := hurtbox.receive_damage(5.0)

	assert_false(hurtbox.is_invulnerable())
	assert_almost_eq(applied_damage, 5.0, 0.001)
	assert_almost_eq(health.current_health, 15.0, 0.001)
