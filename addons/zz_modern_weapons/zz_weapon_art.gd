class_name ZzWeaponArt
extends RefCounted

## The one file with a filename in it: a model is `addons/zz_modern_weapons/assets/<id>.glb`, else a labelled
## PLACEHOLDER of boxes and cylinders. A model's contract: origin at the grip, muzzle toward -Z, length in metres.
## CREDITS.md lists the candidate models for the rest.

const CHANNEL := "zz.art"
const ASSET_DIR := "res://addons/zz_modern_weapons/assets"

## length: metres, muzzle: the bore end along -Z measured from the grip, model: a glb under
## [constant ASSET_DIR] (empty while it is a placeholder). parts: [size, offset, shape, tint]
## (shape b = box, c = cylinder along Z).
const TABLE := {
	&"zz_m4": {
		"model": "zz_m4.glb", "style": "rifle", "length": 0.84, "muzzle": 0.50,
		"parts": [
			[Vector3(0.05, 0.09, 0.30), Vector3(0, 0.02, -0.02), "b", 0],
			[Vector3(0.025, 0.025, 0.36), Vector3(0, 0.03, -0.33), "c", 0],
			[Vector3(0.05, 0.14, 0.05), Vector3(0, -0.10, -0.06), "b", 1],
			[Vector3(0.045, 0.10, 0.04), Vector3(0, -0.09, 0.07), "b", 1],
			[Vector3(0.05, 0.10, 0.22), Vector3(0, 0.0, 0.30), "b", 1],
			[Vector3(0.03, 0.04, 0.12), Vector3(0, 0.09, -0.04), "b", 0],
		],
	},
	&"zz_sniper": {
		"model": "zz_sniper.glb", "style": "sniper", "length": 1.20, "muzzle": 0.75,
		"parts": [
			[Vector3(0.05, 0.08, 0.50), Vector3(0, 0.02, -0.02), "b", 0],
			[Vector3(0.022, 0.022, 0.55), Vector3(0, 0.03, -0.48), "c", 0],
			[Vector3(0.04, 0.04, 0.26), Vector3(0, 0.10, -0.05), "c", 1],
			[Vector3(0.05, 0.12, 0.30), Vector3(0, -0.02, 0.38), "b", 1],
			[Vector3(0.04, 0.10, 0.05), Vector3(0, -0.09, 0.07), "b", 1],
		],
	},
	&"zz_vss": {
		"suppressed": true, "model": "zz_vss.glb", "style": "rifle", "length": 0.95, "muzzle": 0.57,
		"view": {"aim": Vector3(-0.025, -0.115, -0.30)},
		"parts": [
			[Vector3(0.05, 0.08, 0.50), Vector3(0, 0.02, -0.02), "b", 0],
			[Vector3(0.03, 0.03, 0.55), Vector3(0, 0.03, -0.30), "c", 0],
			[Vector3(0.05, 0.12, 0.30), Vector3(0, -0.02, 0.30), "b", 1],
		],
	},
	&"zz_knife": {
		"model": "zz_knife.glb", "style": "melee", "length": 0.30, "muzzle": 0.0,
		"parts": [
			[Vector3(0.025, 0.11, 0.025), Vector3(0, -0.03, 0), "b", 1],
			[Vector3(0.008, 0.17, 0.03), Vector3(0, 0.115, 0), "b", 2],
		],
	},
	&"zz_pistol": {
		"model": "zz_pistol.glb", "style": "pistol", "length": 0.20, "muzzle": 0.165,
		"parts": [
			[Vector3(0.03, 0.035, 0.19), Vector3(0, 0.04, -0.03), "b", 0],
			[Vector3(0.032, 0.11, 0.04), Vector3(0, -0.04, 0.025), "b", 1],
		],
	},
	&"zz_shotgun": {
		"model": "zz_shotgun.glb", "style": "rifle", "length": 1.05, "muzzle": 0.68,
		"parts": [
			[Vector3(0.035, 0.035, 0.62), Vector3(0, 0.04, -0.28), "c", 0],
			[Vector3(0.04, 0.035, 0.30), Vector3(0, 0.0, -0.20), "c", 1],
			[Vector3(0.05, 0.08, 0.24), Vector3(0, 0.02, 0.10), "b", 0],
			[Vector3(0.05, 0.12, 0.26), Vector3(0, -0.02, 0.34), "b", 1],
		],
	},
	&"zz_smg": {
		"model": "zz_smg.glb", "style": "smg", "length": 0.62, "muzzle": 0.45,
		"parts": [
			[Vector3(0.045, 0.08, 0.30), Vector3(0, 0.02, -0.02), "b", 0],
			[Vector3(0.02, 0.02, 0.14), Vector3(0, 0.03, -0.24), "c", 0],
			[Vector3(0.04, 0.16, 0.04), Vector3(0, -0.12, -0.04), "b", 1],
			[Vector3(0.04, 0.10, 0.04), Vector3(0, -0.08, 0.08), "b", 1],
		],
	},
	&"zz_frag": {
		"model": "zz_frag.glb", "style": "throw", "length": 0.11, "muzzle": 0.0,
		"parts": [
			[Vector3(0.058, 0.075, 0.058), Vector3(0, 0, 0), "c", 3],
			[Vector3(0.02, 0.02, 0.02), Vector3(0, 0.05, 0), "b", 0],
		],
	},
	&"zz_revolver": {
		"model": "zz_revolver.glb", "style": "pistol", "length": 0.28, "muzzle": 0.24,
		"view": {"hold": Vector3(0.14, -0.15, -0.34)},
		"parts": [[Vector3(0.03, 0.04, 0.26), Vector3(0, 0.04, -0.08), "b", 2]],
	},
	&"zz_mp5": {
		"model": "zz_mp5.glb", "style": "smg", "length": 0.66, "muzzle": 0.34,
		"parts": [[Vector3(0.045, 0.08, 0.5), Vector3(0, 0.02, -0.1), "b", 0]],
	},
	&"zz_spas": {
		"model": "zz_spas.glb", "style": "rifle", "length": 1.0, "muzzle": 0.90,
		"view": {"hold": Vector3(0.15, -0.16, -0.42)},
		"parts": [[Vector3(0.05, 0.08, 0.9), Vector3(0, 0.02, -0.4), "b", 0]],
	},
	&"zz_lmg": {
		"model": "zz_lmg.glb", "style": "rifle", "length": 1.0, "muzzle": 0.68,
		"view": {"hold": Vector3(0.18, -0.20, -0.55), "aim": Vector3(0.0, -0.15, -0.34), "support": -0.35, "kick": 2.8, "back": 0.045},
		"parts": [[Vector3(0.06, 0.1, 0.9), Vector3(0, 0.02, -0.3), "b", 0]],
	},
	&"zz_dmr": {
		"model": "zz_dmr.glb", "style": "rifle", "length": 1.12, "muzzle": 0.77,
		"view": {"hold": Vector3(0.17, -0.17, -0.5), "kick": 3.2, "back": 0.05, "zoom": 0.6},
		"parts": [[Vector3(0.05, 0.1, 1.0), Vector3(0, 0.02, -0.2), "b", 1]],
	},
	&"zz_m79": {
		"model": "zz_m79.glb", "style": "rifle", "length": 0.78, "muzzle": 0.40,
		"view": {"hold": Vector3(0.20, -0.12, -0.46), "support": -0.52, "kick": 4.0, "back": 0.06},
		"parts": [[Vector3(0.07, 0.09, 0.7), Vector3(0, 0.02, -0.2), "b", 0]],
	},
	&"zz_ak": {
		"model": "zz_ak.glb", "style": "rifle", "length": 0.88, "muzzle": 0.53,
		"view": {"hold": Vector3(0.17, -0.17, -0.50)},
		"parts": [[Vector3(0.05, 0.09, 0.8), Vector3(0, 0.02, -0.2), "b", 0]],
	},
	&"zz_scar": {
		"model": "zz_scar.glb", "style": "rifle", "length": 0.96, "muzzle": 0.56,
		"view": {"hold": Vector3(0.17, -0.17, -0.52), "kick": 2.8, "back": 0.04},
		"parts": [[Vector3(0.05, 0.09, 0.9), Vector3(0, 0.02, -0.2), "b", 0]],
	},
	&"zz_bren": {
		"model": "zz_bren.glb", "style": "rifle", "length": 0.80, "muzzle": 0.46,
		"view": {"hold": Vector3(0.16, -0.16, -0.46)},
		"parts": [[Vector3(0.05, 0.09, 0.7), Vector3(0, 0.02, -0.15), "b", 0]],
	},
	&"zz_glock": {
		"model": "zz_glock.glb", "style": "pistol", "length": 0.19, "muzzle": 0.133,
		"parts": [[Vector3(0.03, 0.035, 0.18), Vector3(0, 0.04, -0.03), "b", 0]],
	},
	&"zz_deagle": {
		"model": "zz_deagle.glb", "style": "pistol", "length": 0.27, "muzzle": 0.189,
		"view": {"kick": 5.0, "back": 0.04},
		"parts": [[Vector3(0.035, 0.05, 0.26), Vector3(0, 0.04, -0.06), "b", 2]],
	},
	&"zz_p90": {
		"model": "zz_p90.glb", "style": "smg", "length": 0.50, "muzzle": 0.25,
		"parts": [[Vector3(0.05, 0.1, 0.45), Vector3(0, 0.02, -0.0), "b", 0]],
	},
	&"zz_aa12": {
		"model": "zz_aa12.glb", "style": "rifle", "length": 0.95, "muzzle": 0.589,
		"view": {"hold": Vector3(0.17, -0.18, -0.52), "kick": 2.4, "back": 0.05},
		"parts": [[Vector3(0.06, 0.1, 0.9), Vector3(0, 0.02, -0.2), "b", 0]],
	},
	&"zz_rpg": {
		"model": "zz_rpg.glb", "style": "rifle", "length": 0.95, "muzzle": 0.52,
		"view": {"hold": Vector3(0.17, -0.20, -0.55), "support": -0.30, "kick": 4.5, "back": 0.06},
		"parts": [[Vector3(0.09, 0.09, 0.9), Vector3(0, 0.02, -0.1), "c", 0]],
	},
	&"zz_machete": {
		"model": "zz_machete.glb", "style": "melee", "length": 0.75, "muzzle": 0.0,
		"view": {"hold": Vector3(0.22, -0.36, -0.46)},
		"parts": [
			[Vector3(0.03, 0.15, 0.03), Vector3(0, -0.05, 0), "b", 1],
			[Vector3(0.01, 0.55, 0.05), Vector3(0, 0.3, 0), "b", 2],
		],
	},
	&"zz_bat": {
		"model": "zz_bat.glb", "style": "melee", "length": 0.91, "muzzle": 0.0,
		"view": {"hold": Vector3(0.22, -0.36, -0.46)},
		"parts": [[Vector3(0.06, 0.8, 0.06), Vector3(0, 0.3, 0), "b", 1]],
	},
	&"zz_crowbar": {
		"model": "zz_crowbar.glb", "style": "melee", "length": 0.56, "muzzle": 0.0,
		"view": {"hold": Vector3(0.22, -0.36, -0.46)},
		"parts": [[Vector3(0.03, 0.5, 0.03), Vector3(0, 0.12, 0), "c", 1]],
	},
	&"zz_axe": {
		"model": "zz_axe.glb", "style": "melee", "length": 0.70, "muzzle": 0.0,
		"view": {"hold": Vector3(0.22, -0.36, -0.46)},
		"parts": [
			[Vector3(0.04, 0.55, 0.04), Vector3(0, 0.15, 0), "b", 1],
			[Vector3(0.03, 0.14, 0.18), Vector3(0, 0.5, 0.1), "c", 2],
		],
	},
	&"zz_sledge": {
		"model": "zz_sledge.glb", "style": "melee", "length": 1.0, "muzzle": 0.0,
		"view": {"hold": Vector3(0.24, -0.40, -0.50)},
		"parts": [
			[Vector3(0.04, 0.8, 0.04), Vector3(0, 0.1, 0), "b", 1],
			[Vector3(0.1, 0.1, 0.2), Vector3(0, 0.62, 0), "c", 2],
		],
	},
	&"zz_hunting": {
		"model": "zz_hunting.glb", "style": "sniper", "length": 1.23, "muzzle": 0.83,
		"view": {"hold": Vector3(0.17, -0.17, -0.46), "kick": 3.4, "back": 0.05, "zoom": 0.5},
		"parts": [[Vector3(0.05, 0.1, 1.0), Vector3(0, 0.02, -0.3), "b", 0]],
	},
}

## View-model placement per [code]style[/code], in the weapon's frame (grip origin, -Z forward, metres, degrees): hold, aim,
## support (off hand along the barrel), kick (deg per shot), back (m), zoom (fov scale at full aim), reload (seconds floor).
## A real model changes TABLE's row and at most one entry here.
const STYLES := {
	"rifle": {"hold": Vector3(0.16, -0.16, -0.38), "aim": Vector3(0.0, -0.13, -0.30), "support": -0.30, "kick": 2.2, "back": 0.035, "zoom": 0.8, "rot": Vector3(0, 10, 30), "scale": 0.8},
	"smg": {"hold": Vector3(0.15, -0.15, -0.34), "aim": Vector3(0.0, -0.12, -0.28), "support": -0.20, "kick": 1.6, "back": 0.025, "zoom": 0.85, "rot": Vector3(0, 10, 28), "scale": 0.85},
	"sniper": {"hold": Vector3(0.17, -0.17, -0.42), "aim": Vector3(0.0, -0.14, -0.34), "support": -0.40, "kick": 5.0, "back": 0.08, "zoom": 0.3, "scoped": true, "rot": Vector3(0, 8, 24), "scale": 0.7},
	"pistol": {"hold": Vector3(0.14, -0.13, -0.32), "aim": Vector3(0.0, -0.10, -0.26), "support": 0.0, "kick": 3.5, "back": 0.03, "zoom": 0.9, "rot": Vector3(0, 8, 22), "scale": 1.0},
	"melee": {"hold": Vector3(0.20, -0.20, -0.36), "aim": Vector3(0.20, -0.20, -0.36), "support": 0.0, "kick": 0.0, "back": 0.0, "zoom": 1.0},
	"throw": {"hold": Vector3(0.20, -0.20, -0.36), "aim": Vector3(0.20, -0.20, -0.36), "support": 0.0, "kick": 0.0, "back": 0.0, "zoom": 1.0},
}

## Metres from the camera to the sight when aimed, and from a window's top to its middle.
const SIGHT_RELIEF := 0.32
const SIGHT_DROP := 0.025

const TINTS: Array[Color] = [
	Color(0.18, 0.19, 0.20), Color(0.30, 0.27, 0.22), Color(0.62, 0.64, 0.67), Color(0.25, 0.32, 0.20),
]


## Where a gun's flash is not what its style says (the style only places the model in the hand).
const FLASH_CATEGORY := {
	&"zz_shotgun": "shotgun", &"zz_spas": "shotgun", &"zz_aa12": "shotgun", &"zz_m79": "shotgun", &"zz_rpg": "shotgun",
	&"zz_revolver": "magnum", &"zz_deagle": "magnum", &"zz_lmg": "lmg", &"zz_bren": "lmg", &"zz_dmr": "dmr",
}


## The dot-fx muzzle category (`DotMuzzleFlash.size_for`) for a weapon.
static func flash_category(id: StringName) -> String:
	if FLASH_CATEGORY.has(id):
		return FLASH_CATEGORY[id]
	return String(TABLE[id].get("style", "rifle")) if TABLE.has(id) else "rifle"


## A suppressed gun: its flash is small and dim.
static func is_suppressed(id: StringName) -> bool:
	return bool(TABLE[id].get("suppressed", false)) if TABLE.has(id) else false


## Where a spent case leaves, in the model's frame: the right of the receiver, a third of the way back from the muzzle.
static func ejection_point(id: StringName) -> Vector3:
	var tip := muzzle_point(id)
	return Vector3(0.025, tip.y + 0.01, tip.z * 0.35)


## Whether the gun throws a case (not a launcher, not a revolver, which keeps its brass).
static func ejects(id: StringName) -> bool:
	return TABLE.has(id) and motion_of(id) == &"gun" and not String(id).ends_with(("m79")) and not String(id).ends_with("rpg") and not String(id).ends_with("revolver")


static func is_placeholder(id: StringName) -> bool:
	return String(TABLE[id]["model"]) == ""


## The weapon's model, origin at the grip, muzzle toward -Z. Null (with a log line) for an
## unknown id, because there is nothing honest to draw.
static func instantiate(id: StringName) -> Node3D:
	if not TABLE.has(id):
		DotLog.warn(CHANNEL, "no art entry for '%s'" % String(id))
		return null
	var entry: Dictionary = TABLE[id]
	if not is_placeholder(id):
		var path := ASSET_DIR.path_join(String(entry["model"]))
		var packed := load(path) as PackedScene
		if packed != null:
			return packed.instantiate() as Node3D
		DotLog.warn(CHANNEL, "model %s will not load; drawing the placeholder" % path)
	return _placeholder(id)


## Distance from the grip to the bore, metres. For effects only, never a shot's origin.
static func muzzle_distance(id: StringName) -> float:
	return float(TABLE[id]["muzzle"]) if TABLE.has(id) else 0.0


## Where the bore ends, in the model's frame: the middle of the vertices within [constant TIP_DEPTH] of
## the frontmost one (the barrel, a brake or a suppressor, whichever sticks out). Measured so a flash,
## tracer and smoke start at the real tip of every model; the table's `muzzle` is only the fallback.
static func muzzle_point(id: StringName) -> Vector3:
	if _tips.has(id):
		return _tips[id]
	var tip := Vector3(0.0, 0.03, -muzzle_distance(id))
	var node := instantiate(id) if TABLE.has(id) and not is_placeholder(id) else null
	if node != null:
		var verts := PackedVector3Array()
		_collect(node, Transform3D.IDENTITY, verts)
		node.free()
		var front := INF
		for v in verts:
			front = minf(front, v.z)
		if front < 0.0:
			var lo := Vector3(INF, INF, front)
			var hi := Vector3(-INF, -INF, front)
			for v in verts:
				if v.z <= front + TIP_DEPTH:
					lo = Vector3(minf(lo.x, v.x), minf(lo.y, v.y), front)
					hi = Vector3(maxf(hi.x, v.x), maxf(hi.y, v.y), front)
			tip = Vector3((lo.x + hi.x) * 0.5, (lo.y + hi.y) * 0.5, front)
	_tips[id] = tip
	return tip


## The view numbers for a weapon (a copy: a caller edits its own). A TABLE row may override any
## key of its style with a [code]"view"[/code] dictionary.
static func view_profile(id: StringName) -> Dictionary:
	if not TABLE.has(id):
		return (STYLES["rifle"] as Dictionary).duplicate()
	var row: Dictionary = TABLE[id]
	var out: Dictionary = (STYLES.get(String(row.get("style", "rifle")), STYLES["rifle"]) as Dictionary).duplicate()
	if motion_of(id) == &"gun" and not is_placeholder(id):
		out["aim"] = _aim_cache(id)
	out.merge(row.get("view", {}) as Dictionary, true)
	return out


static var _aims: Dictionary = {}
static var _tips: Dictionary = {}
const TIP_DEPTH := 0.012


static func _aim_cache(id: StringName) -> Vector3:
	if not _aims.has(id):
		_aims[id] = aim_for(id)
	return _aims[id]


## "gun", "melee" or "throw": which motions the weapon has (kick and reload, swing, or lob).
static func motion_of(id: StringName) -> StringName:
	var style := String(TABLE[id].get("style", "rifle")) if TABLE.has(id) else "rifle"
	return &"melee" if style == "melee" else (&"throw" if style == "throw" else &"gun")


## Where the sight line crosses the model: the highest vertex behind the front half of the barrel, lowered by
## [constant SIGHT_DROP] to the window's middle. Measured, never typed; the table's `view.aim` is this plus
## [constant SIGHT_RELIEF] (tools/measure_sights.gd).
static func sight_point(id: StringName) -> Vector3:
	var node := instantiate(id)
	if node == null:
		return Vector3.ZERO
	var verts := PackedVector3Array()
	_collect(node, Transform3D.IDENTITY, verts)
	node.free()
	var front := -float(TABLE[id]["muzzle"]) * 0.5
	var best := Vector3(0.0, -INF, 0.0)
	for v in verts:
		if v.z >= front and v.y > best.y:
			best = v
	return Vector3(best.x, best.y - SIGHT_DROP, best.z)


## The aim offset that puts [method sight_point] on the camera's axis, [constant SIGHT_RELIEF] ahead of it.
static func aim_for(id: StringName) -> Vector3:
	var s := sight_point(id)
	return Vector3(-s.x, -s.y, -SIGHT_RELIEF - s.z)


static func _collect(n: Node, parent: Transform3D, out: PackedVector3Array) -> void:
	var t := parent
	if n is Node3D:
		t = parent * (n as Node3D).transform
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
		var mesh := (n as MeshInstance3D).mesh
		for surface in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surface)
			for v: Vector3 in (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array):
				out.append(t * v)
	for c in n.get_children():
		_collect(c, t, out)


static func _placeholder(id: StringName) -> Node3D:
	var root := Node3D.new()
	root.name = "Placeholder_%s" % ZzWeaponIds.short_name(id)
	var n := 0
	for part: Array in TABLE[id]["parts"]:
		var mi := MeshInstance3D.new()
		mi.name = "Part%d" % n
		n += 1
		var s: Vector3 = part[0]
		if part[2] == "c":
			var cyl := CylinderMesh.new()
			cyl.top_radius = s.x * 0.5
			cyl.bottom_radius = s.x * 0.5
			# A CylinderMesh stands on Y; a barrel lies on Z, so turn it. The grenade stands.
			cyl.height = s.y if id == ZzWeaponIds.FRAG else s.z
			mi.mesh = cyl
			if id != ZzWeaponIds.FRAG:
				mi.rotation_degrees = Vector3(90, 0, 0)
		else:
			var box := BoxMesh.new()
			box.size = s
			mi.mesh = box
		mi.position = part[1]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = TINTS[int(part[3])]
		mat.roughness = 0.6
		mi.material_override = mat
		root.add_child(mi)
	return root
