class_name ZzViewModel
extends Node3D

## The first-person weapon with arms: a child of the camera, driven by a [DotWeaponArsenal]'s
## signals. Draw, idle sway, recoil, reload and aim come from [ZzWeaponPose]; flash, tracer,
## impact and sound hooks from [ZzShotFx] and [ZzWeaponSound]. Everything here is presentation: a
## player with no view model simulates identically (nothing in the arsenal reads this node).
##
## [b]The art is [ZzWeaponArt]'s alone[/b]: a placeholder or a real glb arrives as a Node3D with its
## origin at the grip and its muzzle toward -Z, and this node never asks which it got.
##
## Why not zee-dot-weapons' [code]ZeeViewModel[/code]: that class names its own art table and ids, and
## this pack may not require another optional addon. A nightly item records the generalisation.

## A sound is wanted. [param kind] is a [ZzWeaponSound] kind; [param at] is the muzzle in world
## space. A game with an audio engine connects this; [member play_builtin_sounds] covers the rest.
signal sound_requested(kind: StringName, weapon_id: StringName, at: Vector3)
## A shot's flash left the muzzle (for a test, or a HUD's hit-marker logic).
signal flashed(weapon_id: StringName)

@export var show_arms: bool = true
@export var show_tracers: bool = true
## Render-frame processing. Off, a caller drives [method step] (a test, a contact sheet).
@export var auto_process: bool = true
@export var play_builtin_sounds: bool = true
## Hang a reflection probe on the view model, for a world whose environment has no sky to mirror.
## A game with a sky leaves it off; docs/lighting.md says why.
@export var provide_reflections: bool = false

var pose := ZzWeaponPose.new()
var weapon_id: StringName = &""
var arsenal: DotWeaponArsenal = null
## Ground speed of the carrier, m/s, set by the host each frame; drives the bob.
var carrier_speed: float = 0.0

var _animated := Node3D.new()
var _holder := Node3D.new()
var _muzzle := Node3D.new()
var _model: Node3D = null
var _arms := ZzViewArms.new()
var _audio := AudioStreamPlayer3D.new()


func _init() -> void:
	name = "ZzViewModel"
	_animated.name = "Animated"
	_holder.name = "Holder"
	_muzzle.name = "Muzzle"
	add_child(_arms)
	add_child(_animated)
	_animated.add_child(_holder)
	_holder.add_child(_muzzle)
	_audio.name = "Audio"
	add_child(_audio)


func _ready() -> void:
	set_process(auto_process)
	if provide_reflections:
		ZzReflectionSource.attach_probe(self)


## Listens to an arsenal. Call once; [method unbind] first to move to another.
func bind(source: DotWeaponArsenal) -> void:
	unbind()
	arsenal = source
	if arsenal == null:
		return
	arsenal.used.connect(_on_used)
	arsenal.dry_used.connect(_on_dry)
	arsenal.reload_started.connect(_on_reload_started)
	arsenal.switched.connect(_on_switched)
	var def := arsenal.current_def()
	if def != null:
		show_weapon(def.id, false)


func unbind() -> void:
	if arsenal != null and is_instance_valid(arsenal):
		arsenal.used.disconnect(_on_used)
		arsenal.dry_used.disconnect(_on_dry)
		arsenal.reload_started.disconnect(_on_reload_started)
		arsenal.switched.disconnect(_on_switched)
	arsenal = null


## Swaps the model. [param play_draw] starts the draw keys.
func show_weapon(id: StringName, play_draw: bool = true) -> void:
	if _model != null:
		_holder.remove_child(_model)
		_model.free()
		_model = null
	weapon_id = id
	pose.set_weapon(id)
	_model = ZzWeaponArt.instantiate(id)
	if _model == null:
		return
	_holder.add_child(_model)
	_muzzle.position = Vector3(0.0, 0.03, -ZzWeaponArt.muzzle_distance(id))
	if play_draw:
		pose.draw(_seconds_for_ticks(arsenal.current_def().deploy_ticks) if _has_def() else 0.4)
		sound_requested.emit(ZzWeaponSound.DRAW, id, _muzzle.global_position)
	_apply()


func muzzle() -> Node3D:
	return _muzzle


func has_model() -> bool:
	return _model != null


func aim(held: bool) -> void:
	pose.set_aim(held)


func aim_fov_scale() -> float:
	return pose.fov_scale()


## The holster plays the draw backwards; the host calls it when a switch begins.
func holster() -> void:
	pose.holster(_seconds_for_ticks(arsenal.current_def().holster_ticks) if _has_def() else 0.3)


func _process(delta: float) -> void:
	step(delta)


## One presentation step (seconds). Public so a test or a sheet can run a fixed time.
func step(delta: float) -> void:
	pose.advance(delta, carrier_speed)
	_apply()


func _apply() -> void:
	if pose.profile.is_empty():
		return
	var off := pose.offset()
	var rest := Transform3D(Basis.IDENTITY, pose.hold())
	# A rotation about the grip, not about the camera: the origin is the grip, so applying the
	# offset in the weapon's own frame turns the gun in the hand instead of swinging it across the
	# screen.
	_animated.transform = rest * off
	_arms.visible = show_arms
	var support_z := float(pose.profile["support"])
	var grip := _animated.transform * Vector3(0.0, -0.05, 0.03)
	var support := _animated.transform * Vector3(-0.02, -0.03, support_z)
	_arms.place(grip, support, support_z != 0.0)


func _has_def() -> bool:
	return arsenal != null and arsenal.current_def() != null


func _seconds_for_ticks(ticks: int) -> float:
	var rate := float(arsenal.tick_rate) if arsenal != null else 64.0
	return float(arsenal.ticks_for(arsenal.current_def(), ticks)) / rate if arsenal != null and arsenal.current_def() != null else float(ticks) / rate


func _on_used(outcome: DotWeaponOutcome) -> void:
	if outcome == null or not outcome.used:
		return
	play_shot(float(outcome.recoil.length()) if outcome.recoil != Vector2.ZERO else 1.0)


## A use happened: kick, flash, tracer and impact, sound. Also what a test calls.
func play_shot(strength: float = 1.0) -> void:
	pose.fire(strength)
	_apply()
	if pose.motion != &"gun":
		return
	ZzShotFx.flash(_muzzle, 1.0 + 0.3 * pose.kick_amount())
	flashed.emit(weapon_id)
	_sound(ZzWeaponSound.FIRE)
	if not show_tracers or not is_inside_tree():
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var from := _muzzle.global_position
	var origin := cam.global_position
	var far := origin + (-cam.global_basis.z) * 80.0
	var query := PhysicsRayQueryParameters3D.create(origin, far)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var end: Vector3 = hit["position"] if not hit.is_empty() else far
	ZzShotFx.tracer(get_tree().current_scene if get_tree().current_scene != null else get_tree().root, from, end)
	if not hit.is_empty():
		ZzShotFx.impact(get_tree().current_scene if get_tree().current_scene != null else get_tree().root, end, hit["normal"])


func _on_dry(_slot: int) -> void:
	_sound(ZzWeaponSound.DRY)


## How long the reload really runs: a per-round reload is the start plus one round time per missing
## round, so the motion must span all of it, not just the first round.
func reload_seconds_for(def: DotWeaponDef, space: int) -> float:
	var ticks := def.reload_ticks
	if def.reload_per_round:
		ticks = def.reload_start_ticks + def.reload_ticks * maxi(space, 1)
	return _seconds_for_ticks(ticks)


func _on_reload_started(_slot: int) -> void:
	var seconds := 1.6
	if _has_def():
		seconds = reload_seconds_for(arsenal.current_def(), arsenal.current().magazine_space())
	pose.start_reload(seconds)
	_sound(ZzWeaponSound.RELOAD)


func _on_switched(_from: int, _to: int) -> void:
	if _has_def():
		show_weapon(arsenal.current_def().id, true)


func _sound(kind: StringName) -> void:
	var at := _muzzle.global_position if _muzzle.is_inside_tree() else Vector3.ZERO
	sound_requested.emit(kind, weapon_id, at)
	if play_builtin_sounds and is_inside_tree():
		var stream := ZzWeaponSound.stream_for(weapon_id, kind)
		if stream != null:
			_audio.stream = stream
			_audio.play()
