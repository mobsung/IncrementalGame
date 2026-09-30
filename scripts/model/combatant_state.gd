class_name CombatantState
extends RefCounted
## Serializable runtime state; never holds a Node or edits a content Resource.

var id: int = 0
var copy_id: String = ""
var definition_id: StringName
var allied: bool = false
var position: Vector2 = Vector2.ZERO
var anchor: Vector2 = Vector2.ZERO
var health: float = 0.0
var max_health: float = 0.0
var attack: float = 0.0
var armor: float = 0.0
var magic_attack: float = 0.0
var magic_resistance: float = 0.0
var ability_power: float = 0.0
var critical_chance: float = 0.0
var critical_multiplier: float = 1.5
var super_critical_chance: float = 0.0
var super_critical_multiplier: float = 2.0
var ultra_critical_chance: float = 0.0
var ultra_critical_multiplier: float = 2.0
var speed: float = 0.0
var attack_speed: float = 1.0
var attack_range: float = 0.0
var multi_hit: int = 1
var multi_cast: int = 1
var target_id: int = 0
var action: StringName = &""
var action_left: float = 0.0
var cooldown: float = 0.0
var pending_cooldown: float = 0.0
var passive_count: int = 0
var return_wait: float = 0.0
var returning: bool = false
var facing: Vector2 = Vector2.RIGHT
var kit_state: Dictionary = {}
var impact_left: float = 0.0
var impacted: bool = false
var unbuffed_attack: float = 0.0
var unbuffed_armor: float = 0.0
var ability_cooldowns: Dictionary = {}
var statuses: Array[Dictionary] = []
var status_base: Dictionary = {}
var summoner_id: String = ""
var summon_remaining: float = 0.0
var reward_multiplier: float = 1.0
var support: bool = false

# Derived from owned progress on creation/load/purchase; not snapshot state.
var basic_bonus: float = 0.0
var sweep_bonus: float = 0.0
var area_bonus: float = 0.0
var cooldown_reduction: float = 0.0
var haste: float = 0.0

func ability_cooldown(base: float) -> float:
	return maxf(0.1, base - cooldown_reduction) * 100.0 / (100.0 + haste)

const FIELDS: Array[StringName] = [
	&"id", &"copy_id", &"definition_id", &"allied", &"position", &"anchor",
	&"health", &"max_health", &"attack", &"armor", &"speed", &"attack_speed", &"attack_range", &"multi_hit", &"multi_cast",
	&"magic_attack", &"magic_resistance", &"ability_power", &"critical_chance", &"critical_multiplier",
	&"super_critical_chance", &"super_critical_multiplier", &"ultra_critical_chance", &"ultra_critical_multiplier",
	&"target_id", &"action", &"action_left", &"cooldown", &"pending_cooldown",
	&"passive_count", &"return_wait", &"returning", &"facing",
	&"kit_state", &"impact_left", &"impacted", &"ability_cooldowns", &"statuses", &"status_base",
	&"summoner_id", &"summon_remaining", &"reward_multiplier", &"support"]

static func create(definition: CombatantDefinition, entity_id: int, is_ally: bool,
		spawn: Vector2, health_scale: float = 1.0, attack_scale: float = 1.0) -> CombatantState:
	var actor: CombatantState = CombatantState.new()
	actor.id = entity_id
	actor.definition_id = definition.id
	actor.allied = is_ally
	actor.position = spawn
	actor.anchor = spawn
	actor.max_health = definition.max_health * health_scale
	actor.health = actor.max_health
	actor.attack = definition.physical_attack * attack_scale
	actor.magic_attack = definition.magic_attack * attack_scale
	for stat: StringName in [&"magic_resistance", &"ability_power", &"critical_chance", &"critical_multiplier",
			&"super_critical_chance", &"super_critical_multiplier", &"ultra_critical_chance", &"ultra_critical_multiplier"]:
		actor.set(stat, definition.get(stat))
	actor.armor = definition.armor
	actor.speed = definition.movement_speed
	actor.attack_speed = definition.attack_speed
	actor.attack_range = definition.attack_range
	actor.multi_hit = definition.multi_hit
	actor.multi_cast = definition.multi_cast
	return actor

func alive() -> bool:
	return health > 0.0

func clear_action() -> void:
	action = &""
	action_left = 0.0
	impact_left = 0.0
	impacted = false

func to_data() -> Dictionary:
	var data: Dictionary = {}
	for field: StringName in FIELDS:
		var value: Variant = get(field)
		data[field] = value.duplicate(true) if value is Dictionary or value is Array else value
	return data

static func from_data(data: Dictionary) -> CombatantState:
	var actor: CombatantState = CombatantState.new()
	for field: StringName in FIELDS:
		var value: Variant = data.get(field, actor.get(field))
		if field == &"statuses":
			actor.statuses.assign(value.duplicate(true))
		else:
			actor.set(field, value.duplicate(true) if value is Dictionary or value is Array else value)
	return actor
