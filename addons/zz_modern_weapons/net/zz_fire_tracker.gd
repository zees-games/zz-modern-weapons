class_name ZzFireTracker
extends RefCounted

## Counts an arsenal's uses for [ZzWeaponNet]: the arsenal knows a use happened (its [signal
## DotWeaponArsenal.used]) but keeps no count a snapshot could carry. Attach once; read [member
## seq] and [member kind] when pulling.

var seq: int = 0
var kind: int = 0


func attach(arsenal: DotWeaponArsenal) -> void:
	if arsenal != null and not arsenal.used.is_connected(_on_used):
		arsenal.used.connect(_on_used)


func detach(arsenal: DotWeaponArsenal) -> void:
	if arsenal != null and arsenal.used.is_connected(_on_used):
		arsenal.used.disconnect(_on_used)


func _on_used(outcome: DotWeaponOutcome) -> void:
	if outcome == null or not outcome.used:
		return
	seq += 1
	kind = ZzWeaponNet.kind_number(outcome.kind)
