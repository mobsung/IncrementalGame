# Regression suites

Run `res://tests/runtime_test_runner.tscn` in Godot 4.7, or use `--headless --path . --script tests/run_spaghetti_tests.gd`.
The current suite uses isolated profiles and disposable `demo_test_*.save` files; it never loads the player's save.
It covers the three forms, action timing, Sauce/buffs/healing, evolution, shared combat/gacha, serialization/migration and UI.
Sprite-sheet checks cover all atlas bounds/alpha, fixed virtual canvases, evolution-specific clips, frame synchronization, pause and independent presentation state. Latest Godot AI run: 434 checks, zero failures (2026-09-29).

`legacy/john_v7.gd.txt` preserves the previous 487-check suite for reference. Its old species, numerical balance and version-specific assumptions no longer describe the game. It is deliberately not registered as a Godot script.
