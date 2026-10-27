#!/usr/bin/env python3
"""Turn a weapon glb 180 degrees about Y so its muzzle points toward -Z (the pack's contract).

    tools/orient_glb.py addons/zz_modern_weapons/assets/zz_m4.glb [--grip-z -0.109]

Wraps the scene's root nodes in one node "Oriented" (rotation only, mesh data untouched, so textures and the
.import stay). --grip-z is where the grip's centre is in the file's own z; it ends at the origin. Run once per
model that faces +Z; running it twice turns it back.
"""
import json, struct, sys

path = sys.argv[1]
grip_z = float(sys.argv[sys.argv.index("--grip-z") + 1]) if "--grip-z" in sys.argv else 0.0
data = open(path, "rb").read()
magic, version, _length = struct.unpack("<III", data[:12])
assert magic == 0x46546C67, "not a glb"
jlen, jtype = struct.unpack("<II", data[12:20])
assert jtype == 0x4E4F534A
doc = json.loads(data[20:20 + jlen])
rest = data[20 + jlen:]
scene = doc["scenes"][doc.get("scene", 0)]
doc["nodes"].append({"name": "Oriented", "rotation": [0.0, 1.0, 0.0, 0.0], "translation": [0.0, 0.0, grip_z], "children": list(scene["nodes"])})
scene["nodes"] = [len(doc["nodes"]) - 1]
blob = json.dumps(doc, separators=(",", ":")).encode()
blob += b" " * (-len(blob) % 4)
out = struct.pack("<II", len(blob), jtype) + blob + rest
open(path, "wb").write(struct.pack("<III", magic, version, 12 + len(out)) + out)
print("oriented", path)
