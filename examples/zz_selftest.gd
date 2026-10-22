extends Node

## The headless suite. Counts sections entered against sections finished and a total number
## of checks, because a script error aborts a section after it announced itself and a count
## of sections alone then reports "0 failed" with checks missing.
##
## What it cannot see is how the weapons look: tools/screenshot.sh is the other half.

const CHECKS := 124

var _entered := 0
var _finished := 0
var _checks := 0
var _failures := 0


func _ready() -> void:
	print("zz-modern-weapons self-test")
	print("===========================")
	_ids_and_pack()
	_numbers()
	_config()
	_spawn_provider()
	_art()
	_workshop()
	await _finish()


func _ids_and_pack() -> void:
	_begin("ids and the catalogue")
	var ids := ZzWeaponIds.all()
	_check("seven weapons are named", ids.size() == 7)
	var defs := ZzWeaponPack.weapons()
	_check("seven rows are built", defs.size() == 7)
	var cat := ZzWeaponPack.catalogue()
	var res := cat.validate()
	_check("the catalogue validates (%s)" % ("" if res.ok else res.error.message), res.ok)
	var seen := {}
	for def in defs:
		seen[def.id] = true
		_check_quiet("%s: validates alone" % def.id, def.validate().ok)
		_check_quiet("%s: authored at the pack's tick rate" % def.id, def.authored_tick_rate == ZzWeaponPack.TICK_RATE)
		_check_quiet("%s: has a name" % def.id, def.display_name != "")
		_check_quiet("%s: id is in the id list" % def.id, ids.has(def.id))
		_check_quiet("%s: has a tuning" % def.id, def.tuning != null)
	_check("no id appears twice", seen.size() == 7)
	_check("short name drops the prefix", ZzWeaponIds.short_name(ZzWeaponIds.M4) == "m4")
	_end()


func _numbers() -> void:
	_begin("default numbers")
	var by := {}
	for def in ZzWeaponPack.weapons():
		by[def.id] = def
	var m4: DotWeaponDef = by[ZzWeaponIds.M4]
	_check("m4 is automatic", m4.fire_mode == DotWeaponDef.Fire.AUTO)
	_check("m4 magazine is 30", m4.magazine == 30)
	_check("m4 interval is 800 rpm in ticks", m4.use_interval_ticks == ZzWeaponPack.rpm_ticks(800.0))
	var sniper: DotWeaponDef = by[ZzWeaponIds.SNIPER]
	_check("sniper is semi and scoped", sniper.fire_mode == DotWeaponDef.Fire.SEMI and sniper.has_tag(&"scoped"))
	_check("sniper hits harder than the m4", (sniper.tuning as DotWeaponBallistics).damage > (m4.tuning as DotWeaponBallistics).damage * 3.0)
	var sg: DotWeaponDef = by[ZzWeaponIds.SHOTGUN]
	_check("shotgun fires nine pellets", (sg.tuning as DotWeaponBallistics).pellets == 9)
	_check("shotgun reloads per round", sg.reload_per_round)
	var knife: DotWeaponDef = by[ZzWeaponIds.KNIFE]
	_check("knife is melee with no magazine", knife.behaviour_path == ZzWeaponPack.MELEE and knife.magazine == 0 and not knife.uses_ammo())
	var frag: DotWeaponDef = by[ZzWeaponIds.FRAG]
	_check("frag is thrown and has a splash", frag.behaviour_path == ZzWeaponPack.THROWN and (frag.tuning as DotWeaponBallistics).splash_radius > 0.0)
	_check("frag fuse matches the cook", int(frag.params[&"fuse_ticks"]) == frag.charge_ticks)
	_check("rpm_ticks never returns zero", ZzWeaponPack.rpm_ticks(100000.0) >= 1)
	_check("rpm_ticks survives a zero rate", ZzWeaponPack.rpm_ticks(0.0) >= 1)
	_check("sec_ticks rounds", ZzWeaponPack.sec_ticks(1.0) == ZzWeaponPack.TICK_RATE)
	_end()


func _config() -> void:
	_begin("config")
	var d := ZzWeaponConfig.defaults()
	_check("defaults cover every weapon", d.size() == 7)

	# A temp directory with TWO files: both must be read, and the later name wins.
	var dir := OS.get_user_data_dir().path_join("zz_selftest_cfg")
	DirAccess.make_dir_recursive_absolute(dir)
	_write(dir.path_join("a.yml"), "m4:\n  damage: 41\n  magazine: 20\nsniper:\n  damage: 200\n")
	_write(dir.path_join("b.yaml"), "m4:\n  damage: 55\n  bogus_key: 1\nnot_a_gun:\n  damage: 1\nsmg:\n  damage: wrong\n")
	_write(dir.path_join("notes.txt"), "m4:\n  damage: 999\n")
	var loaded := ZzWeaponConfig.load_all(dir)
	_check("a later file wins a shared key", is_equal_approx(loaded["m4"]["damage"], 55.0))
	_check("a key only the earlier file sets survives", loaded["m4"]["magazine"] == 20)
	_check("a second weapon from the first file is read", is_equal_approx(loaded["sniper"]["damage"], 200.0))
	_check("a non-yml file is ignored", not is_equal_approx(loaded["m4"]["damage"], 999.0))
	_check("an unknown key is dropped", not (loaded["m4"] as Dictionary).has("bogus_key"))
	_check("an unknown weapon is dropped", not loaded.has("not_a_gun"))
	_check("a wrong type keeps the default", is_equal_approx(loaded["smg"]["damage"], float(d["smg"]["damage"])))
	_check("an untouched weapon keeps its defaults", loaded["pistol"] == d["pistol"])
	_check("magazine stays an int", typeof(loaded["m4"]["magazine"]) == TYPE_INT)

	var tuned := ZzWeaponPack.m4({}, loaded)
	_check("the pack builds from the loaded table: damage", is_equal_approx((tuned.tuning as DotWeaponBallistics).damage, 55.0))
	_check("the pack builds from the loaded table: magazine", tuned.magazine == 20)
	_check("a tuned row still validates", tuned.validate().ok)
	var partial := ZzWeaponPack.pistol({}, {"pistol": {"damage": 31.0}})
	_check("a partial table is filled from defaults", partial.magazine == 15 and is_equal_approx((partial.tuning as DotWeaponBallistics).damage, 31.0))

	_check("an empty directory is the defaults", ZzWeaponConfig.load_all(dir.path_join("missing")) == d)
	for f in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir.path_join(f))
	DirAccess.remove_absolute(dir)

	var shipped := ProjectSettings.globalize_path("res://cfg/addons/zz_modern_weapons")
	_check("the shipped cfg directory exists", DirAccess.dir_exists_absolute(shipped))
	var shipped_cfg := ZzWeaponConfig.load_all(shipped)
	_check("the shipped default.yml equals the built-in defaults", shipped_cfg["m4"]["damage"] == d["m4"]["damage"] and shipped_cfg["frag"]["splash_radius"] == d["frag"]["splash_radius"])
	var rebuilt := ZzWeaponPack.weapons({}, shipped_cfg)
	var builtin := ZzWeaponPack.weapons({}, d)
	var same := true
	for i in rebuilt.size():
		if rebuilt[i].describe() != builtin[i].describe():
			same = false
	_check("the shipped yml builds the same seven rows", same)
	_end()


func _spawn_provider() -> void:
	_begin("spawn provider")
	var entries := ZzSpawnProvider.spawn_entries()
	_check("one entry per weapon", entries.size() == 7)
	var ok := true
	for e in entries:
		for key in ["category", "id", "name", "icon", "kind", "spawn", "cfg_hint"]:
			if not e.has(key):
				ok = false
		if e.get("category") != "Weapons" or e.get("kind") != "weapon":
			ok = false
		if not (e.get("spawn") is Dictionary) or (e["spawn"] as Dictionary).get("weapon") != e.get("id"):
			ok = false
	_check("every entry has the contract's keys, category and kind", ok)
	_check("ids are the pack's ids", entries.map(func(e: Dictionary) -> String: return e["id"]) == ZzWeaponIds.all().map(func(i: StringName) -> String: return String(i)))
	_check("the cfg hint names the weapon's key", String(entries[0]["cfg_hint"]).contains("zz_modern_weapons") and String(entries[0]["cfg_hint"]).contains("m4"))
	_end()


func _art() -> void:
	_begin("art")
	for id in ZzWeaponIds.all():
		_check_quiet("%s: has an art row" % id, ZzWeaponArt.TABLE.has(id))
		var node := ZzWeaponArt.instantiate(id)
		_check_quiet("%s: builds a model" % id, node != null and node.get_child_count() > 0)
		if node != null:
			node.free()
		var length := float(ZzWeaponArt.TABLE[id]["length"])
		_check_quiet("%s: muzzle is inside the length" % id, ZzWeaponArt.muzzle_distance(id) <= length)
	_check("an unknown id draws nothing", ZzWeaponArt.instantiate(&"nope") == null)
	_check("an unknown id has a zero muzzle", ZzWeaponArt.muzzle_distance(&"nope") == 0.0)
	_check("every model is still a placeholder (no download was possible)", ZzWeaponIds.all().all(func(i: StringName) -> bool: return ZzWeaponArt.is_placeholder(i)))
	var credits := FileAccess.get_file_as_string("res://CREDITS.md")
	_check("CREDITS.md exists", credits != "")
	for id in ZzWeaponIds.all():
		_check_quiet("CREDITS.md mentions %s" % id, credits.contains(String(id)))
	_end()


func _workshop() -> void:
	_begin("workshop files")
	var json: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://provides.json"))
	_check("provides.json parses", json is Dictionary)
	if not json is Dictionary:
		_end()
		return
	_check("kind weapon, games *", json["kinds"] == ["weapon"] and json["games"] == "*")
	var defs := ZzDefExport.own_weapons()
	_check("provides.json equals what the code would write", JSON.stringify(json) == JSON.stringify(JSON.parse_string(JSON.stringify(ZzDefExport.provides(defs)))))
	for def in defs:
		var path := "res://weapons/%s.tres" % def.id
		var loaded := load(path) as DotWeaponDef
		_check_quiet("%s: .tres loads" % def.id, loaded != null)
		if loaded != null:
			_check_quiet("%s: .tres matches the code row" % def.id, JSON.stringify(loaded.describe()) == JSON.stringify(def.describe()))
	_end()


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _begin(name: String) -> void:
	_entered += 1
	print("")
	print("-- %s" % name)


func _end() -> void:
	_finished += 1


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if passed:
		print("   ok    %s" % label)
		return
	_failures += 1
	print("   FAIL  %s" % label)


func _check_quiet(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures += 1
		print("   FAIL  %s" % label)


func _finish() -> void:
	print("")
	print("%d sections entered, %d finished, %d checks, %d failed" % [_entered, _finished, _checks, _failures])
	var passed := _failures == 0 and _entered == _finished and _checks == CHECKS
	if _checks != CHECKS:
		print("!! %d checks ran, %d expected. A section aborted part-way." % [_checks, CHECKS])
	print("RESULT: %s" % ("PASS" if passed else "FAIL"))
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if passed else 1)
