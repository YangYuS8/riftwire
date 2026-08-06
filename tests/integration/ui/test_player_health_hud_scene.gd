extends GutTest

const PLAYER_SCENE: PackedScene = preload("res://game/actors/player/player.tscn")
const HUD_SCENE: PackedScene = preload("res://game/ui/player_health_hud.tscn")
const MOVEMENT_LAB_SCENE: PackedScene = preload(
	"res://game/actors/player/movement_lab.tscn"
)


func test_hud_tracks_damage_depletion_and_respawn() -> void:
	var fixture := Node2D.new()
	add_child_autofree(fixture)
	var player := PLAYER_SCENE.instantiate() as RiftwirePlayer
	var hud := HUD_SCENE.instantiate() as PlayerHealthHud
	var movement_config := PlayerMovementConfig.new()
	movement_config.gravity = 1.0
	player.movement_config = movement_config
	player.maximum_health = 80.0
	player.respawn_delay_seconds = 0.25
	player.set_input_source(ScriptedPlayerInputSource.new())
	fixture.add_child(player)
	fixture.add_child(hud)
	await get_tree().process_frame
	hud.bind_player(player)

	assert_eq(hud.get_bound_player(), player)
	assert_eq(hud.get_bound_health_component(), player.get_health_component())
	assert_almost_eq(hud.get_displayed_current_health(), 80.0, 0.001)
	assert_almost_eq(hud.get_displayed_maximum_health(), 80.0, 0.001)
	assert_eq(hud.get_health_text(), "HP 80 / 80")

	player.get_hurtbox().receive_damage(25.0)

	assert_almost_eq(player.get_health_component().current_health, 55.0, 0.001)
	assert_almost_eq(hud.get_displayed_current_health(), 55.0, 0.001)
	assert_eq(hud.get_health_text(), "HP 55 / 80")

	player.get_hurtbox().clear_invulnerability()
	player.get_hurtbox().receive_damage(55.0)

	assert_true(player.is_defeated())
	assert_almost_eq(hud.get_displayed_current_health(), 0.0, 0.001)
	assert_eq(hud.get_health_text(), "HP 0 / 80")

	player.simulate_respawn(0.25)

	assert_false(player.is_defeated())
	assert_almost_eq(player.get_health_component().current_health, 80.0, 0.001)
	assert_almost_eq(hud.get_displayed_current_health(), 80.0, 0.001)
	assert_eq(hud.get_health_text(), "HP 80 / 80")


func test_movement_lab_hud_auto_binds_and_fills_viewport_control() -> void:
	var movement_lab := MOVEMENT_LAB_SCENE.instantiate()
	add_child_autofree(movement_lab)
	await get_tree().process_frame
	var player := movement_lab.get_node("Player") as RiftwirePlayer
	var hud := movement_lab.get_node("PlayerHealthHud") as PlayerHealthHud
	var root_control := hud.get_node("Root") as Control

	assert_eq(hud.get_bound_player(), player)
	assert_eq(hud.get_bound_health_component(), player.get_health_component())
	assert_eq(hud.get_health_text(), "HP 100 / 100")
	assert_almost_eq(root_control.anchor_right, 1.0, 0.001)
	assert_almost_eq(root_control.anchor_bottom, 1.0, 0.001)


func test_movement_lab_circuit_hud_is_viewport_fixed_and_clear_of_health_panel() -> void:
	var movement_lab := MOVEMENT_LAB_SCENE.instantiate()
	add_child_autofree(movement_lab)
	await get_tree().process_frame
	var health_hud := movement_lab.get_node("PlayerHealthHud") as CanvasLayer
	var health_panel := health_hud.get_node("Root/Panel") as Control
	var circuit_hud := movement_lab.get_node("CircuitHud") as CanvasLayer
	var circuit_root := circuit_hud.get_node("Root") as Control
	var circuit_status := circuit_root.get_node("CircuitStatus") as Control
	var circuit_preview := circuit_root.get_node("CircuitPreview") as Control
	var instructions := circuit_root.get_node("Instructions") as Control
	var health_rect := health_panel.get_global_rect()

	assert_eq(circuit_hud.layer, 9)
	assert_eq(health_hud.layer, 10)
	assert_eq(circuit_root.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_almost_eq(circuit_root.anchor_right, 1.0, 0.001)
	assert_almost_eq(circuit_root.anchor_bottom, 1.0, 0.001)
	assert_false(health_rect.intersects(circuit_status.get_global_rect()))
	assert_false(health_rect.intersects(circuit_preview.get_global_rect()))
	assert_false(health_rect.intersects(instructions.get_global_rect()))
