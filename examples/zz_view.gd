extends Node3D

## A render target for tools/screenshot.sh --view / --world: a contact sheet of the view model or of a watcher's
## view of a person holding the weapon, at fixed 60 fps steps. Not headless. Usage: -- --weapon zz_m4 --shot out.png [--world]

const STEP := 1.0 / 60.0
const CELL := Vector2i(400, 225)

var _cam := Camera3D.new()
var _frames: Array[Image] = []
var _labels: Array[String] = []


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var id := &"zz_m4"
	var shot := ""
	var world := args.has("--world")
	for i in args.size():
		if args[i] == "--weapon" and i + 1 < args.size():
			id = StringName(args[i + 1] if args[i + 1].begins_with("zz_") else "zz_" + args[i + 1])
		elif args[i] == "--shot" and i + 1 < args.size():
			shot = args[i + 1]
	_scenery()
	if world:
		await _world_sheet(id)
	else:
		await _view_sheet(id)
	if shot != "":
		_save_sheet(shot)
		get_tree().quit()


func _scenery() -> void:
	# --probe: a flat-colour world with no sky, lit only by the view model's own reflection probe.
	var env := ZzReflectionSource.sky_environment()
	if OS.get_cmdline_user_args().has("--probe"):
		env = Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.55, 0.65, 0.75)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.6, 0.6, 0.65)
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.shadow_enabled = true
	add_child(sun)
	for spec in [[Vector3(0, -0.05, 0), Vector3(40, 0.1, 40), Color(0.35, 0.45, 0.3)], [Vector3(0, 2, -8), Vector3(12, 4, 0.3), Color(0.6, 0.55, 0.5)]]:
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = spec[1]
		cs.shape = shape
		body.add_child(cs)
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = spec[1]
		mi.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = spec[2]
		mi.material_override = mat
		body.add_child(mi)
		body.position = spec[0]
		add_child(body)
	add_child(_cam)
	_cam.current = true
	_cam.fov = 75.0


func _snap(label: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	# A real GPU hands back RGB8, llvmpipe RGBA8; blit_rect refuses a mix and the sheet stays black.
	img.convert(Image.FORMAT_RGBA8)
	img.resize(CELL.x, CELL.y, Image.INTERPOLATE_BILINEAR)
	_frames.append(img)
	_labels.append(label)


func _run(vm: Object, seconds: float) -> void:
	var n := int(round(seconds / STEP))
	for i in n:
		vm.step(STEP)


func _view_sheet(id: StringName) -> void:
	_cam.position = Vector3(0, 1.6, 0)
	var vm := ZzViewModel.new()
	vm.auto_process = false
	vm.provide_reflections = OS.get_cmdline_user_args().has("--probe")
	_cam.add_child(vm)
	vm.show_weapon(id, false)
	_run(vm, 1.0)
	await _snap("hip")
	vm.pose.draw(0.4)
	_run(vm, 0.12)
	await _snap("draw 0.12s")
	_run(vm, 0.5)
	vm.aim(true)
	_run(vm, 0.3)
	await _snap("aim")
	vm.aim(false)
	_run(vm, 0.3)
	vm.play_shot(1.0)
	_run(vm, 0.02)
	await _snap("fire +0.02s")
	_run(vm, 0.06)
	await _snap("recoil +0.08s")
	_run(vm, 1.0)
	vm.pose.start_reload(1.6)
	for t in [0.4, 0.8, 1.2]:
		_run(vm, 0.4)
		await _snap("reload %.1fs" % t)


func _world_sheet(id: StringName) -> void:
	# From the person's right, a little ahead, so the weapon is seen in profile.
	_cam.position = Vector3(2.0, 1.35, -4.2)
	_cam.look_at(Vector3(0.2, 1.2, -4.9))
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.25
	cap.height = 1.7
	body.mesh = cap
	body.position = Vector3(0, 0.85, -4.5)
	add_child(body)
	var arm := MeshInstance3D.new()
	var abox := BoxMesh.new()
	abox.size = Vector3(0.1, 0.1, 0.55)
	arm.mesh = abox
	arm.position = Vector3(0.28, 1.25, -4.75)
	add_child(arm)
	var hand := Marker3D.new()
	hand.position = Vector3(0.28, 1.25, -5.0)
	add_child(hand)
	var wm := ZzWorldModel.new()
	hand.add_child(wm)
	var holder := ZzFakeNet.new()
	wm.apply_net(holder, id)
	wm.step(1.0)
	await _snap("idle")
	holder.net_fire_seq = 1
	wm.apply_net(holder, id)
	wm.step(0.03)
	await _snap("fire +0.03s")
	wm.step(0.08)
	await _snap("recoil +0.1s")
	holder.net_reloading = true
	wm.apply_net(holder, id)
	for t in [0.4, 0.8, 1.2]:
		wm.step(0.4)
		await _snap("reload %.1fs" % t)
	holder.net_reloading = false
	holder.net_switching = true
	wm.apply_net(holder, id)
	holder.net_switching = false
	wm.apply_net(holder, id)
	wm.step(0.1)
	await _snap("draw 0.1s")


func _save_sheet(path: String) -> void:
	var cols := 4
	var rows := int(ceil(float(_frames.size()) / cols))
	var sheet := Image.create(CELL.x * cols, CELL.y * rows, false, Image.FORMAT_RGBA8)
	for i in _frames.size():
		sheet.blit_rect(_frames[i], Rect2i(Vector2i.ZERO, CELL), Vector2i((i % cols) * CELL.x, (i / cols) * CELL.y))
	sheet.save_png(path)
	print("frames: ", ", ".join(_labels))
