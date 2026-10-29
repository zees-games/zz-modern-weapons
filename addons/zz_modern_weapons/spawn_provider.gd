class_name ZzSpawnProvider
extends RefCounted

## What a host's spawn menu lists for this pack: [method spawn_entries] returns one dictionary per row,
## [code]{category, id, name, icon, kind, spawn, cfg_hint}[/code]. [code]spawn[/code] is data for the host's
## weapon-giving path; the pack puts nothing in the world itself.

const CATEGORY := "Weapons"


## The contract game-zombie-zone's zz_packs.gd reads by path: a "weapon" row is handed out only if its
## spawn.weapon (or weapon_id, or the row id) is one of these ids. [param types] replaces this pack's own
## damage entry per id; there is no weapon_art() because zee's art source names a class this pack may not.
static func weapon_defs(types: Dictionary = {}) -> Array[DotWeaponDef]:
	var table := ZzWeaponDamage.table()
	for key in types:
		table[StringName(key)] = types[key]
	return ZzWeaponPack.weapons(table)


## [method weapon_defs] rebuilt over a host's live profile edits ([param layer]: id -> {path: value}).
static func weapon_defs_with(layer: Dictionary, types: Dictionary = {}) -> Array[DotWeaponDef]:
	var table := ZzWeaponDamage.table()
	for key in types:
		table[StringName(key)] = types[key]
	return ZzWeaponPack.weapons(table, ZzWeaponConfig.load_all("", PackedStringArray(), layer))


## What a host needs to draw each weapon with its own rig, as plain data (no class of another addon is named here):
## id -> {model, muzzle, motion, view: {hold, aim, zoom, support, ...}}. `model` is "" for a weapon still on a placeholder;
## the glb has its origin at the grip and its muzzle toward -Z.
static func art_rows() -> Dictionary:
	var out := {}
	for id: StringName in ZzWeaponArt.TABLE:
		var model := "" if ZzWeaponArt.is_placeholder(id) else ZzWeaponArt.ASSET_DIR.path_join(String(ZzWeaponArt.TABLE[id]["model"]))
		out[id] = {"model": model, "muzzle": ZzWeaponArt.muzzle_distance(id), "motion": ZzWeaponArt.motion_of(id), "view": _view(id)}
	return out


static func _view(id: StringName) -> Dictionary:
	var out := ZzWeaponArt.view_profile(id)
	out.merge(ZzWeaponConfig.view_overrides(ZzWeaponIds.short_name(id)), true)
	return out


## Who made each weapon model, as plain rows {id, model, author, licence, url}: a host shows them wherever it credits art.
static func credits() -> Array[Dictionary]:
	return ZzWeaponCredits.rows()


## The one line CC-BY asks a host to show beside the art.
static func credits_line() -> String:
	return ZzWeaponCredits.line()


static func spawn_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var defs := ZzWeaponPack.weapons()
	var order := {}
	for e: Dictionary in ZzWeaponConfig.menu_entries():
		order["zz_" + String(e["id"])] = int(e["sort"])
	defs.sort_custom(func(a: DotWeaponDef, b: DotWeaponDef) -> bool: return order.get(String(a.id), 99) < order.get(String(b.id), 99))
	for def in defs:
		var short := ZzWeaponIds.short_name(def.id)
		out.append({
			"category": CATEGORY,
			"id": String(def.id),
			"name": def.name_or_id(),
			"icon": "",
			"kind": "weapon",
			"spawn": {"weapon": String(def.id)},
			"cfg_hint": "cfg/addons/%s/weapon/%s.yml" % [ZzWeaponConfig.ADDON, short],
		})
	return out
