# Spaghetti Golem sprites — 2026-09-27

Update 2026-09-29: arena animation now uses nine generated sprite sheets, replacing the previous soft-mesh pass. Original single textures remain unchanged for portraits. See `spritesheets/ART_NOTES.md` for the complete prompt set, and `animations/README.md` for frame mapping, integration and limitations. No audio generated.

Current textures: `noodle_squire.png`, `saucebound_knight.png`, `spaghetti_golem.png`.
Original portrait generation (2026-09-27): built-in image editing tool from the three user-provided evolution sheets in `../concepts/`. Transparent full-body sprites, matched to the corresponding stage. That original pass did not include animation frames; the later sheet pass is documented separately above.

Prompt intent: extract/adapt the single full-body character from each supplied concept sheet into a transparent standalone game sprite, preserving that stage's anatomy, spaghetti/meatball construction, glass and sauce details, palette and silhouette; remove labels, panels, background and floor shadows; no redesign or additional subjects.

The older `john_*` textures and portrait are historical references, not used by the current roster. Their original provenance remains in `assets/battle/ART_NOTES.md`.
