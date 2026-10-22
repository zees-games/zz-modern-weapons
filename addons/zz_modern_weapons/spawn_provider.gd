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
