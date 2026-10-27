extends Node3D

## A render target for tools/screenshot.sh: every weapon on a rack (no argument), or one
## weapon close up (`-- --weapon zz_smg`). Not headless: a headless frame is black.
## `--seconds N` quits after N seconds. `--muzzle` marks each model's measured barrel tip: a red dot
## and a yellow shaft along the bore, which is where the flash, tracer and smoke start.

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var only := ""
	var seconds := 0.0
	var shot := ""
	var listed := PackedStringArray()
	for i in args.size():
		if args[i] == "--weapon" and i + 1 < args.size():
			only = args[i + 1]
		elif args[i] == "--weapons" and i + 1 < args.size():
			listed = args[i + 1].split(",")
		elif args[i] == "--shot" and i + 1 < args.size():
			shot = args[i + 1]
		elif args[i] == "--seconds" and i + 1 < args.size():
			seconds = float(args[i + 1])

	var ids: Array[StringName] = ZzWeaponIds.all()
	if only != "":
		var want := StringName(only if only.begins_with("zz_") else "zz_" + only)
		if ZzWeaponArt.TABLE.has(want):
			ids = [want] as Array[StringName]

	if not listed.is_empty():
		ids = []
		for w in listed:
			ids.append(StringName(w if w.begins_with("zz_") else "zz_" + w))

	var env := ZzReflectionSource.sky_environment()
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -35, 0)
	add_child(sun)

	var spacing := (1.0 if not listed.is_empty() else 1.35) if ids.size() > 1 else 0.0
	var x0 := -spacing * float(ids.size() - 1) * 0.5
	for i in ids.size():
		var model := ZzWeaponArt.instantiate(ids[i])
		if model == null:
			continue
		add_child(model)
		# Side on (muzzle to the left) so the silhouette reads.
		model.rotation_degrees = Vector3(0, -90, 0) if ids[i] != ZzWeaponIds.KNIFE else Vector3(0, 0, 90)
		model.position = Vector3(x0 + spacing * i, 0, 0)
		if args.has("--muzzle"):
			_mark_muzzle(model, ids[i])

		var tag := Label3D.new()
		tag.text = "%s\n(placeholder)" % ZzWeaponIds.short_name(ids[i]) if ZzWeaponArt.is_placeholder(ids[i]) else ZzWeaponIds.short_name(ids[i])
		tag.font_size = 48
		tag.pixel_size = 0.0032
		tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		tag.position = Vector3(x0 + spacing * i, -0.3, 0)
		add_child(tag)

	var cam := Camera3D.new()
	var span := maxf(spacing * float(ids.size()), 1.3)
	cam.position = Vector3(0, 0.0, 1.5 if not listed.is_empty() else span * (0.38 if ids.size() > 1 else 0.8))
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


func _mark_muzzle(model: Node3D, id: StringName) -> void:
	var tip := ZzWeaponArt.muzzle_point(id)
	var dot := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.012
	ball.height = 0.024
	dot.mesh = ball
	dot.position = tip
	dot.material_override = _flat(Color(1.0, 0.1, 0.1))
	model.add_child(dot)
	var shaft := MeshInstance3D.new()
	var rod := CylinderMesh.new()
	rod.top_radius = 0.004
	rod.bottom_radius = 0.004
	rod.height = 0.12
	shaft.mesh = rod
	shaft.rotation = Vector3(PI * 0.5, 0.0, 0.0)
	shaft.position = tip + Vector3(0.0, 0.0, -0.06)
	shaft.material_override = _flat(Color(1.0, 0.9, 0.1))
	model.add_child(shaft)


func _flat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	m.no_depth_test = true
	return m
