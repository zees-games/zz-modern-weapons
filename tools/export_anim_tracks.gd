extends "res://addons/gs_weapon/tools/gs_weapon_anim_export.gd"

## Bakes each weapon's procedural first-person animations into <model>.anim.json (see ZzAnimBake): the sidecar Nightly's asset viewer plays next to the model.
## The arguments and the output are the shared shell's (addons/gs_weapon/tools/gs_weapon_anim_export.gd). No ids bakes every weapon.
## godot --headless --path . --script res://tools/export_anim_tracks.gd -- out_dir zz_mp5,zz_m4


func _bake_all(host: Node3D, wanted: PackedStringArray) -> void:
	var defs := {}
	for d in ZzWeaponPack.weapons():
		defs[d.id] = d
	for id in ZzWeaponIds.all():
		if not wanted.is_empty() and not String(id) in wanted:
			continue
		var sidecar := ZzAnimBake.new().bake(host, id, defs.get(id))
		if sidecar.is_empty():
			print("SKIP %s (no model)" % id)
			continue
		emit(sidecar)
