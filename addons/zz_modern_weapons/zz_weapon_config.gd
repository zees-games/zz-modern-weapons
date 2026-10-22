class_name ZzWeaponConfig
extends RefCounted

## Every tunable number of every weapon, with the built-in defaults, overlaid by the server
## owner's `cfg/addons/zz_modern_weapons/*.yml` (every file in the directory is read, in name
## order, a later file winning).
##
## [b]File shape.[/b] A top-level key per weapon (m4, sniper, knife, pistol, shotgun, smg,
## frag), each a map of the keys in [method defaults]. A key not listed keeps its default; a
## key this pack does not know is logged and ignored, so a typo is visible rather than silent.
##
## [b]Reading goes through dot-core's DotAddonConfig when it exists[/b], by global class
## name and reflection, so the pack still parses and runs on a dot-core that predates it.
## Otherwise this file reads the directory itself with DotYaml. Either way a missing or
## broken file means the defaults, never a failed boot.

const CHANNEL := "zz.config"
const ADDON := "zz_modern_weapons"

## Seconds are used for human-facing times; the pack converts to ticks.
static func defaults() -> Dictionary:
	return {
		"m4": {
			"damage": 29.0, "rpm": 800.0, "magazine": 30, "reserve": 150, "reserve_max": 240,
			"reload_seconds": 2.1, "deploy_seconds": 0.35, "spread": 0.45,
			"spread_moving": 2.2, "spread_airborne": 4.5, "spread_crouched": 0.35,
			"bloom": 0.2, "bloom_max": 4.0, "recoil_pitch": 0.32, "recoil_yaw": 0.14,
			"max_range": 400.0,
		},
		"sniper": {
			"damage": 125.0, "rpm": 45.0, "magazine": 5, "reserve": 20, "reserve_max": 40,
			"reload_seconds": 3.4, "deploy_seconds": 0.75, "spread": 0.0,
			"spread_moving": 9.0, "spread_airborne": 15.0, "spread_crouched": 0.0,
			"bloom": 0.0, "bloom_max": 0.0, "recoil_pitch": 4.2, "recoil_yaw": 0.4,
			"max_range": 1000.0,
		},
		"knife": {
			"damage": 50.0, "rpm": 140.0, "reach": 1.9, "arc_degrees": 26.0, "rays": 3,
			"deploy_seconds": 0.15,
		},
		"pistol": {
			"damage": 24.0, "rpm": 330.0, "magazine": 15, "reserve": 75, "reserve_max": 120,
			"reload_seconds": 1.5, "deploy_seconds": 0.25, "spread": 0.5,
			"spread_moving": 1.8, "spread_airborne": 3.5, "spread_crouched": 0.4,
			"bloom": 0.35, "bloom_max": 3.0, "recoil_pitch": 0.9, "recoil_yaw": 0.2,
			"max_range": 200.0,
		},
		"shotgun": {
			"damage": 12.0, "rpm": 70.0, "magazine": 8, "reserve": 32, "reserve_max": 64,
			"reload_seconds": 0.45, "reload_start_seconds": 0.3, "deploy_seconds": 0.4,
			"pellets": 9, "spread": 4.2, "spread_moving": 0.5, "spread_airborne": 1.0,
			"recoil_pitch": 2.6, "recoil_yaw": 0.3, "max_range": 30.0,
		},
		"smg": {
			"damage": 18.0, "rpm": 900.0, "magazine": 32, "reserve": 160, "reserve_max": 256,
			"reload_seconds": 1.8, "deploy_seconds": 0.26, "spread": 0.7,
			"spread_moving": 2.4, "spread_airborne": 5.0, "spread_crouched": 0.6,
			"bloom": 0.26, "bloom_max": 4.5, "recoil_pitch": 0.26, "recoil_yaw": 0.14,
			"max_range": 120.0,
		},
		"frag": {
			"fuse_seconds": 3.0, "splash_radius": 5.5, "splash_damage": 120.0,
			"speed": 19.0, "gravity_scale": 1.0, "reserve": 2, "reserve_max": 4,
		},
	}


## The defaults with the cfg directory laid over them. [param dir] overrides where to look
## (a test's own directory); empty means the standard location.
static func load_all(dir: String = "") -> Dictionary:
	var out := defaults()
	var loaded := _read_dir(dir)

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


## Keeps the default's type, so `magazine: 30.0` stays an int and a string stays rejected.
static func _coerce(default: Variant, given: Variant) -> Variant:
	if default is int and (given is int or given is float):
		return int(given)
	if default is float and (given is int or given is float):
		return float(given)
	DotLog.warn(CHANNEL, "cfg value %s has the wrong type; default kept" % str(given))
	return default


## The merged `{weapon: {key: value}}` of every yml in the directory. Empty on any problem.
static func _read_dir(dir: String) -> Dictionary:
	if dir == "":
		var via := _via_addon_config()
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
static func _via_addon_config() -> Variant:
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if entry.get("class", "") != "DotAddonConfig":
			continue
		var script: Variant = load(entry["path"])
		if script == null or not script.has_method("load_dir"):
			return null
		var res: Variant = script.call("load_dir", ADDON, defaults())
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
