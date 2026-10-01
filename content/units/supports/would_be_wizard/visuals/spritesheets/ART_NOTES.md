# Wizard artwork — 2026-10-01

Source: the five user-provided PNG concepts under `assets/concepts/units/supports/The-Would-Be-Wizard`. Original files preserved. Generated with the integrated imagegen tool, requested transparent backgrounds, copied into this directory without changing source pixels. Seven RGBA sheets, 1536×1024 each.

Reference mapping: apprentice = stage 0; acolyte = 1b; archsage = 2b; makeshift = 1a; archmage = 2a. The letter in the reference filename is not the branch letter in the kit.

Generation direction: painterly storybook fantasy, matching worn blue and cream robes, readable silhouette and authored tools; side-facing full-body game character, consistent ground contact, six columns per row, isolated poses with transparent gutters, no labels/background. Apprentice: crooked wooden training staff, inexperienced physical swing. Acolyte: ink/book magic. Archsage: floating written pages and healing gestures. Makeshift: weighted staff, improvised mechanical tricks, no genuine spellcasting. Archmage: loaded staff, mechanical owl, smoke/mirrors and explosive tricks, no magical fireball.

Pose direction: idle/anticipation, six walking poses, six basic attack poses, active cast sequences, hit and six-frame collapse/death. Apprentice has five rows (30 poses), others six (36 each): 174 source poses. Runtime idle uses planted pose zero with upper-body breathing; unused idle alternatives retained. Cast clips for multi-ability forms use distinct subsets of the authored cast rows. Source art is not a limb rig or frame-perfect hand animation.

Effects direction: 4×4 atlas, ink projectile, physical dart, folded/open mechanical trap, four successive amber physical explosions, four golden healing/recovery page effects, three owl poses, mirror prop. Icons direction: 6×4 atlas of 24 readable circular blue-and-gold ability/attack/passive symbols in the same illustration style.

`wizard_sheet.gd` owns clip indices. `.tres` metadata owns exact crop/pivot rectangles. `tests/calibrate_wizard_atlas.py` reads alpha to isolate each primary connected silhouette inside authored cells; it does not edit PNGs. The initial rectangular cells accidentally included neighboring hats in some extended casts; corrected metadata uses primary-component bounds. The icons authoring helper is idempotent; the initial content bootstrap deliberately refuses to run over authored resources.

Limits: residual differences in proportions, cloth detail, tools and shading between generated poses; some hit/cast clips reuse frames. No manual pixel-perfect redraw or new audio assets. Transparency is real alpha: brown RGB values in fully transparent gutters are not a rendered background.

## Frame contamination correction — 2026-10-01

Bounding rectangles alone were insufficient: a pose could contain separate neighboring fragments inside its bounding box, and extended tools were clipped at nominal column edges. Runtime now draws authored UV patches through cached meshes. `tests/isolate_wizard_frames.py` reads full-sheet connected silhouettes, assigns detached props (including complete owls/traps/bombs), preserves soft edges, and excludes audited gutter slivers and tiny orphan alpha islands. Source PNGs remain unchanged. Several tiny decorative sparkles/glow tails are omitted.

The Makeshift source's cell 27 contains no full character. Runtime frame 27 reuses character pose 28 for hit instead of rendering the fragment in that cell. The five atlases have 174 runtime indices, 173 distinct full-body source poses. `wizard_atlas_preview.tscn` renders every index including the death row. Five complete sheets and the arena preview were inspected. The old rectangular calibration helper now refuses to overwrite these coordinates; use the isolation authoring script for metadata regeneration.
