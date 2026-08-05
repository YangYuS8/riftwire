extends Area2D
class_name ContactDamageArea

signal damage_dealt(hurtbox: Hurtbox, applied_damage: float)

@export_range(0.0, 1000000.0, 0.1, "or_greater") var damage: float = 25.0
@export_range(0.016, 30.0, 0.001, "or_greater") var repeat_interval_seconds: float = 0.75

var _cooldowns_by_hurtbox_id: Dictionary = {}


func _physics_process(delta: float) -> void:
	if not monitoring:
		_cooldowns_by_hurtbox_id.clear()
		return

	var overlapping_hurtboxes: Array[Hurtbox] = []
	for area in get_overlapping_areas():
		if area is Hurtbox:
			overlapping_hurtboxes.append(area as Hurtbox)
	simulate(delta, overlapping_hurtboxes)


func simulate(delta: float, overlapping_hurtboxes: Array[Hurtbox]) -> void:
	assert(delta >= 0.0, "Contact damage simulation delta cannot be negative.")
	var active_hurtbox_ids: Dictionary = {}

	for hurtbox in overlapping_hurtboxes:
		if hurtbox == null or not is_instance_valid(hurtbox):
			continue

		var hurtbox_id := hurtbox.get_instance_id()
		active_hurtbox_ids[hurtbox_id] = true
		var had_existing_contact := _cooldowns_by_hurtbox_id.has(hurtbox_id)
		var remaining_seconds := float(_cooldowns_by_hurtbox_id.get(hurtbox_id, 0.0))
		if had_existing_contact:
			remaining_seconds = maxf(0.0, remaining_seconds - delta)

		if not had_existing_contact or remaining_seconds <= 0.0:
			var applied_damage := hurtbox.receive_damage(maxf(0.0, damage))
			if applied_damage > 0.0:
				damage_dealt.emit(hurtbox, applied_damage)
			remaining_seconds = maxf(0.001, repeat_interval_seconds)

		_cooldowns_by_hurtbox_id[hurtbox_id] = remaining_seconds

	for tracked_id in _cooldowns_by_hurtbox_id.keys():
		if not active_hurtbox_ids.has(tracked_id):
			_cooldowns_by_hurtbox_id.erase(tracked_id)


func deactivate() -> void:
	set_physics_process(false)
	_cooldowns_by_hurtbox_id.clear()
	set_deferred("monitoring", false)


func get_tracked_contact_count() -> int:
	return _cooldowns_by_hurtbox_id.size()