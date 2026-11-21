extends "zz_selftest_base.gd"

## The weapon-side sections of the headless suite that need no world: the arsenal's spread and
## fire bloom, and the attachments (mounts table, catalogue, fittings, the view of a fitted gun).
## zz_selftest.gd extends this and has the rest.

const _NO_MOUNTS := [&"zz_vss", &"zz_sniper", &"zz_hunting", &"zz_revolver", &"zz_m79", &"zz_rpg", &"zz_frag",
	&"zz_knife", &"zz_machete", &"zz_bat", &"zz_crowbar", &"zz_axe", &"zz_sledge"]


func _arsenal_spread() -> void:
	_begin("the arsenal spread")
	var fresh := [&"zz_ak", &"zz_scar", &"zz_bren", &"zz_glock", &"zz_deagle", &"zz_p90", &"zz_aa12", &"zz_rpg", &"zz_machete"]
	var cfg := ZzWeaponConfig.defaults()
	var by_id := {}
	for def in ZzWeaponPack.weapons():
		by_id[def.id] = def
	var modelled := 0
	var weighted := 0
	var slotted := 0
	var ammo_ok := 0
	for id: StringName in fresh:
		if not ZzWeaponArt.is_placeholder(id) and ResourceLoader.exists(ZzWeaponArt.ASSET_DIR.path_join(String(ZzWeaponArt.TABLE[id]["model"]))):
			modelled += 1
		if float(cfg[ZzWeaponIds.short_name(id)].get("weight", 0.0)) > 0.0:
			weighted += 1
		var def: GSWeaponDef = by_id[id]
		if def.slot >= ZzWeaponIds.SLOT_MELEE and def.slot <= ZzWeaponIds.SLOT_THROWN:
			slotted += 1
		if def.slot == ZzWeaponIds.SLOT_MELEE or def.ammo_type != &"":
			ammo_ok += 1
	_check("every new weapon has a real model", modelled == 9)
	_check("every new weapon has a carry weight", weighted == 9)
	_check("every new weapon sits in a slot", slotted == 9)
	_check("every new gun names its ammo", ammo_ok == 9)
	var primary := 0
	var side := 0
	for id: StringName in fresh:
		var s: int = (by_id[id] as GSWeaponDef).slot
		primary += 1 if s == ZzWeaponIds.SLOT_PRIMARY else 0
		side += 1 if s == ZzWeaponIds.SLOT_SIDEARM else 0
	_check("the new set adds five primaries, two sidearms, a launcher and a blade", primary == 5 and side == 2)
	_check("the launcher is heavy-slot and explodes", (by_id[ZzWeaponIds.RPG] as GSWeaponDef).slot == ZzWeaponIds.SLOT_HEAVY and (by_id[ZzWeaponIds.RPG].tuning as GSWeaponBallistics).splash_radius > 5.0)
	_check("the machete outreaches the knife", (by_id[ZzWeaponIds.MACHETE].tuning as GSWeaponBallistics).max_range > (by_id[ZzWeaponIds.KNIFE].tuning as GSWeaponBallistics).max_range)
	var swung := [&"zz_bat", &"zz_crowbar", &"zz_axe", &"zz_sledge"]
	var swung_ok := 0
	for id: StringName in swung:
		var d: GSWeaponDef = by_id[id]
		if d.slot == ZzWeaponIds.SLOT_MELEE and d.ammo_type == &"" and ResourceLoader.exists(ZzWeaponArt.ASSET_DIR.path_join(String(ZzWeaponArt.TABLE[id]["model"]))):
			swung_ok += 1
	_check("the four new melee weapons are modelled, ammunition-free and in the melee slot", swung_ok == 4)
	_check("the sledgehammer hits hardest and swings slowest", (by_id[ZzWeaponIds.SLEDGE].tuning as GSWeaponBallistics).damage > (by_id[ZzWeaponIds.AXE].tuning as GSWeaponBallistics).damage and (by_id[ZzWeaponIds.SLEDGE] as GSWeaponDef).use_interval_ticks > (by_id[ZzWeaponIds.AXE] as GSWeaponDef).use_interval_ticks)
	var hunt: GSWeaponDef = by_id[ZzWeaponIds.HUNTING]
	_check("the hunting rifle is a scoped primary that fires sniper rounds", hunt.slot == ZzWeaponIds.SLOT_PRIMARY and hunt.tags.has(&"scoped") and hunt.ammo_type == ZzWeaponIds.AMMO_SNIPER and hunt.magazine == 5 and ResourceLoader.exists(ZzWeaponArt.ASSET_DIR.path_join("zz_hunting.glb")))
	_check("the AK hits harder than the M4 and the carbine softer", (by_id[ZzWeaponIds.AK].tuning as GSWeaponBallistics).damage > (by_id[ZzWeaponIds.M4].tuning as GSWeaponBallistics).damage and (by_id[ZzWeaponIds.BREN].tuning as GSWeaponBallistics).damage < (by_id[ZzWeaponIds.M4].tuning as GSWeaponBallistics).damage)
	_end()


func _fire_bloom() -> void:
	_begin("fire bloom")
	var guns := [&"zz_m4", &"zz_ak", &"zz_bren", &"zz_lmg", &"zz_mp5", &"zz_p90", &"zz_smg", &"zz_vss", &"zz_scar", &"zz_glock",
		&"zz_aa12", &"zz_spas", &"zz_shotgun", &"zz_sniper", &"zz_hunting"]
	var by_id := {}
	for def in ZzWeaponPack.weapons():
		by_id[def.id] = def
	var bad: PackedStringArray = []
	for id: StringName in guns:
		var b := (by_id[id] as GSWeaponDef).tuning as GSWeaponBallistics
		# Slower than the 9 deg/s default, or the cone closes before the next shot and the crosshair never opens.
		if not (b.bloom > 0.0 and b.bloom_max >= b.bloom and b.bloom_recovery * 64.0 < 4.0):
			bad.append(String(id))
	_check("every automatic, burst, shotgun and sniper row blooms and recovers slowly (%s)" % ", ".join(bad), bad.is_empty())
	var sniper := (by_id[ZzWeaponIds.SNIPER] as GSWeaponDef).tuning as GSWeaponBallistics
	var m4 := (by_id[ZzWeaponIds.M4] as GSWeaponDef).tuning as GSWeaponBallistics
	_check("a sniper shot blooms more than a rifle's and recovers slower", sniper.bloom > 2.0 * m4.bloom and sniper.bloom_recovery < m4.bloom_recovery)
	_check("the sniper still rests at a pin point", is_zero_approx(sniper.spread) and is_zero_approx(sniper.spread_crouched))
	var worst := 0.0
	for id: StringName in guns:
		worst = maxf(worst, ((by_id[id] as GSWeaponDef).tuning as GSWeaponBallistics).bloom_max)
	_check("no held-fire cap exceeds 6 degrees", worst <= 6.0)
	for id: StringName in [ZzWeaponIds.M4, ZzWeaponIds.SMG, ZzWeaponIds.SNIPER, ZzWeaponIds.SPAS]:
		var ars := GSWeaponArsenal.new()
		ars.catalogue = ZzWeaponPack.catalogue()
		var rules := GSWeaponSpreadRules.new()
		rules.enabled = true
		ars.set(&"spread_rules", rules)
		add_child(ars)
		ars.setup()
		ars.give(id)
		var tick := 0
		var idle := GSWeaponCommand.new()
		idle.slot = (by_id[id] as GSWeaponDef).slot
		var _warm := ars.simulate_tick(idle, GSWeaponContext.make(1, tick, Vector3(0.0, 1.6, 0.0), Vector3.FORWARD))
		var rest := ars.spread_now()
		var fire := GSWeaponCommand.new()
		fire.set_button(GSWeaponCommand.BUTTON_ATTACK, true)
		fire.slot = idle.slot
		var peak := rest
		for t in 16:
			tick += 1
			var _o := ars.simulate_tick(fire, GSWeaponContext.make(1, tick, Vector3(0.0, 1.6, 0.0), Vector3.FORWARD))
			peak = maxf(peak, ars.spread_now())
		_check("%s: the arsenal reports a wider cone while firing (%.2f over %.2f)" % [id, peak, rest], peak > rest + 0.4)
		ars.queue_free()
	_end()


func _attachments() -> void:
	_begin("attachments")
	var known := [GSWeaponAttachment.MOUNT_OPTIC, GSWeaponAttachment.MOUNT_MUZZLE, GSWeaponAttachment.MOUNT_UNDERBARREL,
		GSWeaponAttachment.MOUNT_SIDE, GSWeaponAttachment.MOUNT_MAGAZINE]
	var bad_rows: PackedStringArray = []
	for id: StringName in ZzWeaponPack.MOUNTS:
		if not ZzWeaponIds.all().has(id):
			bad_rows.append(str(id))
		for m: StringName in ZzWeaponPack.MOUNTS[id]:
			if not known.has(m):
				bad_rows.append("%s/%s" % [id, m])
	_check("the mounts table names real guns and real mounts %s" % bad_rows, bad_rows.is_empty())
	var mounted: PackedStringArray = []
	var drift: PackedStringArray = []
	for def in ZzWeaponPack.weapons():
		if _NO_MOUNTS.has(def.id) and not def.mounts.is_empty():
			mounted.append(str(def.id))
		if str(def.mounts) != str(ZzWeaponPack.MOUNTS.get(def.id, [])):
			drift.append(str(def.id))
	_check("suppressed, built-in-sight, launcher, thrown and melee weapons take nothing %s" % mounted, mounted.is_empty())
	_check("every def carries its row of the mounts table %s" % drift, drift.is_empty())
	var cat := ZzAttachmentPack.catalogue()
	_check("the catalogue loads all six attachments from cfg", cat.ids().size() == 6 and _has_all(cat.ids(), ZzWeaponIds.attachment_ids()))
	var stale: PackedStringArray = []
	for id in ZzWeaponIds.attachment_ids():
		if FileAccess.get_file_as_string(ZzAttachmentPack.profile_path(id)) != ZzAttachmentPack.to_yaml(id):
			stale.append(str(id))
	_check("each shipped attachment yml is its built-in row %s" % stale, stale.is_empty())
	var unmarked: PackedStringArray = []
	for id in ZzWeaponIds.attachment_ids():
		var att := cat.get_attachment(id)
		var scene := load(att.model) as PackedScene if ResourceLoader.exists(att.model) else null
		var node := scene.instantiate() if scene != null else null
		if node == null:
			unmarked.append("%s: no model" % id)
			continue
		var marker := "Sight" if att.mount == GSWeaponAttachment.MOUNT_OPTIC else "Tip" if att.mount == GSWeaponAttachment.MOUNT_MUZZLE else ""
		if marker != "" and node.get_node_or_null(marker) == null:
			unmarked.append("%s: no %s" % [id, marker])
		node.free()
	_check("every model loads; optics mark a Sight, the suppressor a Tip %s" % unmarked, unmarked.is_empty())
	var empty_mounts: PackedStringArray = []
	var failed: PackedStringArray = []
	for def in ZzWeaponPack.weapons():
		var choices := cat.choices_for(def)
		for m: StringName in choices:
			if (choices[m] as Array).is_empty():
				empty_mounts.append("%s/%s" % [def.id, m])
			for att_id: StringName in choices[m]:
				var f := GSWeaponFitting.make(def.id)
				f.fit(m, att_id)
				var res := cat.apply(def, f)
				if not res.ok:
					failed.append("%s+%s: %s" % [def.id, att_id, res.error.message])
	_check("every mount of every gun has something to fit %s" % empty_mounts, empty_mounts.is_empty())
	_check("every attachment applies to every gun it fits %s" % failed, failed.is_empty())
	var m4 := ZzWeaponPack.catalogue().get_def(ZzWeaponIds.M4)
	var full := _full_fitting(cat, m4, ZzWeaponIds.ATT_RED_DOT)
	var fitted: GSWeaponDef = cat.apply(m4, full).value
	_check("the extended mag holds half again (M4 %d -> %d)" % [m4.magazine, fitted.magazine], fitted.magazine == int(round(m4.magazine * 1.5)))
	_check("the suppressor sets its param and tag", bool(fitted.params.get(GSWeaponAttachment.PARAM_SUPPRESSED, false)) and fitted.tags.has(&"suppressed"))
	var fb := fitted.tuning as GSWeaponBallistics
	var mb := m4.tuning as GSWeaponBallistics
	_check("grip, laser and red dot lower the numbers they name", fb.recoil_yaw < mb.recoil_yaw and fb.spread_moving < mb.spread_moving and fb.spread < mb.spread)
	var scoped := GSWeaponFitting.make(m4.id)
	scoped.fit(GSWeaponAttachment.MOUNT_OPTIC, ZzWeaponIds.ATT_SCOPE)
	var sd: GSWeaponDef = cat.apply(m4, scoped).value
	_check("the 4x scope sets a 0.25 zoom and the scoped tag", is_equal_approx(float(sd.params.get(GSWeaponAttachment.PARAM_ZOOM, 0.0)), 0.25) and sd.tags.has(&"scoped"))
	_check("a full fitting survives encode and decode", cat.decode(m4, cat.encode(m4, full)).key() == full.key())
	_attachment_zee_art()
	var ars := _make_arsenal()
	ars.attachments = cat
	var r := ars.fit(ZzWeaponIds.SLOT_PRIMARY, full)
	var slot_def := ars.slot_at(ZzWeaponIds.SLOT_PRIMARY).def
	_check("the arsenal fits the slot and keeps the catalogue's def", r.ok and slot_def.magazine == fitted.magazine and ars.catalogue.get_def(ZzWeaponIds.M4).magazine == m4.magazine)
	ars.queue_free()
	_end()


## The zee art and provider side of the attachments: sights, sockets and the catalogue it serves.
func _attachment_zee_art() -> void:
	var dot_art := ZzSpawnProvider.attachment_art(ZzWeaponIds.ATT_RED_DOT)
	var scope_art := ZzSpawnProvider.attachment_art(ZzWeaponIds.ATT_SCOPE)
	_check("zee art: the red dot is a glass sight and the scope a scoped one at 0.25", dot_art.get("aim") == &"glass" and ResourceLoader.exists(str(dot_art.get("path"))) and scope_art.get("aim") == &"scoped" and is_equal_approx(float(scope_art.get("zoom", 0.0)), 0.25))
	_check("zee art: an id that is not ours has no entry", ZzSpawnProvider.attachment_art(&"zee_red_dot").is_empty())
	var zee_sockets := ZzWeaponZeeArt.sockets_of(ZzWeaponIds.M4)
	_check("zee art: the M4 has optic, muzzle and underbarrel sockets as transforms", zee_sockets.has(GSWeaponAttachment.MOUNT_OPTIC) and zee_sockets.has(GSWeaponAttachment.MOUNT_MUZZLE) and zee_sockets.has(&"underbarrel") and zee_sockets[GSWeaponAttachment.MOUNT_OPTIC] is Transform3D)
	_check("the provider's catalogue has the six attachments", ZzSpawnProvider.attachments().ids().size() == 6)


func _has_all(have: Array, want: Array) -> bool:
	for x in want:
		if not have.has(x):
			return false
	return true


## Every mount [param def] has, filled with the first choice, [param optic] on the optic.
func _full_fitting(cat: GSWeaponAttachments, def: GSWeaponDef, optic: StringName) -> GSWeaponFitting:
	var f := GSWeaponFitting.make(def.id)
	var choices := cat.choices_for(def)
	for m: StringName in choices:
		if not (choices[m] as Array).is_empty():
			f.fit(m, optic if m == GSWeaponAttachment.MOUNT_OPTIC else (choices[m] as Array)[0])
	return f


func _attachment_view() -> void:
	_begin("attachments on the view and world models")
	var cat := ZzAttachmentPack.catalogue()
	var ars := _make_arsenal()
	ars.attachments = cat
	ars.select(ZzWeaponIds.SLOT_PRIMARY, 0)
	var vm := ZzViewModel.new()
	vm.auto_process = false
	vm.show_tracers = false
	add_child(vm)
	vm.bind(ars)
	var bare_muzzle := vm.muzzle().position
	var bare_aim: Vector3 = vm.pose.profile["aim"]
	var m4 := ars.current_def()
	ars.fit(ZzWeaponIds.SLOT_PRIMARY, _full_fitting(cat, m4, ZzWeaponIds.ATT_RED_DOT))
	_check("fitting the arsenal dresses all five mounts", _placed(vm) == 5)
	_check("the suppressor moves the muzzle to its tip", vm.muzzle().position.z < bare_muzzle.z - 0.1)
	_check("a fitted suppressor makes the gun quiet", vm.is_quiet())
	vm.aim(true)
	for i in 90:
		vm.step(1.0 / 60.0)
	var sight := ZzAttachmentDress.marker(vm._model, GSWeaponAttachment.MOUNT_OPTIC, "Sight")
	var eye := (vm.get_node("Animated") as Node3D).transform * ZzAttachmentDress.point_in(vm._model, sight) if sight != null else Vector3.ONE
	_check("aimed in, the red dot's sight is on the eye line %s" % eye, sight != null and Vector2(eye.x, eye.y).length() < 0.01 and eye.z < 0.0)
	_check("a red dot is not a scope", not vm.has_scope() and not vm.is_scoped())
	var scope := GSWeaponFitting.make(m4.id)
	scope.fit(GSWeaponAttachment.MOUNT_OPTIC, ZzWeaponIds.ATT_SCOPE)
	ars.fit(ZzWeaponIds.SLOT_PRIMARY, scope)
	for i in 90:
		vm.step(1.0 / 60.0)
	_check("aimed through the 4x scope the view zooms to 0.25", is_equal_approx(vm.aim_fov_scale(), 0.25))
	_check("scoped in, the weapon and arms are hidden for the overlay", vm.is_scoped() and vm.scope_fraction() > 0.99 and not (vm.get_node("Animated") as Node3D).visible)
	vm.aim(false)
	ars.fit(ZzWeaponIds.SLOT_PRIMARY, GSWeaponFitting.make(m4.id))
	for i in 90:
		vm.step(1.0 / 60.0)
	_check("unfitting restores the bare gun", _placed(vm) == 0 and vm.muzzle().position.is_equal_approx(bare_muzzle) and (vm.pose.profile["aim"] as Vector3).is_equal_approx(bare_aim) and not vm.has_scope() and not vm.is_quiet() and (vm.get_node("Animated") as Node3D).visible)
	vm.show_fitting(cat, _full_fitting(cat, ZzWeaponPack.catalogue().get_def(ZzWeaponIds.AK), ZzWeaponIds.ATT_RED_DOT))
	_check("a fitting for another gun shows nothing", _placed(vm) == 0)
	var wm := ZzWorldModel.new()
	add_child(wm)
	wm.set_weapon(ZzWeaponIds.M4)
	var world_bare := wm.muzzle().position
	var sup := GSWeaponFitting.make(ZzWeaponIds.M4)
	sup.fit(GSWeaponAttachment.MOUNT_MUZZLE, ZzWeaponIds.ATT_SUPPRESSOR)
	wm.set_fitting(cat, sup)
	_check("the world model wears the suppressor and moves its muzzle", _placed(wm) == 1 and wm.muzzle().position.z < world_bare.z - 0.1)
	vm.unbind()
	vm.queue_free()
	wm.queue_free()
	ars.queue_free()
	_end()


func _placed(n: Node) -> int:
	var count := 0
	for c in n.find_children("*", "", true, false):
		if c.has_meta(&"dot_attachment_model") and not c.is_queued_for_deletion():
			count += 1
	return count


func _make_arsenal() -> GSWeaponArsenal:
	var ars := GSWeaponArsenal.new()
	ars.catalogue = ZzWeaponPack.catalogue()
	add_child(ars)
	ars.setup()
	ars.give(ZzWeaponIds.M4)
	ars.give(ZzWeaponIds.KNIFE)
	return ars
