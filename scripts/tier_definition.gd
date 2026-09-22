class_name TierDefinition
extends Resource


@export var tier_name: String = "Bronze"
@export var conversion: float = 100.0
@export var increment_value: float = 5.0
@export var base_timer_wait_time: float = 1.0
@export var max_conversion: float = 1.0
@export var available_upgrades: Array[UpgradeDefinition] = []
