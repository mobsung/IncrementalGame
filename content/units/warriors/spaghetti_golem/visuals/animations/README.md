# Spaghetti Golem sprite-sheet animation

Idle correction (2026-09-30): all three forms use one planted source pose. The lower slice below virtual y=400 (including both wooden feet) stays fixed. Only the upper slice breathes vertically by ±0.6% over 3.2 seconds, anchored at the join; there is no horizontal scaling or foot translation. Two small glossy sauce drops grow, detach, fall and fade in staggered 2.4-second cycles. Their origins are calibrated per form in idle_drip_origins; breathing split/amplitude are configurable. Mirroring reflects the complete idle drawing around its ground pivot. Everything uses the existing per-copy visual clock, freezes on pause and yields immediately to other states. Source idle poses 1–3 remain in the PNGs but are no longer cycled.

Run preview.tscn with -- idle-capture and a graphical renderer for 38 pixel checks: fixed feet at four times in both facings, changing upper body and sauce, and exact pause stability. It saves planted/mirrored preview and baseline PNGs in tests/idle_*_preview.png. Coordinates account for viewport stretch. This graphical check is separate from the headless gameplay suite.
Current implementation (2026-09-30): nine revised transparent raster sheets in `../spritesheets/refined/`, 16 source poses each, 144 total. Generated with the built-in image tool from the approved portraits and existing sheets; selected prompts and review notes are in `../spritesheets/refined/ART_NOTES.md`. Original portraits and the September 29 sheets remain available.

`sprite_sheet_motion.gd` builds shared immutable SpriteFrames/AtlasTexture resources; each copy has its own `sprite_sheet_player.gd`. Three `*_sheet.tres` configurations are referenced by the unit visual resources. The previous `golem_motion*.gd` soft-mesh implementation is retained as unused historical code, not used by the three forms.

| Sheet | Frames (zero-based, reading order) |
| --- | --- |
| Locomotion | Idle uses pose 0; walk 4–11; death 12–15; hit reuses 12 |
| Attacks | Meatball Jab 0–7; Meatball Sweep 8–15 |
| Base abilities | Slow Simmer 0–15 |
| Knight abilities | Slow Simmer 0–7; Sauce Guard 8–15 |
| Final abilities | Slow Simmer 0–3; Sauce Guard 4–7; Glassheart Surge 8–15 |

Sources retain their generated dimensions: seven 1254×1254 sheets, Knight locomotion 1269×1239 and final locomotion 1301×1209. Authored row/column separators accommodate nonuniform gutters and extended fists. All frames use a 640×640 virtual canvas and per-pose ground/root registration in full-sheet UV coordinates. Uniform clip scale normalizes standing height between sheets while preserving intentional crouching and collapse. Registration is authored in the resources, not computed from pixels at runtime. Filter clipping prevents sampling across each region. Small drawing/antialias variations remain; this is not a pixel-perfect hand-cleaned atlas. Final Guard reads source poses 4, 6, 5, 7 so its crossed fists appear at activation.

The player selects real frames, never deforms a mesh. Walking follows displacement. Jab frames 0–3 anticipate the simulation's impact at 25% of its captured cycle; 4–7 recover. Sweep contact starts at 0.4 s, recovery ends at 0.6 s. Guard/Surge split cast and effect frames at their existing authoritative timings. Casts, attacks and movement take priority over passive Simmer; Simmer waits for an available pose interval, and new actions can interrupt effect tails. Buff duration is still indicated by the arena's existing tint/UI, not by prolonging a cast.

Pause freezes frame selection. Copies/evolutions, hit/heal routing and the presentation-only death echo continue to use ArenaView. No damage, RNG, inventory, balance or save schema changes. Loading mid-Jab after impact infers visual recovery from the remaining timer/current speed if the captured duration is unavailable; simulation timing is untouched.

Open `preview.tscn` with F6: Space pauses; Left/Right selects states; Up/Down pauses and steps individual drawn frames; F mirrors. A frame strip shows every pose in the current clip. All three forms use synthetic actors, never SaveStore. Running the scene with `-- capture` writes nine isolated screenshots in `tests/refined_sheet_*_preview.png` and exits. `tests/sprite_sheet_audit.gd -- refined` reads source PNG geometry for offline inspection only.

The regression suite checks atlas bounds/alpha, all shared canvas dimensions, authored ground registration, form gates, independent state, authoritative impact timing, pause and model isolation. Final verification and remaining limitations are recorded in PROJECT_CONTEXT.md. No extended performance/balance benchmark or audio work was done.
