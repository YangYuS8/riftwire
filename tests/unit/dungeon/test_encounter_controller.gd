extends GutTest

class FakeEnemy:
	extends Node
	signal destroyed

	func destroy() -> void:
		destroyed.emit()


class FakeGate:
	extends Node
	var locked: bool = false
	var transitions: Array[bool] = []

	func set_locked(value: bool) -> void:
		locked = value
		transitions.append(value)


func test_tracks_each_destroyed_enemy_once_and_unlocks_all_gates() -> void:
	var fixture := _build_fixture(2)
	await _wait_process_frames(2)
	var controller := fixture["controller"] as EncounterController
	var left_gate := fixture["left_gate"] as FakeGate
	var right_gate := fixture["right_gate"] as FakeGate
	var status := fixture["status"] as Label
	var enemies: Array = fixture["enemies"]

	assert_true(controller.is_initialized())
	assert_false(controller.is_completed())
	assert_eq(controller.get_remaining_enemy_count(), 2)
	assert_true(left_gate.locked)
	assert_true(right_gate.locked)
	assert_true(status.text.contains("HOSTILES: 2"))

	var remaining_events: Array[int] = []
	var completion_events: Array[int] = []
	controller.remaining_enemies_changed.connect(
		func(count: int) -> void: remaining_events.append(count)
	)
	controller.encounter_completed.connect(
		func() -> void: completion_events.append(1)
	)

	(enemies[0] as FakeEnemy).destroy()
	assert_eq(controller.get_remaining_enemy_count(), 1)
	assert_false(controller.is_completed())
	assert_true(left_gate.locked)
	assert_true(status.text.contains("HOSTILES: 1"))

	(enemies[1] as FakeEnemy).destroy()
	assert_eq(controller.get_remaining_enemy_count(), 0)
	assert_true(controller.is_completed())
	assert_false(left_gate.locked)
	assert_false(right_gate.locked)
	assert_true(status.text.contains("ROOM CLEAR"))
	assert_eq(remaining_events, [1, 0])
	assert_eq(completion_events.size(), 1)

	(enemies[1] as FakeEnemy).destroy()
	assert_eq(controller.get_remaining_enemy_count(), 0)
	assert_eq(completion_events.size(), 1)


func test_empty_encounter_completes_without_leaving_gates_locked() -> void:
	var fixture := _build_fixture(0)
	await _wait_process_frames(2)
	var controller := fixture["controller"] as EncounterController
	var left_gate := fixture["left_gate"] as FakeGate
	var right_gate := fixture["right_gate"] as FakeGate
	var status := fixture["status"] as Label

	assert_true(controller.is_initialized())
	assert_true(controller.is_completed())
	assert_eq(controller.get_remaining_enemy_count(), 0)
	assert_false(left_gate.locked)
	assert_false(right_gate.locked)
	assert_eq(left_gate.transitions, [true, false])
	assert_eq(right_gate.transitions, [true, false])
	assert_true(status.text.contains("ROOM CLEAR"))


func _build_fixture(enemy_count: int) -> Dictionary:
	var root := Node.new()
	root.name = "Fixture"

	var enemy_container := Node.new()
	enemy_container.name = "Enemies"
	root.add_child(enemy_container)
	var enemies: Array[Node] = []
	for enemy_index in range(enemy_count):
		var enemy := FakeEnemy.new()
		enemy.name = "Enemy%d" % enemy_index
		enemy_container.add_child(enemy)
		enemies.append(enemy)

	var left_gate := FakeGate.new()
	left_gate.name = "LeftGate"
	root.add_child(left_gate)
	var right_gate := FakeGate.new()
	right_gate.name = "RightGate"
	root.add_child(right_gate)

	var status := Label.new()
	status.name = "Status"
	root.add_child(status)

	var controller := EncounterController.new()
	controller.name = "EncounterController"
	controller.enemy_container_path = NodePath("../Enemies")
	var paths: Array[NodePath] = [
		NodePath("../LeftGate"),
		NodePath("../RightGate"),
	]
	controller.gate_paths = paths
	controller.status_label_path = NodePath("../Status")
	root.add_child(controller)
	add_child_autofree(root)

	return {
		"controller": controller,
		"enemies": enemies,
		"left_gate": left_gate,
		"right_gate": right_gate,
		"status": status,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().process_frame
