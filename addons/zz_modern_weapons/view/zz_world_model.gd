class_name ZzWorldModel
extends Node3D

## The third-person weapon: what a watcher sees in somebody else's hand. A child of the hand
## attachment of the carrier's figure (a bone attachment, or a Marker3D in the placeholder body).
## It is fed by the replicated fields ([ZzWeaponNet]) and moves with the same [ZzModernWeaponPose] as the
## view model, at the scale of the world: a kick when the fire counter advances, a roll for a
## reload, the draw when a switch ends. Casts a shadow (the view model does not).
##
## It never reads the arsenal: a watcher does not have one. [method apply_net] takes the
## replicated object and the weapon id the game resolved from the replicated slot.

signal sound_requested(kind: StringName, weapon_id: StringName, at: Vector3)

## The world model hangs off a hand, and a hand is smaller in the picture than a view model is in
## the camera's: the same motion at this fraction of the distance.
@export var motion_scale: float = 0.6
@export var reload_seconds: float = 1.6
@export var deploy_seconds: float = 0.4

var pose := ZzModernWeaponPose.new()
var weapon_id: StringName = &""

var _model: Node3D = null
var _muzzle := Node3D.new()
var _last_seq: int = -1
var _was_reloading: bool = false
var _was_switching: bool = false


func _init() -> void:
	name = "ZzWorldModel"
	pose.scale_factor = motion_scale
	_muzzle.name = "Muzzle"
	add_child(_muzzle)


func set_weapon(id: StringName) -> void:
	if id == weapon_id and _model != null:
		return
	if _model != null:
		remove_child(_model)
		_model.free()
		_model = null
	weapon_id = id
	pose.scale_factor = motion_scale
	pose.set_weapon(id)
	_model = ZzWeaponArt.instantiate(id)
	if _model == null:
		return
	add_child(_model)
	_muzzle.position = ZzWeaponArt.muzzle_point(id)
	for n in _model.find_children("*", "GeometryInstance3D", true, false):
		(n as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func muzzle() -> Node3D:
	return _muzzle


## Feed it every snapshot. The first call only learns the counter, so a player who walks into
## view does not appear to fire the shots they fired before.
func apply_net(source: Object, id: StringName) -> void:
	if source == null:
		return
	set_weapon(id)
	var state := ZzWeaponNet.read(source)
	var seq: int = state["seq"]
	if _last_seq >= 0:
		var uses := ZzWeaponNet.uses_between(_last_seq, seq)
		if uses > 0:
			play_use()
	_last_seq = seq
	var reloading: bool = state["reloading"]
	if reloading and not _was_reloading:
		pose.start_reload(reload_seconds)
		sound_requested.emit(ZzWeaponSound.RELOAD, weapon_id, global_position)
	elif _was_reloading and not reloading:
		pose.cancel_reload()
	_was_reloading = reloading
	var switching: bool = state["switching"]
	if switching and not _was_switching:
		pose.holster(0.3)
	elif _was_switching and not switching:
		pose.draw(deploy_seconds)
		sound_requested.emit(ZzWeaponSound.DRAW, weapon_id, global_position)
	_was_switching = switching


## One use seen from outside: the kick or swing, the flash, the sound.
func play_use() -> void:
	pose.fire(1.0)
	if pose.motion == &"gun" and is_inside_tree():
		ZzShotFx.flash(_muzzle, 0.4 if ZzWeaponArt.is_suppressed(weapon_id) else 1.2)
		var world: Node = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
		var from := _muzzle.global_position
		var axis := -_muzzle.global_basis.z
		var far := from + axis * 60.0
		var hit := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, far))
		var _t := ZzShotFx.tracer(world, from, hit["position"] if not hit.is_empty() else far)
		if ZzWeaponArt.ejects(weapon_id):
			var _s := ZzShotFx.shell(world, to_global(ZzWeaponArt.ejection_point(weapon_id)), global_basis.x)
		sound_requested.emit(ZzWeaponSound.FIRE, weapon_id, _muzzle.global_position)


func _process(delta: float) -> void:
	step(delta)


func step(delta: float) -> void:
	pose.advance(delta, 0.0)
	transform = Transform3D(Basis.IDENTITY, Vector3.ZERO) * pose.offset()
