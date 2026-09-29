extends Resource
## Species mechanics, independent from scene presentation and shared combat rules.

@export var guard: SelfBuffDefinition
@export var surge: SelfBuffDefinition
@export var simmer_interval: float = 4.0
@export var simmer_fraction: float = 0.015
@export var final_simmer_fraction: float = 0.02
@export var simmer_ap: float = 0.1
@export var stack_healing: float = 0.0025
@export var stack_bonus: float = 0.01
@export var maximum_stacks: int = 5
@export var attack_cap: float = 0.35
@export var armor_cap: float = 0.40
@export var jab_impact_fraction: float = 0.25
@export var sweep_impact_time: float = 0.4
@export var sweep_minimum_cooldown: float = 4.0
@export var sweep_max_targets: int = 3

func initial_state() -> Dictionary:
	return {"sauce": 0, "simmer_elapsed": 0.0, "guard_cooldown": 0.0,
		"surge_cooldown": 0.0, "guard_duration": 0.0, "surge_duration": 0.0}

func ensure_state(actor: CombatantState) -> void:
	if actor.kit_state.is_empty():
		actor.kit_state = initial_state()

func valid_state(state: Dictionary, evolution: int) -> bool:
	var expected: Dictionary = initial_state()
	if state.size() != expected.size():
		return false
	for key: String in expected:
		if not state.has(key) or typeof(state[key]) != typeof(expected[key]):
			return false
		if not is_finite(float(state[key])) or state[key] < 0:
			return false
	return state.sauce <= maximum_stacks and state.simmer_elapsed <= simmer_interval and (
		evolution > 0 or (state.sauce == 0 and state.guard_duration == 0.0 and state.guard_cooldown == 0.0)) and (
		evolution > 1 or (state.surge_duration == 0.0 and state.surge_cooldown == 0.0)) and (
		state.guard_duration <= guard.duration and state.surge_duration <= surge.duration and
		state.guard_cooldown <= guard.cooldown and state.surge_cooldown <= surge.cooldown)

func apply_stats(actor: CombatantState, copy: UnitProgress) -> void:
	ensure_state(actor)
	var bonus: float = int(actor.kit_state.sauce) * stack_bonus if copy.evolution > 0 else 0.0
	var attack: float = bonus
	var armor: float = bonus
	if actor.kit_state.guard_duration > 0.0:
		attack += guard.attack_bonus
		armor += guard.armor_bonus + 0.02 * copy.purchased_rank(&"thickened_glaze")
	if actor.kit_state.surge_duration > 0.0:
		attack += surge.attack_bonus
		armor += surge.armor_bonus
	actor.attack = actor.unbuffed_attack * (1.0 + minf(attack, attack_cap))
	actor.armor = actor.unbuffed_armor * (1.0 + minf(armor, armor_cap))

func advance_timers(actor: CombatantState, copy: UnitProgress, delta: float) -> void:
	ensure_state(actor)
	for key: String in ["guard_cooldown", "surge_cooldown", "guard_duration", "surge_duration"]:
		actor.kit_state[key] = maxf(0.0, float(actor.kit_state[key]) - delta)
	actor.kit_state.simmer_elapsed += delta
	apply_stats(actor, copy)

func periodic_healing(actor: CombatantState, copy: UnitProgress, healing: Dictionary, events: Array[Dictionary]) -> void:
	if actor.kit_state.simmer_elapsed + 0.000001 < simmer_interval:
		return
	actor.kit_state.simmer_elapsed = maxf(0.0, actor.kit_state.simmer_elapsed - simmer_interval)
	var fraction: float = final_simmer_fraction if copy.evolution == 2 else simmer_fraction
	fraction += 0.0025 * copy.purchased_rank(&"sauce_infusion")
	if copy.evolution > 0:
		fraction += stack_healing * int(actor.kit_state.sauce)
	var amount: float = actor.max_health * fraction + actor.ability_power * simmer_ap
	if actor.kit_state.guard_duration > 0.0:
		amount *= 2.0
	_add_heal(actor, amount, healing, events, &"simmer")

func select_action(actor: CombatantState, copy: UnitProgress) -> StringName:
	if surge.available(actor, copy):
		return &"surge"
	if guard.available(actor, copy):
		return &"guard"
	return &""

func self_ability(action: StringName) -> SelfBuffDefinition:
	return surge if action == &"surge" else guard

func complete_self(actor: CombatantState, copy: UnitProgress, healing: Dictionary, events: Array[Dictionary]) -> void:
	var ability: SelfBuffDefinition = self_ability(actor.action)
	if not ability.available(actor, copy):
		return
	actor.kit_state.sauce -= ability.consumed_stacks
	var fraction: float = ability.heal_fraction
	if actor.action == &"surge":
		fraction += 0.01 * copy.purchased_rank(&"core_tempering")
	_add_heal(actor, actor.max_health * fraction + actor.ability_power * ability.heal_ap, healing, events, actor.action)
	actor.kit_state[String(ability.id) + "_duration"] = ability.duration
	actor.kit_state[String(ability.id) + "_cooldown"] = actor.pending_cooldown

func successful_action(actor: CombatantState, copy: UnitProgress) -> void:
	if copy.evolution > 0:
		actor.kit_state.sauce = mini(maximum_stacks, int(actor.kit_state.sauce) + 1)

func reset_wave(actor: CombatantState, copy: UnitProgress) -> void:
	ensure_state(actor)
	actor.kit_state.sauce = 0
	actor.kit_state.simmer_elapsed = 0.0
	apply_stats(actor, copy)

func on_death(actor: CombatantState, copy: UnitProgress) -> void:
	actor.kit_state.sauce = 0
	actor.kit_state.simmer_elapsed = 0.0
	actor.kit_state.guard_duration = 0.0
	actor.kit_state.surge_duration = 0.0
	apply_stats(actor, copy)

func _add_heal(actor: CombatantState, amount: float, healing: Dictionary, events: Array[Dictionary], ability: StringName) -> void:
	healing[actor.id] = float(healing.get(actor.id, 0.0)) + amount
	events.append({"kind": "heal", "position": actor.position, "amount": amount, "target_id": actor.id, "ability": ability})
