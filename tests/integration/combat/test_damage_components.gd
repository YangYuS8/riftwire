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
