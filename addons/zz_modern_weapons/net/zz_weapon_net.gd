class_name ZzWeaponNet
extends RefCounted

## What has to travel so somebody else's gun looks right on your screen. dot-weapon's
## [DotWeaponNetSync] already replicates the simulation (slot, magazine, reserve); none of that
## tells a watcher a shot just happened. This adds four public fields, and a game concatenates
## the two spec lists ([method all_specs]).
##
## [b]A counter, not an event.[/b] A four-bit counter in the snapshot arrives with the state it
## describes, costs four bits, and a watcher who missed a snapshot sees it jump by two and plays
## one flash. An RPC per shot needs a reliable channel for something worthless late, and can show
## the flash of a weapon the same snapshot says is holstered. Ammunition stays owner-only
## (dot-weapon's call); "that player is firing" is public because anybody in the room sees it.
##
## The property names are the same as zee-dot-weapons' [code]ZeeWeaponNet[/code] on purpose: a
## game's bridge is then pack-agnostic. A carrier uses one pack, so they never both appear. This
## file names no class of that pack (it is optional, as dot-net is here).

const FIRE_SEQ_BITS := 4
const FIRE_SEQ_WRAP := 1 << FIRE_SEQ_BITS
const FIRE_KIND_BITS := 3

const KIND_NONE := 0
const KIND_SHOT := 1
const KIND_SWING := 2
const KIND_SPAWN := 3
const KIND_BEAM := 4
const KIND_THROW := 5


static func specs() -> Array[Dictionary]:
	return [
		{"property": &"net_fire_seq", "type": "UINT", "bits": FIRE_SEQ_BITS, "owner_only": false, "interpolated": false},
		{"property": &"net_fire_kind", "type": "UINT", "bits": FIRE_KIND_BITS, "owner_only": false, "interpolated": false},
		{"property": &"net_reloading", "type": "BOOL", "bits": 1, "owner_only": false, "interpolated": false},
		{"property": &"net_switching", "type": "BOOL", "bits": 1, "owner_only": false, "interpolated": false},
	]


## dot-weapon's specs, then these. The one call a game should make.
static func all_specs() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	out.append_array(DotWeaponNetSync.specs())
	out.append_array(specs())
	return out


static func properties() -> Array[StringName]:
	var out: Array[StringName] = []
	for spec in all_specs():
		out.append(spec["property"])
	return out


static func estimated_bits() -> int:
	return DotWeaponNetSync.estimated_bits() + FIRE_SEQ_BITS + FIRE_KIND_BITS + 2


## Authority side, once per tick after the arsenal has simulated.
static func pull(arsenal: DotWeaponArsenal, tracker: ZzFireTracker, target: Object) -> void:
	if arsenal == null or target == null:
		return
	DotWeaponNetSync.pull(arsenal, target)
	target.set(&"net_reloading", arsenal.is_reloading())
	target.set(&"net_switching", arsenal.is_switching())
	if tracker != null:
		target.set(&"net_fire_seq", tracker.seq % FIRE_SEQ_WRAP)
		target.set(&"net_fire_kind", tracker.kind)


## Watcher side: what the replicated object says right now.
static func read(source: Object) -> Dictionary:
	return {
		"seq": int(source.get(&"net_fire_seq")) % FIRE_SEQ_WRAP,
		"kind": int(source.get(&"net_fire_kind")),
		"reloading": bool(source.get(&"net_reloading")),
		"switching": bool(source.get(&"net_switching")),
	}


## Uses between two counter readings, wrap-aware. Sixteen or more reads as none (a stale frame).
static func uses_between(previous: int, now: int) -> int:
	return posmod(now - previous, FIRE_SEQ_WRAP)


static func kind_number(kind: StringName) -> int:
	match kind:
		DotWeaponOutcome.KIND_SHOT: return KIND_SHOT
		DotWeaponOutcome.KIND_SWING: return KIND_SWING
		DotWeaponOutcome.KIND_SPAWN: return KIND_SPAWN
		DotWeaponOutcome.KIND_BEAM: return KIND_BEAM
		DotWeaponOutcome.KIND_THROW: return KIND_THROW
	return KIND_NONE
