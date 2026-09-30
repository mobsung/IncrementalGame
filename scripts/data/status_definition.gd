class_name StatusDefinition
extends Resource
## Each author chooses stacking and modifiers; no universal crowd-control rules added.

const STATS: Array[String] = ["attack", "magic_attack", "armor", "magic_resistance", "attack_speed", "speed", "ability_power"]
const REWARDS: Array[String] = ["gold", "experience", "souls"]
@export var id: StringName
@export var display_name: String
@export var duration: float = 5.0
@export var max_stacks: int = 1
@export var refresh_duration: bool = true
@export var ends_on_death: bool = false
@export var additive: Dictionary[String, float] = {}
@export var multiplier: Dictionary[String, float] = {}

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if id.is_empty() or display_name.is_empty() or not is_finite(duration) or duration <= 0.0 or max_stacks < 1:
		errors.append("Invalid status identity, duration or stack limit.")
	for pool: Dictionary in [additive, multiplier]:
		for stat: String in pool:
			if stat not in STATS and stat not in REWARDS or not is_finite(float(pool[stat])):
				errors.append("Invalid status modifier: %s" % stat)
	return errors
