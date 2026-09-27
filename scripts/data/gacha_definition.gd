class_name GachaDefinition
extends Resource
## Data-driven summon cost and pool. Only authored entries can be drawn.

const SummonEntryType = preload("res://scripts/data/summon_entry_definition.gd")

@export var cost_dust: int = 5
@export var rarity_weights: Dictionary = {
	&"common": 55.0, &"uncommon": 30.0, &"rare": 12.0, &"epic": 3.0}
@export var entries: Array[Resource] = []

func draw(rng: RandomNumberGenerator) -> Resource:
	var available: Dictionary = {}
	for entry: Resource in entries:
		if entry == null or entry.unit == null or entry.pool_weight <= 0.0:
			continue
		if not available.has(entry.rarity):
			available[entry.rarity] = []
		available[entry.rarity].append(entry)
	if available.is_empty():
		return null
	var rarity: StringName = _weighted_key(available.keys(), rarity_weights, rng)
	var candidates: Array = available[rarity]
	if candidates.size() == 1:
		return candidates[0]
	var total: float = 0.0
	for entry: Resource in candidates:
		total += entry.pool_weight
	var roll: float = rng.randf() * total
	for entry: Resource in candidates:
		roll -= entry.pool_weight
		if roll <= 0.0:
			return entry
	return candidates.back()

func _weighted_key(keys: Array, weights: Dictionary, rng: RandomNumberGenerator) -> StringName:
	if keys.size() == 1:
		return keys[0]
	var total: float = 0.0
	for key: StringName in keys:
		total += float(weights.get(key, 0.0))
	var roll: float = rng.randf() * total
	for key: StringName in keys:
		roll -= float(weights.get(key, 0.0))
		if roll <= 0.0:
			return key
	return keys.back()

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if cost_dust <= 0:
		errors.append("Summon Dust cost must be positive.")
	for rarity: StringName in SummonEntryType.RARITIES:
		var weight: Variant = rarity_weights.get(rarity)
		if not weight is float and not weight is int:
			errors.append("Missing rarity weight: %s" % rarity)
		elif not is_finite(float(weight)) or float(weight) <= 0.0:
			errors.append("Invalid rarity weight: %s" % rarity)
	if entries.is_empty():
		errors.append("Summon pool cannot be empty.")
	var species: Array[StringName] = []
	for entry: Resource in entries:
		if entry == null:
			errors.append("Missing summon pool entry.")
			continue
		errors.append_array(entry.validation_errors())
		if entry.unit != null:
			if entry.unit.id in species:
				errors.append("Duplicate summon species: %s" % entry.unit.id)
			species.append(entry.unit.id)
	return errors
