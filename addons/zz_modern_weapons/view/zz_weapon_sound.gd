class_name ZzWeaponSound
extends RefCounted

## The sound hook, with no sound shipped. A view model asks [method stream_for] for an id and a
## kind ([constant FIRE], [constant RELOAD], [constant DRAW], [constant DRY]) and plays whatever
## comes back; null means "silent", which is what every weapon is until a game or a real model
## pack registers streams. The same shape as [ZzWeaponArt]: the table is the only thing to change.
## A game that wants its own audio engine connects [signal ZzViewModel.sound_requested] instead
## and ignores this class.

const FIRE := &"fire"
const RELOAD := &"reload"
const DRAW := &"draw"
const DRY := &"dry"

## id -> {kind -> res:// path}. Empty: no audio was sourced.
const TABLE := {}

static var _cache: Dictionary = {}


static func path_for(id: StringName, kind: StringName) -> String:
	var row: Dictionary = TABLE.get(id, {})
	return String(row.get(kind, ""))


static func stream_for(id: StringName, kind: StringName) -> AudioStream:
	var path := path_for(id, kind)
	if path == "" or not ResourceLoader.exists(path):
		return null
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path] as AudioStream
