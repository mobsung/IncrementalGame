class_name AbilityDefinition
extends Resource
## A reusable active action; ordered effects allow explicit mark-then-damage abilities.

@export var id: StringName
@export var display_name: String
@export var minimum_evolution: int = 0
@export var cast_time: float = 0.0
@export var cooldown: float = 5.0
@export var minimum_cooldown: float = 0.1
@export var range_radius: float = 100.0
@export var area_radius: float = 0.0
@export var supports_area: bool = false
@export var supports_multi_cast: bool = false
@export var include_summons: bool = false
@export_enum("opponent", "injured_ally", "dead_ally", "ally", "self") var target_kind: String = "opponent"
@export var effects: Array[AbilityEffectDefinition] = []

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if id.is_empty() or display_name.is_empty() or id in [&"basic", &"sweep", &"guard", &"surge"]:
		errors.append("Missing or reserved ability ID/name.")
	if minimum_evolution < 0 or effects.is_empty():
		errors.append("Ability needs effects and a valid evolution gate.")
	for value: float in [cast_time, cooldown, minimum_cooldown, range_radius, area_radius]:
		if not is_finite(value) or value < 0.0:
			errors.append("Invalid ability timing or geometry: %s" % id)
	if cooldown <= 0.0 or minimum_cooldown <= 0.0:
		errors.append("Ability cooldown must be positive.")
	if target_kind not in ["opponent", "injured_ally", "dead_ally", "ally", "self"]:
		errors.append("Invalid ability target kind.")
	for effect: AbilityEffectDefinition in effects:
		if effect == null:
			errors.append("Missing ability effect.")
		else:
			errors.append_array(effect.validation_errors())
	return errors
