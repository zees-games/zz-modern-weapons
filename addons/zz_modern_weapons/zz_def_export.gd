class_name ZzDefExport
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
	var f := FileAccess.open(root.path_join("provides.json"), FileAccess.WRITE)
	if f == null:
		return DotResult.fail(DotError.CODE_IO, "Cannot write provides.json.")
	f.store_string(JSON.stringify(provides(defs), "\t", false) + "\n")
	f.close()
	return DotResult.success(defs.size())
