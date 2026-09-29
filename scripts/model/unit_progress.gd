class_name UnitProgress
extends RefCounted
## One owned copy. No battle health or cooldowns belong here.

var id: String = ""
var species_id: StringName = &"spaghetti_golem"
var evolution: int = 0
var level: int = 1
var experience: float = 0.0
var level_points: int = 0
var mobile: bool = true
var priority: int = 0
var slot: int = 4
var deployed: bool = false
var movement_speed: float = 220.0
var upgrade_ranks: Dictionary = {}
var gold_ranks: Dictionary = {}

const FIELDS: Array[StringName] = [
	&"id", &"species_id", &"evolution", &"level", &"experience", &"level_points",
	&"mobile", &"priority", &"slot", &"deployed", &"movement_speed"]

func xp_required(config: BattleConfig) -> float:
	return ceil(config.experience_base * pow(config.experience_growth, level - 1))

func grant_experience(amount: float, config: BattleConfig) -> void:
	experience += amount
	while experience >= xp_required(config):
		experience -= xp_required(config)
		level += 1
		level_points += 1

func purchased_rank(upgrade_id: StringName) -> int:
	return int(upgrade_ranks.get(upgrade_id, 0))

func gold_rank(upgrade_id: StringName) -> int:
	return int(gold_ranks.get(upgrade_id, 0))

func purchase_upgrade(upgrade: LevelUpgradeDefinition) -> bool:
	var rank: int = purchased_rank(upgrade.id)
	if rank >= upgrade.cap_for(evolution) or level_points < upgrade.cost_for_rank(rank):
		return false
	if not upgrade.unlocked_for(rank, level):
		return false
	level_points -= upgrade.cost_for_rank(rank)
	upgrade_ranks[upgrade.id] = rank + 1
	return true

func to_data() -> Dictionary:
	var data: Dictionary = {}
	for field: StringName in FIELDS:
		data[field] = get(field)
	data[&"upgrade_ranks"] = upgrade_ranks.duplicate(true)
	data[&"gold_ranks"] = gold_ranks.duplicate(true)
	return data

static func from_data(data: Dictionary) -> UnitProgress:
	var copy: UnitProgress = UnitProgress.new()
	for field: StringName in FIELDS:
		copy.set(field, data[field])
	copy.upgrade_ranks = data.get(&"upgrade_ranks", {}).duplicate(true)
	copy.gold_ranks = data.get(&"gold_ranks", {}).duplicate(true)
	return copy
