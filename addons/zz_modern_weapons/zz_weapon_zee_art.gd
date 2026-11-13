class_name ZzWeaponZeeArt
extends RefCounted

## The pack's own art as zee-dot-weapons' `ZeeWeaponArt` resources, for a host (game-zombie-zone) that draws its weapons with
## zee's rig: [method build] backs `ZzSpawnProvider.weapon_art()`. This pack may not require zee, so no zee class is named
## here: each is looked up by its global name when called, and without zee the answer is empty (the pack draws itself with
## [ZzViewModel] / [ZzWorldModel] and needs none of it). The model, muzzle, third-person size and hold come from
## [method ZzSpawnProvider.art_rows]; zee's table only lends the arm pose and the reload keys of a similar weapon.

## Weapon ids that carry a heavy launcher's pose; every other gun is picked by its art style.
const LAUNCHERS: Array[StringName] = [&"zz_m79", &"zz_rpg"]

## style -> the zee table factory whose pose and reload the weapon borrows.
const BASE_BY_STYLE := {
	"pistol": &"pistol", "smg": &"smg", "rifle": &"rifle", "sniper": &"marksman", "melee": &"knife", "throw": &"frag",
}


## One art per weapon id ([param dressed] false leaves zee's own gun under the id, which is what a bare stand-in shows), typed `Array[ZeeWeaponArt]` (zee's art source is typed), or an empty untyped array without zee.
static func build(dressed: bool = true) -> Array:
	var art_script := _global_script(&"ZeeWeaponArt")
	var table := _global_script(&"ZeeWeaponArtTable")
	var dress := _global_script(&"ZeeArtDress")
	var out: Array = []

	if art_script == null or table == null or dress == null:
		return out

	out = Array([], TYPE_OBJECT, &"Resource", art_script)
	var rows := ZzSpawnProvider.art_rows()

	for id: StringName in ZzWeaponIds.all():
		var art: Resource = table.call(_base_of(id))
		art.set(&"id", id)
		if dressed:
			dress.call(&"apply", art, rows.get(id, {}))
			art.set(&"sockets", sockets_of(id))
		out.append(art)

	return out


## [method ZzWeaponArt.socket_points] as zee's `sockets` (mount -> Transform3D in model space); our attachment models are sized for our guns, so no scale.
static func sockets_of(id: StringName) -> Dictionary:
	var out := {}
	var points := ZzWeaponArt.socket_points(id)
	for mount: String in points:
		out[StringName(mount)] = Transform3D(Basis.IDENTITY, points[mount])
	return out


## zee's attachment art entry for one of our attachment ids (`{path, hides, aim, zoom}`), or empty for an id that is not ours.
## A host registers it with `ZeeAttachmentArt.add_source` so zee's rig draws our parts.
static func attachment_art(id: StringName) -> Dictionary:
	var row: Dictionary = ZzAttachmentPack.defaults().get(id, {})
	if row.is_empty():
		return {}
	var out := {"path": str(row["model"]), "hides": []}
	if str(row.get("mount", "")) == "optic":
		var scoped := str(row.get("tags_added", "")).contains("scoped")
		out["aim"] = &"scoped" if scoped else &"glass"
		var params: Dictionary = row.get("params", {})
		if params.has("optic_zoom"):
			out["zoom"] = float(params["optic_zoom"])
	return out


static func _base_of(id: StringName) -> StringName:
	if LAUNCHERS.has(id):
		return &"launcher"

	var style := String(ZzWeaponArt.TABLE[id].get("style", "rifle")) if ZzWeaponArt.TABLE.has(id) else "rifle"
	return BASE_BY_STYLE.get(style, &"rifle")


## A global class's script by name, or null when its addon is not installed.
static func _global_script(name: StringName) -> Script:
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if StringName(entry.get("class", "")) == name:
			return load(str(entry["path"])) as Script

	return null
