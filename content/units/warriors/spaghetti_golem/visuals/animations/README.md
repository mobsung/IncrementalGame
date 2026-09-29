# Spaghetti Golem sprite-sheet animation

Current implementation (2026-09-29): nine transparent raster sheets in `../spritesheets/`, 16 source poses each, 144 total. Generated with the built-in image tool from the existing character art; prompts and provenance are in `../spritesheets/ART_NOTES.md`. Original portrait textures remain unchanged.

`sprite_sheet_motion.gd` builds shared immutable SpriteFrames/AtlasTexture resources; each copy has its own `sprite_sheet_player.gd`. Three `*_sheet.tres` configurations are referenced by the unit visual resources. The previous `golem_motion*.gd` soft-mesh implementation is retained as unused historical code, not used by the three forms.

| Sheet | Frames (zero-based, reading order) |
| --- | --- |
| Locomotion | Idle 0–3; walk 4–11; death 12–15; hit reuses 12 |
| Attacks | Meatball Jab 0–7; Meatball Sweep 8–15 |
| Base abilities | Slow Simmer 0–15 |
| Knight abilities | Slow Simmer 0–7; Sauce Guard 8–15 |
| Final abilities | Slow Simmer 0–3; Sauce Guard 4–7; Glassheart Surge 8–15 |

Sources are 1254×1254, not the requested 2048×2048. Atlas dimensions are read from the actual textures. Authored row/column separators accommodate nonuniform generated gutters and extended fists. Equal virtual canvases preserve the nominal pivot, and filter clipping prevents sampling adjacent atlas cells. These remain generated raster drawings, with some frame-to-frame variation in volume and foot placement; they are not a pixel-perfect hand-cleaned production atlas.

The player selects real frames, never deforms a mesh. Walking follows displacement. Jab frames 0–3 anticipate the simulation's impact at 25% of its captured cycle; 4–7 recover. Sweep contact starts at 0.4 s, recovery ends at 0.6 s. Guard/Surge split cast and effect frames at their existing authoritative timings. Casts, attacks and movement take priority over passive Simmer; Simmer waits for an available pose interval, and new actions can interrupt effect tails. Buff duration is still indicated by the arena's existing tint/UI, not by prolonging a cast.

Pause freezes frame selection. Copies/evolutions, hit/heal routing and the presentation-only death echo continue to use ArenaView. No damage, RNG, inventory, balance or save schema changes. Loading mid-Jab after impact infers visual recovery from the remaining timer/current speed if the captured duration is unavailable; simulation timing is untouched.

Open `preview.tscn` with F6: Space pauses; Left/Right selects states. All three forms use synthetic actors, never SaveStore. The regression suite checks atlas bounds/alpha, virtual canvas size, form gates, independent state, frame timing, pause and model isolation. Visual checks and a short battle smoke test complement it; no extended performance/balance benchmark or audio work was done.
