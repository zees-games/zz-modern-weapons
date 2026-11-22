#!/usr/bin/env python3
"""Replaces the embedded textures of a shipped weapon GLB with the author's full-size ones; mesh, UVs, nodes and materials stay.

  python3 -I tools/swap_glb_textures.py <weapon.glb> <source scene.gltf dir> [--max 2048] [--other 1024] [--quality 90] [--dry]

Each GLB image is matched to the source image (same map kind) that looks most like it at 24 px, then replaced by that
source scaled down to --max for colour maps (--other for normal/ORM maps, and for every map of a GLB with over 8 images but its first colour map; the repo
grows by every byte twice, Godot extracts them beside the GLB), never up, JPEG, or PNG when it needs alpha. Godot extracts the images on import: delete the
stale extracted files and their .import files beside the GLB, re-import, and set compress/mode=1, lossy_quality=0.9.
"""
import io, json, os, struct, sys
from PIL import Image


def read_glb(path):
    b = open(path, 'rb').read()
    jl = struct.unpack('<I', b[12:16])[0]
    j = json.loads(b[20:20 + jl])
    o = 20 + jl
    bl = struct.unpack('<I', b[o:o + 4])[0]
    return j, b[o + 8:o + 8 + bl]


def write_glb(path, j, binb):
    js = json.dumps(j, separators=(',', ':')).encode()
    js += b' ' * (-len(js) % 4)
    binb += b'\0' * (-len(binb) % 4)
    with open(path, 'wb') as f:
        f.write(struct.pack('<4sII', b'glTF', 2, 28 + len(js) + len(binb)))
        f.write(struct.pack('<I4s', len(js), b'JSON') + js)
        f.write(struct.pack('<I4s', len(binb), b'BIN\0') + binb)


def kinds(j):
    ti = [t.get('source') for t in j.get('textures', [])]
    out = {}
    for m in j.get('materials', []):
        p = m.get('pbrMetallicRoughness', {})
        for ref, kind in ((p.get('baseColorTexture'), 'color'), (p.get('metallicRoughnessTexture'), 'orm'),
                (m.get('normalTexture'), 'normal'), (m.get('occlusionTexture'), 'orm'), (m.get('emissiveTexture'), 'emissive')):
            if ref is not None:
                out.setdefault(ti[ref['index']], kind)
    return out


def sig(img):
    return list(img.convert('RGB').resize((24, 24), Image.BILINEAR).tobytes())


def dist(a, b):
    return sum((x - y) ** 2 for x, y in zip(a, b)) / len(a)


def opt(name, default):
    return int(sys.argv[sys.argv.index(name) + 1]) if name in sys.argv else default


def main():
    mx, q, other = opt('--max', 2048), opt('--quality', 90), opt('--other', 1024)
    pos = [a for i, a in enumerate(sys.argv[1:], 1) if not a.startswith('--') and not sys.argv[i - 1].startswith('--')]
    glb, src = pos[0], pos[1]
    sj = json.load(open(os.path.join(src, 'scene.gltf')))
    sk = kinds(sj)
    sources = []
    for i, im in enumerate(sj.get('images', [])):
        p = os.path.join(src, im.get('uri', ''))
        if os.path.isfile(p):
            img = Image.open(p)
            sources.append((i, img, sig(img), sk.get(i, 'color')))
    j, binb = read_glb(glb)
    gk, views, new = kinds(j), j['bufferViews'], {}
    # Which GLB image gets the full --max: all colour maps of a small GLB, only the first colour map of a big one.
    full = {i for i in gk if gk[i] == 'color'} if len(j['images']) <= 8 else {min(i for i in gk if gk[i] == 'color')}
    for i, im in enumerate(j.get('images', [])):
        bv = views[im['bufferView']]
        o = bv.get('byteOffset', 0)
        cur = Image.open(io.BytesIO(binb[o:o + bv['byteLength']]))
        cs, kind = sig(cur), gk.get(i, 'color')
        best = min([s for s in sources if s[3] == kind] or sources, key=lambda s: dist(cs, s[2]))
        d, img = dist(cs, best[2]), best[1]
        alpha = img.mode in ('RGBA', 'LA') and img.convert('RGBA').getchannel('A').getextrema()[0] < 250
        lim = mx if i in full else min(mx, other)
        if max(img.size) > lim:
            r = lim / max(img.size)
            img = img.resize((round(img.width * r), round(img.height * r)), Image.LANCZOS)
        buf = io.BytesIO()
        if alpha:
            img.convert('RGBA').save(buf, 'PNG', optimize=True)
        else:
            img.convert('RGB').save(buf, 'JPEG', quality=q, subsampling=0 if kind == 'normal' else 2)
        print('image %d %s %s -> src %d %s mse %.0f -> %s %d KB%s' % (i, kind, cur.size, best[0], best[1].size, d, img.size,
                len(buf.getvalue()) // 1024, '  WEAK MATCH' if d > 400 else ''))
        new[im['bufferView']] = (buf.getvalue(), 'image/png' if alpha else 'image/jpeg', i)
    if '--dry' in sys.argv:
        return
    out = bytearray()
    for n, bv in enumerate(views):
        out += b'\0' * (-len(out) % 4)
        if n in new:
            data, mime, i = new[n]
            j['images'][i]['mimeType'] = mime
        else:
            o = bv.get('byteOffset', 0)
            data = binb[o:o + bv['byteLength']]
        bv['byteOffset'], bv['byteLength'] = len(out), len(data)
        out += data
    j['buffers'][0]['byteLength'] = len(out)
    write_glb(glb, j, bytes(out))


main()
