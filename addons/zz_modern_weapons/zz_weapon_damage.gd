class_name ZzWeaponDamage
extends RefCounted

## The three damage types the pack's weapons produce, built once and shared.
##
## A game that wants harder armour hands [method ZzWeaponPack.catalogue] its own table; the
## ids in [ZzWeaponIds] are the whole contract.


static func bullet() -> DotDamageType:
	var type := DotDamageType.make(ZzWeaponIds.DAMAGE_BULLET, "Bullet")
	type.armour_share = 0.6
	type.armour_wear = 1.0
	type.falloff_start = 40.0
	type.falloff_end = 120.0
	type.falloff_floor = 0.5
	type.self_scale = 0.0
	return type


static func blade() -> DotDamageType:
	var type := DotDamageType.make(ZzWeaponIds.DAMAGE_BLADE, "Blade")
	type.armour_share = 0.2
	type.armour_wear = 0.5
	type.self_scale = 0.0
	return type


## Hit groups off for the reason a splash sphere cannot be trusted to land a headshot.
static func blast() -> DotDamageType:
	var type := DotDamageType.make(ZzWeaponIds.DAMAGE_BLAST, "Blast")
	type.armour_share = 0.75
	type.armour_wear = 1.5
	type.uses_hit_groups = false
	type.self_scale = 0.5
	type.knockback_per_point = 0.35
	return type


static func table() -> Dictionary:
	return {
		ZzWeaponIds.DAMAGE_BULLET: bullet(),
		ZzWeaponIds.DAMAGE_BLADE: blade(),
		ZzWeaponIds.DAMAGE_BLAST: blast(),
	}
