# Zee's Modern Weapons

Modern, realistic weapons on top of [dot-weapon](../dot-weapon): M4 carbine, sniper rifle, combat knife, pistol, shotgun, SMG and frag grenade. Made for Zombie Zone, usable in any game or server through Dot (`provides.json` kind `weapon`, games `*`). Addon `zz_modern_weapons`.

![the rack](docs/rack.png)

## Status

The rows (damage, rate, recoil, spread, magazine, reload, range) are done, tested and configurable. **The art is not: every weapon is a labelled placeholder** (boxes and cylinders), because Sketchfab's download endpoint needs an account token and none was available. [CREDITS.md](CREDITS.md) lists a CC0 or CC-BY candidate model per weapon (uid, author, licence); converting them to `assets/<id>.glb` (origin at the grip, muzzle toward -Z, metres) and setting `model` in `ZzWeaponArt.TABLE` is the remaining work.

## Tuning

Every number is in `cfg/addons/zz_modern_weapons/*.yml`. All `.yml` files in the directory are read in name order (a later file wins), so keep your changes in `server.yml` and leave `default.yml` alone. A weapon or key you do not list keeps its built-in default; an unknown key is logged and ignored. Reading goes through dot-core's `DotAddonConfig.load_dir("zz_modern_weapons", defaults)` when dot-core has it, and through `DotYaml` otherwise.

```yaml
m4:
  damage: 35
  rpm: 700
  magazine: 20
```

## Using it

```gdscript
var catalogue := ZzWeaponPack.catalogue()      # a DotWeaponCatalogue, validates with no art
var model := ZzWeaponArt.instantiate(ZzWeaponIds.M4)
```

A host's spawn menu calls `ZzSpawnProvider.spawn_entries()` (`addons/zz_modern_weapons/spawn_provider.gd`) and gets one `{category: "Weapons", id, name, icon, kind: "weapon", spawn, cfg_hint}` row per weapon.

The Workshop form (`weapons/*.tres`, `provides.json`) is generated from the code by `tools/export-defs.sh`; the suite fails when it is stale.

## Testing

`./game.sh test` parses every script and runs `zz_selftest`. `tools/screenshot.sh [--all|<weapon>]` renders the rack to `screenshots/` (look at it; no assertion reaches how a weapon looks).

## Art and licences

See [CREDITS.md](CREDITS.md). Only CC0 and CC-BY models are used, with URL, author and licence recorded there. Code is MIT.
