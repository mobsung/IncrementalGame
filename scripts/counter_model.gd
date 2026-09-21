class_name CounterModel
extends RefCounted

const UpgradeDefinition = preload("res://scripts/upgrade_definition.gd")

signal value_changed(current_value: float, progress: float, conversion: float)
signal xp_changed(current_xp: float, required_xp: float, level: int)
signal star_points_changed(new_amount: int)
signal stats_changed()
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal level_up(new_level: int)
signal crit_occurred(is_super: bool)
signal milestone_reached(currency_gained: float)

# State & Configuration
var tier_name: String = "Bronze"
var counter_value: float = 0.0
var last_milestone: float = 0.0
var conversion: float = 100.0
var max_conversion: float = 1.0

var base_yield: float = 5.0
var star_yield_bonus: float = 0.0
var timer_wait_time: float = 1.0

var crit_chance: float = 0.0
var crit_power: float = 2.0
var super_crit_chance: float = 0.0
var super_crit_power: float = 2.0

var counter_level: int = 1
var current_xp: float = 0.0
var xp_required: float = 10.0
var star_points: int = 0
var xp_per_conversion: float = 1.0

var ms_1: float = 0.0 # Rate per second

# Dictionary mapping upgrade_id -> current level (int)
var upgrades: Dictionary = {}
var upgrade_definitions: Array[UpgradeDefinition] = []

func setup(p_name: String, p_conversion: float, p_yield: float, p_wait_time: float, p_max_conv: float, p_definitions: Array[UpgradeDefinition] = []) -> void:
	tier_name = p_name
	conversion = p_conversion
	base_yield = p_yield
	timer_wait_time = p_wait_time
	max_conversion = p_max_conv
	upgrade_definitions = p_definitions
	calculate_m_s()

func get_effective_yield() -> float:
	return base_yield + star_yield_bonus

func calculate_m_s() -> float:
	var p_normal: float = maxf(0.0, 1.0 - crit_chance)
	var p_crit_only: float = crit_chance * (1.0 - super_crit_chance)
	var p_super: float = crit_chance * super_crit_chance

	var eff_yield: float = get_effective_yield()
	var expected_yield: float = 0.0
	expected_yield += eff_yield * p_normal
	expected_yield += (eff_yield * crit_power) * p_crit_only
	expected_yield += (eff_yield * crit_power * super_crit_power) * p_super

	var safe_time: float = maxf(timer_wait_time, 0.05)
	ms_1 = expected_yield / safe_time
	return ms_1

func calculate_increment_value() -> Dictionary:
	var val: float = get_effective_yield()
	var is_crit: bool = false
	var is_super: bool = false
	
	if randf() <= crit_chance:
		val *= crit_power
		is_crit = true
		if randf() <= super_crit_chance:
			val *= super_crit_power
			is_super = true
			
	return {
		"value": val,
		"is_crit": is_crit,
		"is_super": is_super
	}

func tick() -> Dictionary:
	var res: Dictionary = calculate_increment_value()
	counter_value += res["value"]
	if res["is_crit"]:
		crit_occurred.emit(res["is_super"])
	check_milestone()
	_notify_value_changed()
	return res

func manual_click() -> Dictionary:
	var res: Dictionary = calculate_increment_value()
	counter_value += res["value"]
	if res["is_crit"]:
		crit_occurred.emit(res["is_super"])
	check_milestone()
	_notify_value_changed()
	return res

func check_milestone() -> void:
	if conversion <= 0.0:
		return
	var current_milestone: float = floor(counter_value / conversion)
	if current_milestone > last_milestone:
		var diff: float = current_milestone - last_milestone
		CurrencyManager.add_currency(diff)
		last_milestone = current_milestone
		milestone_reached.emit(diff)
		add_xp(diff * xp_per_conversion * CurrencyManager.global_xp_multiplier)

func add_xp(amount: float) -> void:
	current_xp += amount
	var leveled_up: bool = false
	while current_xp >= xp_required:
		current_xp -= xp_required
		counter_level += 1
		star_points += 1
		xp_required = round(10.0 * pow(1.5, counter_level - 1))
		leveled_up = true
		level_up.emit(counter_level)
		star_points_changed.emit(star_points)
	
	xp_changed.emit(current_xp, xp_required, counter_level)

func _notify_value_changed() -> void:
	var progress: float = fmod(counter_value, conversion) if conversion > 0.0 else 0.0
	value_changed.emit(counter_value, progress, conversion)

func get_upgrade_level(upgrade_id: String) -> int:
	return upgrades.get(upgrade_id, 0)

func get_upgrade_cost(def: UpgradeDefinition) -> float:
	var lvl: int = get_upgrade_level(def.id)
	return def.calculate_cost(lvl)

func is_upgrade_max_level(def: UpgradeDefinition) -> bool:
	var lvl: int = get_upgrade_level(def.id)
	if def.max_level > 0 and lvl >= def.max_level:
		return true
	match def.effect_type:
		UpgradeDefinition.EffectType.SPEED:
			return timer_wait_time <= 0.1
		UpgradeDefinition.EffectType.CONVERT:
			return conversion <= max_conversion
		UpgradeDefinition.EffectType.CRIT_CHANCE:
			return crit_chance >= 1.0
		UpgradeDefinition.EffectType.SUPER_CRIT_CHANCE:
			return super_crit_chance >= 1.0
	return false

func can_afford_upgrade(def: UpgradeDefinition) -> bool:
	if is_upgrade_max_level(def):
		return false
	var cost: float = get_upgrade_cost(def)
	if def.cost_type == UpgradeDefinition.CostType.STAR_POINTS:
		return star_points >= int(cost)
	else:
		return CurrencyManager.can_afford(cost)

func buy_upgrade(def: UpgradeDefinition) -> bool:
	if not can_afford_upgrade(def):
		return false
		
	var cost: float = get_upgrade_cost(def)
	if def.cost_type == UpgradeDefinition.CostType.STAR_POINTS:
		var int_cost: int = int(cost)
		if star_points < int_cost:
			return false
		star_points -= int_cost
		star_points_changed.emit(star_points)
	else:
		if not CurrencyManager.spend_currency(cost):
			return false
			
	var new_lvl: int = get_upgrade_level(def.id) + 1
	upgrades[def.id] = new_lvl
	_apply_upgrade_effect(def)
	calculate_m_s()
	stats_changed.emit()
	upgrade_purchased.emit(def.id, new_lvl)
	return true

func _apply_upgrade_effect(def: UpgradeDefinition) -> void:
	match def.effect_type:
		UpgradeDefinition.EffectType.SPEED:
			timer_wait_time = maxf(0.1, snappedf(timer_wait_time - def.effect_value, 0.05))
		UpgradeDefinition.EffectType.YIELD:
			base_yield += def.effect_value
		UpgradeDefinition.EffectType.CONVERT:
			conversion = maxf(max_conversion, conversion - def.effect_value)
		UpgradeDefinition.EffectType.CRIT_CHANCE:
			crit_chance = minf(1.0, snappedf(crit_chance + def.effect_value, 0.05))
		UpgradeDefinition.EffectType.CRIT_POWER:
			crit_power += def.effect_value
		UpgradeDefinition.EffectType.SUPER_CRIT_CHANCE:
			super_crit_chance = minf(1.0, snappedf(super_crit_chance + def.effect_value, 0.05))
		UpgradeDefinition.EffectType.SUPER_CRIT_POWER:
			super_crit_power += def.effect_value
		UpgradeDefinition.EffectType.MEGA_YIELD:
			star_yield_bonus += def.effect_value
		UpgradeDefinition.EffectType.XP_WISDOM:
			xp_per_conversion += def.effect_value

func get_standard_upgrades() -> Array[UpgradeDefinition]:
	var list: Array[UpgradeDefinition] = []
	for def in upgrade_definitions:
		if def.category == UpgradeDefinition.Category.STANDARD:
			list.append(def)
	return list

func get_star_upgrades() -> Array[UpgradeDefinition]:
	var list: Array[UpgradeDefinition] = []
	for def in upgrade_definitions:
		if def.category == UpgradeDefinition.Category.STAR:
			list.append(def)
	return list

# --- Serialization (Step 3 Hook) ---
func serialize() -> Dictionary:
	return {
		"tier_name": tier_name,
		"counter_value": counter_value,
		"last_milestone": last_milestone,
		"conversion": conversion,
		"max_conversion": max_conversion,
		"base_yield": base_yield,
		"star_yield_bonus": star_yield_bonus,
		"timer_wait_time": timer_wait_time,
		"crit_chance": crit_chance,
		"crit_power": crit_power,
		"super_crit_chance": super_crit_chance,
		"super_crit_power": super_crit_power,
		"counter_level": counter_level,
		"current_xp": current_xp,
		"xp_required": xp_required,
		"star_points": star_points,
		"xp_per_conversion": xp_per_conversion,
		"upgrades": upgrades.duplicate()
	}

func deserialize(data: Dictionary) -> void:
	tier_name = data.get("tier_name", tier_name)
	counter_value = data.get("counter_value", 0.0)
	last_milestone = data.get("last_milestone", 0.0)
	conversion = data.get("conversion", conversion)
	max_conversion = data.get("max_conversion", max_conversion)
	base_yield = data.get("base_yield", base_yield)
	star_yield_bonus = data.get("star_yield_bonus", 0.0)
	timer_wait_time = data.get("timer_wait_time", timer_wait_time)
	crit_chance = data.get("crit_chance", 0.0)
	crit_power = data.get("crit_power", 2.0)
	super_crit_chance = data.get("super_crit_chance", 0.0)
	super_crit_power = data.get("super_crit_power", 2.0)
	counter_level = data.get("counter_level", 1)
	current_xp = data.get("current_xp", 0.0)
	xp_required = data.get("xp_required", 10.0)
	star_points = data.get("star_points", 0)
	xp_per_conversion = data.get("xp_per_conversion", 1.0)
	upgrades = data.get("upgrades", {}).duplicate()
	calculate_m_s()
	stats_changed.emit()
	_notify_value_changed()
	xp_changed.emit(current_xp, xp_required, counter_level)
	star_points_changed.emit(star_points)

# --- Offline Gains Simulation (Step 3 Hook) ---
func simulate_offline_time(seconds: float) -> Dictionary:
	if seconds <= 0.0:
		return { "ticks": 0, "value_gained": 0.0, "currency_gained": 0.0, "xp_gained": 0.0 }
		
	var safe_time: float = maxf(timer_wait_time, 0.05)
	var ticks_count: float = floor(seconds / safe_time)
	calculate_m_s()
	var expected_per_tick: float = ms_1 * safe_time
	var value_gained: float = ticks_count * expected_per_tick
	
	var old_milestone: float = last_milestone
	counter_value += value_gained
	check_milestone()
	var milestones_gained: float = last_milestone - old_milestone
	var xp_gained: float = milestones_gained * xp_per_conversion * CurrencyManager.global_xp_multiplier
	
	_notify_value_changed()
	return {
		"ticks": int(ticks_count),
		"value_gained": value_gained,
		"currency_gained": milestones_gained,
		"xp_gained": xp_gained
	}
