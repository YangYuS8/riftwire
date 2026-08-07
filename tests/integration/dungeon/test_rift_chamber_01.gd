extends GutTest

const ROOM_SCENE: PackedScene = preload(
	"res://game/dungeon/rooms/rift_chamber_01.tscn"
)
const MOVEMENT_LAB_SCENE: PackedScene = preload(
	"res://game/actors/player/movement_lab.tscn"
)


func test_room_locks_until_both_live_enemies_are_destroyed() -> void:
	var room := ROOM_SCENE.instantiate() as Node2D
	add_child_autofree(room)
	await _wait_process_frames(2)

	var player := room.get_node("Player") as RiftwirePlayer
	player.set_physics_process(false)
	var enemy_container := room.get_node("Enemies")
	var left_enemy := enemy_container.get_node("LeftPatrol") as PatrolEnemy
	var right_enemy := enemy_container.get_node("RightSentry") as RiftSentry
	left_enemy.set_physics_process(false)
	right_enemy.set_physics_process(false)
	var controller := room.get_node("EncounterController") as EncounterController
	var left_gate := room.get_node("LeftGate") as EncounterGate
	var right_gate := room.get_node("RightGate") as EncounterGate
	var status := room.get_node("CombatHud/Root/EncounterStatus") as Label

	assert_not_null(left_enemy)
	assert_not_null(right_enemy)
	assert_eq(controller.get_remaining_enemy_count(), 2)
	assert_false(controller.is_completed())
	assert_true(left_gate.is_locked())
	assert_true(right_gate.is_locked())
	assert_eq(left_gate.collision_layer, 1)
	assert_eq(right_gate.collision_layer, 1)
	assert_eq(left_gate.get_visual_color(), left_gate.locked_color)
	assert_true(status.text.contains("HOSTILES: 2"))

	left_enemy.get_health_component().apply_damage(1000.0)
	await get_tree().process_frame
	assert_eq(controller.get_remaining_enemy_count(), 1)
	assert_false(controller.is_completed())
	assert_true(left_gate.is_locked())
	assert_true(status.text.contains("HOSTILES: 1"))

	right_enemy.get_health_component().apply_damage(1000.0)
	await get_tree().process_frame
	assert_eq(controller.get_remaining_enemy_count(), 0)
	assert_true(controller.is_completed())
	assert_false(left_gate.is_locked())
	assert_false(right_gate.is_locked())
	assert_eq(left_gate.collision_layer, 0)
	assert_eq(right_gate.collision_layer, 0)
	assert_eq(left_gate.get_visual_color(), left_gate.unlocked_color)
	assert_true(status.text.contains("ROOM CLEAR"))


func test_authored_room_is_main_scene_and_movement_lab_remains_loadable() -> void:
	assert_eq(
		str(ProjectSettings.get_setting("application/run/main_scene")),
		"res://game/dungeon/rooms/rift_chamber_01.tscn"
	)
	assert_true(ROOM_SCENE.can_instantiate())
	assert_true(MOVEMENT_LAB_SCENE.can_instantiate())


func _wait_process_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().process_frame
