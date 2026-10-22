# Credits

**Every weapon has a model.** A model is adopted only after its licence is re-read there, and the file converted (model-3d skill) to `assets/<id>.glb` with the origin at the grip and the muzzle toward -Z; its row then moves to "Used" below and `model` in `ZzWeaponArt.TABLE` is set. Licences allowed: CC0 and CC-BY only (never NC, ND or SA).

## Used

| Weapon id | Model | Author | Licence | URL | Change |
| --- | --- | --- | --- | --- | --- |
| zz_vss | Special Sniper Rifle VSS Vintorez | Arms Museum | CC0 1.0 | https://sketchfab.com/3d-models/special-sniper-rifle-vss-vintorez-4d5d8c1b7b79429abfa4816f18330089 | Joined, decimated 35.7k to 9k triangles, re-UVed and baked to one 1536 px texture (JPEG), scaled to 0.95 m, origin at the pistol grip, muzzle toward -Z, desaturated with grime and rust (2026-10-22). A new weapon beside the sniper, not its replacement. Licence read from the download's `license.txt`. |
| zz_m4 | Classic M4 | SpatialNeglect (Mateusz Woliński) | CC-BY 4.0 | https://sketchfab.com/3d-models/classic-m4-a747ebdbb3d941ecb09b459c62865a75 | Joined, decimated 28k to 12k triangles, textures resized to 1024 px (original PBR base colour, normal, metallic-roughness kept; metallic kept at the original values; see docs/lighting.md for what a view must give it), 0.84 m, origin at the grip, muzzle toward -Z (2026-10-22). |
| zz_sniper | Sniper | DJMaesen | CC-BY 4.0 | https://sketchfab.com/3d-models/sniper-cdefd833b4b5407ba32c53c9e7f50cae | Joined, decimated 13k to 9k triangles, one 1024 px PBR texture set, metallic as authored, 1.20 m, origin at the grip, muzzle toward -Z (2026-10-22). |
| zz_knife | Fighting Ka-Bar knifes | vitvitskyi | CC-BY 4.0 | https://sketchfab.com/3d-models/fighting-ka-bar-knifes-b3c3a8c7c28349268f6631567cf01d8a | One of the three knives (serrated steel blade, leather handle) split out, 4.9k triangles, 1024 px PBR textures, metallic as authored, 0.30 m, origin at the handle, blade along +Y (2026-10-22). |
| zz_pistol | Vis P35(p) pistol | Virtual Museums of Małopolska | CC0 1.0 | https://sketchfab.com/3d-models/vis-p35p-pistol-babe98e5485241f1971c10544f2ff796 | Decimated 64k to 6k triangles, one 1024 px PBR set, 0.20 m, origin at the grip, muzzle toward -Z (2026-10-22). Licence read from the download's `license.txt`. |
| zz_shotgun | Shotgun | Virtual Museums of Małopolska | CC0 1.0 | https://sketchfab.com/3d-models/shotgun-3c3ed272927c4f3d83d607b2acbf7aab | Four meshes joined, decimated 326k to 14k triangles, one 1024 px PBR set, 1.05 m, origin at the wrist of the stock, muzzle toward -Z (2026-10-22). |
| zz_smg | SMG-M32 | Frostoise | CC-BY 4.0 | https://sketchfab.com/3d-models/smg-m32-3a5f98f75e804e5888379cbe640cc883 | Joined, 4.4k triangles kept, 1024 px PBR textures, 0.62 m, turned so the muzzle points toward -Z, origin at the pistol grip (2026-10-22). |
| zz_frag | M69 Frag Grenade | Riley Lewand | CC-BY 4.0 | https://sketchfab.com/3d-models/m69-frag-grenade-e94d90f68bdb4fd68d7a0aac6d9c5dd0 | 5.5k triangles kept, 1024 px PBR textures, base colour re-tinted from the blue practice grenade to olive drab, 0.11 m tall, origin in the body (2026-10-22). |

## Other

Everything else in the repository is original code (MIT, see LICENSE).
