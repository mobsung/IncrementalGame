# Regression suites

Run `res://tests/runtime_test_runner.tscn` in Godot 4.7, or use `--headless --path . --script tests/run_spaghetti_tests.gd`.
The current suite uses isolated profiles and disposable `demo_test_*.save` files; it never loads the player's save. Latest final run: 831 checks, zero failures, Godot 4.7 console and Godot AI (2026-09-30, planted idle). The lower count reflects replacing three unused idle frames per form; new checks cover the planted source pose and visual-clock pause.

Run the isolated animation preview with `-- idle-capture` using a graphical renderer for 38 pixel checks across all three forms and both facings: unchanged feet through the loop, changing breathing/drips and exact pause stability. Latest run: 38 checks, zero failures. Captures in `tests/idle_*_preview.png` are ignored.
It covers the three forms, action timing, Sauce/buffs/healing, evolution, shared combat/gacha, serialization/migration and UI.
Sprite-sheet checks cover all atlas bounds/alpha, fixed virtual canvases, evolution-specific clips, frame synchronization, pause and independent presentation state. The suite now also includes `base_mechanics_tests.gd`: Chrono structural purchases, priorities, healing/resurrection, status/reward effects, dead-copy timers, support roles, summons, evolution branches, generated packets, exact offline simulation and v8→v9 migration. Final results are recorded in PROJECT_CONTEXT.md.

Revised-sheet checks also cover the common 640×640 presentation canvas, finite uniform scale, ground registration across idle/impact, and final Guard activation ordering. `sprite_sheet_audit.gd -- refined` inspects all nine source PNGs offline without changing artwork. The isolated `content/units/warriors/spaghetti_golem/visuals/animations/preview.tscn` supports frame scrubbing and mirroring; run it with `-- capture` for nine screenshots in `tests/refined_sheet_*_preview.png`.

`base_mechanics_preview.tscn` is a disposable four-copy preview with persistence disabled. For viewport captures, run the installed Godot with `--path . res://tests/base_mechanics_preview.tscn -- capture`; screenshots in `tests/*_preview.png` are ignored by Git. It captures unit/priorities, Chrono and the offline summary, then exits.

`legacy/john_v7.gd.txt` preserves the previous 487-check suite for reference. Its old species, numerical balance and version-specific assumptions no longer describe the game. It is deliberately not registered as a Godot script.
