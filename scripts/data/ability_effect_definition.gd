class_name AbilityEffectDefinition
extends Resource
## Shared, immutable effect template. No target, timer or stack lives here.

@export_enum("damage", "heal", "resurrect", "status", "summon") var kind: String = "damage"
@export var damage: DamageDefinition
@export var damage_delay: float = 0.0
@export var flat_healing: float = 0.0
@export var health_fraction: float = 0.0
@export var healing_ap: float = 0.0
@export var resurrection_fraction: float = 0.1
@export var status: StatusDefinition
@export var summon: CombatantDefinition
@export var summon_count: int = 1
@export var summon_limit: int = 3
@export var summon_duration: float = 30.0
@export var summon_reward_multiplier: float = 1.0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if kind not in ["damage", "heal", "resurrect", "status", "summon"]:
		errors.append("Unknown ability effect.")
	for value: float in [damage_delay, flat_healing, health_fraction, healing_ap, summon_duration, summon_reward_multiplier]:
		if not is_finite(value) or value < 0.0:
			errors.append("Invalid ability effect value.")
	if not is_finite(resurrection_fraction) or resurrection_fraction <= 0.0 or resurrection_fraction > 1.0:
		errors.append("Resurrection fraction must be in (0, 1].")
	if kind == "damage":
		if damage == null:
			errors.append("Damage effect requires a damage definition.")
		else:
			errors.append_array(damage.validation_errors())
	if kind == "status":
		if status == null:
			errors.append("Status effect requires a status definition.")
		else:
			errors.append_array(status.validation_errors())
	if kind == "summon" and (summon == null or summon_count < 1 or summon_limit < 1 or summon_duration <= 0.0):
		errors.append("Invalid summon definition or limits.")
	return errors
