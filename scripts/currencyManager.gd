extends Node

signal currency_changed(new_amount: float)
signal prestige_points_changed(new_amount: int)
signal prestige_upgrades_changed()
signal prestige_performed(points_gained: int)

const PRESTIGE_BASE_CURRENCY: float = 100000.0

var current_currency: float = 0.0
var run_currency_earned: float = 0.0

var prestige_multiplier: float = 1.0
var global_multiplier: float = 1.0
var global_xp_multiplier: float = 1.0

var prestige_points: int = 0
var prestige_currency_level: int = 0
var prestige_xp_level: int = 0
var prestige_slots_level: int = 0

func can_afford(cost: float) -> bool:
	return current_currency >= cost

func add_currency(amount: float) -> void:
	var added: float = amount * prestige_multiplier * global_multiplier
	current_currency += added
	run_currency_earned += added
	currency_changed.emit(current_currency)

func spend_currency(cost: float) -> bool:
	if can_afford(cost):
		current_currency -= cost
		currency_changed.emit(current_currency)
		return true
	return false

# --- Prestige Logic ---

func get_claimable_prestige_points() -> int:
	if run_currency_earned < PRESTIGE_BASE_CURRENCY:
		return 0
	# 100k -> 1, 200k -> 2, 400k -> 3, 800k -> 4...
	var ratio: float = run_currency_earned / PRESTIGE_BASE_CURRENCY
	return int(floor(log(ratio) / log(2.0))) + 1

func get_next_point_target() -> float:
	var current_pts: int = get_claimable_prestige_points()
	if current_pts == 0:
		return PRESTIGE_BASE_CURRENCY
	return PRESTIGE_BASE_CURRENCY * pow(2.0, current_pts)

func get_current_point_threshold() -> float:
	var current_pts: int = get_claimable_prestige_points()
	if current_pts <= 0:
		return 0.0
	return PRESTIGE_BASE_CURRENCY * pow(2.0, current_pts - 1)

func get_prestige_progress() -> float:
	var prev: float = get_current_point_threshold()
	var next_tgt: float = get_next_point_target()
	if next_tgt <= prev:
		return 0.0
	return clampf((run_currency_earned - prev) / (next_tgt - prev), 0.0, 1.0)

func execute_prestige() -> int:
	var claimable: int = get_claimable_prestige_points()
	if claimable <= 0:
		return 0
	prestige_points += claimable
	current_currency = 0.0
	run_currency_earned = 0.0
	currency_changed.emit(current_currency)
	prestige_points_changed.emit(prestige_points)
	prestige_performed.emit(claimable)
	return claimable

# --- Prestige Shop Logic ---

func get_bonus_slots() -> int:
	return prestige_slots_level

func get_upgrade_cost(type: String) -> int:
	match type:
		"currency":
			return int(pow(2, prestige_currency_level))
		"xp":
			return int(pow(2, prestige_xp_level))
		"slots":
			return int(2 * pow(5, prestige_slots_level))
	return 999999999

func can_afford_prestige_upgrade(type: String) -> bool:
	return prestige_points >= get_upgrade_cost(type)

func buy_prestige_upgrade(type: String) -> bool:
	if not can_afford_prestige_upgrade(type):
		return false
	var cost: int = get_upgrade_cost(type)
	prestige_points -= cost
	match type:
		"currency":
			prestige_currency_level += 1
			prestige_multiplier = 1.0 + float(prestige_currency_level) * 1.0
		"xp":
			prestige_xp_level += 1
			global_xp_multiplier = 1.0 + float(prestige_xp_level) * 1.0
		"slots":
			prestige_slots_level += 1
	prestige_points_changed.emit(prestige_points)
	prestige_upgrades_changed.emit()
	return true
