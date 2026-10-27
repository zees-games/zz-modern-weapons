extends SceneTree

## Prints, per gun, the measured sight point and the aim offset that centres it, next to the table's.
## Run: heavy -- godot --headless --path . --script tools/measure_sights.gd


func _init() -> void:
	for id in ZzWeaponArt.TABLE:
		if ZzWeaponArt.motion_of(id) != &"gun" or ZzWeaponArt.is_placeholder(id):
			continue
		var sight := ZzWeaponArt.sight_point(id)
		var aim := ZzWeaponArt.aim_for(id)
		var now: Vector3 = ZzWeaponArt.view_profile(id)["aim"]
		print("%s sight=(%.3f, %.3f, %.3f) aim=Vector3(%.3f, %.3f, %.3f) table=%s" % [id, sight.x, sight.y, sight.z, aim.x, aim.y, aim.z, now])
	quit()
