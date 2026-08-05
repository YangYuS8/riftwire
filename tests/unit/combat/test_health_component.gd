extends GutTest

var _depletion_count: int = 0


func before_each() -> void:
	_depletion_count = 0


func test_damage_clamps_at_zero_and_depletes_once() -> void:
	var health := HealthComponent.new()
	health.configure(25.0)
	health.depleted.connect(_on_depleted)

	assert_almost_eq(health.apply_damage(10.0), 10.0, 0.001)
	assert_almost_eq(health.current_health, 15.0, 0.001)
	assert_almost_eq(health.apply_damage(50.0), 15.0, 0.001)
	assert_almost_eq(health.current_health, 0.0, 0.001)
	assert_true(health.is_depleted())
	assert_almost_eq(health.apply_damage(1.0), 0.0, 0.001)
	assert_eq(_depletion_count, 1)
	health.free()


func test_restore_and_manual_assignment_clamp_to_valid_range() -> void:
	var health := HealthComponent.new()
	health.configure(10.0)
	health.apply_damage(7.0)

	assert_almost_eq(health.restore_health(100.0), 7.0, 0.001)
	assert_almost_eq(health.current_health, 10.0, 0.001)
	health.set_current_health(99.0)
	assert_almost_eq(health.current_health, 10.0, 0.001)
	health.set_current_health(-5.0)
	assert_almost_eq(health.current_health, 0.0, 0.001)
	health.free()


func test_reset_allows_a_later_depletion_event() -> void:
	var health := HealthComponent.new()
	health.configure(5.0)
	health.depleted.connect(_on_depleted)

	health.apply_damage(5.0)
	health.reset_to_maximum()
	health.apply_damage(5.0)

	assert_eq(_depletion_count, 2)
	health.free()


func _on_depleted() -> void:
	_depletion_count += 1
