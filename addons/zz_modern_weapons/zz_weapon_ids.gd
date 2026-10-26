class_name ZzWeaponIds
extends RefCounted

## The names this pack uses, in one place, so a typo is a parse error rather than a weapon
## that silently has no damage type.

const M4 := &"zz_m4"
const SNIPER := &"zz_sniper"
const KNIFE := &"zz_knife"
const PISTOL := &"zz_pistol"
const SHOTGUN := &"zz_shotgun"
const SMG := &"zz_smg"
const FRAG := &"zz_frag"
const VSS := &"zz_vss"
const REVOLVER := &"zz_revolver"
const MP5 := &"zz_mp5"
const SPAS := &"zz_spas"
const LMG := &"zz_lmg"
const DMR := &"zz_dmr"
const M79 := &"zz_m79"
const AK := &"zz_ak"
const SCAR := &"zz_scar"
const BREN := &"zz_bren"
const GLOCK := &"zz_glock"
const DEAGLE := &"zz_deagle"
const P90 := &"zz_p90"
const AA12 := &"zz_aa12"
const RPG := &"zz_rpg"
const MACHETE := &"zz_machete"

const DAMAGE_BULLET := &"zz_bullet"
const DAMAGE_BLADE := &"zz_blade"
const DAMAGE_BLAST := &"zz_blast"

const AMMO_PISTOL := &"zz_9mm"
const AMMO_RIFLE := &"zz_556"
const AMMO_SNIPER := &"zz_762"
const AMMO_SUBSONIC := &"zz_939"
const AMMO_SHELL := &"zz_12ga"
const AMMO_GRENADE := &"zz_grenade"
const AMMO_MAGNUM := &"zz_357"
const AMMO_LAUNCHER := &"zz_40mm"
const AMMO_ROCKET := &"zz_rocket"

const SLOT_MELEE := 1
const SLOT_SIDEARM := 2
const SLOT_PRIMARY := 3
const SLOT_HEAVY := 4
const SLOT_THROWN := 5


## Every weapon id, in the order the spawn menu lists them.
static func all() -> Array[StringName]:
	return [M4, SNIPER, KNIFE, PISTOL, SHOTGUN, SMG, FRAG, VSS, REVOLVER, MP5, SPAS, LMG, DMR, M79,
		AK, SCAR, BREN, GLOCK, DEAGLE, P90, AA12, RPG, MACHETE]


## The short name a cfg file uses for a weapon: the id without the prefix.
static func short_name(id: StringName) -> String:
	return String(id).trim_prefix("zz_")
