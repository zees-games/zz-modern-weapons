extends Node

## The headless suite. Counts sections entered against sections finished and a total number
## of checks, because a script error aborts a section after it announced itself and a count
## of sections alone then reports "0 failed" with checks missing.
##
## What it cannot see is how the weapons look: tools/screenshot.sh is the other half.

const CHECKS := 237

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
	_packs()
	_art()
	_pose()
	_view_model()
	_net_and_world()
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


## Loads the provider the way game-zombie-zone's game/zz_packs.gd does (by path, `script.new()`,
## `has_method`, `call`, then a source Callable on the script), so a change that breaks the
## contract fails here and not in a game that lists the weapons and refuses them.
func _packs() -> void:
	_begin("zz_packs contract")
	var path := "res://addons/zz_modern_weapons/spawn_provider.gd"
	_check("provider file found by path", ResourceLoader.exists(path) or FileAccess.file_exists(path))
	var script := load(path) as GDScript
	_check("provider loads and instantiates", script != null and script.can_instantiate())
	var provider: Object = script.new()
	_check("has spawn_entries", provider.has_method(&"spawn_entries"))
	_check("has weapon_defs", provider.has_method(&"weapon_defs"))
	var rows: Array = provider.call(&"spawn_entries")
	var defs: Array = provider.call(&"weapon_defs")
	var ids := PackedStringArray()
	for def: Variant in defs:
		_check_quiet("weapon_defs holds only DotWeaponDef", def is DotWeaponDef)
		if def is DotWeaponDef:
			ids.append(String(def.id))
	_check("one definition per weapon id", ids.size() == ZzWeaponIds.all().size())
	var types := {"zz_bullet": DotDamageType.new()}
	var via: Array = Callable(provider.get_script(), &"weapon_defs").call(types)
	_check("the source Callable returns the same set", via.size() == ids.size())
	var used := false
	for def: DotWeaponDef in via:
		if def.tuning != null and def.tuning.damage_type == types["zz_bullet"]:
			used = true
	_check("the game's damage type replaces the pack's own", used)
	var kept := 0
	for row: Variant in rows:
		var r: Dictionary = row
		var spawn: Dictionary = r.get("spawn", {})
		var wid := str(spawn.get("weapon", spawn.get("weapon_id", r.get("id", ""))))
		if ids.has(wid) or ids.has(str(r.get("id", ""))):
			kept += 1
	_check("every weapon row has a definition behind it", kept == rows.size() and kept == ids.size())
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

class FakeNet:
	extends RefCounted
	var net_fire_seq := 0
	var net_fire_kind := 0
	var net_reloading := false
	var net_switching := false


func _pose() -> void:
	_begin("procedural pose")
	for id in ZzWeaponIds.all():
		var prof := ZzWeaponArt.view_profile(id)
		for key in ["hold", "aim", "support", "kick", "back", "zoom"]:
			_check_quiet("%s: view profile has %s" % [id, key], prof.has(key))
	var rifle := ZzWeaponPose.new()
	rifle.set_weapon(ZzWeaponIds.M4)
	rifle.advance(1.0)
	_check("a rested pose is within a centimetre of the hold", rifle.offset().origin.length() < 0.012)
	rifle.draw(0.4)
	_check("a draw starts well below the hold", rifle.offset().origin.y < -0.2)
	for i in 40:
		rifle.advance(0.02)
	_check("a draw ends at rest", not rifle.is_drawing() and rifle.offset().origin.length() < 0.012)
	rifle.fire(1.0)
	var peak := 0.0
	for i in 12:
		rifle.advance(1.0 / 60.0)
		peak = maxf(peak, rifle.kick_amount())
	_check("a shot kicks the muzzle up", peak > 0.1)
	for i in 120:
		rifle.advance(1.0 / 60.0)
	_check("the kick settles", rifle.kick_amount() < 0.01)
	var held := 0.0
	for i in 60 * 30:
		if i % 5 == 0:
			rifle.fire(1.0)
		rifle.advance(1.0 / 60.0)
		held = maxf(held, rifle.kick_amount())
	_check("thirty seconds of held fire never exceeds the kick limit", held <= 1.0 and rifle.offset().origin.is_finite())
	var slow := ZzWeaponPose.new()
	var fast := ZzWeaponPose.new()
	slow.set_weapon(ZzWeaponIds.M4)
	fast.set_weapon(ZzWeaponIds.M4)
	slow.advance(1.0)
	fast.advance(1.0)
	slow.fire(1.0)
	fast.fire(1.0)
	var peak_slow := 0.0
	var peak_fast := 0.0
	for i in 30:
		slow.advance(1.0 / 30.0)
		peak_slow = maxf(peak_slow, slow.kick_amount())
	for i in 144:
		fast.advance(1.0 / 144.0)
		peak_fast = maxf(peak_fast, fast.kick_amount())
	_check("the kick is the same size at 30 and at 144 fps", absf(peak_slow - peak_fast) < 0.15 * peak_fast)
	rifle.start_reload(1.0)
	var rolled := 0.0
	for i in 30:
		rifle.advance(1.0 / 60.0)
		rolled = maxf(rolled, absf(rifle.offset().basis.get_euler().z))
	_check("a reload rolls the gun onto its side", rolled > 0.5)
	for i in 80:
		rifle.advance(1.0 / 60.0)
	_check("a reload ends at rest", not rifle.is_reloading() and rifle.offset().origin.length() < 0.012)
	var sniper := ZzWeaponPose.new()
	sniper.set_weapon(ZzWeaponIds.SNIPER)
	var hip := sniper.hold()
	sniper.set_aim(true)
	for i in 30:
		sniper.advance(1.0 / 60.0)
	_check("aiming moves the weapon to the sight line", sniper.hold().distance_to(hip) > 0.03 and sniper.aim_amount() == 1.0)
	_check("a sniper zooms when aimed", sniper.fov_scale() < 0.5)
	var knife := ZzWeaponPose.new()
	knife.set_weapon(ZzWeaponIds.KNIFE)
	knife.set_aim(true)
	knife.advance(1.0)
	_check("a knife does not aim", knife.fov_scale() == 1.0)
	knife.fire(1.0)
	knife.advance(0.12)
	_check("a knife swings instead of kicking", knife.is_acting() and knife.offset().origin.length() > 0.02)
	var nan := ZzWeaponPose.new()
	nan.set_weapon(ZzWeaponIds.PISTOL)
	nan.advance(NAN, NAN)
	nan.advance(0.016, INF)
	_check("a NaN delta or speed leaves a finite pose", nan.offset().origin.is_finite() and nan.offset().basis.is_finite())
	_check("malformed keys sample as rest", ZzWeaponPose.sample_keys([], 0.5)[0] == Vector3.ZERO and ZzWeaponPose.sample_keys([[0.0, Vector3.ONE, Vector3.ONE]], 0.5)[1] == Vector3.ZERO)
	_end()


func _make_arsenal() -> DotWeaponArsenal:
	var ars := DotWeaponArsenal.new()
	ars.catalogue = ZzWeaponPack.catalogue()
	add_child(ars)
	ars.setup()
	ars.give(ZzWeaponIds.M4)
	ars.give(ZzWeaponIds.KNIFE)
	return ars


func _view_model() -> void:
	_begin("view model")
	var ars := _make_arsenal()
	ars.select(ZzWeaponIds.SLOT_PRIMARY, 0)
	var vm := ZzViewModel.new()
	vm.auto_process = false
	add_child(vm)
	vm.bind(ars)
	_check("bound to an arsenal it shows the current weapon", vm.has_model() and vm.weapon_id == ars.current_def().id)
	for id in ZzWeaponIds.all():
		vm.show_weapon(id, false)
		_check_quiet("%s: view model builds" % id, vm.has_model())
		_check_quiet("%s: muzzle is ahead of the grip (-Z)" % id, vm.muzzle().position.z <= 0.0)
	vm.show_weapon(ZzWeaponIds.M4, false)
	var shots := [0]
	vm.flashed.connect(func(_id: StringName) -> void: shots[0] += 1)
	var sounds: Array[StringName] = []
	vm.sound_requested.connect(func(kind: StringName, _id: StringName, _at: Vector3) -> void: sounds.append(kind))
	vm.show_tracers = false
	ars.used.emit(DotWeaponOutcome.of(DotWeaponOutcome.KIND_SHOT))
	_check("a use from the arsenal flashes the muzzle", shots[0] == 1 and vm.muzzle().get_node_or_null("MuzzleFlash") != null)
	_check("a use asks for a fire sound", sounds.has(ZzWeaponSound.FIRE))
	vm.step(0.016)
	_check("the kick moves the weapon", vm.pose.kick_amount() > 0.0)
	ars.reload_started.emit(0)
	_check("reload_started starts the reload motion and asks for its sound", vm.pose.is_reloading() and sounds.has(ZzWeaponSound.RELOAD))
	ars.used.emit(DotWeaponOutcome.nothing("refused"))
	_check("a refused use does nothing", shots[0] == 1)
	vm.aim(true)
	_check("aim reports a zoom of 1 or less", vm.aim_fov_scale() <= 1.0)
	_check("no sound is shipped, so the built-in hook is silent", ZzWeaponSound.stream_for(ZzWeaponIds.M4, ZzWeaponSound.FIRE) == null)
	vm.unbind()
	ars.used.emit(DotWeaponOutcome.of(DotWeaponOutcome.KIND_SHOT))
	_check("an unbound view model ignores the arsenal", shots[0] == 1)
	vm.free()
	ars.free()
	_end()


func _net_and_world() -> void:
	_begin("replicated fields and the world model")
	var props := ZzWeaponNet.properties()
	for p in [&"net_fire_seq", &"net_fire_kind", &"net_reloading", &"net_switching"]:
		_check_quiet("%s is replicated" % p, props.has(p))
	_check("dot-weapon's fields come first", props.size() > 4 and props[props.size() - 4] == &"net_fire_seq")
	for spec in ZzWeaponNet.specs():
		_check_quiet("%s is public" % spec["property"], spec["owner_only"] == false)
	_check("the counter wraps: 15 to 1 is two uses", ZzWeaponNet.uses_between(15, 1) == 2)
	_check("the counter: no change is no use", ZzWeaponNet.uses_between(7, 7) == 0)
	var ars := _make_arsenal()
	var tracker := ZzFireTracker.new()
	tracker.attach(ars)
	ars.used.emit(DotWeaponOutcome.of(DotWeaponOutcome.KIND_SWING))
	ars.used.emit(DotWeaponOutcome.nothing())
	_check("the tracker counts uses, not refusals, and keeps the kind", tracker.seq == 1 and tracker.kind == ZzWeaponNet.KIND_SWING)
	var net := FakeNet.new()
	ZzWeaponNet.pull(ars, tracker, net)
	_check("pull copies the counter and the flags", net.net_fire_seq == 1 and net.net_fire_kind == ZzWeaponNet.KIND_SWING and not net.net_reloading)
	var wm := ZzWorldModel.new()
	add_child(wm)
	wm.apply_net(net, ZzWeaponIds.M4)
	_check("the first snapshot only learns the counter", wm.pose.kick_amount() == 0.0)
	net.net_fire_seq = 2
	wm.apply_net(net, ZzWeaponIds.M4)
	wm.step(0.02)
	_check("a watcher sees the gun kick when the counter advances", wm.pose.kick_amount() > 0.0 and wm.muzzle().get_node_or_null("MuzzleFlash") != null)
	net.net_reloading = true
	wm.apply_net(net, ZzWeaponIds.M4)
	_check("net_reloading starts the reload motion", wm.pose.is_reloading())
	net.net_reloading = false
	wm.apply_net(net, ZzWeaponIds.M4)
	_check("and its end stops it", not wm.pose.is_reloading())
	net.net_switching = true
	wm.apply_net(net, ZzWeaponIds.M4)
	net.net_switching = false
	wm.apply_net(net, ZzWeaponIds.KNIFE)
	_check("a finished switch draws the new weapon", wm.weapon_id == ZzWeaponIds.KNIFE and wm.pose.is_drawing())
	tracker.detach(ars)
	wm.free()
	ars.free()
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
