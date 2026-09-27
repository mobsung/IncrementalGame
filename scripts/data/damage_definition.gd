class_name DamageDefinition
extends Resource
## Shared action data. Each component declares its scaling and critical eligibility.

@export var damage_coefficient: float = 1.0
@export var magic_coefficient: float = 0.0
@export var ability_power_ratio: float = 0.0
@export var can_crit: bool = false
@export var physical_can_crit: bool = true
@export var magic_can_crit: bool = true
@export var supports_multi_hit: bool = false

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	for value: float in [damage_coefficient, magic_coefficient, ability_power_ratio]:
		if not is_finite(value) or value < 0.0:
			errors.append("Damage coefficients must be finite and nonnegative.")
	return errors
