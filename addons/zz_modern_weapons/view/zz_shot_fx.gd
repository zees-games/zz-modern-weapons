class_name ZzShotFx
extends RefCounted

## Muzzle flash, tracer and impact, built in code (no art file to vendor) and gone in a fraction
## of a second. All presentation: a shot's real origin and hit are the server's. Each function
## adds a node to [param world] that frees itself, and returns it so a test can look at it.

const FLASH_SECONDS := 0.05
const TRACER_SECONDS := 0.07
const SMOKE_SECONDS := 0.45
const SHELL_SECONDS := 0.5
const IMPACT_SECONDS := 0.25
const TRACER_COLOR := Color(1.0, 0.85, 0.45)
const POOLED_META := "zz_pooled_flash_"


## Flash, smoke and light at [param muzzle] (a Node3D at the barrel tip on the weapon, so it follows the
## kick), pointing along -Z. [param size] scales it; a suppressed gun passes about a third.
static func flash(muzzle: Node3D, size: float = 1.0, weapon_id: StringName = &"", first_person: bool = false) -> Node3D:
	if muzzle == null or not muzzle.is_inside_tree():
		return null
	if weapon_id != &"" and _pooled_flash(muzzle, weapon_id, first_person):
		return _pooled_for(muzzle, weapon_id)
	var root := Node3D.new()
	root.name = "MuzzleFlash"
	var burst := Node3D.new()
	burst.name = "Burst"
	root.add_child(burst)
	for roll in [0.0, PI * 0.5]:
		var blade := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(0.07, 0.16) * size
		blade.mesh = quad
		blade.material_override = _glow(Color(1.0, 0.8, 0.35), true)
		blade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# A quad faces +Z; turned a quarter about X its long side runs down the barrel, rolled about it for the cross.
		blade.transform = Transform3D(Basis(Vector3.BACK, roll) * Basis(Vector3.RIGHT, PI * 0.5), Vector3(0.0, 0.0, -0.08 * size))
		burst.add_child(blade)
	var core := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.02 * size
	sphere.height = 0.04 * size
	core.mesh = sphere
	core.material_override = _glow(Color(1.0, 0.95, 0.7))
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	burst.add_child(core)
	var smoke := MeshInstance3D.new()
	smoke.name = "Smoke"
	var puff := SphereMesh.new()
	puff.radius = 0.025 * size
	puff.height = 0.05 * size
	smoke.mesh = puff
	smoke.material_override = _glow(Color(0.7, 0.7, 0.72, 0.35), true)
	smoke.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	smoke.position = Vector3(0.0, 0.0, -0.05 * size)
	root.add_child(smoke)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.75, 0.4)
	light.light_energy = 2.0 * size
	light.omni_range = 3.0 * minf(size, 1.0)
	light.shadow_enabled = false
	burst.add_child(light)
	muzzle.add_child(root)
	_expire(burst, FLASH_SECONDS)
	_expire(root, SMOKE_SECONDS)
	if smoke.is_inside_tree():
		var tw := smoke.create_tween()
		tw.tween_property(smoke, "scale", Vector3.ONE * 3.0, SMOKE_SECONDS)
	return root


static func _pooled_key(id: StringName) -> String:
	return POOLED_META + str(ZzWeaponArt.is_suppressed(id)) + ZzWeaponArt.flash_category(id)


static func _pooled_for(muzzle: Node3D, id: StringName) -> Node3D:
	return muzzle.get_meta(_pooled_key(id))


## Plays dot-fx's pooled flash on [param muzzle], built once and kept on it. False when dot-fx draws
## nothing here (not linked, headless, suppressed), and the procedural flash below is used.
static func _pooled_flash(muzzle: Node3D, id: StringName, first_person: bool) -> bool:
	var key := _pooled_key(id)
	if not muzzle.has_meta(key):
		muzzle.set_meta(key, DotWeaponMuzzle.attach(muzzle, ZzWeaponArt.flash_category(id), null, first_person, ZzWeaponArt.is_suppressed(id)))
	var pooled: Variant = muzzle.get_meta(key)
	return pooled != null and is_instance_valid(pooled) and DotWeaponMuzzle.fire(pooled)


## A spent case thrown from [param from] along [param right] and up, falling under gravity.
static func shell(world: Node, from: Vector3, right: Vector3) -> Node3D:
	if world == null or not world.is_inside_tree():
		return null
	var mi := MeshInstance3D.new()
	mi.name = "Shell"
	var box := BoxMesh.new()
	box.size = Vector3(0.008, 0.008, 0.022)
	mi.mesh = box
	mi.material_override = _glow(Color(0.85, 0.65, 0.25))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(mi)
	mi.global_position = from
	var v := right.normalized() * 1.6 + Vector3.UP * 1.8
	var tw := mi.create_tween()
	tw.tween_method(func(t: float) -> void: mi.global_position = from + v * t + Vector3.DOWN * 4.9 * t * t, 0.0, SHELL_SECONDS, SHELL_SECONDS)
	_expire(mi, SHELL_SECONDS)
	return mi


## A streak from [param from] to [param to] in world space. A tracer is a stretched, unshaded
## box; a sphere-sweep would be dearer for something visible for four frames.
static func tracer(world: Node, from: Vector3, to: Vector3) -> Node3D:
	if world == null or not world.is_inside_tree() or from.distance_to(to) < 0.05:
		return null
	var mi := MeshInstance3D.new()
	mi.name = "Tracer"
	var box := BoxMesh.new()
	box.size = Vector3(0.012, 0.012, 1.0)
	mi.mesh = box
	mi.material_override = _glow(TRACER_COLOR)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(mi)
	var dir := to - from
	var up := Vector3.UP if absf(dir.normalized().dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	mi.global_transform = Transform3D(Basis.looking_at(dir, up).scaled(Vector3(1, 1, dir.length())), (from + to) * 0.5)
	_expire(mi, TRACER_SECONDS)
	return mi


## A puff and a spark where a shot landed, facing out of the surface.
static func impact(world: Node, point: Vector3, normal: Vector3) -> Node3D:
	if world == null or not world.is_inside_tree():
		return null
	var root := Node3D.new()
	root.name = "Impact"
	var puff := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = 0.05
	s.height = 0.1
	puff.mesh = s
	puff.material_override = _glow(Color(0.75, 0.7, 0.62))
	puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(puff)
	world.add_child(root)
	root.global_position = point + normal * 0.02
	var tw := root.create_tween()
	tw.tween_property(puff, "scale", Vector3.ONE * 2.5, IMPACT_SECONDS)
	_expire(root, IMPACT_SECONDS)
	return root


static func _expire(node: Node, seconds: float) -> void:
	node.get_tree().create_timer(seconds).timeout.connect(node.queue_free)


static func _glow(c: Color, blend: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	if blend:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m
