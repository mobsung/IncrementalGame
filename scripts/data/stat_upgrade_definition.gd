class_name StatUpgradeDefinition
extends Resource
## Shared pricing/effect contract for permanent stat purchases.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export_enum("max_health", "attack", "armor", "gold", "experience", "souls", "attack_speed", "attack_range", "area", "haste", "magic_attack", "magic_resistance", "ability_power", "critical_chance", "critical_multiplier", "super_critical_chance", "super_critical_multiplier", "ultra_critical_chance", "ultra_critical_multiplier", "multi_hit", "multi_cast") var stat: String = "max_health"
@export_enum("additive", "multiplier") var operation: String = "additive"
@export var increment: float = 1.0
@export var base_cost: float = 10.0
@export var cost_growth: float = 1.18
@export var max_ranks: int = 100

func cost_for_rank(rank: int) -> float:
	return ceil(base_cost * pow(cost_growth, rank))

func valid() -> bool:
	return not id.is_empty() and not display_name.is_empty() and stat in ["max_health", "attack", "armor", "gold", "experience", "souls", "attack_speed", "attack_range", "area", "haste", "magic_attack", "magic_resistance", "ability_power", "critical_chance", "critical_multiplier", "super_critical_chance", "super_critical_multiplier", "ultra_critical_chance", "ultra_critical_multiplier", "multi_hit", "multi_cast"] and operation in ["additive", "multiplier"] and max_ranks > 0 and is_finite(increment) and increment > 0.0 and is_finite(base_cost) and base_cost > 0.0 and is_finite(cost_growth) and cost_growth > 1.0 and is_finite(cost_for_rank(max_ranks))
