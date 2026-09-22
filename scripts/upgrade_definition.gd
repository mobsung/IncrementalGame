class_name UpgradeDefinition
extends Resource

enum Category { STANDARD, STAR }
enum CostType { CURRENCY, STAR_POINTS }
enum CostGrowthType { EXPONENTIAL, LINEAR }
enum EffectType {
	SPEED,
	YIELD,
	CONVERT,
	CRIT_CHANCE,
	CRIT_POWER,
	SUPER_CRIT_CHANCE,
	SUPER_CRIT_POWER,
	MEGA_YIELD,
	XP_WISDOM
}

@export var id: String = ""
@export var display_name: String = ""
@export var category: Category = Category.STANDARD
@export var cost_type: CostType = CostType.CURRENCY
@export var base_cost: float = 1.0
@export var cost_growth_type: CostGrowthType = CostGrowthType.EXPONENTIAL
@export var cost_multiplier_or_step: float = 1.15
@export var max_level: int = -1
@export var effect_type: EffectType = EffectType.YIELD
@export var effect_value: float = 1.0

func calculate_cost(current_level: int) -> float:
	if cost_growth_type == CostGrowthType.EXPONENTIAL:
		return base_cost * pow(cost_multiplier_or_step, current_level)
	else:
		return base_cost + (float(current_level) * cost_multiplier_or_step)
