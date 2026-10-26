class_name ZzWeaponPack
extends RefCounted

## Twenty-three modern weapons as one [DotWeaponCatalogue] a server can validate with no art.
##
## Every number comes from [ZzWeaponConfig] (built-in defaults, overlaid by
## `cfg/addons/zz_modern_weapons/*.yml`), so an operator retunes a weapon without a fork.
## Pass [param cfg] to a builder to use a table other than the on-disk one (the suite does).
##
## Durations are authored at [constant TICK_RATE] and every row says so in
## [member DotWeaponDef.authored_tick_rate], so the arsenal scales them to the running rate.
## Nothing here mentions a mesh: a dedicated server boots and validates without any art.

const CHANNEL := "zz.pack"
const TICK_RATE := 64

const HITSCAN := "res://addons/dot_weapon/behaviour/dot_weapon_hitscan.gd"
const PROJECTILE := "res://addons/dot_weapon/behaviour/dot_weapon_projectile.gd"
const THROWN := "res://addons/dot_weapon/behaviour/dot_weapon_thrown.gd"
const MELEE := "res://addons/dot_weapon/behaviour/dot_weapon_melee.gd"


static func rpm_ticks(rpm: float) -> int:
	return maxi(1, int(round(60.0 / maxf(rpm, 1.0) * float(TICK_RATE))))


static func sec_ticks(seconds: float) -> int:
	return maxi(0, int(round(seconds * float(TICK_RATE))))


static func catalogue(types: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponCatalogue:
	var out := DotWeaponCatalogue.new()
	for def in weapons(types, cfg):
		out.add(def)
	return out


static func weapons(types: Dictionary = {}, cfg: Dictionary = {}) -> Array[DotWeaponDef]:
	var t := types if not types.is_empty() else ZzWeaponDamage.table()
	var c := cfg if not cfg.is_empty() else ZzWeaponConfig.load_all()
	return [m4(t, c), sniper(t, c), knife(t, c), pistol(t, c), shotgun(t, c), smg(t, c), frag(t, c), vss(t, c),
		revolver(t, c), mp5(t, c), spas(t, c), lmg(t, c), dmr(t, c), m79(t, c),
		ak(t, c), scar(t, c), bren(t, c), glock(t, c), deagle(t, c), p90(t, c), aa12(t, c), rpg(t, c), machete(t, c)]


## The rifle for every distance that is not extreme.
static func m4(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "m4")
	var def := _gun(ZzWeaponIds.M4, "M4 Carbine", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_RIFLE, [&"primary", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## One shot, one answer, and a scope the game draws.
static func sniper(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "sniper")
	var def := _gun(ZzWeaponIds.SNIPER, "Sniper Rifle", ZzWeaponIds.SLOT_HEAVY,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_SNIPER, [&"heavy", &"scoped", &"primary"])
	def.tuning = _bullet(t, r)
	return def


static func pistol(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "pistol")
	var def := _gun(ZzWeaponIds.PISTOL, "Pistol", ZzWeaponIds.SLOT_SIDEARM,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_PISTOL, [&"sidearm"])
	def.tuning = _bullet(t, r)
	return def


static func smg(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "smg")
	var def := _gun(ZzWeaponIds.SMG, "SMG", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_PISTOL, [&"primary", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## A suppressed automatic rifle: steady, quiet, and reaches further than the M4.
static func vss(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "vss")
	var def := _gun(ZzWeaponIds.VSS, "VSS Vintorez", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_SUBSONIC, [&"primary", &"automatic", &"suppressed"])
	def.tuning = _bullet(t, r)
	return def


## Loaded one shell at a time, so a reload can be cut short and the gun used half full.
static func shotgun(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "shotgun")
	var def := _gun(ZzWeaponIds.SHOTGUN, "Shotgun", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_SHELL, [&"primary"])
	def.reload_per_round = true
	def.reload_start_ticks = sec_ticks(float(r.get("reload_start_seconds", 0.3)))
	var b := _bullet(t, r)
	b.pellets = int(r.get("pellets", 9))
	b.fixed_pattern = true
	def.tuning = b
	return def


## Six heavy rounds and a slow hand: the sidearm that kills a common in two.
static func revolver(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "revolver")
	var def := _gun(ZzWeaponIds.REVOLVER, "Magnum Revolver", ZzWeaponIds.SLOT_SIDEARM,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_MAGNUM, [&"sidearm"])
	def.tuning = _bullet(t, r)
	return def


## A lighter, steadier submachine gun than the SMG, with a smaller magazine.
static func mp5(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "mp5")
	var def := _gun(ZzWeaponIds.MP5, "MP5", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_PISTOL, [&"primary", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## A self-loading shotgun: a faster rate than the pump, a looser pattern.
static func spas(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "spas")
	var def := _gun(ZzWeaponIds.SPAS, "Combat Shotgun", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_SHELL, [&"primary"])
	def.reload_per_round = true
	def.reload_start_ticks = sec_ticks(float(r.get("reload_start_seconds", 0.3)))
	var b := _bullet(t, r)
	b.pellets = int(r.get("pellets", 8))
	b.fixed_pattern = true
	def.tuning = b
	return def


## A belt-fed hundred rounds that holds a doorway; slow to draw and slower to reload.
static func lmg(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "lmg")
	var def := _gun(ZzWeaponIds.LMG, "Light Machine Gun", ZzWeaponIds.SLOT_HEAVY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_RIFLE, [&"heavy", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## A self-loading rifle that trades rate for a hit that nearly halves a special.
static func dmr(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "dmr")
	var def := _gun(ZzWeaponIds.DMR, "Marksman Rifle", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_SNIPER, [&"primary"])
	def.tuning = _bullet(t, r)
	return def


## One 40 mm round at a time, lobbed; the blast hurts its owner.
static func m79(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "m79")
	var def := _gun(ZzWeaponIds.M79, "Grenade Launcher", ZzWeaponIds.SLOT_HEAVY,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_LAUNCHER, [&"heavy", &"explosive"])
	_projectile(def, t, r)
	return def


## A worn-in rifle that hits harder than the M4 and climbs more.
static func ak(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "ak")
	var def := _gun(ZzWeaponIds.AK, "Assault Rifle", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_SNIPER, [&"primary", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## A battle rifle: slow, accurate and heavy, for the specials the M4 only annoys.
static func scar(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "scar")
	var def := _gun(ZzWeaponIds.SCAR, "Battle Rifle", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_SNIPER, [&"primary", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## A bullpup-sized carbine: lighter and steadier than the M4, a little weaker.
static func bren(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "bren")
	var def := _gun(ZzWeaponIds.BREN, "Carbine", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_RIFLE, [&"primary", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## A seventeen-round sidearm that out-shoots the pistol on volume.
static func glock(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "glock")
	var def := _gun(ZzWeaponIds.GLOCK, "Service Pistol", ZzWeaponIds.SLOT_SIDEARM,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_PISTOL, [&"sidearm"])
	def.tuning = _bullet(t, r)
	return def


## Seven big rounds and a hard kick: the hand cannon above the revolver.
static func deagle(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "deagle")
	var def := _gun(ZzWeaponIds.DEAGLE, "Hand Cannon", ZzWeaponIds.SLOT_SIDEARM,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_MAGNUM, [&"sidearm"])
	def.tuning = _bullet(t, r)
	return def


## Fifty rounds that barely climb, each weak: the crowd-thinning submachine gun.
static func p90(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "p90")
	var def := _gun(ZzWeaponIds.P90, "Compact SMG", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_PISTOL, [&"primary", &"automatic"])
	def.tuning = _bullet(t, r)
	return def


## A drum-fed automatic shotgun: reloads whole, so it empties fast and refills slowly.
static func aa12(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "aa12")
	var def := _gun(ZzWeaponIds.AA12, "Auto Shotgun", ZzWeaponIds.SLOT_PRIMARY,
		DotWeaponDef.Fire.AUTO, r, ZzWeaponIds.AMMO_SHELL, [&"primary", &"automatic"])
	var b := _bullet(t, r)
	b.pellets = int(r.get("pellets", 8))
	b.fixed_pattern = true
	def.tuning = b
	return def


## One rocket and a long reload; the blast reaches further than the grenade launcher's and hurts its owner.
static func rpg(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "rpg")
	var def := _gun(ZzWeaponIds.RPG, "Rocket Launcher", ZzWeaponIds.SLOT_HEAVY,
		DotWeaponDef.Fire.SEMI, r, ZzWeaponIds.AMMO_ROCKET, [&"heavy", &"explosive"])
	_projectile(def, t, r)
	return def


static func knife(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "knife")
	var def := DotWeaponDef.new()
	def.authored_tick_rate = TICK_RATE
	def.id = ZzWeaponIds.KNIFE
	def.display_name = "Combat Knife"
	def.behaviour_path = MELEE
	def.slot = ZzWeaponIds.SLOT_MELEE
	def.fire_mode = DotWeaponDef.Fire.SEMI
	def.use_interval_ticks = rpm_ticks(float(r["rpm"]))
	def.tags = [&"melee"]
	def.ammo_type = &""
	def.magazine = 0
	def.cost_per_use = 0
	def.auto_reload = false
	def.reload_ticks = 0
	def.deploy_ticks = sec_ticks(float(r["deploy_seconds"]))
	def.holster_ticks = sec_ticks(0.1)
	def.params = {&"arc_degrees": float(r["arc_degrees"]), &"rays": int(r["rays"])}
	var b := DotWeaponBallistics.new()
	b.damage = float(r["damage"])
	b.damage_type = _type(t, ZzWeaponIds.DAMAGE_BLADE)
	b.max_range = float(r["reach"])
	b.spread = 0.0
	b.spread_moving = 0.0
	b.spread_airborne = 0.0
	b.recoil_pitch = 0.0
	def.tuning = b
	return def


## A long blade that reaches further and cuts harder than the knife, and swings slower.
static func machete(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "machete")
	var def := DotWeaponDef.new()
	def.authored_tick_rate = TICK_RATE
	def.id = ZzWeaponIds.MACHETE
	def.display_name = "Machete"
	def.behaviour_path = MELEE
	def.slot = ZzWeaponIds.SLOT_MELEE
	def.fire_mode = DotWeaponDef.Fire.SEMI
	def.use_interval_ticks = rpm_ticks(float(r["rpm"]))
	def.tags = [&"melee"]
	def.ammo_type = &""
	def.magazine = 0
	def.cost_per_use = 0
	def.auto_reload = false
	def.reload_ticks = 0
	def.deploy_ticks = sec_ticks(float(r["deploy_seconds"]))
	def.holster_ticks = sec_ticks(0.12)
	def.params = {&"arc_degrees": float(r["arc_degrees"]), &"rays": int(r["rays"])}
	var b := DotWeaponBallistics.new()
	b.damage = float(r["damage"])
	b.damage_type = _type(t, ZzWeaponIds.DAMAGE_BLADE)
	b.max_range = float(r["reach"])
	b.spread = 0.0
	b.spread_moving = 0.0
	b.spread_airborne = 0.0
	b.recoil_pitch = 0.0
	def.tuning = b
	return def


static func frag(t: Dictionary = {}, cfg: Dictionary = {}) -> DotWeaponDef:
	var r := _row(cfg, "frag")
	var def := DotWeaponDef.new()
	def.authored_tick_rate = TICK_RATE
	def.id = ZzWeaponIds.FRAG
	def.display_name = "Frag Grenade"
	def.behaviour_path = THROWN
	def.slot = ZzWeaponIds.SLOT_THROWN
	def.fire_mode = DotWeaponDef.Fire.CHARGE
	def.use_interval_ticks = sec_ticks(1.0)
	def.tags = [&"thrown", &"explosive"]
	def.ammo_type = ZzWeaponIds.AMMO_GRENADE
	def.magazine = 0
	def.reserve = int(r["reserve"])
	def.reserve_max = int(r["reserve_max"])
	def.cost_per_use = 1
	def.auto_reload = false
	def.reload_ticks = 0
	# The cook: held past the fuse and it goes off in the hand.
	var fuse := sec_ticks(float(r["fuse_seconds"]))
	def.charge_ticks = maxi(1, fuse)
	def.charge_requires_min = false
	def.deploy_ticks = sec_ticks(0.35)
	def.holster_ticks = sec_ticks(0.25)
	def.params = {&"fuse_ticks": fuse, &"speed_scales_with_cook": false}
	var b := DotWeaponBallistics.new()
	b.damage = 0.0
	b.damage_type = _type(t, ZzWeaponIds.DAMAGE_BLAST)
	b.radius = 0.12
	b.life_ticks = sec_ticks(12.0)
	b.max_range = 100.0
	b.splash_hurts_owner = true
	b.splash_radius = float(r["splash_radius"])
	b.splash_damage = float(r["splash_damage"])
	b.speed = float(r["speed"])
	b.min_speed = float(r["speed"])
	b.gravity_scale = float(r["gravity_scale"])
	def.tuning = b
	return def


# --- Builders ---------------------------------------------------------------

static func _projectile(def: DotWeaponDef, t: Dictionary, r: Dictionary) -> void:
	def.behaviour_path = PROJECTILE
	var b := DotWeaponBallistics.new()
	b.damage = float(r["damage"])
	b.damage_type = _type(t, ZzWeaponIds.DAMAGE_BLAST)
	b.splash_type = b.damage_type
	b.speed = float(r["speed"])
	b.min_speed = float(r["speed"])
	b.min_charge_damage = 1.0
	b.gravity_scale = float(r["gravity_scale"])
	b.radius = 0.15
	b.life_ticks = sec_ticks(5.0)
	b.splash_radius = float(r["splash_radius"])
	b.splash_damage = float(r["splash_damage"])
	b.splash_hurts_owner = true
	b.spread = 0.0
	b.spread_moving = 0.0
	b.spread_airborne = 0.0
	b.recoil_pitch = float(r["recoil_pitch"])
	b.max_range = float(r["max_range"])
	def.tuning = b


static func _row(cfg: Dictionary, key: String) -> Dictionary:
	var c := cfg if not cfg.is_empty() else ZzWeaponConfig.defaults()
	var row: Dictionary = ZzWeaponConfig.defaults()[key].duplicate()
	row.merge(c.get(key, {}), true)
	return row


static func _gun(
	id: StringName, name: String, slot: int, fire: DotWeaponDef.Fire,
	r: Dictionary, ammo: StringName, tags: Array
) -> DotWeaponDef:
	var def := DotWeaponDef.new()
	def.authored_tick_rate = TICK_RATE
	def.id = id
	def.display_name = name
	def.behaviour_path = HITSCAN
	def.slot = slot
	def.fire_mode = fire
	def.use_interval_ticks = rpm_ticks(float(r["rpm"]))
	def.cost_per_use = 1
	def.tags = []
	for tag in tags:
		def.tags.append(StringName(tag))
	def.ammo_type = ammo
	def.magazine = int(r["magazine"])
	def.reserve = int(r["reserve"])
	def.reserve_max = int(r["reserve_max"])
	def.reload_ticks = sec_ticks(float(r["reload_seconds"]))
	def.deploy_ticks = sec_ticks(float(r["deploy_seconds"]))
	def.holster_ticks = sec_ticks(float(r["deploy_seconds"]) * 0.7)
	return def


static func _bullet(t: Dictionary, r: Dictionary) -> DotWeaponBallistics:
	var b := DotWeaponBallistics.new()
	b.damage = float(r["damage"])
	b.damage_type = _type(t, ZzWeaponIds.DAMAGE_BULLET)
	b.spread = float(r.get("spread", 0.5))
	b.spread_moving = float(r.get("spread_moving", 2.0))
	b.spread_airborne = float(r.get("spread_airborne", 4.0))
	b.spread_crouched = float(r.get("spread_crouched", b.spread))
	b.bloom = float(r.get("bloom", 0.0))
	b.bloom_max = float(r.get("bloom_max", 5.0))
	b.bloom_recovery = 9.0 / float(TICK_RATE)
	b.recoil_pitch = float(r.get("recoil_pitch", 0.4))
	b.recoil_yaw = float(r.get("recoil_yaw", 0.15))
	b.max_range = float(r.get("max_range", 200.0))
	return b


static func _type(t: Dictionary, id: StringName) -> DotDamageType:
	var found: Variant = t.get(id, null)
	if found is DotDamageType:
		return found
	DotLog.warn(CHANNEL, "no damage type '%s' supplied; using the pack's own" % String(id))
	return ZzWeaponDamage.table()[id]
