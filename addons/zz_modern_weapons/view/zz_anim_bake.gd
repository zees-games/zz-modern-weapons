class_name ZzAnimBake
extends RefCounted

## Samples a weapon's procedural first-person motion into keyframed tracks, from the code the game runs: a real [ZzViewModel] is driven through each
## clip (fire or swing, reload, reload_empty, draw, holster, inspect, idle) at 60 fps and the weapon's transform is read back each frame; no number is copied.
## Used by tools/export_anim_tracks.gd (Nightly's asset viewer plays the sidecar next to the model) and the suite.
## Space: the view model's own (the camera's frame, no hands lens), metres, -Z forward. The sidecar format is Nightly's version 1 (lib/anim-sample.mjs).

const Sidecar := preload("res://addons/gs_weapon/view/gs_weapon_anim_sidecar.gd")
const FPS := Sidecar.FPS
const STEP := Sidecar.STEP
const TICK_RATE := 64.0
## Frames the pose settles for before a clip is recorded (the draw keys finish, the springs rest).
const SETTLE := 90
## Shortest holster the clip shows: the game's is a tenth of a second, which reads as a pop in a viewer.
const MIN_HOLSTER := 0.3
## No hands lens in this pack: the game draws the view model at the world's field of view, so the viewer's lens is the identity.
const PACK := "zz-modern-weapons"

var _vm: ZzViewModel = null
var _values: Array = []
var _bolt: Array = []
var _frames := 0


## The clips a weapon has, in play order, each {name, loop}. A gun with a magazine reloads; a melee weapon or a grenade has no reload.
static func clip_names(def: GSWeaponDef) -> Array[Dictionary]:
	var out: Array[Dictionary] = [{"name": "fire", "loop": false}]
	if def != null and def.uses_magazine() and def.reload_ticks > 0:
		out.append({"name": "reload", "loop": false})
		out.append({"name": "reload_empty", "loop": false})
	out.append({"name": "draw", "loop": false})
	out.append({"name": "holster", "loop": false})
	out.append({"name": "inspect", "loop": false})
	out.append({"name": "idle", "loop": false})
	return out


## Bakes every clip of weapon [param id] under [param host] (a node in the tree). Returns the sidecar dictionary, or {} for an unknown id or a weapon with no model file.
func bake(host: Node, id: StringName, def: GSWeaponDef) -> Dictionary:
	if not ZzWeaponArt.TABLE.has(id) or ZzWeaponArt.is_placeholder(id):
		return {}
	var model: String = ZzWeaponArt.TABLE[id]["model"]
	var clips: Array = []
	var bolt_node := ""
	for c in clip_names(def):
		_vm = ZzViewModel.new()
		_vm.auto_process = false
		_vm.show_tracers = false
		_vm.play_builtin_sounds = false
		host.add_child(_vm)
		_vm.show_weapon(id, false)
		var baked := _clip(String(c.name), bool(c.loop), def)
		clips.append(baked)
		if (baked.tracks as Array).size() > 1:
			bolt_node = "slide"
		host.remove_child(_vm)
		_vm.free()
	return Sidecar.sidecar(String(id), model.get_basename(), Sidecar.asset_of(PACK, "res://addons/zz_modern_weapons/assets/" + model.get_basename()),
		Sidecar.lens_identity(), bolt_node, "", clips)


## The models are one merged mesh each, so no weapon has a magazine node and only the pistol's procedural slide (a part split off its mesh) is a bolt: its transform is baked relative to the weapon.
func _clip(name: String, loop: bool, def: GSWeaponDef) -> Dictionary:
	_values = []
	_bolt = []
	_frames = 0
	_run(1.5)
	_values = []
	_bolt = []
	_frames = 0
	var pose := _vm.pose
	match name:
		"fire":
			_snap()
			pose.fire(1.0)
			_run(0.8)
		"reload", "reload_empty":
			var seconds := maxf(_vm.reload_seconds_for(def, def.magazine), 0.5)
			pose.slide_locked = name == "reload_empty"
			_snap()
			pose.start_reload(seconds, name == "reload_empty")
			_run(seconds + 0.25)
		"draw":
			pose.draw(maxf(float(def.deploy_ticks) / TICK_RATE if def != null else 0.0, 0.4))
			_run(maxf(float(def.deploy_ticks) / TICK_RATE if def != null else 0.0, 0.4) + 0.2)
		"holster":
			var seconds := maxf(float(def.holster_ticks) / TICK_RATE if def != null else 0.0, MIN_HOLSTER)
			_snap()
			pose.holster(seconds)
			_run(seconds + 0.1)
		"inspect":
			_snap()
			pose.inspect()
			_run(2.4)
		"idle":
			_snap()
			_run(4.0)
	var tracks: Array = [Sidecar.track("weapon", "transform", _values)]
	if not _bolt.is_empty():
		tracks.append(Sidecar.track("bolt", "transform", _bolt))
	return Sidecar.clip(name, loop, _frames, tracks)


func _run(seconds: float) -> void:
	for _i in int(ceil(seconds * FPS)):
		_vm.step(STEP)
		_snap()


func _snap() -> void:
	var t := _vm.weapon_transform()
	_values.append_array(Sidecar.t7(t))
	var slide := _vm.part_node(&"slide")
	if slide != null:
		_bolt.append_array(Sidecar.t7(slide.transform))
	_frames += 1

