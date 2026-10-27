class_name ZzSpawnProvider
extends RefCounted

## What a host's spawn menu (Playground's) lists for this pack.
##
## The host calls [method spawn_entries] and shows one row per dictionary:
## [code]{category, id, name, icon, kind, spawn, cfg_hint}[/code]. [code]spawn[/code] is the
## request the host hands its weapon-giving path ([code]{"weapon": id}[/code]); it is data, so
## this pack puts nothing in the world itself. [code]icon[/code] is a texture path, empty
## while the pack has no thumbnails (the host draws its own). [code]cfg_hint[/code] says where
## the weapon's profile lives; the menu order is the profiles' `menu: sort`, so a menu can show it as a tooltip.

const CATEGORY := "Weapons"


## The contract game-zombie-zone's zz_packs.gd reads (it loads this file by path and calls it by
## name, so nothing there names this pack): a "weapon" row is handed out only if its
## [code]spawn.weapon[/code] (or [code]spawn.weapon_id[/code], or the row id) is the id of one of
## these. [param types] is the game's damage table (id -> DotDamageType); an entry replaces this
## pack's own of that id. Called with no argument it uses the pack's. There is no
## [code]weapon_art()[/code] on purpose: zee's art source takes an Array of ZeeWeaponArt, a class
## this pack may not name, and every row here is a placeholder with no model yet.
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
