class_name ZzWeaponConfig
extends RefCounted

## Every tunable number of every weapon, with the built-in defaults, overlaid by weapon
## profiles (`cfg/addons/zz_modern_weapons/weapon/<id>.yml`, see [DotWeaponProfiles]) and then
## by any old one-file ymls beside them.
##
## [b]File shape.[/b] A profile per weapon (m4, sniper, knife, pistol, shotgun, smg, frag): the
## common keys (`magazine`, `reserve`, `reserve_max`) at the top, the pack's own under `extra:`,
## a `menu:` block, and for a weapon with upgrades a folder holding `<id>.yml` and `upgrades/`.
## The old shape (a top-level key per weapon in any `*.yml` of the directory) is still read and
## wins, as an operator's own tuning. A key this pack does not know is logged and ignored.
##
## [b]Reading goes through dot-core's DotAddonConfig when it exists[/b], by global class
## name and reflection, so the pack still parses and runs on a dot-core that predates it.
## Otherwise this file reads the directory itself with DotYaml. Either way a missing or
## broken file means the defaults, never a failed boot.

const CHANNEL := "zz.config"
const ADDON := "zz_modern_weapons"
const VIEW_KEY := "view"

## Weapon ids in menu order.
const IDS: Array[String] = ["m4", "sniper", "knife", "pistol", "shotgun", "smg", "frag", "vss", "revolver", "mp5", "spas", "lmg", "dmr", "m79",
	"ak", "scar", "bren", "glock", "deagle", "p90", "aa12", "rpg", "machete",
	"bat", "crowbar", "axe", "sledge", "hunting"]

## Where old one-file ymls are read when [method load_all] gets no directory; empty means search.
static var fallback_dir: String = ""
## The game id for the game tier (`cfg/game/<game>/weapon`); empty skips it.
static var game: String = ""
## A mounted pack's `cfg` root (`DotCloudMounter.cfg_root_of`), the weakest root when [method profile_set] gets none.
static var pack_cfg_root: String = ""
## Roots stacked over [member pack_cfg_root]; empty means [method DotProfileSet.default_roots]. Tests set it to hide the project's own `res://cfg`.
static var base_roots: PackedStringArray = PackedStringArray()
## Profiles that failed to load in the last [method load_all]; their weapons keep the layer below.
static var errors: PackedStringArray = PackedStringArray()


## Seconds are used for human-facing times; the pack converts to ticks.
static func defaults() -> Dictionary:
	return {
		"m4": {
			"weight": 3.4,
			"damage": 29.0, "rpm": 800.0, "magazine": 30, "reserve": 150, "reserve_max": 240,
			"reload_seconds": 2.1, "deploy_seconds": 0.35, "spread": 0.45,
			"spread_moving": 2.2, "spread_airborne": 4.5, "spread_crouched": 0.35,
			"bloom": 0.2, "bloom_max": 4.0, "recoil_pitch": 0.32, "recoil_yaw": 0.14,
			"recoil_recovery": 5, "recoil_build": 0.06, "max_range": 400.0,
		},
		"sniper": {
			"weight": 5.2,
			"damage": 125.0, "rpm": 45.0, "magazine": 5, "reserve": 20, "reserve_max": 40,
			"reload_seconds": 3.4, "deploy_seconds": 0.75, "spread": 0.0,
			"spread_moving": 9.0, "spread_airborne": 15.0, "spread_crouched": 0.0,
			"bloom": 0.0, "bloom_max": 0.0, "recoil_pitch": 4.2, "recoil_yaw": 0.4,
			"recoil_recovery": 3, "recoil_build": 0.0, "max_range": 1000.0,
		},
		"knife": {
			"weight": 0.3,
			"damage": 50.0, "rpm": 140.0, "reach": 1.9, "arc_degrees": 26.0, "rays": 3,
			"deploy_seconds": 0.15,
		},
		"pistol": {
			"weight": 1.0,
			"damage": 24.0, "rpm": 330.0, "magazine": 15, "reserve": 75, "reserve_max": 120,
			"reload_seconds": 1.5, "deploy_seconds": 0.25, "spread": 0.5,
			"spread_moving": 1.8, "spread_airborne": 3.5, "spread_crouched": 0.4,
			"bloom": 0.35, "bloom_max": 3.0, "recoil_pitch": 0.9, "recoil_yaw": 0.2,
			"recoil_recovery": 8, "recoil_build": 0.05, "max_range": 200.0,
		},
		"shotgun": {
			"weight": 3.6,
			"damage": 12.0, "rpm": 70.0, "magazine": 8, "reserve": 32, "reserve_max": 64,
			"reload_seconds": 0.45, "reload_start_seconds": 0.3, "deploy_seconds": 0.4,
			"pellets": 9, "spread": 4.2, "spread_moving": 0.5, "spread_airborne": 1.0,
			"recoil_pitch": 2.6, "recoil_yaw": 0.3, "recoil_recovery": 4, "recoil_build": 0.0, "max_range": 30.0,
		},
		"smg": {
			"weight": 3.0,
			"damage": 18.0, "rpm": 900.0, "magazine": 32, "reserve": 160, "reserve_max": 256,
			"reload_seconds": 1.8, "deploy_seconds": 0.26, "spread": 0.7,
			"spread_moving": 2.4, "spread_airborne": 5.0, "spread_crouched": 0.6,
			"bloom": 0.26, "bloom_max": 4.5, "recoil_pitch": 0.26, "recoil_yaw": 0.14,
			"recoil_recovery": 6, "recoil_build": 0.07, "max_range": 120.0,
		},
		"vss": {
			"weight": 2.6,
			"damage": 38.0, "rpm": 780.0, "magazine": 20, "reserve": 100, "reserve_max": 160,
			"reload_seconds": 2.5, "deploy_seconds": 0.5, "spread": 0.25,
			"spread_moving": 2.0, "spread_airborne": 4.0, "spread_crouched": 0.15,
			"bloom": 0.14, "bloom_max": 2.6, "recoil_pitch": 0.5, "recoil_yaw": 0.12,
			"recoil_recovery": 5, "recoil_build": 0.05, "max_range": 600.0,
		},
		"frag": {
			"weight": 0.4,
			"fuse_seconds": 3.0, "splash_radius": 5.5, "splash_damage": 120.0,
			"speed": 19.0, "gravity_scale": 1.0, "reserve": 2, "reserve_max": 4,
		},
		"revolver": {
			"weight": 1.2, "damage": 62.0, "rpm": 150.0, "magazine": 6, "reserve": 36, "reserve_max": 60,
			"reload_seconds": 2.6, "deploy_seconds": 0.3, "spread": 0.3,
			"spread_moving": 2.0, "spread_airborne": 4.0, "spread_crouched": 0.2,
			"bloom": 0.6, "bloom_max": 3.0, "recoil_pitch": 2.2, "recoil_yaw": 0.4,
			"recoil_recovery": 7, "recoil_build": 0.03, "max_range": 260.0,
		},
		"mp5": {
			"weight": 2.5, "damage": 22.0, "rpm": 750.0, "magazine": 30, "reserve": 150, "reserve_max": 240,
			"reload_seconds": 2.0, "deploy_seconds": 0.3, "spread": 0.4,
			"spread_moving": 2.0, "spread_airborne": 4.5, "spread_crouched": 0.3,
			"bloom": 0.2, "bloom_max": 3.5, "recoil_pitch": 0.3, "recoil_yaw": 0.12,
			"recoil_recovery": 6, "recoil_build": 0.07, "max_range": 160.0,
		},
		"spas": {
			"weight": 4.2, "damage": 10.0, "rpm": 190.0, "magazine": 8, "reserve": 32, "reserve_max": 56,
			"reload_seconds": 0.5, "reload_start_seconds": 0.35, "deploy_seconds": 0.45,
			"pellets": 8, "spread": 4.8, "spread_moving": 0.6, "spread_airborne": 1.2,
			"recoil_pitch": 2.0, "recoil_yaw": 0.3, "recoil_recovery": 4, "recoil_build": 0.0, "max_range": 28.0,
		},
		"lmg": {
			"weight": 7.5, "damage": 26.0, "rpm": 700.0, "magazine": 100, "reserve": 200, "reserve_max": 300,
			"reload_seconds": 5.2, "deploy_seconds": 0.9, "spread": 0.9,
			"spread_moving": 3.2, "spread_airborne": 6.0, "spread_crouched": 0.6,
			"bloom": 0.3, "bloom_max": 5.5, "recoil_pitch": 0.38, "recoil_yaw": 0.22,
			"recoil_recovery": 4, "recoil_build": 0.08, "max_range": 450.0,
		},
		"dmr": {
			"weight": 4.5, "damage": 58.0, "rpm": 240.0, "magazine": 20, "reserve": 80, "reserve_max": 120,
			"reload_seconds": 2.7, "deploy_seconds": 0.55, "spread": 0.1,
			"spread_moving": 3.5, "spread_airborne": 7.0, "spread_crouched": 0.05,
			"bloom": 0.5, "bloom_max": 2.5, "recoil_pitch": 1.4, "recoil_yaw": 0.25,
			"recoil_recovery": 4, "recoil_build": 0.02, "max_range": 700.0,
		},
		"m79": {
			"weight": 2.9, "damage": 30.0, "rpm": 60.0, "magazine": 1, "reserve": 8, "reserve_max": 16,
			"reload_seconds": 2.4, "deploy_seconds": 0.5, "speed": 40.0, "gravity_scale": 0.3,
			"splash_radius": 5.0, "splash_damage": 150.0, "recoil_pitch": 3.5, "recoil_recovery": 3.5, "recoil_build": 0.0, "max_range": 240.0,
		},
		"ak": {
			"weight": 4.3, "damage": 34.0, "rpm": 600.0, "magazine": 30, "reserve": 120, "reserve_max": 180,
			"reload_seconds": 2.4, "deploy_seconds": 0.4, "spread": 0.55,
			"spread_moving": 2.6, "spread_airborne": 5.0, "spread_crouched": 0.42,
			"bloom": 0.3, "bloom_max": 4.5, "recoil_pitch": 0.55, "recoil_yaw": 0.25,
			"recoil_recovery": 4.5, "recoil_build": 0.07, "max_range": 420.0,
		},
		"scar": {
			"weight": 4.8, "damage": 46.0, "rpm": 420.0, "magazine": 20, "reserve": 80, "reserve_max": 120,
			"reload_seconds": 2.5, "deploy_seconds": 0.5, "spread": 0.3,
			"spread_moving": 2.4, "spread_airborne": 5.0, "spread_crouched": 0.2,
			"bloom": 0.35, "bloom_max": 3.5, "recoil_pitch": 0.8, "recoil_yaw": 0.2,
			"recoil_recovery": 5, "recoil_build": 0.06, "max_range": 600.0,
		},
		"bren": {
			"weight": 3.1, "damage": 26.0, "rpm": 700.0, "magazine": 30, "reserve": 150, "reserve_max": 240,
			"reload_seconds": 2.0, "deploy_seconds": 0.32, "spread": 0.4,
			"spread_moving": 2.0, "spread_airborne": 4.2, "spread_crouched": 0.3,
			"bloom": 0.2, "bloom_max": 3.8, "recoil_pitch": 0.3, "recoil_yaw": 0.12,
			"recoil_recovery": 4.5, "recoil_build": 0.06, "max_range": 380.0,
		},
		"glock": {
			"weight": 0.8, "damage": 20.0, "rpm": 420.0, "magazine": 17, "reserve": 85, "reserve_max": 136,
			"reload_seconds": 1.4, "deploy_seconds": 0.22, "spread": 0.55,
			"spread_moving": 1.8, "spread_airborne": 3.5, "spread_crouched": 0.4,
			"bloom": 0.25, "bloom_max": 2.8, "recoil_pitch": 0.45, "recoil_yaw": 0.16,
			"recoil_recovery": 8, "recoil_build": 0.05, "max_range": 180.0,
		},
		"deagle": {
			"weight": 1.8, "damage": 78.0, "rpm": 130.0, "magazine": 7, "reserve": 28, "reserve_max": 42,
			"reload_seconds": 2.2, "deploy_seconds": 0.35, "spread": 0.35,
			"spread_moving": 2.2, "spread_airborne": 4.2, "spread_crouched": 0.25,
			"bloom": 0.8, "bloom_max": 3.2, "recoil_pitch": 2.8, "recoil_yaw": 0.5,
			"recoil_recovery": 6, "recoil_build": 0.0, "max_range": 280.0,
		},
		"p90": {
			"weight": 2.8, "damage": 19.0, "rpm": 880.0, "magazine": 50, "reserve": 150, "reserve_max": 250,
			"reload_seconds": 2.3, "deploy_seconds": 0.28, "spread": 0.5,
			"spread_moving": 1.8, "spread_airborne": 4.5, "spread_crouched": 0.35,
			"bloom": 0.15, "bloom_max": 3.0, "recoil_pitch": 0.22, "recoil_yaw": 0.1,
			"recoil_recovery": 6, "recoil_build": 0.06, "max_range": 140.0,
		},
		"aa12": {
			"weight": 5.2, "damage": 8.0, "rpm": 300.0, "magazine": 20, "reserve": 40, "reserve_max": 80,
			"reload_seconds": 3.4, "deploy_seconds": 0.6,
			"pellets": 8, "spread": 5.2, "spread_moving": 0.8, "spread_airborne": 1.4,
			"recoil_pitch": 1.5, "recoil_yaw": 0.35, "recoil_recovery": 4.5, "recoil_build": 0.04, "max_range": 26.0,
		},
		"rpg": {
			"weight": 6.4, "damage": 60.0, "rpm": 30.0, "magazine": 1, "reserve": 3, "reserve_max": 6,
			"reload_seconds": 3.6, "deploy_seconds": 0.8, "speed": 55.0, "gravity_scale": 0.08,
			"splash_radius": 7.5, "splash_damage": 320.0, "recoil_pitch": 4.5, "recoil_recovery": 3, "recoil_build": 0.0, "max_range": 300.0,
		},
		"machete": {
			"weight": 0.9, "damage": 62.0, "rpm": 100.0, "reach": 2.1, "arc_degrees": 34.0, "rays": 4,
			"deploy_seconds": 0.2,
		},
		"bat": {
			"weight": 1.1, "damage": 45.0, "rpm": 120.0, "reach": 2.0, "arc_degrees": 40.0, "rays": 4,
			"deploy_seconds": 0.2,
		},
		"crowbar": {
			"weight": 1.0, "damage": 55.0, "rpm": 130.0, "reach": 1.9, "arc_degrees": 30.0, "rays": 3,
			"deploy_seconds": 0.18,
		},
		"axe": {
			"weight": 1.6, "damage": 85.0, "rpm": 75.0, "reach": 2.0, "arc_degrees": 32.0, "rays": 4,
			"deploy_seconds": 0.3,
		},
		"sledge": {
			"weight": 4.5, "damage": 140.0, "rpm": 40.0, "reach": 2.2, "arc_degrees": 44.0, "rays": 5,
			"deploy_seconds": 0.45,
		},
		"hunting": {
			"weight": 4.0, "damage": 95.0, "rpm": 55.0, "magazine": 5, "reserve": 30, "reserve_max": 50,
			"reload_seconds": 3.0, "deploy_seconds": 0.5, "spread": 0.0,
			"spread_moving": 5.0, "spread_airborne": 10.0, "spread_crouched": 0.0,
			"bloom": 0.0, "bloom_max": 0.0, "recoil_pitch": 2.6, "recoil_yaw": 0.3, "recoil_recovery": 3, "recoil_build": 0.0, "max_range": 700.0,
		},
	}


## Defaults, then the `weapon` profiles of every tier, then old-style ymls on top (an old file is
## an operator's own tuning, so it still wins). [param dir] reads that directory as the old-style
## yml; [param roots] replaces the profile config roots (tests); [param layer] is a runtime layer (id -> {path: value}) over the files.
static func load_all(dir: String = "", roots: PackedStringArray = PackedStringArray(), layer: Variant = null) -> Dictionary:
	errors = PackedStringArray()
	var out := defaults()
	var set := profile_set(roots, layer)
	for id in set.list_ids():
		if not out.has(id):
			DotLog.warn(CHANNEL, "unknown weapon profile '%s'; ignored" % id)
			continue
		var res := set.load_profile(id)
		if not res.ok:
			errors.append(res.error.message)
			DotLog.error(CHANNEL, "weapon profile skipped", {"id": id, "why": res.error.message})
			continue
		_overlay(out[id], res.value, id)
	set.clear_cache()
	var loaded := _read_dir(dir if dir != "" else fallback_dir, out)
	for weapon: String in loaded:
		if not out.has(weapon):
			DotLog.warn(CHANNEL, "unknown weapon '%s' in cfg; ignored" % weapon)
			continue
		var row: Variant = loaded[weapon]
		if not row is Dictionary:
			DotLog.warn(CHANNEL, "cfg entry '%s' is not a map; ignored" % weapon)
			continue
		for key: String in row:
			if not (out[weapon] as Dictionary).has(key):
				DotLog.warn(CHANNEL, "unknown key '%s.%s' in cfg; ignored" % [weapon, key])
				continue
			out[weapon][key] = _coerce(out[weapon][key], row[key])
	return out


## The profile set the weapons load from. Call [method DotProfileSet.clear_cache] when done or it leaks.
static func profile_set(roots: PackedStringArray = PackedStringArray(), layer: Variant = null) -> DotProfileSet:
	if roots.is_empty() and pack_cfg_root != "":
		roots = PackedStringArray([pack_cfg_root]) + (base_roots if not base_roots.is_empty() else DotProfileSet.default_roots())
	return DotWeaponProfiles.make_set(ADDON, game, roots, layer)


## Weapon menu entries (id, category, icon, sort) in menu order, from the profiles' `menu:` keys.
static func menu_entries(roots: PackedStringArray = PackedStringArray()) -> Array:
	var set := profile_set(roots)
	var out := DotWeaponProfiles.menu_entries(set)
	set.clear_cache()
	return out


## Weapon [param id] with the upgrades [param ids] applied to its tuned row; value `{values, cost}`.
static func upgraded(id: String, ids: Array, roots: PackedStringArray = PackedStringArray()) -> DotResult:
	var base: Dictionary = load_all("", roots).get(id, {})
	if base.is_empty():
		return DotResult.fail(DotError.CODE_INVALID, "no weapon %s" % id)
	var ups := DotWeaponProfiles.upgrade_set(profile_set(roots), id)
	var res := DotWeaponProfiles.apply_upgrades(base, ups, ids)
	ups.clear_cache()
	return res


## The `view:` block a weapon profile may carry under `extra:` (hold, rot, scale, aim, zoom, scoped, support), layered like every
## other key (addon, game, server, runtime) so the workbench can tune where a gun sits; empty means the pack's own style.
static func view_overrides(id: String, roots: PackedStringArray = PackedStringArray(), layer: Variant = null) -> Dictionary:
	var set := profile_set(roots, layer)
	var out := {}
	if set.has_id(id):
		var res := set.load_profile(id)
		if res.ok and (res.value as DotProfile).extra.get(VIEW_KEY) is Dictionary:
			out = _vectors((res.value as DotProfile).extra[VIEW_KEY])
	set.clear_cache()
	return out


## Lists of three numbers become Vector3 (a yml has no vectors).
static func _vectors(row: Dictionary) -> Dictionary:
	var out := {}
	for k: String in row:
		var v: Variant = row[k]
		out[k] = Vector3(float(v[0]), float(v[1]), float(v[2])) if v is Array and v.size() == 3 else v
	return out


static func _overlay(row: Dictionary, p: DotProfile, id: String) -> void:
	for k in p.values:
		if row.has(k):
			row[k] = _coerce(row[k], p.values[k])
	for k in p.extra:
		if k == VIEW_KEY:
			continue
		if row.has(k):
			row[k] = _coerce(row[k], p.extra[k])
		else:
			DotLog.warn(CHANNEL, "unknown key '%s.%s' in profile; ignored" % [id, k])


## Keeps the default's type, so `magazine: 30.0` stays an int and a string stays rejected.
static func _coerce(default: Variant, given: Variant) -> Variant:
	if default is int and (given is int or given is float):
		return int(given)
	if default is float and (given is int or given is float):
		return float(given)
	DotLog.warn(CHANNEL, "cfg value %s has the wrong type; default kept" % str(given))
	return default


## The merged `{weapon: {key: value}}` of every yml in the directory. Empty on any problem.
static func _read_dir(dir: String, defs: Dictionary) -> Dictionary:
	if dir == "":
		var via := _via_addon_config(defs)
		if via != null:
			return via
		dir = _find_dir()
		if dir == "":
			return {}

	if not DirAccess.dir_exists_absolute(dir):
		return {}

	var files := PackedStringArray()
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".yml") or f.ends_with(".yaml"):
			files.append(f)
	files.sort()

	var merged: Dictionary = {}
	for f in files:
		var res: DotResult = DotYaml.parse_file(dir.path_join(f))
		if not res.ok or not res.value is Dictionary:
			DotLog.warn(CHANNEL, "cannot read %s; skipped" % f)
			continue
		_merge(merged, res.value)
	return merged


static func _merge(into: Dictionary, over: Dictionary) -> void:
	for key in over:
		if into.get(key) is Dictionary and over[key] is Dictionary:
			_merge(into[key], over[key])
		else:
			into[key] = over[key]


## dot-core's DotAddonConfig, when this dot-core has it. Null means "not available".
static func _via_addon_config(defs: Dictionary) -> Variant:
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if entry.get("class", "") != "DotAddonConfig":
			continue
		var script: Variant = load(entry["path"])
		if script == null or not script.has_method("load_dir"):
			return null
		var res: Variant = script.call("load_dir", ADDON, defs)
		if res is DotResult:
			if res.ok and res.value is Dictionary:
				return res.value
			return null
		if res is Dictionary:
			return res
	return null


static func _find_dir() -> String:
	var rel := "cfg/addons/%s" % ADDON
	for base in [
		ProjectSettings.globalize_path("res://"),
		OS.get_executable_path().get_base_dir(),
		OS.get_user_data_dir(),
	]:
		var candidate: String = String(base).path_join(rel)
		if DirAccess.dir_exists_absolute(candidate):
			return candidate
	return ""


## The yml text for [param id]'s defaults: what the shipped `weapon/<id>.yml` contains.
## The common keys sit at the top, the pack's own under `extra:`.
static func to_yaml(id: String) -> String:
	var row: Dictionary = defaults()[id]
	var common := PackedStringArray()
	for f: Dictionary in DotWeaponProfiles.schema():
		common.append(f["name"])
	var top: PackedStringArray = ["# Zee's Modern Weapons: %s. Durations are seconds, rates rounds per minute." % id]
	var extra: PackedStringArray = ["extra:"]
	for k in row:
		var line := "%s: %s" % [k, str(row[k])]
		if common.has(k):
			top.append(line)
		else:
			extra.append("  " + line)
	top.append("menu:")
	top.append("  category: %s" % _category(id))
	top.append("  sort: %d" % IDS.find(id))
	return "\n".join(top + extra) + "\n"


static func _category(id: String) -> String:
	return "melee" if id in ["knife", "machete", "bat", "crowbar", "axe", "sledge"] else ("thrown" if id == "frag" else "ranged")


## Where the shipped yml for [param id] lives under [param root]: the folder form when the
## weapon has a folder (for its upgrades), else the flat file.
static func profile_path(id: String, root: String = "res://cfg") -> String:
	var base := root.path_join("addons").path_join(ADDON).path_join("weapon")
	if DirAccess.dir_exists_absolute(base.path_join(id)):
		return base.path_join(id).path_join("%s.yml" % id)
	return base.path_join("%s.yml" % id)
