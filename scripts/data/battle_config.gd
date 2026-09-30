class_name BattleConfig
extends Resource

const GachaDefinitionType = preload("res://scripts/data/gacha_definition.gd")

@export var ally: CombatantDefinition
@export var balanced: CombatantDefinition
@export var offensive: CombatantDefinition
@export var special: CombatantDefinition
@export var gacha: GachaDefinitionType
@export var arena: Rect2 = Rect2(30, 50, 1220, 540)
@export var slots: PackedVector2Array = PackedVector2Array([
	Vector2(200, 170), Vector2(340, 170), Vector2(480, 170),
	Vector2(200, 320), Vector2(340, 320), Vector2(480, 320),
	Vector2(200, 470), Vector2(340, 470), Vector2(480, 470)])
@export var spawn_position: Vector2 = Vector2(1120, 240)
@export var spawn_spread: float = 26.0
@export var return_delay: float = 0.75
@export var health_growth: float = 1.08
@export var attack_growth: float = 1.05
@export var spawn_window: float = 10.0
@export var special_delay: float = 1.0
@export var experience_base: float = 30.0
@export var experience_growth: float = 1.30
@export var soul_threshold: float = 20.0
@export var upgrades: Array[LevelUpgradeDefinition] = []
@export var gold_upgrades: Array[GoldUpgradeDefinition] = []
@export var global_upgrades: Array[StatUpgradeDefinition] = []
@export var chrono_upgrades: Array[StatUpgradeDefinition] = []
@export var offline_enabled: bool = true
@export var offline_max_seconds: float = 900.0
@export var offline_frame_budget_ms: float = 6.0
@export var support_slots: PackedVector2Array = PackedVector2Array([Vector2(960, 170), Vector2(960, 320), Vector2(960, 470)])
@export var extra_definitions: Array[CombatantDefinition] = []

func shop_catalog(shop: StringName) -> Array[StatUpgradeDefinition]:
	if shop == &"global":
		return global_upgrades
	if shop == &"chrono":
		return chrono_upgrades
	return []

func shop_upgrade(shop: StringName, upgrade_id: StringName) -> StatUpgradeDefinition:
	for upgrade: StatUpgradeDefinition in shop_catalog(shop):
		if upgrade.id == upgrade_id:
			return upgrade
	return null

func definitions() -> Dictionary:
	var result: Dictionary = {ally.id: ally, balanced.id: balanced, offensive.id: offensive, special.id: special}
	if gacha != null:
		for entry: Resource in gacha.entries:
			if entry != null and entry.unit != null and not result.has(entry.unit.id):
				result[entry.unit.id] = entry.unit
	for definition: CombatantDefinition in extra_definitions:
		result[definition.id] = definition
	var pending: Array = result.values()
	var visited: Dictionary = {}
	while not pending.is_empty():
		var definition: CombatantDefinition = pending.pop_back()
		if visited.has(definition.get_instance_id()):
			continue
		visited[definition.get_instance_id()] = true
		pending.append_array(definition.forms)
		for option: EvolutionDefinition in definition.evolution_options:
			if option.form != null:
				pending.append(option.form)
		for ability: AbilityDefinition in definition.active_abilities:
			for effect: AbilityEffectDefinition in ability.effects:
				if effect.summon != null:
					result[effect.summon.id] = effect.summon
					pending.append(effect.summon)
	return result

func upgrade_by_id(upgrade_id: StringName) -> LevelUpgradeDefinition:
	for upgrade: LevelUpgradeDefinition in upgrades:
		if upgrade.id == upgrade_id:
			return upgrade
	return null

func definition_for(copy: UnitProgress) -> CombatantDefinition:
	var base: CombatantDefinition = definitions().get(copy.species_id)
	if base != null and not copy.evolution_path.is_empty():
		var current: CombatantDefinition = base
		for index: int in range(copy.evolution_path.size()):
			var id: String = copy.evolution_path[index]
			if id == "__linear_%d" % (index + 1) and index < base.forms.size():
				current = base.forms[index]
				continue
			var next: CombatantDefinition = null
			for option: EvolutionDefinition in current.evolution_options:
				if String(option.id) == id:
					next = option.form
					break
			if next == null:
				return null
			current = next
		return current
	if base != null and copy.evolution > 0 and copy.evolution <= base.forms.size():
		return base.forms[copy.evolution - 1] as CombatantDefinition
	return base

func forms_for(base: CombatantDefinition) -> Array[CombatantDefinition]:
	var result: Array[CombatantDefinition] = []
	var pending: Array[CombatantDefinition] = [base]
	while not pending.is_empty():
		var current: CombatantDefinition = pending.pop_back()
		if current in result:
			continue
		result.append(current)
		for form: CombatantDefinition in current.forms:
			pending.append(form)
		for option: EvolutionDefinition in current.evolution_options:
			if option.form != null:
				pending.append(option.form)
	return result

func gold_upgrade_by_id(upgrade_id: StringName) -> GoldUpgradeDefinition:
	for upgrade: GoldUpgradeDefinition in gold_upgrades:
		if upgrade.id == upgrade_id:
			return upgrade
	return null

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	var ids: Array[StringName] = []
	for definition: CombatantDefinition in [ally, balanced, offensive, special]:
		if definition == null:
			errors.append("Missing combatant definition.")
			continue
		errors.append_array(definition.validation_errors())
		if definition.id in ids:
			errors.append("Duplicate content ID: %s" % definition.id)
		ids.append(definition.id)
	if gacha == null:
		errors.append("Missing gacha definition.")
	else:
		errors.append_array(gacha.validation_errors())
	if not is_finite(offline_max_seconds) or offline_max_seconds < 0.0 or not is_finite(offline_frame_budget_ms) or offline_frame_budget_ms <= 0.0:
		errors.append("Invalid offline simulation limits.")
	if slots.size() != 9 or not arena.has_point(spawn_position):
		errors.append("Invalid first arena geometry.")
	for upgrade: LevelUpgradeDefinition in upgrades:
		if upgrade == null or upgrade.id.is_empty() or upgrade.id in ids:
			errors.append("Missing or duplicate level upgrade.")
			continue
		ids.append(upgrade.id)
		if upgrade.max_ranks < 1 or upgrade.required_levels.size() != upgrade.max_ranks or upgrade.base_cost < 1 or upgrade.cost_increment < 0 or upgrade.effects.is_empty():
			errors.append("Invalid level upgrade: %s" % upgrade.id)
		for key: StringName in upgrade.effects:
			if key not in [&"gold_health", &"gold_attack", &"gold_armor", &"basic_coefficient", &"sweep_coefficient", &"sweep_area", &"sweep_cooldown", &"simmer_fraction", &"guard_armor", &"surge_fraction"] or not is_finite(upgrade.effects[key]) or upgrade.effects[key] < 0.0:
				errors.append("Invalid upgrade effect: %s" % key)
	for upgrade: GoldUpgradeDefinition in gold_upgrades:
		if upgrade == null or upgrade.id.is_empty() or upgrade.id in ids:
			errors.append("Missing or duplicate Gold upgrade.")
			continue
		ids.append(upgrade.id)
		if not upgrade.valid() or upgrade.operation != "additive" or upgrade.stat not in ["max_health", "attack", "armor", "attack_speed", "attack_range", "area", "haste", "gold", "experience", "souls", "magic_attack", "magic_resistance", "ability_power", "critical_chance", "critical_multiplier", "super_critical_chance", "super_critical_multiplier", "ultra_critical_chance", "ultra_critical_multiplier", "multi_hit", "multi_cast"]:
			errors.append("Invalid Gold upgrade: %s" % upgrade.id)
	for shop: StringName in [&"global", &"chrono"]:
		for upgrade: StatUpgradeDefinition in shop_catalog(shop):
			if upgrade == null or not upgrade.valid() or upgrade.id in ids:
				errors.append("Invalid or duplicate shop upgrade: %s" % shop)
				continue
			ids.append(upgrade.id)
	return errors
