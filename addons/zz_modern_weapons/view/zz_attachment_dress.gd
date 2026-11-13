class_name ZzAttachmentDress
extends RefCounted

## Puts a fitting's attachment models on one of this pack's weapon models, view or world: adds the
## `socket_<mount>` nodes at [method ZzWeaponArt.socket_points], then hands over to [DotWeaponAttachmentModels].
## An optic scene marks its eye line with a `Sight` marker (meta `relief`), a muzzle scene its end with `Tip`.


## Dresses [param model] (an instance of [param id]'s art) with [param fitting]; returns how many models it placed.
static func dress(model: Node3D, id: StringName, catalogue: DotWeaponAttachments, fitting: DotWeaponFitting) -> int:
	if model == null:
		return 0
	var points := ZzWeaponArt.socket_points(id)
	var to_local := model.transform.affine_inverse()
	for mount: StringName in ZzWeaponPack.MOUNTS.get(id, []):
		var key := String(mount)
		if not points.has(key) or model.has_node(NodePath(DotWeaponAttachmentModels.SOCKET_PREFIX + key)):
			continue
		var socket := Node3D.new()
		socket.name = DotWeaponAttachmentModels.SOCKET_PREFIX + key
		socket.position = to_local * (points[key] as Vector3)
		model.add_child(socket)
	return DotWeaponAttachmentModels.dress(model, catalogue, fitting)


## The placed model's marker [param marker_name] on [param mount] (`Sight` on the optic, `Tip` on the muzzle), or null.
static func marker(model: Node3D, mount: StringName, marker_name: String) -> Node3D:
	if model == null:
		return null
	var socket := model.get_node_or_null(NodePath(DotWeaponAttachmentModels.SOCKET_PREFIX + String(mount)))
	if socket == null:
		return null
	for placed in socket.get_children():
		if placed.is_queued_for_deletion():
			continue
		var found := placed.get_node_or_null(NodePath(marker_name)) as Node3D
		if found != null:
			return found
	return null


## The value a fitted attachment sets for param [param key] (`suppressed`, `optic_zoom`), else [param fallback].
static func fitted_param(catalogue: DotWeaponAttachments, fitting: DotWeaponFitting, key: String, fallback: Variant = null) -> Variant:
	if catalogue == null or fitting == null:
		return fallback
	for att_id in fitting.ids():
		var att := catalogue.get_attachment(att_id)
		if att != null and att.params_set.has(key):
			return att.params_set[key]
	return fallback


## [param node]'s origin in the frame [param model] sits in (its parent's), the frame a muzzle or an aim hold is in.
static func point_in(model: Node3D, node: Node3D) -> Vector3:
	var t := Transform3D.IDENTITY
	var n: Node = node
	while n != null and n != model:
		if n is Node3D:
			t = (n as Node3D).transform * t
		n = n.get_parent()
	return (model.transform * t).origin
