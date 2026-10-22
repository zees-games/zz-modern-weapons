# Credits

**The VSS Vintorez, M4, sniper and knife have models.** Every other weapon is still a clearly labelled placeholder built from boxes and cylinders (`ZzWeaponArt`) until its candidate below is converted. The Sketchfab search API works without one, so the table below lists, per weapon, the candidate models found on 2026-10-21 with their uid, author and licence as the API reports them. A model is adopted only after its page is opened, its licence re-read there, and the file converted (model-3d skill) to `assets/<id>.glb` with the origin at the grip and the muzzle toward -Z; its row then moves to "Used" below and `model` in `ZzWeaponArt.TABLE` is set. Licences allowed: CC0 and CC-BY only (never NC, ND or SA).

## Used

| Weapon id | Model | Author | Licence | URL | Change |
| --- | --- | --- | --- | --- | --- |
| zz_vss | Special Sniper Rifle VSS Vintorez | Arms Museum | CC0 1.0 | https://sketchfab.com/3d-models/special-sniper-rifle-vss-vintorez-4d5d8c1b7b79429abfa4816f18330089 | Joined, decimated 35.7k to 9k triangles, re-UVed and baked to one 1536 px texture (JPEG), scaled to 0.95 m, origin at the pistol grip, muzzle toward -Z, desaturated with grime and rust (2026-10-22). A new weapon beside the sniper, not its replacement. Licence read from the download's `license.txt`. |
| zz_m4 | Classic M4 | SpatialNeglect (Mateusz Woliński) | CC-BY 4.0 | https://sketchfab.com/3d-models/classic-m4-a747ebdbb3d941ecb09b459c62865a75 | Joined, decimated 28k to 12k triangles, textures resized to 1024 px (original PBR base colour, normal, metallic-roughness kept; metallic scaled to 0.6 so steel still reads without a reflection probe), 0.84 m, origin at the grip, muzzle toward -Z (2026-10-22). |
| zz_sniper | Sniper | DJMaesen | CC-BY 4.0 | https://sketchfab.com/3d-models/sniper-cdefd833b4b5407ba32c53c9e7f50cae | Joined, decimated 13k to 9k triangles, one 1024 px PBR texture set, metallic scaled to 0.6, 1.20 m, origin at the grip, muzzle toward -Z (2026-10-22). |
| zz_knife | Fighting Ka-Bar knifes | vitvitskyi | CC-BY 4.0 | https://sketchfab.com/3d-models/fighting-ka-bar-knifes-b3c3a8c7c28349268f6631567cf01d8a | One of the three knives (serrated steel blade, leather handle) split out, 4.9k triangles, 1024 px PBR textures, metallic scaled to 0.6, 0.30 m, origin at the handle, blade along +Y (2026-10-22). |

## Candidates, not downloaded (TODO)

URL form is `https://sketchfab.com/3d-models/<uid>`.

| Weapon id | Candidate | Author | Licence | Faces | uid |
| --- | --- | --- | --- | --- | --- |
| zz_m4 | M4A4 carbine pbr (free model) | javadbayat | CC-BY | 76k | 7db8ad6ac71d4c0a8df13850d6d01338 |
| zz_pistol | Vis P35(p) pistol | Virtual Museums of Malopolska | CC0 | 64k | babe98e5485241f1971c10544f2ff796 |
| zz_shotgun | Shotgun | Virtual Museums of Malopolska | CC0 | 326k (decimate) | 3c3ed272927c4f3d83d607b2acbf7aab |
| zz_smg | SMG-M32 | Frostoise | CC-BY | 4k | 3a5f98f75e804e5888379cbe640cc883 |
| zz_frag | M69 Frag Grenade | Riley Lewand | CC-BY | 5.5k | e94d90f68bdb4fd68d7a0aac6d9c5dd0 |

Not yet looked at by eye: the search lists names and licences, not whether the model is a clean single mesh in the right pose. Check each in the viewer first.

## Other

Everything else in the repository is original code (MIT, see LICENSE).
