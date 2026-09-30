class_name StatusSystem
extends RefCounted
## Rebuild modifiers from a clean baseline. New statuses commit after simultaneous hits.

static func remove_stats(actor: CombatantState) -> void:
	for stat: String in actor.status_base:
		actor.set(stat, actor.status_base[stat])
	actor.status_base.clear()

static func advance(actor: CombatantState, delta: float) -> void:
	remove_stats(actor)
	for index: int in range(actor.statuses.size() - 1, -1, -1):
		actor.statuses[index].remaining = maxf(0.0, actor.statuses[index].remaining - delta)
		if actor.statuses[index].remaining <= 0.0:
			actor.statuses.remove_at(index)

static func apply_stats(actor: CombatantState) -> void:
	remove_stats(actor)
	var additions: Dictionary = {}
	var percentages: Dictionary = {}
	for effect: Dictionary in actor.statuses:
		for key: String in ["additive", "multiplier"]:
			var pool: Dictionary = effect[key]
			var totals: Dictionary = additions if key == "additive" else percentages
			for stat: String in pool:
				totals[stat] = float(totals.get(stat, 0.0)) + float(pool[stat]) * effect.stacks
	for stat: String in StatusDefinition.STATS:
		if not additions.has(stat) and not percentages.has(stat):
			continue
		var base: float = actor.get(stat)
		actor.status_base[stat] = base
		var value: float = (base + float(additions.get(stat, 0.0))) * maxf(0.0, 1.0 + float(percentages.get(stat, 0.0)))
		if stat in ["speed", "attack_speed"]:
			value = maxf(0.001, value)
		elif stat not in ["armor", "magic_resistance"]:
			value = maxf(0.0, value)
		actor.set(stat, value)

static func add(actor: CombatantState, definition: StatusDefinition, source_id: int) -> void:
	if not actor.alive():
		return
	for state: Dictionary in actor.statuses:
		if state.id == definition.id and state.source_id == source_id:
			state.stacks = mini(definition.max_stacks, state.stacks + 1)
			if definition.refresh_duration:
				state.remaining = definition.duration
			return
	actor.statuses.append({"id": definition.id, "source_id": source_id, "stacks": 1,
		"remaining": definition.duration, "additive": definition.additive.duplicate(true),
		"multiplier": definition.multiplier.duplicate(true), "ends_on_death": definition.ends_on_death})

static func on_death(actor: CombatantState) -> void:
	remove_stats(actor)
	for index: int in range(actor.statuses.size() - 1, -1, -1):
		if actor.statuses[index].ends_on_death:
			actor.statuses.remove_at(index)
