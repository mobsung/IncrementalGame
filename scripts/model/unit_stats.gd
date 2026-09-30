class_name UnitStats
extends RefCounted
## Rebuild effective stats from immutable content and owned purchases, never from
## previously modified stats. Transient health/actions/timers remain untouched.

static func apply(actor: CombatantState, copy: UnitProgress, config: BattleConfig, profile: PlayerProfile) -> void:
	StatusSystem.remove_stats(actor)
	var definition: CombatantDefinition = config.definition_for(copy)
	var base: CombatantDefinition = config.definitions()[copy.species_id]
	assert(definition != null)
	var bonuses: Dictionary = {}
	for upgrade: LevelUpgradeDefinition in config.upgrades:
		for key: StringName in upgrade.effects:
			bonuses[key] = float(bonuses.get(key, 0.0)) + upgrade.effects[key] * copy.purchased_rank(upgrade.id)
	var gold: Dictionary = individual_gold_bonuses(copy, config)
	actor.max_health = base.max_health + float(gold.get("max_health", 0.0)) * (1.0 + float(bonuses.get(&"gold_health", 0.0)))
	actor.attack = base.physical_attack + float(gold.get("attack", 0.0)) * (1.0 + float(bonuses.get(&"gold_attack", 0.0)))
	actor.armor = base.armor + float(gold.get("armor", 0.0)) * (1.0 + float(bonuses.get(&"gold_armor", 0.0)))
	actor.max_health = ShopModifiers.value(actor.max_health, "max_health", profile, config)
	actor.attack = ShopModifiers.value(actor.attack, "attack", profile, config)
	actor.armor = ShopModifiers.value(actor.armor, "armor", profile, config)
	actor.unbuffed_attack = actor.attack
	actor.unbuffed_armor = actor.armor
	actor.health = minf(actor.health, actor.max_health)
	actor.basic_bonus = float(bonuses.get(&"basic_coefficient", 0.0))
	actor.sweep_bonus = float(bonuses.get(&"sweep_coefficient", 0.0))
	actor.attack_speed = ShopModifiers.value(base.attack_speed + float(gold.get("attack_speed", 0.0)), "attack_speed", profile, config)
	actor.attack_range = ShopModifiers.value(base.attack_range + float(gold.get("attack_range", 0.0)), "attack_range", profile, config)
	actor.multi_hit = maxi(1, roundi(ShopModifiers.value(float(base.multi_hit), "multi_hit", profile, config)))
	actor.multi_cast = maxi(1, roundi(ShopModifiers.value(float(base.multi_cast), "multi_cast", profile, config)))
	actor.area_bonus = ShopModifiers.value(float(bonuses.get(&"sweep_area", 0.0)) + float(gold.get("area", 0.0)), "area", profile, config)
	actor.haste = ShopModifiers.value(float(gold.get("haste", 0.0)), "haste", profile, config)
	actor.cooldown_reduction = float(bonuses.get(&"sweep_cooldown", 0.0))
	for stat: String in ["magic_attack", "magic_resistance", "ability_power", "critical_chance", "critical_multiplier",
			"super_critical_chance", "super_critical_multiplier", "ultra_critical_chance", "ultra_critical_multiplier"]:
		var value: float = ShopModifiers.value(float(base.get(stat)) + float(gold.get(stat, 0.0)), stat, profile, config)
		actor.set(stat, clampf(value, 0.0, 1.0) if stat.ends_with("_chance") else value)
	if definition.kit != null:
		definition.kit.ensure_state(actor)
		definition.kit.apply_stats(actor, copy)
	StatusSystem.apply_stats(actor)

static func individual_gold_bonuses(copy: UnitProgress, config: BattleConfig) -> Dictionary:
	var bonuses: Dictionary = {}
	for upgrade: GoldUpgradeDefinition in config.gold_upgrades:
		bonuses[upgrade.stat] = float(bonuses.get(upgrade.stat, 0.0)) + upgrade.increment * copy.gold_rank(upgrade.id)
	return bonuses

## Additive contribution of this copy, before shared reward pools.
static func reward_contribution(copy: UnitProgress, definition: CombatantDefinition, config: BattleConfig, stat: String) -> float:
	assert(stat in ["gold", "experience", "souls"])
	return float(definition.get(stat)) + float(individual_gold_bonuses(copy, config).get(stat, 0.0))
