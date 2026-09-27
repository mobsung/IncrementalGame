class_name SummonEntryDefinition
extends Resource
## One authored result in a summon pool. Copy progress is created at runtime.

const RARITIES: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic"]

@export var unit: CombatantDefinition
@export var rarity: StringName = &"common"
@export var pool_weight: float = 1.0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if unit == null:
		errors.append("Summon entry requires a unit definition.")
	elif unit.id.is_empty():
		errors.append("Summon entry unit requires a stable ID.")
	if rarity not in RARITIES:
		errors.append("Unknown summon rarity: %s" % rarity)
	if not is_finite(pool_weight) or pool_weight <= 0.0:
		errors.append("Summon pool weight must be positive: %s" % rarity)
	return errors
