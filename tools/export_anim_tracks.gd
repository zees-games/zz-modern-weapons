extends SceneTree

## Bakes each weapon's procedural first-person animations into <model>.anim.json (see ZzAnimBake): the sidecar Nightly's asset viewer plays next to the model.
## Args: out_dir (or - to print one SIDECAR<TAB>asset<TAB>json line each to stdout, for offloaded runs) [id,id ...]; the file is named like Nightly's GLB for the model (pack__path__with__underscores) so the viewer finds it beside the asset. No ids bakes every weapon.
## godot --headless --path . --script res://tools/export_anim_tracks.gd -- out_dir zz_mp5,zz_m4


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("usage: export_anim_tracks.gd -- out_dir [ids]")
		quit(2)
		return
	var out := args[0]
	if out != "-":
		DirAccess.make_dir_recursive_absolute(out)
	var wanted: PackedStringArray = args[1].split(",") if args.size() > 1 and args[1] != "" else PackedStringArray()
	var defs := {}
	for d in ZzWeaponPack.weapons():
		defs[d.id] = d
	var host := Node3D.new()
	root.add_child(host)
	await process_frame
	var failed := 0
	for id in ZzWeaponIds.all():
		if not wanted.is_empty() and not String(id) in wanted:
			continue
		var sidecar := ZzAnimBake.new().bake(host, id, defs.get(id))
		if sidecar.is_empty():
			print("SKIP %s (no model)" % id)
			continue
		if out == "-":
			print("SIDECAR\t%s\t%s" % [sidecar.asset, JSON.stringify(sidecar)])
			continue
		var path := "%s/%s.anim.json" % [out, sidecar.asset]
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f == null:
			push_error("cannot write %s" % path)
			failed += 1
			continue
		f.store_string(JSON.stringify(sidecar))
		f.close()
		var n := 0
		for c: Dictionary in sidecar.clips:
			n += (c.tracks as Array).size()
		print("BAKED %s -> %s (%d clips, %d tracks)" % [id, path, (sidecar.clips as Array).size(), n])
	quit(1 if failed > 0 else 0)
