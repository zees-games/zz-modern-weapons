class_name ZzViewArms
extends Node3D

## Two arms and two hands for the first-person view, built from boxes: a labelled placeholder until a rigged
## model replaces it. Each arm runs from a fixed shoulder to a hand the view model moves.
## Presentation only; casts no shadow.

const SKIN := Color(0.80, 0.60, 0.48)
const SLEEVE := Color(0.20, 0.24, 0.20)
const SHOULDERS := [Vector3(0.24, -0.34, 0.22), Vector3(-0.26, -0.34, 0.22)]

var _upper: Array[MeshInstance3D] = []
var _hands: Array[MeshInstance3D] = []


func _init() -> void:
	name = "PlaceholderArms"
	for i in 2:
		var arm := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.07, 0.07, 1.0)
		arm.mesh = box
		arm.material_override = _mat(SLEEVE)
		arm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(arm)
		_upper.append(arm)
		var hand := MeshInstance3D.new()
		var hb := BoxMesh.new()
		hb.size = Vector3(0.075, 0.075, 0.10)
		hand.mesh = hb
		hand.material_override = _mat(SKIN)
		hand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(hand)
		_hands.append(hand)


## Puts the right hand at [param grip] and the left at [param support] (this node's frame). A
## support of NaN parks the left hand on the grip's far side, relaxed, for one-handed weapons.
func place(grip: Vector3, support: Vector3, use_support: bool) -> void:
	var left := support if use_support else grip + Vector3(-0.16, -0.10, 0.06)
	_reach(0, grip)
	_reach(1, left)


func _reach(i: int, hand: Vector3) -> void:
	var shoulder: Vector3 = SHOULDERS[i]
	var span := shoulder.distance_to(hand)
	if span < 0.02 or not hand.is_finite():
		_upper[i].visible = false
		_hands[i].visible = false
		return
	_upper[i].visible = true
	_hands[i].visible = true
	var mid := (shoulder + hand) * 0.5
	var up := Vector3.UP if absf((hand - shoulder).normalized().dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
	_upper[i].transform = Transform3D(Basis.looking_at(hand - shoulder, up).scaled(Vector3(1, 1, span)), mid)
	_hands[i].transform = Transform3D(_upper[i].transform.basis.orthonormalized(), hand)


static func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.8
	return m
