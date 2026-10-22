# What a game must give the weapon viewmodel

The weapon models keep their authored PBR values, metal included (steel barrels and receivers are `metallic` near 1). **A fully metallic surface has no diffuse colour: it shows only what it reflects.** With nothing to reflect it renders black, which is why the first conversions scaled metal down to 0.6 to hide the problem. That scaling is gone; the view must provide the reflection instead.

A game does one of these, and needs only one:

1. **A sky in the world's Environment** (the usual case): `background_mode = BG_SKY` with a `Sky`, or any `Environment` whose `reflected_light_source` is `REFLECTION_SOURCE_SKY` and whose sky is set. The view model sits in the same world, so its metal reflects that sky. Most games here already have one.
2. **`ZzReflectionSource.sky_environment()`** for a world that has none: a procedural sky that is the background, the ambient and the reflected light. This is what `examples/zz_rack.tscn` and `examples/zz_view.tscn` use.
3. **`ZzViewModel.provide_reflections = true`** (or `ZzReflectionSource.attach_probe(node)`): a one-shot `ReflectionProbe` hung on the view model, for a world with a flat-colour background and no sky. It captures whatever surrounds the player at the next frame; call `ZzReflectionSource.refresh(probe)` after a big change of lighting (night to day). It reflects scenery and background colour only, so the result is flatter than a sky.

Also needed, as for any lit mesh: at least one light (a `DirectionalLight3D`), and no `Environment` with `reflected_light_source = REFLECTION_SOURCE_DISABLED`.

Check it by eye: `tools/screenshot.sh --view m4` (sky environment) and `examples/zz_view.tscn -- --weapon m4 --probe --shot out.png` (probe only). A black barrel with bright glints is this problem.
