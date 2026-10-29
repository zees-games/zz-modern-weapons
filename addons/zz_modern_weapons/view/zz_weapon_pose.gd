class_name ZzModernWeaponPose
extends RefCounted

## The procedural motion of one weapon: draw, idle sway, fire recoil, reload, aim. Presentation only; writes nothing the simulation reads.
## Draw and reload are keys [t 0..1, position m, rotation deg] (they have a chosen shape); recoil is a
## closed-form critically damped spring, because explicit Euler adds energy and a 10 fps frame breaks a semi-implicit one.

const DRAW_KEYS: Array = [
	[0.0, Vector3(0.0, -0.32, 0.12), Vector3(-40.0, 12.0, 0.0)],
	[0.6, Vector3(0.0, -0.06, 0.03), Vector3(-8.0, 3.0, 0.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const RELOAD_KEYS_GUN: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.15, Vector3(-0.04, 0.03, 0.04), Vector3(10.0, 0.0, 35.0)],
	[0.30, Vector3(-0.05, 0.02, 0.05), Vector3(14.0, 6.0, 55.0)],
	[0.60, Vector3(-0.05, 0.02, 0.05), Vector3(14.0, 6.0, 55.0)],
	[0.72, Vector3(-0.03, 0.04, 0.03), Vector3(18.0, 2.0, 30.0)],
	[0.88, Vector3(0.0, -0.02, 0.02), Vector3(-3.0, 0.0, 6.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const RELOAD_KEYS_BOLT: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.08, Vector3(-0.06, 0.06, 0.02), Vector3(8.0, 14.0, 4.0)],
	[0.14, Vector3(-0.10, 0.095, 0.04), Vector3(10.0, 20.0, 6.0)],
	[0.20, Vector3(-0.10, 0.09, 0.06), Vector3(8.0, 20.0, 8.0)],
	[0.26, Vector3(-0.105, 0.10, 0.05), Vector3(10.0, 21.0, 6.0)],
	[0.48, Vector3(-0.107, 0.102, 0.05), Vector3(10.0, 21.0, 6.0)],
	[0.70, Vector3(-0.105, 0.10, 0.05), Vector3(10.0, 21.0, 6.0)],
	[0.75, Vector3(-0.102, 0.098, 0.06), Vector3(9.0, 20.0, 7.0)],
	[0.82, Vector3(-0.10, 0.094, 0.025), Vector3(8.0, 20.0, 4.0)],
	[0.90, Vector3(-0.035, 0.03, 0.005), Vector3(3.0, 7.0, 2.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const RELOAD_KEYS_TUBE: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.10, Vector3(-0.05, 0.045, 0.01), Vector3(9.0, 11.0, 30.0)],
	[0.22, Vector3(-0.08, 0.07, 0.015), Vector3(13.0, 15.0, 48.0)],
	[0.46, Vector3(-0.082, 0.072, 0.015), Vector3(13.0, 15.0, 49.0)],
	[0.68, Vector3(-0.08, 0.07, 0.015), Vector3(13.0, 15.0, 48.0)],
	[0.76, Vector3(-0.035, 0.03, 0.005), Vector3(5.0, 6.0, 18.0)],
	[0.83, Vector3(0.0, -0.004, 0.03), Vector3(-2.0, 2.0, 3.0)],
	[0.90, Vector3(0.0, -0.004, -0.008), Vector3(2.0, 0.0, 0.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const RELOAD_KEYS_REVOLVER: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.12, Vector3(-0.06, 0.07, 0.0), Vector3(24.0, 16.0, 16.0)],
	[0.22, Vector3(-0.075, 0.085, 0.0), Vector3(30.0, 20.0, 48.0)],
	[0.62, Vector3(-0.077, 0.087, 0.0), Vector3(32.0, 20.0, 50.0)],
	[0.70, Vector3(-0.07, 0.08, 0.0), Vector3(30.0, 18.0, 36.0)],
	[0.76, Vector3(-0.06, 0.07, 0.0), Vector3(22.0, 16.0, 10.0)],
	[0.88, Vector3(-0.015, 0.015, 0.0), Vector3(5.0, 5.0, 3.0)],
	[0.94, Vector3(0.0, -0.003, 0.01), Vector3(-1.0, 1.0, 0.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const RELOAD_KEYS_SMG: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.08, Vector3(-0.035, 0.03, 0.005), Vector3(6.0, 8.0, 24.0)],
	[0.16, Vector3(-0.06, 0.05, 0.01), Vector3(10.0, 12.0, 38.0)],
	[0.38, Vector3(-0.064, 0.053, 0.01), Vector3(9.0, 13.0, 40.0)],
	[0.46, Vector3(-0.06, 0.045, 0.008), Vector3(12.0, 12.0, 36.0)],
	[0.52, Vector3(-0.06, 0.058, 0.008), Vector3(7.0, 12.0, 34.0)],
	[0.66, Vector3(-0.03, 0.025, 0.0), Vector3(3.0, 5.0, 12.0)],
	[0.76, Vector3(0.0, -0.003, 0.022), Vector3(-3.0, 2.0, 3.0)],
	[0.82, Vector3(0.0, -0.003, -0.005), Vector3(1.5, 0.0, 0.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
## Pistol: the gun tips over the mag hand, the mag drops, a new one seats with a tap, then the slide is racked.
const RELOAD_KEYS_PISTOL: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.10, Vector3(-0.02, 0.02, 0.02), Vector3(8.0, 4.0, 18.0)],
	[0.22, Vector3(-0.035, 0.03, 0.03), Vector3(14.0, 8.0, 34.0)],
	[0.30, Vector3(-0.035, 0.026, 0.03), Vector3(18.0, 8.0, 36.0)],
	[0.52, Vector3(-0.035, 0.03, 0.03), Vector3(14.0, 8.0, 34.0)],
	[0.58, Vector3(-0.03, 0.022, 0.02), Vector3(10.0, 6.0, 28.0)],
	[0.68, Vector3(-0.015, 0.03, 0.02), Vector3(16.0, 2.0, 8.0)],
	[0.76, Vector3(-0.01, 0.03, 0.05), Vector3(18.0, 0.0, 6.0)],
	[0.84, Vector3(-0.01, 0.028, -0.005), Vector3(14.0, 0.0, 4.0)],
	[0.92, Vector3(0.0, 0.006, 0.0), Vector3(2.0, 0.0, 0.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
## Marksman rifle: a long gun, so a steadier cant, a slow mag swap with the butt braced, then a charging-handle pull.
const RELOAD_KEYS_DMR: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.12, Vector3(-0.03, 0.02, 0.03), Vector3(8.0, 3.0, 24.0)],
	[0.26, Vector3(-0.045, 0.025, 0.045), Vector3(12.0, 6.0, 44.0)],
	[0.36, Vector3(-0.045, 0.03, 0.045), Vector3(16.0, 6.0, 46.0)],
	[0.58, Vector3(-0.045, 0.025, 0.045), Vector3(12.0, 6.0, 44.0)],
	[0.68, Vector3(-0.03, 0.03, 0.03), Vector3(10.0, 3.0, 22.0)],
	[0.78, Vector3(-0.02, 0.025, 0.04), Vector3(8.0, 2.0, 8.0)],
	[0.86, Vector3(-0.015, 0.02, 0.0), Vector3(4.0, 0.0, 3.0)],
	[0.94, Vector3(0.0, -0.006, 0.006), Vector3(-1.0, 0.0, 0.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
## Slide travel 0..1 over a reload (x of the first vector): held back until the rack on an empty gun, else pulled once.
const SLIDE_KEYS_EMPTY: Array = [
	[0.0, Vector3(1, 0, 0), Vector3.ZERO],
	[0.72, Vector3(1, 0, 0), Vector3.ZERO],
	[0.80, Vector3.ZERO, Vector3.ZERO],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const SLIDE_KEYS_LOADED: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.68, Vector3.ZERO, Vector3.ZERO],
	[0.76, Vector3(1, 0, 0), Vector3.ZERO],
	[0.84, Vector3.ZERO, Vector3.ZERO],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const SWING_KEYS: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.25, Vector3(0.06, 0.04, 0.10), Vector3(25.0, -20.0, 25.0)],
	[0.55, Vector3(-0.10, -0.06, -0.14), Vector3(-30.0, 35.0, -30.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]
const THROW_KEYS: Array = [
	[0.0, Vector3.ZERO, Vector3.ZERO],
	[0.35, Vector3(0.02, 0.12, 0.14), Vector3(30.0, 0.0, 10.0)],
	[0.6, Vector3(-0.02, -0.04, -0.20), Vector3(-35.0, 0.0, 0.0)],
	[1.0, Vector3.ZERO, Vector3.ZERO],
]

## Spring stiffness (rad/s) of the recoil and the largest kick it will hold, so a held trigger
## settles instead of climbing without end.
const SPRING_OMEGA := 22.0
const KICK_LIMIT_DEG := 9.0

var weapon_id: StringName = &""
var profile: Dictionary = {}
var motion: StringName = &"gun"
## Scales every distance (the world model is the same motion at the size of a person's hand).
var scale_factor: float = 1.0
var aim_time: float = 0.14
## Spring stiffness multiplier: a gun that fires faster, or recovers faster, settles faster
## ([method follow_weapon]), so a burst's kicks ride the pattern instead of smearing together.
var settle: float = 1.0

var _draw: float = 1.0
var _draw_seconds: float = 0.4
var _draw_reverse: bool = false
var _reload: float = -1.0
var _reload_seconds: float = 1.5
var _reload_keys: Array = RELOAD_KEYS_GUN
## The slide is held open: the last round went, or a reload began on an empty gun. Cleared by the rack.
var slide_locked: bool = false
var _reload_empty: bool = false
var _action: float = -1.0
var _action_keys: Array = []
var _action_seconds: float = 0.4
var _aim: float = 0.0
var _aim_want: bool = false
var _kick_pitch: float = 0.0
var _kick_pitch_v: float = 0.0
var _kick_back: float = 0.0
var _kick_back_v: float = 0.0
var _kick_yaw: float = 0.0
var _kick_yaw_v: float = 0.0
var _yaw_side: float = 1.0
var _clock: float = 0.0
var _walk: float = 0.0


func set_weapon(id: StringName) -> void:
	weapon_id = id
	profile = ZzWeaponArt.view_profile(id)
	motion = ZzWeaponArt.motion_of(id)
	_reload = -1.0
	slide_locked = false
	_reload_keys = reload_keys_for(id)
	_action = -1.0
	_kick_pitch = 0.0
	_kick_pitch_v = 0.0
	_kick_back = 0.0
	_kick_back_v = 0.0
	_kick_yaw = 0.0
	_kick_yaw_v = 0.0


## A gun reloads the way its class does; a profile `reload_class` param can override (revolver, smg, tube, bolt, pistol, dmr, gun or rifle).
static func reload_keys_for(id: StringName) -> Array:
	match ZzWeaponArt.reload_class_of(id):
		&"revolver": return RELOAD_KEYS_REVOLVER
		&"smg": return RELOAD_KEYS_SMG
		&"tube": return RELOAD_KEYS_TUBE
		&"bolt": return RELOAD_KEYS_BOLT
		&"pistol": return RELOAD_KEYS_PISTOL
		&"dmr": return RELOAD_KEYS_DMR
	return RELOAD_KEYS_GUN


func draw(seconds: float) -> void:
	_draw = 0.0
	_draw_seconds = maxf(seconds, 0.05)
	_draw_reverse = false
	_reload = -1.0


## The holster plays the draw backwards, from wherever it is.
func holster(seconds: float) -> void:
	_draw = 1.0
	_draw_seconds = maxf(seconds, 0.05)
	_draw_reverse = true


func start_reload(seconds: float, empty: bool = false) -> void:
	_reload = 0.0
	_reload_empty = empty or slide_locked
	_reload_seconds = maxf(seconds, 0.2)


func cancel_reload() -> void:
	_reload = -1.0


## Sets [member settle] from the weapon's fire interval (seconds) and its recoil recovery (per second).
func follow_weapon(interval: float, recovery: float) -> void:
	settle = clampf(0.14 / maxf(interval, 0.02), 0.8, 1.8) * clampf(recovery / 6.0, 0.7, 1.4)


## A kick (guns) or a swing / lob (melee, thrown). [param strength] scales the kick; [param yaw_dir]
## (-1..1, from the recoil pattern) steers the sideways part, NAN alternates it.
func fire(strength: float = 1.0, yaw_dir: float = NAN) -> void:
	if motion == &"gun":
		var kick := minf(float(profile["kick"]) * clampf(strength, 0.0, 4.0), KICK_LIMIT_DEG)
		_kick_pitch_v += kick * SPRING_OMEGA * 2.7
		_kick_back_v += float(profile["back"]) * clampf(strength, 0.0, 4.0) * SPRING_OMEGA * 2.7
		var side := _yaw_side if is_nan(yaw_dir) else clampf(yaw_dir, -1.0, 1.0)
		_kick_yaw_v += side * kick * 0.25 * SPRING_OMEGA * 2.7
		_yaw_side = -_yaw_side
	else:
		_action = 0.0
		_action_keys = SWING_KEYS if motion == &"melee" else THROW_KEYS
		_action_seconds = 0.42 if motion == &"melee" else 0.6


func set_aim(held: bool) -> void:
	_aim_want = held and float(profile.get("zoom", 1.0)) < 1.0


func aim_amount() -> float:
	return _aim


## Field-of-view scale a camera should apply (1 at the hip).
func fov_scale() -> float:
	return lerpf(1.0, float(profile.get("zoom", 1.0)), _aim)


func is_drawing() -> bool:
	return _draw < 1.0


func is_reloading() -> bool:
	return _reload >= 0.0


func is_acting() -> bool:
	return _action >= 0.0


## 0 at rest, up to about 1 at the kick limit; for a test and for a muzzle flash's size.
func kick_amount() -> float:
	return clampf(absf(_kick_pitch) / KICK_LIMIT_DEG, 0.0, 1.0)


## [param speed] is the carrier's ground speed in m/s: it drives the walk bob.
func advance(delta: float, speed: float = 0.0) -> void:
	if not is_finite(delta) or delta <= 0.0:
		return
	delta = minf(delta, 0.1)
	_clock += delta
	_walk = lerpf(_walk, clampf(speed / 6.0, 0.0, 1.0) if is_finite(speed) else 0.0, minf(delta * 8.0, 1.0))
	_draw = clampf(_draw + delta / _draw_seconds, 0.0, 1.0) if not _draw_reverse else _draw
	if _draw_reverse:
		_draw = clampf(_draw - delta / _draw_seconds, 0.0, 1.0)
	if _reload >= 0.0:
		_reload += delta / _reload_seconds
		if _reload >= 1.0:
			_reload = -1.0
			slide_locked = false
	if _action >= 0.0:
		_action += delta / _action_seconds
		if _action >= 1.0:
			_action = -1.0
	_aim = move_toward(_aim, 1.0 if _aim_want else 0.0, delta / aim_time)
	var omega := SPRING_OMEGA * settle
	var e := exp(-omega * delta)
	var r := _spring(_kick_pitch, _kick_pitch_v, delta, e, omega)
	_kick_pitch = clampf(r.x, -KICK_LIMIT_DEG, KICK_LIMIT_DEG)
	_kick_pitch_v = r.y
	r = _spring(_kick_back, _kick_back_v, delta, e, omega)
	_kick_back = r.x
	_kick_back_v = r.y
	r = _spring(_kick_yaw, _kick_yaw_v, delta, e, omega)
	_kick_yaw = r.x
	_kick_yaw_v = r.y


## The weapon's transform relative to its rest placement (the hip hold or the aim hold; see
## [method hold]). Always finite.
func offset() -> Transform3D:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	var steady := 1.0 - 0.8 * _aim
	var bob := sin(_clock * 9.0)
	pos += Vector3(sin(_clock * 4.5) * 0.008, bob * bob * 0.010, 0.0) * _walk * steady
	pos += Vector3(sin(_clock * 1.3) * 0.002, sin(_clock * 1.9) * 0.0025, 0.0) * steady
	rot += Vector3(sin(_clock * 1.9) * 0.4, sin(_clock * 1.3) * 0.3, 0.0) * steady
	var d := _sample(DRAW_KEYS, _draw)
	pos += d[0]
	rot += d[1]
	if _reload >= 0.0:
		var k := _sample(_reload_keys, _reload)
		pos += k[0]
		rot += k[1]
	if _action >= 0.0:
		var a := _sample(_action_keys, _action)
		pos += a[0]
		rot += a[1]
	rot += Vector3(_kick_pitch, _kick_yaw, 0.0)
	pos += Vector3(0.0, 0.0, _kick_back)
	pos *= scale_factor
	if not (pos.is_finite() and rot.is_finite()):
		return Transform3D.IDENTITY
	var basis := Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)))
	return Transform3D(basis, pos)


## How far back the slide is, 0 (closed) to 1 (fully back): the shot's kick, the lock-back, the rack.
func slide_back() -> float:
	if _reload >= 0.0:
		return clampf(float(_sample(SLIDE_KEYS_EMPTY if _reload_empty else SLIDE_KEYS_LOADED, _reload)[0].x), 0.0, 1.0)
	return 1.0 if slide_locked else clampf(kick_amount() * 1.5, 0.0, 1.0)


## Where the weapon rests: the hip hold eased to the aim hold.
func hold() -> Vector3:
	if profile.is_empty():
		return Vector3.ZERO
	return (profile["hold"] as Vector3).lerp(profile["aim"] as Vector3, _aim) * scale_factor


## Position and rotation of keys at [param t], eased (smoothstep between neighbours, so the
## velocity is zero at every key: no corner, at the price of a slight pause). Malformed keys
## sample as rest.
static func sample_keys(keys: Array, t: float) -> Array:
	return _sample(keys, t)


static func _sample(keys: Array, t: float) -> Array:
	if keys.size() < 2 or not is_finite(t):
		return [Vector3.ZERO, Vector3.ZERO]
	t = clampf(t, 0.0, 1.0)
	for i in keys.size() - 1:
		var a: Array = keys[i]
		var b: Array = keys[i + 1]
		var ta := float(a[0])
		var tb := float(b[0])
		if t <= tb:
			var f := smoothstep(0.0, 1.0, clampf((t - ta) / maxf(tb - ta, 0.0001), 0.0, 1.0))
			return [(a[1] as Vector3).lerp(b[1] as Vector3, f), (a[2] as Vector3).lerp(b[2] as Vector3, f)]
	var last: Array = keys[keys.size() - 1]
	return [last[1], last[2]]


## Critically damped spring, closed form. Returns (x, v).
static func _spring(x: float, v: float, dt: float, e: float, omega: float = SPRING_OMEGA) -> Vector2:
	var c := v + omega * x
	return Vector2((x + c * dt) * e, (v - omega * c * dt) * e)
