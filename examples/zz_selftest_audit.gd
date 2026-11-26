extends "zz_selftest_attachments.gd"

## Per-weapon audit sections of the headless suite (sounds, icons). zz_selftest.gd extends this and has the rest.


func _view_sounds() -> void:
	var stocked := GSWeaponSound.count(&"rifle_fire") > 0
	_check("the hook plays gs-audio's stock when linked and is silent when not", (ZzWeaponSound.stream_for(ZzWeaponIds.M4, ZzWeaponSound.FIRE) != null) == stocked)
	var unclassed: PackedStringArray = []
	for wid in ZzWeaponIds.all():
		if not ZzWeaponSound.CLASSES.has(wid):
			unclassed.append(String(wid))
	_check("every weapon has a sound class (%s)" % ", ".join(unclassed), unclassed.is_empty())
	var sound_problems := GSWeaponSound.check_classes(ZzWeaponSound.CLASSES)
	_check("every weapon's class has fire, reload and dry files of a fitting length: %s" % "; ".join(sound_problems), sound_problems.is_empty())
	var mute: PackedStringArray = []
	for wid in ZzWeaponIds.all():
		var melee: bool = ZzWeaponSound.CLASSES.get(wid, &"") in [&"swing", &"bash"]
		var throw: bool = ZzWeaponSound.CLASSES.get(wid, &"") == &"throw"
		var kinds: Array[StringName] = [ZzWeaponSound.FIRE]
		if not melee or wid in ZzWeaponSound._BLADES:
			kinds.append(ZzWeaponSound.DRAW)
		if not melee and not throw:
			kinds.append_array([ZzWeaponSound.RELOAD, ZzWeaponSound.RELOAD_IN, ZzWeaponSound.DRY])
		for kind in kinds:
			if ZzWeaponSound.stream_for(wid, kind) == null:
				mute.append("%s/%s" % [wid, kind])
	_check("every weapon plays a stock sound for each cue it uses: %s" % ", ".join(mute), mute.is_empty())
	var stock_problems := GSWeaponSound.check_stock()
	_check("stock files are present, not clipped and not silent: %s" % "; ".join(stock_problems), stock_problems.is_empty())
	var shared := GSWeaponSound.check_unique()
	_check("no two sound classes share a recording: %s" % "; ".join(shared), shared.is_empty())


func _audit_icons(entries: Array) -> void:
	var missing: PackedStringArray = []
	for e: Dictionary in entries:
		if String(e["icon"]) == "" or not ResourceLoader.exists(String(e["icon"])):
			missing.append(String(e["id"]))
	_check("every spawn entry names an icon that loads (%s)" % ", ".join(missing), missing.is_empty())
