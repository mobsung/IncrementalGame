class_name SelfBuffDefinition
extends Resource
## Immutable authoring data; per-copy timers live in CombatantState.kit_state.

@export var id: StringName
@export var display_name: String
@export var minimum_evolution: int = 1
@export var health_threshold: float = 0.7
@export var required_stacks: int = 2
@export var consumed_stacks: int = 0
@export var cast_time: float = 0.35
@export var cooldown: float = 12.0
@export var minimum_cooldown: float = 8.0
@export var duration: float = 6.0
@export var heal_fraction: float = 0.03
@export var heal_ap: float = 0.25
@export var attack_bonus: float = 0.1
@export var armor_bonus: float = 0.12

func available(actor: CombatantState, copy: UnitProgress) -> bool:
	return actor.alive() and copy.evolution >= minimum_evolution and (
		actor.health <= actor.max_health * health_threshold and
		int(actor.kit_state.get("sauce", 0)) >= required_stacks and
		float(actor.kit_state.get(String(id) + "_cooldown", 0.0)) <= 0.0 and
		float(actor.kit_state.get(String(id) + "_duration", 0.0)) <= 0.0)
