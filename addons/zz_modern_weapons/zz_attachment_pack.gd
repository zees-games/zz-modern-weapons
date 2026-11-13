class_name ZzAttachmentPack
extends RefCounted

## The pack's attachments: built-in rows, overlaid by `attachment` profiles
## (`cfg/addons/zz_modern_weapons/attachment/<id>.yml`, see [DotWeaponAttachments]). Which gun takes
## which mount is [constant ZzWeaponPack.MOUNTS]; the models are ours, under assets/attachments/.

const CHANNEL := "zz.attachments"
const MODEL_DIR := "res://addons/zz_modern_weapons/assets/attachments"


## One flat profile per attachment id, in the profile schema's field names. Numbers scale the gun's own.
static func defaults() -> Dictionary:
	return {
		ZzWeaponIds.ATT_RED_DOT: {
			"name": "Red Dot", "description": "A clear sight picture: a little tighter when aimed.",
			"mount": "optic", "model": _model("red_dot"),
			"scale": {"spread": 0.9},
		},
		ZzWeaponIds.ATT_SCOPE: {
			"name": "4x Scope", "description": "Four times magnification; slower to bring up close.",
			"mount": "optic", "model": _model("scope_4x"), "tags_added": "scoped",
			"scale": {"spread": 0.85},
			"params": {"optic_zoom": 0.25},
		},
		ZzWeaponIds.ATT_SUPPRESSOR: {
			"name": "Suppressor", "description": "Quiet and nearly flashless; a little less reach.",
			"mount": "muzzle", "model": _model("suppressor"), "tags_added": "suppressed",
			"scale": {"recoil_pitch": 0.9, "max_range": 0.9},
			"params": {"suppressed": true},
		},
		ZzWeaponIds.ATT_EXTENDED_MAG: {
			"name": "Extended Magazine", "description": "Half again as many rounds; a slower reload.",
			"mount": "magazine", "model": _model("extended_mag"),
			"scale": {"magazine": 1.5, "reload_ticks": 1.1},
		},
		ZzWeaponIds.ATT_GRIP: {
			"name": "Vertical Grip", "description": "Less climb and less side kick.",
			"mount": "underbarrel", "model": _model("grip"),
			"scale": {"recoil_pitch": 0.85, "recoil_yaw": 0.8},
		},
		ZzWeaponIds.ATT_LASER: {
			"name": "Laser", "description": "Tighter from the hip on the move.",
			"mount": "side", "model": _model("laser"),
			"scale": {"spread_moving": 0.8},
		},
	}


static func _model(short: String) -> String:
	return MODEL_DIR.path_join("zz_%s.tscn" % short)


## The `attachment` profile set over [member ZzWeaponConfig.pack_cfg_root] and the default roots, like the weapons'.
static func profile_set(roots: PackedStringArray = PackedStringArray()) -> DotProfileSet:
	if roots.is_empty() and ZzWeaponConfig.pack_cfg_root != "":
		roots = PackedStringArray([ZzWeaponConfig.pack_cfg_root]) + (ZzWeaponConfig.base_roots if not ZzWeaponConfig.base_roots.is_empty() else DotProfileSet.default_roots())
	return DotWeaponAttachments.make_set(ZzWeaponConfig.ADDON, ZzWeaponConfig.game, roots)


## The built-in rows alone, with no files read.
static func builtin() -> DotWeaponAttachments:
	var out := DotWeaponAttachments.new()
	var rows := defaults()
	for id: StringName in rows:
		out.add(DotWeaponAttachment.from_flat(id, rows[id]))
	return out


## The catalogue a game hands its arsenal: the profiles when they load, else the built-in rows (a broken file never fails a boot).
static func catalogue(roots: PackedStringArray = PackedStringArray()) -> DotWeaponAttachments:
	var set := profile_set(roots)
	if set.list_ids().is_empty():
		return builtin()
	var out := DotWeaponAttachments.new()
	var res := out.load_set(set)
	set.clear_cache()
	if not res.ok:
		DotLog.error(CHANNEL, "attachment profiles skipped; using the built-in rows", {"why": res.error.message})
		return builtin()
	return out


## The shipped yml for [param id]: the built-in row in profile form; the suite fails when a file drifts.
static func to_yaml(id: StringName) -> String:
	var row: Dictionary = defaults()[id]
	var lines: PackedStringArray = ["# Zombie Zone attachment: %s. Scales multiply the gun's own numbers." % String(id)]
	for key: String in row:
		var v: Variant = row[key]
		if v is Dictionary:
			lines.append("%s:" % key)
			for k: String in v:
				lines.append("  %s: %s" % [k, _yaml_value(v[k])])
		else:
			lines.append("%s: %s" % [key, _yaml_value(v)])
	return "\n".join(lines) + "\n"


static func _yaml_value(v: Variant) -> String:
	if v is String:
		return "\"%s\"" % v
	if v is bool:
		return "true" if v else "false"
	return str(v)


static func profile_path(id: StringName, root: String = "res://cfg") -> String:
	return root.path_join("addons").path_join(ZzWeaponConfig.ADDON).path_join(DotWeaponAttachments.KIND).path_join("%s.yml" % String(id))
