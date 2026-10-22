class_name ZzWeaponArt
extends RefCounted

## The one file with a filename in it. Weapons are named by id; a model is `assets/<id>.glb`
## once it exists, and until then a clearly-marked PLACEHOLDER built from boxes and cylinders.
##
## [b]Why placeholders.[/b] The brief is a CC0 or CC-BY Sketchfab model per weapon. Sketchfab's
## download endpoint needs an account token and none was available to the agent that built
## this, so no model was downloaded and none was invented: CREDITS.md lists the candidate
## models found by search (uid, author, licence), and each weapon below has
## [code]"model": ""[/code] until its glb lands. Everything else (scale, muzzle, grip) is
## already the contract the real model must meet: origin at the grip, the muzzle toward -Z,
## length in metres.

const CHANNEL := "zz.art"
const ASSET_DIR := "res://assets"

## length: metres, muzzle: the bore end along -Z measured from the grip, model: a glb under
## [constant ASSET_DIR] (empty while it is a placeholder). parts: [size, offset, shape, tint]
## (shape b = box, c = cylinder along Z).
const TABLE := {
	&"zz_m4": {
		"model": "", "length": 0.84, "muzzle": 0.50,
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
		"model": "", "length": 1.20, "muzzle": 0.75,
		"parts": [
			[Vector3(0.05, 0.08, 0.50), Vector3(0, 0.02, -0.02), "b", 0],
			[Vector3(0.022, 0.022, 0.55), Vector3(0, 0.03, -0.48), "c", 0],
			[Vector3(0.04, 0.04, 0.26), Vector3(0, 0.10, -0.05), "c", 1],
			[Vector3(0.05, 0.12, 0.30), Vector3(0, -0.02, 0.38), "b", 1],
			[Vector3(0.04, 0.10, 0.05), Vector3(0, -0.09, 0.07), "b", 1],
		],
	},
	&"zz_knife": {
		"model": "", "length": 0.30, "muzzle": 0.0,
		"parts": [
			[Vector3(0.025, 0.11, 0.025), Vector3(0, -0.03, 0), "b", 1],
			[Vector3(0.008, 0.17, 0.03), Vector3(0, 0.115, 0), "b", 2],
		],
	},
	&"zz_pistol": {
		"model": "", "length": 0.20, "muzzle": 0.12,
		"parts": [
			[Vector3(0.03, 0.035, 0.19), Vector3(0, 0.04, -0.03), "b", 0],
			[Vector3(0.032, 0.11, 0.04), Vector3(0, -0.04, 0.025), "b", 1],
		],
	},
	&"zz_shotgun": {
		"model": "", "length": 1.0, "muzzle": 0.60,
		"parts": [
			[Vector3(0.035, 0.035, 0.62), Vector3(0, 0.04, -0.28), "c", 0],
			[Vector3(0.04, 0.035, 0.30), Vector3(0, 0.0, -0.20), "c", 1],
			[Vector3(0.05, 0.08, 0.24), Vector3(0, 0.02, 0.10), "b", 0],
			[Vector3(0.05, 0.12, 0.26), Vector3(0, -0.02, 0.34), "b", 1],
		],
	},
	&"zz_smg": {
		"model": "", "length": 0.55, "muzzle": 0.30,
		"parts": [
			[Vector3(0.045, 0.08, 0.30), Vector3(0, 0.02, -0.02), "b", 0],
			[Vector3(0.02, 0.02, 0.14), Vector3(0, 0.03, -0.24), "c", 0],
			[Vector3(0.04, 0.16, 0.04), Vector3(0, -0.12, -0.04), "b", 1],
			[Vector3(0.04, 0.10, 0.04), Vector3(0, -0.08, 0.08), "b", 1],
		],
	},
	&"zz_frag": {
		"model": "", "length": 0.10, "muzzle": 0.0,
		"parts": [
			[Vector3(0.058, 0.075, 0.058), Vector3(0, 0, 0), "c", 3],
			[Vector3(0.02, 0.02, 0.02), Vector3(0, 0.05, 0), "b", 0],
		],
	},
}

const TINTS: Array[Color] = [
	Color(0.18, 0.19, 0.20), Color(0.30, 0.27, 0.22), Color(0.62, 0.64, 0.67), Color(0.25, 0.32, 0.20),
]


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
