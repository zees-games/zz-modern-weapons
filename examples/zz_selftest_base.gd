extends Node

## Counters and helpers of the headless suite; the sections live in zz_selftest.gd.

var _entered := 0
var _finished := 0
var _checks := 0
var _failures := 0


func _write(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _begin(name: String) -> void:
	_entered += 1
	print("")
	print("-- %s" % name)


func _end() -> void:
	_finished += 1


func _model_aabb(n: Node, parent: Transform3D) -> AABB:
	var t := parent
	if n is Node3D:
		t = parent * (n as Node3D).transform
	var box := AABB()
	var have := false
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
		box = t * (n as MeshInstance3D).mesh.get_aabb()
		have = true
	for c in n.get_children():
		var sub := _model_aabb(c, t)
		if sub.size != Vector3.ZERO:
			box = sub if not have else box.merge(sub)
			have = true
	return box


func _check(label: String, passed: bool) -> void:
	_checks += 1
	if passed:
		print("   ok    %s" % label)
		return
	_failures += 1
	print("   FAIL  %s" % label)


func _check_quiet(label: String, passed: bool) -> void:
	_checks += 1
	if not passed:
		_failures += 1
		print("   FAIL  %s" % label)
