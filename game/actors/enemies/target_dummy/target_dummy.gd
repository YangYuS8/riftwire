extends Node2D
class_name TargetDummy

signal destroyed

@export_range(1.0, 1000000.0, 1.0, "or_greater") var maximum_health: float = 30.0

@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _health_label: Label = $HealthLabel


func _ready() -> void:
	_health_component.configure(maximum_health)
	_hurtbox.set_health_component(_health_component)
	_health_component.health_changed.connect(_on_health_changed)
	_health_component.depleted.connect(_on_depleted)
	_update_health_label()


func get_health_component() -> HealthComponent:
	return _health_component


func get_hurtbox() -> Hurtbox:
	return _hurtbox


func _on_health_changed(
	_previous_health: float,
	_current_health: float,
	_maximum_health: float
) -> void:
	_update_health_label()


func _on_depleted() -> void:
	destroyed.emit()
	queue_free()


func _update_health_label() -> void:
	if _health_label == null:
		return
	_health_label.text = "%d / %d HP" % [
		int(round(_health_component.current_health)),
		int(round(_health_component.maximum_health)),
	]
