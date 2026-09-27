class_name SweepDefinition
extends DamageDefinition

@export var id: StringName = &"spaghetti_sweep"
@export var display_name: String = "Spaghetti Sweep"
@export var radius: float = 180.0
@export var angle_degrees: float = 120.0
@export var cast_time: float = 0.6
@export var cooldown: float = 8.0
@export var supports_multi_cast: bool = false

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	for value: float in [radius, angle_degrees, cast_time, cooldown]:
		if not is_finite(value) or value < 0.0:
			errors.append("Invalid Sweep geometry or timing.")
	if angle_degrees > 360.0 or cooldown <= 0.0:
		errors.append("Sweep needs a positive cooldown and an angle at most 360 degrees.")
	return errors
