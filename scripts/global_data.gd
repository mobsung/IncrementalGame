class_name GlobalData
extends RefCounted

const SUFFIXES: Array[String] = [
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg",
	"Uvg", "Dvg", "Tvg", "Qavg", "Qivg", "Sxvg", "Spvg", "Ocvg", "Novg",
	"Tg", "Utg", "Dtg", "Gg"
]

const CREATURE_PATHS: Dictionary = {
	"mana_wisp": "res://resources/creatures/mana_wisp.tres",
	# Stage 1
	"pyro_sprite": "res://resources/creatures/pyro_sprite.tres",
	"aqua_nymph": "res://resources/creatures/aqua_nymph.tres",
	"terra_gnome": "res://resources/creatures/terra_gnome.tres",
	# Stage 2 (Fire)
	"flame_ifrit": "res://resources/creatures/flame_ifrit.tres",
	"magma_drake": "res://resources/creatures/magma_drake.tres",
	"spark_phoenix": "res://resources/creatures/spark_phoenix.tres",
	# Stage 2 (Water)
	"tidal_siren": "res://resources/creatures/tidal_siren.tres",
	"glacial_nixie": "res://resources/creatures/glacial_nixie.tres",
	"abyssal_kelpie": "res://resources/creatures/abyssal_kelpie.tres",
	# Stage 2 (Earth)
	"stone_golem": "res://resources/creatures/stone_golem.tres",
	"crystal_warden": "res://resources/creatures/crystal_warden.tres",
	"shadow_behemoth": "res://resources/creatures/shadow_behemoth.tres",
	# Stage 3 Apex
	"solar_colossus": "res://resources/creatures/solar_colossus.tres",
	"volcanic_hydra": "res://resources/creatures/volcanic_hydra.tres",
	"calamity_inferno": "res://resources/creatures/calamity_inferno.tres",
	"tectonic_beast": "res://resources/creatures/tectonic_beast.tres",
	"tempest_phoenix": "res://resources/creatures/tempest_phoenix.tres",
	"oceanic_leviathan": "res://resources/creatures/oceanic_leviathan.tres",
	"abyssal_archon": "res://resources/creatures/abyssal_archon.tres",
	"rime_storm_serpent": "res://resources/creatures/rime_storm_serpent.tres",
	"shadow_cataclysm": "res://resources/creatures/shadow_cataclysm.tres",
	"gaia_prime_colossus": "res://resources/creatures/gaia_prime_colossus.tres",
	"continental_turtle": "res://resources/creatures/continental_turtle.tres",
	"dusk_titan": "res://resources/creatures/dusk_titan.tres"
}

static func get_starting_creature() -> CreatureDefinition:
	var path: String = CREATURE_PATHS.get("mana_wisp", "")
	if ResourceLoader.exists(path):
		var def: CreatureDefinition = load(path) as CreatureDefinition
		if def != null:
			return def
	# Fallback
	var fallback := CreatureDefinition.new()
	fallback.id = "mana_wisp"
	fallback.display_name = "Mana Wisp"
	fallback.primary_element = "Neutral"
	fallback.element_color = Color(0.35, 0.75, 1.0, 1.0)
	fallback.base_yield = 5.0
	fallback.base_conversion = 100.0
	fallback.channel_interval = 1.0
	return fallback

static func get_creature_definition(id: String) -> CreatureDefinition:
	var path: String = CREATURE_PATHS.get(id, "")
	if ResourceLoader.exists(path):
		var def: CreatureDefinition = load(path) as CreatureDefinition
		if def != null:
			return def
	return null

static func get_creature_by_id(id: String) -> CreatureDefinition:
	var def: CreatureDefinition = get_creature_definition(id)
	return def if def != null else get_starting_creature()

static func get_default_upgrades() -> Array[UpgradeDefinition]:
	var list: Array[UpgradeDefinition] = []
	var paths: Array[String] = [
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
	for p in paths:
		if ResourceLoader.exists(p):
			var upg: UpgradeDefinition = load(p) as UpgradeDefinition
			if upg != null:
				list.append(upg)
	return list


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
