class_name CounterModel
extends RefCounted

signal value_changed(total_value: float, progress: float, conversion: float)
signal xp_changed(current_xp: float, required_xp: float, level: int)
signal star_points_changed(new_amount: int)
signal stats_changed()
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal level_up(new_level: int)
signal crit_occurred(is_super: bool, multiplier: float, energy_added: float)
signal milestone_reached(currency_gained: float)
signal elemental_proc_triggered(proc_name: String, proc_color: Color, bonus_mana: float)
signal evolution_ready(ready: bool)
signal evolved(new_definition: CreatureDefinition)

# Current Creature Reference & Identification
var definition: CreatureDefinition = null
var tier_name: String = "Mana Wisp"
var element_name: String = "Neutral"
var element_color: Color = Color(0.35, 0.75, 1.0, 1.0)

# Energy & Mana Cycle (Robust Accumulator Model)
var cycle_progress: float = 0.0
var total_energy_accumulated: float = 0.0
var total_mana_produced: float = 0.0
var conversion: float = 100.0
var max_conversion: float = 1.0 # Dynamic Flow cap from creature

# Backwards compatibility aliases
var counter_value: float:
	get: return total_energy_accumulated
	set(v): total_energy_accumulated = v

var last_milestone: float:
	get: return total_mana_produced
	set(v): total_mana_produced = v

# Channel Stats (Synchronized via recalculate_all_stats)
var base_yield: float = 5.0
var star_yield_bonus: float = 0.0
var timer_wait_time: float = 1.0

var crit_chance: float = 0.05
var crit_power: float = 2.0
var super_crit_chance: float = 0.0
var super_crit_power: float = 2.0

# Elemental Caps & Multipliers
var speed_cap: float = 0.15
var flow_cap: float = 10.0
var crit_cap: float = 0.50
var super_crit_cap: float = 0.0
var yield_multiplier: float = 1.0

# Elemental Burst Proc Tracking
var cycle_counter: int = 0

# Leveling & Star Points
var counter_level: int = 1
var level: int:
	get: return counter_level
	set(v): counter_level = v
var current_xp: float = 0.0
var xp_required: float = 10.0
var star_points: int = 0
var xp_per_conversion: float = 1.0

# Production Rate
var ms_1: float = 0.0 # Expected energy rate per second

# Upgrade states: upgrade_id -> current level (int)
var upgrades: Dictionary = {}
var upgrade_definitions: Array[UpgradeDefinition] = []

func setup_from_definition(p_def: CreatureDefinition) -> void:
	definition = p_def
	tier_name = p_def.display_name
	element_name = p_def.primary_element
	element_color = p_def.element_color
	
	if p_def.available_upgrades.is_empty():
		upgrade_definitions = GlobalData.get_default_upgrades()
	else:
		upgrade_definitions = p_def.available_upgrades.duplicate()
		
	recalculate_all_stats()

func setup(p_name: String, p_conversion: float, p_yield: float, p_wait_time: float, p_max_conv: float, p_definitions: Array[UpgradeDefinition] = []) -> void:
	tier_name = p_name
	conversion = p_conversion
	base_yield = p_yield
	timer_wait_time = p_wait_time
	max_conversion = p_max_conv
	upgrade_definitions = p_definitions.duplicate() if not p_definitions.is_empty() else GlobalData.get_default_upgrades()
	recalculate_all_stats()

func recalculate_all_stats() -> void:
	if definition == null:
		return
		
	# 1. Elemental Caps & Multipliers
	yield_multiplier = definition.yield_multiplier
	speed_cap = definition.speed_cap
	flow_cap = definition.flow_cap
	crit_cap = definition.crit_cap
	super_crit_cap = definition.super_crit_cap
	max_conversion = flow_cap
	
	# 2. Multiplicative Stats based on Creature Base + Persistent Upgrade Levels
	var y_lvl: int = get_upgrade_level("yield")
	var mega_y: int = get_upgrade_level("mega_yield")
	var yield_mult: float = 1.0 + float(y_lvl) * 0.15
	base_yield = (definition.base_yield * yield_mult + float(mega_y) * 100.0) * yield_multiplier
	
	var spd_lvl: int = get_upgrade_level("speed")
	var raw_wait: float = definition.channel_interval * pow(0.95, float(spd_lvl))
	timer_wait_time = maxf(speed_cap, snappedf(raw_wait, 0.01))
	
	var flow_lvl: int = get_upgrade_level("convert")
	var raw_conv: float = definition.base_conversion * pow(0.95, float(flow_lvl))
	conversion = maxf(flow_cap, snappedf(raw_conv, 0.5))
	cycle_progress = minf(cycle_progress, conversion)
	
	var c_lvl: int = get_upgrade_level("crit_chance")
	crit_chance = minf(crit_cap, definition.crit_chance + float(c_lvl) * 0.02)
	
	var cp_lvl: int = get_upgrade_level("crit_power")
	crit_power = definition.crit_power + float(cp_lvl) * 0.25
	
	var sc_lvl: int = get_upgrade_level("super_crit_chance")
	super_crit_chance = minf(super_crit_cap, definition.super_crit_chance + float(sc_lvl) * 0.02)
	
	var scp_lvl: int = get_upgrade_level("super_crit_power")
	super_crit_power = definition.super_crit_power + float(scp_lvl) * 0.5
	
	var xp_lvl: int = get_upgrade_level("xp_wisdom")
	xp_per_conversion = 1.0 + float(xp_lvl) * 0.5
	
	calculate_m_s()

func get_effective_yield() -> float:
	return (base_yield + star_yield_bonus) * CurrencyManager.prestige_multiplier

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
	var mult: float = 1.0
	
	if randf() <= crit_chance:
		val *= crit_power
		mult *= crit_power
		is_crit = true
		if super_crit_chance > 0.0 and randf() <= super_crit_chance:
			val *= super_crit_power
			mult *= super_crit_power
			is_super = true
			
	return {
		"value": val,
		"is_crit": is_crit,
		"is_super": is_super,
		"multiplier": mult
	}

func tick() -> Dictionary:
	var res: Dictionary = calculate_increment_value()
	_add_energy(res["value"])
	if res["is_crit"]:
		crit_occurred.emit(res["is_super"], res["multiplier"], res["value"])
	return res

func manual_click() -> Dictionary:
	var res: Dictionary = calculate_increment_value()
	_add_energy(res["value"])
	if res["is_crit"]:
		crit_occurred.emit(res["is_super"], res["multiplier"], res["value"])
	return res

func _add_energy(amount: float) -> float:
	cycle_progress += amount
	total_energy_accumulated += amount
	var mana_discharged: float = 0.0
	
	var safe_conv: float = maxf(conversion, 1.0)
	if cycle_progress >= safe_conv:
		var discharges: int = int(cycle_progress / safe_conv)
		cycle_progress -= float(discharges) * safe_conv
		mana_discharged = float(discharges)
		
		if definition != null and definition.proc_cycle_interval > 0:
			var total_cycles: int = cycle_counter + discharges
			var num_procs: int = int(total_cycles / definition.proc_cycle_interval)
			cycle_counter = total_cycles % definition.proc_cycle_interval
			if num_procs > 0:
				_trigger_elemental_proc_batch(num_procs)
				
		CurrencyManager.add_currency(mana_discharged)
		total_mana_produced += mana_discharged
		milestone_reached.emit(mana_discharged)
		add_xp(mana_discharged * xp_per_conversion * CurrencyManager.global_xp_multiplier)
		
	_notify_value_changed()
	return mana_discharged

func _trigger_elemental_proc() -> void:
	_trigger_elemental_proc_batch(1)

func _trigger_elemental_proc_batch(num_procs: int) -> void:
	if definition == null or definition.proc_name.is_empty() or num_procs <= 0:
		return
	var base_bonus: float = 0.0
	match definition.primary_element:
		"Fire":
			base_bonus = get_effective_yield() * 3.0
		"Water":
			base_bonus = get_effective_yield() * 1.5
			cycle_progress = conversion # Instant fill
		"Earth":
			base_bonus = get_effective_yield() * 2.0
			add_xp(counter_level * 5.0 * float(num_procs))
		"Lightning":
			base_bonus = get_effective_yield() * crit_power * 2.0
		"Ice":
			base_bonus = get_effective_yield() * 1.5
		"Darkness":
			base_bonus = get_effective_yield() * crit_power * (super_crit_power if super_crit_power > 0.0 else 3.0)
		_:
			base_bonus = get_effective_yield() * 1.0
			
	var total_bonus: float = base_bonus * float(num_procs)
	CurrencyManager.add_currency(total_bonus)
	var proc_display_name: String = definition.proc_name if num_procs == 1 else "%s (x%d)" % [definition.proc_name, num_procs]
	elemental_proc_triggered.emit(proc_display_name, definition.proc_color, total_bonus)

func add_xp(amount: float) -> void:
	current_xp += amount
	var levels_gained: int = 0
	while current_xp >= xp_required and levels_gained < 200:
		current_xp -= xp_required
		counter_level += 1
		star_points += 1
		xp_required = round(10.0 * pow(1.4, counter_level - 1))
		levels_gained += 1
		
	if levels_gained > 0:
		star_points_changed.emit(star_points)
		level_up.emit(counter_level)
		evolution_ready.emit(can_evolve())
		
	xp_changed.emit(current_xp, xp_required, counter_level)

func _notify_value_changed() -> void:
	value_changed.emit(total_energy_accumulated, cycle_progress, conversion)

# --- Evolution Logic ---
func can_evolve() -> bool:
	if definition == null:
		return false
	if definition.evolution_level_req <= 0 or definition.get_evolution_choices().is_empty():
		return false
	return counter_level >= definition.evolution_level_req

func get_evolution_options() -> Array[CreatureDefinition]:
	if definition == null:
		return []
	var res: Array[CreatureDefinition] = []
	for item in definition.get_evolution_choices():
		if item is CreatureDefinition:
			res.append(item as CreatureDefinition)
	return res

func evolve_to(new_def: CreatureDefinition) -> void:
	definition = new_def
	tier_name = new_def.display_name
	element_name = new_def.primary_element
	element_color = new_def.element_color
	
	# All upgrades already purchased in upgrades dictionary are preserved!
	# Recalculate stats immediately scales new base stats with existing upgrades
	recalculate_all_stats()
	
	stats_changed.emit()
	_notify_value_changed()
	evolved.emit(new_def)
	evolution_ready.emit(can_evolve())

# --- Upgrade Handling ---
func get_upgrade_level(upgrade_id: String) -> int:
	if upgrades.has(upgrade_id):
		return upgrades[upgrade_id]
	match upgrade_id:
		"speed", "speed_1":
			return upgrades.get("speed_1", upgrades.get("speed", 0))
		"yield", "value_1":
			return upgrades.get("value_1", upgrades.get("yield", 0))
		"convert", "convert_1":
			return upgrades.get("convert_1", upgrades.get("convert", 0))
		"crit_chance", "crit_1":
			return upgrades.get("crit_1", upgrades.get("crit_chance", 0))
		"crit_power", "crit_power_1":
			return upgrades.get("crit_power_1", upgrades.get("crit_power", 0))
		"super_crit_chance", "scrit_1":
			return upgrades.get("scrit_1", upgrades.get("super_crit_chance", 0))
		"super_crit_power", "scrit_power_1":
			return upgrades.get("scrit_power_1", upgrades.get("super_crit_power", 0))
		"mega_yield", "mega_yield_1":
			return upgrades.get("mega_yield_1", upgrades.get("mega_yield", 0))
		"xp_wisdom", "xp_wisdom_1":
			return upgrades.get("xp_wisdom_1", upgrades.get("xp_wisdom", 0))
	return 0

func get_upgrade_cost(def: UpgradeDefinition) -> float:
	var lvl: int = get_upgrade_level(def.id)
	return def.calculate_cost(lvl)

func is_upgrade_max_level(def: UpgradeDefinition) -> bool:
	var lvl: int = get_upgrade_level(def.id)
	if def.max_level > 0 and lvl >= def.max_level:
		return true
	match def.effect_type:
		UpgradeDefinition.EffectType.SPEED:
			return timer_wait_time <= speed_cap
		UpgradeDefinition.EffectType.CONVERT:
			return conversion <= flow_cap
		UpgradeDefinition.EffectType.CRIT_CHANCE:
			return crit_chance >= crit_cap
		UpgradeDefinition.EffectType.SUPER_CRIT_CHANCE:
			return super_crit_chance >= super_crit_cap or super_crit_cap <= 0.0
		UpgradeDefinition.EffectType.SUPER_CRIT_POWER:
			return super_crit_cap <= 0.0
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
	recalculate_all_stats()
	stats_changed.emit()
	upgrade_purchased.emit(def.id, new_lvl)
	return true

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

# --- Serialization Hooks ---
func serialize() -> Dictionary:
	return {
		"definition_id": definition.id if definition != null else "",
		"tier_name": tier_name,
		"total_energy": total_energy_accumulated,
		"cycle_progress": cycle_progress,
		"total_mana": total_mana_produced,
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
	total_energy_accumulated = data.get("total_energy", 0.0)
	cycle_progress = data.get("cycle_progress", 0.0)
	total_mana_produced = data.get("total_mana", 0.0)
	conversion = data.get("conversion", conversion)
	max_conversion = data.get("max_conversion", max_conversion)
	base_yield = data.get("base_yield", base_yield)
	star_yield_bonus = data.get("star_yield_bonus", 0.0)
	timer_wait_time = data.get("timer_wait_time", timer_wait_time)
	crit_chance = data.get("crit_chance", crit_chance)
	crit_power = data.get("crit_power", crit_power)
	super_crit_chance = data.get("super_crit_chance", super_crit_chance)
	super_crit_power = data.get("super_crit_power", super_crit_power)
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
	evolution_ready.emit(can_evolve())
