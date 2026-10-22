extends Node3D

## A render target for tools/screenshot.sh: every weapon on a rack (no argument), or one
## weapon close up (`-- --weapon zz_smg`). Not headless: a headless frame is black.
## `--seconds N` quits after N seconds.

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var only := ""
	var seconds := 0.0
	var shot := ""
	for i in args.size():
		if args[i] == "--weapon" and i + 1 < args.size():
			only = args[i + 1]
		elif args[i] == "--shot" and i + 1 < args.size():
			shot = args[i + 1]
		elif args[i] == "--seconds" and i + 1 < args.size():
			seconds = float(args[i + 1])

	var ids: Array[StringName] = ZzWeaponIds.all()
	if only != "":
		var want := StringName(only if only.begins_with("zz_") else "zz_" + only)
		if ZzWeaponArt.TABLE.has(want):
			ids = [want] as Array[StringName]

	var env := ZzReflectionSource.sky_environment()
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -35, 0)
	add_child(sun)

	var spacing := 1.35 if ids.size() > 1 else 0.0
	var x0 := -spacing * float(ids.size() - 1) * 0.5
	for i in ids.size():
		var model := ZzWeaponArt.instantiate(ids[i])
		if model == null:
			continue
		add_child(model)
		# Side on (muzzle to the left) so the silhouette reads.
		model.rotation_degrees = Vector3(0, -90, 0) if ids[i] != ZzWeaponIds.KNIFE else Vector3(0, 0, 90)
		model.position = Vector3(x0 + spacing * i, 0, 0)

		var tag := Label3D.new()
		tag.text = "%s\n(placeholder)" % ZzWeaponIds.short_name(ids[i]) if ZzWeaponArt.is_placeholder(ids[i]) else ZzWeaponIds.short_name(ids[i])
		tag.font_size = 48
		tag.pixel_size = 0.0032
		tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		tag.position = Vector3(x0 + spacing * i, -0.3, 0)
		add_child(tag)

	var cam := Camera3D.new()
	var span := maxf(spacing * float(ids.size()), 1.3)
	cam.position = Vector3(0, 0.0, span * (0.38 if ids.size() > 1 else 0.8))
	add_child(cam)
	cam.current = true

	if shot != "":
		# A few frames so the first render has happened; the viewport, not the screen.
		for i in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(shot)
		get_tree().quit()
		return

	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
		get_tree().quit()
