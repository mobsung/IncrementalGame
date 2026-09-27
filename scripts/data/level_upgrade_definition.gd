class_name LevelUpgradeDefinition
extends Resource

@export var id: StringName
@export var display_name: String
@export var max_ranks: int = 1
@export var base_cost: int = 1
@export var cost_increment: int = 1
@export var required_levels: PackedInt32Array = PackedInt32Array([1])
@export var description: String
@export var effects: Dictionary[StringName, float] = {}

func cost_for_rank(rank: int) -> int:
	return base_cost + cost_increment * rank

func unlocked_for(rank: int, level: int) -> bool:
	return rank < required_levels.size() and level >= required_levels[rank]
