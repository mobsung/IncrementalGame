# Regression suites

2026-10-01 Wizard frame correction: latest CLI suite 1,569 checks / zero failures; UV isolation and extended-prop regression probes included. `wizard_atlas_preview.tscn` captures all 174 runtime indices in five pages, including death. `isolate_wizard_frames.py` regenerates metadata only, preserving PNGs; `calibrate_wizard_atlas.py` is superseded and guarded. Runtime frames reuse one valid Makeshift pose for the empty source cell. Current MCP results are in PROJECT_CONTEXT.md.

Run `res://tests/runtime_test_runner.tscn` in Godot 4.7, or use `--headless --path . --script tests/run_spaghetti_tests.gd`.
The current suite uses isolated profiles and disposable `demo_test_*.save` files; it never loads the player's save. Latest final CLI run: 1,210 checks, zero failures, Godot 4.7 (2026-10-01). Wizard coverage includes both branches, healing/sharing/rescue, physical traps and real decoys, Encore, atlas bounds/icons, two-species gacha, formation restrictions, UI slot placement and deterministic resumed battles. MCP results are recorded in PROJECT_CONTEXT.md.

Run the isolated animation preview with `-- idle-capture` using a graphical renderer for 38 pixel checks across all three forms and both facings: unchanged feet through the loop, changing breathing/drips and exact pause stability. Latest run: 38 checks, zero failures. Captures in `tests/idle_*_preview.png` are ignored.
It covers the three forms, action timing, Sauce/buffs/healing, evolution, shared combat/gacha, serialization/migration and UI.
Sprite-sheet checks cover all atlas bounds/alpha, fixed virtual canvases, evolution-specific clips, frame synchronization, pause and independent presentation state. The suite now also includes `base_mechanics_tests.gd`: Chrono structural purchases, priorities, healing/resurrection, status/reward effects, dead-copy timers, support roles, summons, evolution branches, generated packets, exact offline simulation and v8→v9 migration. Final results are recorded in PROJECT_CONTEXT.md.

Revised-sheet checks also cover the common 640×640 presentation canvas, finite uniform scale, ground registration across idle/impact, and final Guard activation ordering. `sprite_sheet_audit.gd -- refined` inspects all nine source PNGs offline without changing artwork. The isolated `content/units/warriors/spaghetti_golem/visuals/animations/preview.tscn` supports frame scrubbing and mirroring; run it with `-- capture` for nine screenshots in `tests/refined_sheet_*_preview.png`.

`wizard_playground.tscn` is a disposable Golem+Wizard playground: F6, keys 1–5 select forms, 200 Dust, persistence disabled. `-- capture` emits ten form/cast captures and a kit panel. `grant_wizard_copy.tscn` is an explicitly authorized real-profile grant utility, not a regression test: preserves wallets/battle state/offline timestamp and rereads the save; never run it as part of the isolated suite.

`base_mechanics_preview.tscn` is a disposable four-synthetic-species preview with persistence disabled. For viewport captures, run the installed Godot with `--path . res://tests/base_mechanics_preview.tscn -- capture`; screenshots in `tests/*_preview.png` are ignored by Git. It captures unit/priorities, Chrono and the offline summary, then exits.

`legacy/john_v7.gd.txt` preserves the previous 487-check suite for reference. Its old species, numerical balance and version-specific assumptions no longer describe the game. It is deliberately not registered as a Godot script.
