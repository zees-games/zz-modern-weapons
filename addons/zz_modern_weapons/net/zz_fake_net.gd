class_name ZzFakeNet
extends RefCounted

## A stand-in for a replicated object: the four public fields and nothing else. For the render
## scene and tests, where no network exists; a game's own replicated node takes its place.

var net_fire_seq: int = 0
var net_fire_kind: int = 1
var net_reloading: bool = false
var net_switching: bool = false
