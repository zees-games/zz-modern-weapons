class_name ZzShotFx
extends RefCounted

## Muzzle flash, tracer and impact, built in code (no art file to vendor) and gone in a fraction
## of a second. All presentation: a shot's real origin and hit are the server's. Each function
## adds a node to [param world] that frees itself, and returns it so a test can look at it.

const FLASH_SECONDS := 0.05
const TRACER_SECONDS := 0.07
const IMPACT_SECONDS := 0.25
const TRACER_COLOR := Color(1.0, 0.85, 0.45)


## A short bright flash at [param muzzle] (a Node3D on the weapon, so it follows the kick).
static func flash(muzzle: Node3D, size: float = 1.0) -> Node3D:
	if muzzle == null or not muzzle.is_inside_tree():
		return null
	var root := Node3D.new()
	root.name = "MuzzleFlash"
	var quad := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.04 * size
	sphere.height = 0.08 * size
	quad.mesh = sphere
	quad.scale = Vector3(1, 1, 2.2)
	quad.material_override = _glow(Color(1.0, 0.8, 0.35))
	quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(quad)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.75, 0.4)
	light.light_energy = 2.0 * size
	light.omni_range = 3.0
	light.shadow_enabled = false
	root.add_child(light)
	muzzle.add_child(root)
	_expire(root, FLASH_SECONDS)
	return root


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


static func _glow(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	return m
