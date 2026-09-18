class_name Global_data

const UpgradeDefinition = preload("res://scripts/upgrade_definition.gd")
const TierDefinition = preload("res://scripts/tier_definition.gd")

const SUFFIXES: Array[String] = [
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg",
	"Uvg", "Dvg", "Tvg", "Qavg", "Qivg", "Sxvg", "Spvg", "Ocvg", "Novg",
	"Tg", "Utg", "Dtg", "Gg"
]

const TIER_RESOURCE_PATHS: Array[String] = [
	"res://resources/tiers/bronze.tres",
	"res://resources/tiers/silver.tres",
	"res://resources/tiers/gold.tres",
	"res://resources/tiers/platinum.tres",
	"res://resources/tiers/diamond.tres",
	"res://resources/tiers/obsidian.tres"
]

const UPGRADE_RESOURCE_PATHS: Array[String] = [
	"res://resources/upgrades/speed.tres",
	"res://resources/upgrades/yield.tres",
	"res://resources/upgrades/convert.tres",
	"res://resources/upgrades/crit_chance.tres",
	"res://resources/upgrades/crit_power.tres",
	"res://resources/upgrades/super_crit_chance.tres",
	"res://resources/upgrades/super_crit_power.tres",
	"res://resources/upgrades/mega_yield.tres",
	"res://resources/upgrades/xp_wisdom.tres"
]

static func load_default_upgrades() -> Array[UpgradeDefinition]:
	var list: Array[UpgradeDefinition] = []
	for p in UPGRADE_RESOURCE_PATHS:
		if ResourceLoader.exists(p):
			var res: UpgradeDefinition = load(p) as UpgradeDefinition
			if res != null:
				list.append(res)
	return list

static func get_tier_definition(index: int) -> TierDefinition:
	if index >= 0 and index < TIER_RESOURCE_PATHS.size():
		var path: String = TIER_RESOURCE_PATHS[index]
		if ResourceLoader.exists(path):
			var tier: TierDefinition = load(path) as TierDefinition
			if tier != null:
				return tier
				
	# Procedural fallback for tiers beyond the 6 authored resources
	var last_tier: TierDefinition = null
	if ResourceLoader.exists(TIER_RESOURCE_PATHS[TIER_RESOURCE_PATHS.size() - 1]):
		last_tier = load(TIER_RESOURCE_PATHS[TIER_RESOURCE_PATHS.size() - 1]) as TierDefinition
	
	var base_val: float = last_tier.increment_value if last_tier != null else 5000.0
	var base_time: float = last_tier.base_timer_wait_time if last_tier != null else 0.25
	var extra_levels: int = max(0, index - TIER_RESOURCE_PATHS.size() + 1)
	
	var proc_tier := TierDefinition.new()
	proc_tier.tier_name = "Tier %d" % (index + 1)
	proc_tier.conversion = 1.0
	proc_tier.increment_value = base_val * pow(4.0, extra_levels)
	proc_tier.base_timer_wait_time = maxf(0.1, base_time)
	proc_tier.max_conversion = 1.0
	proc_tier.available_upgrades = load_default_upgrades()
	return proc_tier

static func get_counter_tier(index: int) -> Dictionary:
	var def: TierDefinition = get_tier_definition(index)
	return {
		"name": def.tier_name,
		"conversion": def.conversion,
		"increment_value": def.increment_value,
		"base_timer_wait_time": def.base_timer_wait_time,
		"max_conversion": def.max_conversion
	}

static func format_number(value: float) -> String:
	if is_nan(value):
		return "0"
	if is_inf(value):
		return "Infinity" if value > 0.0 else "-Infinity"
	if value == 0.0:
		return "0"
		
	var sign_str: String = "-" if value < 0.0 else ""
	var abs_val: float = absf(value)
	
	if abs_val < 1000.0:
		if abs_val == floor(abs_val):
			return sign_str + str(int(abs_val))
		return sign_str + "%.1f" % abs_val

	var exponent: int = int(floor(log(abs_val) / log(1000.0)))
	if exponent >= SUFFIXES.size():
		var base10_exp: int = int(floor(log(abs_val) / log(10.0)))
		var mantissa: float = abs_val / pow(10.0, base10_exp)
		if mantissa >= 9.995:
			mantissa = 1.0
			base10_exp += 1
		return sign_str + "%.2fe%d" % [mantissa, base10_exp]
		
	var scaled: float = abs_val / pow(1000.0, exponent)
	if scaled >= 999.995:
		exponent += 1
		if exponent < SUFFIXES.size():
			scaled = abs_val / pow(1000.0, exponent)
		else:
			var base10_exp: int = int(floor(log(abs_val) / log(10.0)))
			var mantissa: float = abs_val / pow(10.0, base10_exp)
			return sign_str + "%.2fe%d" % [mantissa, base10_exp]
			
	return sign_str + "%.2f%s" % [scaled, SUFFIXES[exponent]]
