class_name ZzWeaponSound
extends RefCounted

## The sound hook: [method stream_for] takes an id and a kind ([constant FIRE], [constant RELOAD], [constant DRAW], [constant DRY]).
## [constant TABLE] paths win, then dot-audio's stock sounds by class when linked, else null; the pack ships no audio.
## A game with its own audio connects [signal ZzViewModel.sound_requested] instead.

const FIRE := &"fire"
const RELOAD := &"reload"
const DRAW := &"draw"
const DRY := &"dry"

## id -> {kind -> res:// path}. Empty: the stock covers every weapon.
const TABLE := {}


## id -> sound class, a name in [constant DotWeaponSound.FIRE] (melee swings use "swing"/"bash").
const CLASSES := {
	&"zz_aa12": &"shotgun", &"zz_spas": &"shotgun", &"zz_shotgun": &"shotgun",
	&"zz_ak": &"rifle", &"zz_m4": &"rifle", &"zz_scar": &"rifle",
	&"zz_bren": &"heavy", &"zz_lmg": &"heavy", &"zz_dmr": &"heavy",
	&"zz_hunting": &"sniper", &"zz_sniper": &"sniper", &"zz_vss": &"sniper",
	&"zz_deagle": &"magnum", &"zz_revolver": &"magnum",
	&"zz_glock": &"light", &"zz_pistol": &"light",
	&"zz_mp5": &"smg", &"zz_p90": &"smg", &"zz_smg": &"smg",
	&"zz_m79": &"launcher", &"zz_rpg": &"launcher",
	&"zz_frag": &"throw",
	&"zz_axe": &"swing", &"zz_machete": &"swing", &"zz_knife": &"swing",
	&"zz_bat": &"bash", &"zz_crowbar": &"bash", &"zz_sledge": &"bash",
}

const _BLADES := [&"zz_axe", &"zz_machete", &"zz_knife"]

static var _cache: Dictionary = {}


static func path_for(id: StringName, kind: StringName) -> String:
	var row: Dictionary = TABLE.get(id, {})
	return String(row.get(kind, ""))


static func stream_for(id: StringName, kind: StringName) -> AudioStream:
	var path := path_for(id, kind)
	if path != "" and ResourceLoader.exists(path):
		if not _cache.has(path):
			_cache[path] = load(path)
		return _cache[path] as AudioStream
	return stock_for(id, kind)


## The stock recording for [param id]'s use of [param kind], or null.
static func stock_for(id: StringName, kind: StringName) -> AudioStream:
	var sound_class: StringName = CLASSES.get(id, &"")
	if sound_class == &"":
		return null
	var roll := randi()
	var melee := sound_class in [&"swing", &"bash"]
	match kind:
		FIRE:
			if sound_class == &"swing" and id == &"zz_axe":
				return DotWeaponSound.pick(&"swing_heavy", roll)
			return DotWeaponSound.pick_class(sound_class, roll)
		RELOAD:
			return null if melee or sound_class == &"throw" else DotWeaponSound.pick_reload(sound_class, &"out", roll)
		DRAW:
			if id in _BLADES:
				return DotWeaponSound.pick(&"draw_blade", roll)
			if sound_class == &"throw":
				return DotWeaponSound.pick(&"pin_pull", roll)
			return null if melee else DotWeaponSound.pick(&"equip", roll)
		DRY:
			return null if melee or sound_class == &"throw" else DotWeaponSound.pick(&"dry", roll)
	return null
