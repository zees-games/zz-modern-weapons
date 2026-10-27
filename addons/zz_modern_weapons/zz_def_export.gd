class_name ZzModernDefExport
extends RefCounted

## Writes the pack as Workshop files: one [DotWeaponDef] `.tres` per weapon and `provides.json`
## (kind `weapon`, games `*`). Generated from the code table with the built-in defaults, never
## from a server's cfg, and never hand-edited; the suite compares them. Run `tools/export-defs.sh`.

const CHANNEL := "zz.defs"

const CATEGORIES: Array[Dictionary] = [
	{"slot": 1, "id": "melee", "name": "Melee"},
	{"slot": 2, "id": "sidearm", "name": "Sidearms"},
	{"slot": 3, "id": "primary", "name": "Primary"},
	{"slot": 4, "id": "heavy", "name": "Heavy"},
	{"slot": 5, "id": "thrown", "name": "Thrown"},
]


static func own_weapons() -> Array[DotWeaponDef]:
	return ZzWeaponPack.weapons({}, ZzWeaponConfig.defaults())


static func category_for(slot: int) -> String:
	for c in CATEGORIES:
		if c["slot"] == slot:
			return c["id"]
	return ""


static func provides(defs: Array[DotWeaponDef]) -> Dictionary:
	var cats: Array = []
	for c in CATEGORIES:
		cats.append({"id": c["id"], "name": c["name"]})
	var entries: Array = []
	for def in defs:
		entries.append({
			"kind": "weapon",
			"id": String(def.id),
			"name": def.name_or_id(),
			"def": "weapons/%s.tres" % String(def.id),
			"slot": def.slot,
			"category": category_for(def.slot),
			"tags": Array(def.tags).map(func(t: StringName) -> String: return String(t)),
			"meta": {"asset_root": "."},
		})
	return {
		"schema": 1, "title": "Zee's Modern Weapons", "kinds": ["weapon"],
		"games": "*", "categories": cats, "entries": entries,
	}


static func export_to(root: String) -> DotResult:
	var dir := root.path_join("weapons")
	var made := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	if made != OK:
		return DotResult.fail(DotError.CODE_IO, "Cannot create %s (error %d)." % [dir, made])
	var defs := own_weapons()
	for def in defs:
		var path := dir.path_join("%s.tres" % String(def.id))
		var saved := ResourceSaver.save(def, path)
		if saved != OK:
			return DotResult.fail(DotError.CODE_IO, "Cannot save %s (error %d)." % [path, saved])
	var cfg := _copy_cfg(root, "addons/zz_modern_weapons/weapon")
	if not cfg.ok:
		return cfg
	var f := FileAccess.open(root.path_join("provides.json"), FileAccess.WRITE)
	if f == null:
		return DotResult.fail(DotError.CODE_IO, "Cannot write provides.json.")
	f.store_string(JSON.stringify(provides(defs), "\t", false) + "\n")
	f.close()
	return DotResult.success(defs.size())


## Copies the shipped `cfg/addons/<addon>/weapon` tree (upgrades included) under [param root] when it is not the project's own.
static func _copy_cfg(root: String, rel: String) -> DotResult:
	var from := "res://cfg".path_join(rel)
	var to := root.path_join("cfg").path_join(rel)
	if root.trim_suffix("/") == "res:/" or to == from or not DirAccess.dir_exists_absolute(from):
		return DotResult.success(0)
	var n := 0
	var stack: Array[String] = [""]
	while not stack.is_empty():
		var sub: String = stack.pop_back()
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(to.path_join(sub)))
		for d in DirAccess.get_directories_at(from.path_join(sub)):
			stack.append(sub.path_join(d))
		for f in DirAccess.get_files_at(from.path_join(sub)):
			if f.get_extension() != "yml":
				continue
			var text := FileAccess.get_file_as_string(from.path_join(sub).path_join(f))
			var o := FileAccess.open(to.path_join(sub).path_join(f), FileAccess.WRITE)
			if o == null:
				return DotResult.fail(DotError.CODE_IO, "Cannot write cfg %s." % f)
			o.store_string(text)
			o.close()
			n += 1
	return DotResult.success(n)
