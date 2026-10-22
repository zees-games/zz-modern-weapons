class_name ZzSpawnProvider
extends RefCounted

## What a host's spawn menu (Playground's) lists for this pack.
##
## The host calls [method spawn_entries] and shows one row per dictionary:
## [code]{category, id, name, icon, kind, spawn, cfg_hint}[/code]. [code]spawn[/code] is the
## request the host hands its weapon-giving path ([code]{"weapon": id}[/code]); it is data, so
## this pack puts nothing in the world itself. [code]icon[/code] is a texture path, empty
## while the pack has no thumbnails (the host draws its own). [code]cfg_hint[/code] says where
## the weapon's numbers live, so a menu can show it as a tooltip.

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


static func spawn_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for def in ZzWeaponPack.weapons():
		var short := ZzWeaponIds.short_name(def.id)
		out.append({
			"category": CATEGORY,
			"id": String(def.id),
			"name": def.name_or_id(),
			"icon": "",
			"kind": "weapon",
			"spawn": {"weapon": String(def.id)},
			"cfg_hint": "cfg/addons/%s/*.yml  ->  %s:" % [ZzWeaponConfig.ADDON, short],
		})
	return out
