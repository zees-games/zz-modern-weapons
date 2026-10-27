extends SceneTree

## Prints, per gun, the table's muzzle distance beside the measured tip of the model.
## Run: heavy -- godot --headless --path . --script tools/measure_muzzle.gd


func _init() -> void:
	for id in ZzWeaponArt.TABLE:
		if ZzWeaponArt.motion_of(id) != &"gun" or ZzWeaponArt.is_placeholder(id):
			continue
		var tip := ZzWeaponArt.muzzle_point(id)
		print("%s table=%.3f measured=(%.3f, %.3f, %.3f)" % [id, ZzWeaponArt.muzzle_distance(id), tip.x, tip.y, tip.z])
	quit()
