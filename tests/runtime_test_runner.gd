extends Node
## Runs the headless suite through an editor-launched custom scene.

func _ready() -> void:
	await get_tree().process_frame
	var runner: Variant = load("res://tests/run_tests.gd").new()
	runner.host_tree = get_tree()
	await runner._run(false)
	set_meta("checks", runner.checks)
	set_meta("failures", runner.failures)
	# Keep the isolated runner available briefly so MCP can inspect its result.
	await get_tree().create_timer(30.0).timeout
	get_tree().quit(0 if runner.failures == 0 else 1)
