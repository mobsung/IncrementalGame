class_name OfflineSimulation
extends RefCounted
## Exact, bounded catch-up. UI calls pump() each frame; no wall-clock timers in combat.

var simulation: BattleSimulation
var remaining_steps: int = 0
var total_steps: int = 0
var processed_steps: int = 0
var report: Dictionary = {}
var finished: bool = false

func _init(model: BattleSimulation, elapsed: float) -> void:
	simulation = model
	var eligible: float = 0.0
	if model.config.offline_enabled and model.phase == &"battle" and is_finite(elapsed):
		eligible = clampf(elapsed, 0.0, model.config.offline_max_seconds)
	total_steps = floori(eligible / BattleSimulation.STEP)
	remaining_steps = total_steps
	report = {"seconds": 0.0, "eligible_seconds": eligible, "victories": 0, "defeats": 0,
		"gold": 0.0, "xp_per_copy": 0.0, "dust": 0, "reason": "Time limit"}
	if remaining_steps == 0:
		finished = true
		report.reason = "Paused or no offline time"
	else:
		simulation.offline_running = true
		simulation.attempt_finished.connect(_record_attempt)

func pump(max_steps: int = 600) -> bool:
	if finished:
		return true
	var started: int = Time.get_ticks_usec()
	var dust_before: int = simulation.profile.dust
	var count: int = 0
	while remaining_steps > 0 and simulation.phase == &"battle" and count < max_steps:
		# Preserve the saved fractional accumulator just as advance() does online.
		simulation.advance(BattleSimulation.STEP)
		remaining_steps -= 1
		processed_steps += 1
		count += 1
		if Time.get_ticks_usec() - started >= simulation.config.offline_frame_budget_ms * 1000.0:
			break
	report.dust += simulation.profile.dust - dust_before
	report.seconds = processed_steps * BattleSimulation.STEP
	if simulation.phase != &"battle":
		report.reason = "Defeat" if report.defeats > 0 else "Queued pause"
	if remaining_steps == 0 or simulation.phase != &"battle":
		_finish()
	return finished

func cancel() -> void:
	if not finished:
		report.reason = "Stopped by player"
		_finish()

func _finish() -> void:
	finished = true
	simulation.offline_running = false
	if simulation.attempt_finished.is_connected(_record_attempt):
		simulation.attempt_finished.disconnect(_record_attempt)

func _record_attempt(summary: Dictionary) -> void:
	report.victories += 1 if summary.victory else 0
	report.defeats += 0 if summary.victory else 1
	report.gold += summary.gold
	report.xp_per_copy += summary.xp
