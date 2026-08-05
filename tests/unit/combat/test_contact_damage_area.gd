extends GutTest


func test_contact_damage_applies_immediately_then_respects_repeat_interval() -> void:
	var fixture := Node.new()
	add_child_autofree(fixture)
	var health := HealthComponent.new()
	var hurtbox := Hurtbox.new()
	var damage_area := ContactDamageArea.new()
	fixture.add_child(health)
	fixture.add_child(hurtbox)
	fixture.add_child(damage_area)
	health.configure(100.0)
	hurtbox.set_health_component(health)
	damage_area.damage = 25.0
	damage_area.repeat_interval_seconds = 0.5
	var contacts: Array[Hurtbox] = [hurtbox]

	damage_area.simulate(0.0, contacts)
	assert_almost_eq(health.current_health, 75.0, 0.001)
	damage_area.simulate(0.25, contacts)
	assert_almost_eq(health.current_health, 75.0, 0.001)
	damage_area.simulate(0.25, contacts)
	assert_almost_eq(health.current_health, 50.0, 0.001)
	assert_eq(damage_area.get_tracked_contact_count(), 1)


func test_leaving_and_reentering_allows_immediate_damage_again() -> void:
	var fixture := Node.new()
	add_child_autofree(fixture)
	var health := HealthComponent.new()
	var hurtbox := Hurtbox.new()
	var damage_area := ContactDamageArea.new()
	fixture.add_child(health)
	fixture.add_child(hurtbox)
	fixture.add_child(damage_area)
	health.configure(100.0)
	hurtbox.set_health_component(health)
	damage_area.damage = 20.0
	damage_area.repeat_interval_seconds = 1.0
	var contacts: Array[Hurtbox] = [hurtbox]
	var no_contacts: Array[Hurtbox] = []

	damage_area.simulate(0.0, contacts)
	damage_area.simulate(0.1, no_contacts)
	assert_eq(damage_area.get_tracked_contact_count(), 0)
	damage_area.simulate(0.0, contacts)

	assert_almost_eq(health.current_health, 60.0, 0.001)


func test_fixed_contact_sequence_is_repeatable() -> void:
	var first_result := _run_fixed_sequence()
	var second_result := _run_fixed_sequence()
	assert_almost_eq(first_result, second_result, 0.001)
	assert_almost_eq(first_result, 40.0, 0.001)


func _run_fixed_sequence() -> float:
	var fixture := Node.new()
	add_child_autofree(fixture)
	var health := HealthComponent.new()
	var hurtbox := Hurtbox.new()
	var damage_area := ContactDamageArea.new()
	fixture.add_child(health)
	fixture.add_child(hurtbox)
	fixture.add_child(damage_area)
	health.configure(100.0)
	hurtbox.set_health_component(health)
	damage_area.damage = 15.0
	damage_area.repeat_interval_seconds = 0.25
	var contacts: Array[Hurtbox] = [hurtbox]

	damage_area.simulate(0.0, contacts)
	for _tick in range(6):
		damage_area.simulate(0.125, contacts)
	return health.current_health
