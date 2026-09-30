class_name AbilitySystem
extends RefCounted
## Automatic actions on pure model state; cooldowns, targets and effects are per actor.

static func definition_for(definition: CombatantDefinition, id: StringName) -> AbilityDefinition:
	for ability: AbilityDefinition in definition.active_abilities:
		if ability.id == id:
			return ability
	return null

static func candidates(actor: CombatantState, actors: Array[CombatantState], ability: AbilityDefinition) -> Array[CombatantState]:
	var result: Array[CombatantState] = []
	for target: CombatantState in actors:
		if (target.support and not (target == actor and ability.target_kind == "self")) or (not ability.include_summons and not target.summoner_id.is_empty()):
			continue
		if actor.position.distance_to(target.position) > ability.range_radius + 0.0001:
			continue
		var valid: bool = false
		match ability.target_kind:
			"opponent": valid = target.alive() and target.allied != actor.allied
			"injured_ally": valid = target.alive() and target.allied == actor.allied and target.health < target.max_health
			"dead_ally": valid = not target.alive() and target.allied == actor.allied
			"ally": valid = target.alive() and target.allied == actor.allied
			"self": valid = target == actor and target.alive()
		if valid:
			result.append(target)
	return result

static func target_for(actor: CombatantState, actors: Array[CombatantState], ability: AbilityDefinition,
		copy: UnitProgress, rng: RandomNumberGenerator) -> CombatantState:
	var available: Array[CombatantState] = candidates(actor, actors, ability)
	if ability.target_kind == "injured_ally":
		var lowest: float = INF
		var ties: Array[CombatantState] = []
		for target: CombatantState in available:
			var ratio: float = target.health / target.max_health
			if ratio < lowest and not is_equal_approx(ratio, lowest):
				lowest = ratio
				ties.assign([target])
			elif is_equal_approx(ratio, lowest):
				ties.append(target)
		return null if ties.is_empty() else ties[rng.randi_range(0, ties.size() - 1)]
	return Targeting.choose(actor, available, copy.priority if copy != null else 0, rng)

static func select(actor: CombatantState, actors: Array[CombatantState], definition: CombatantDefinition,
		copy: UnitProgress, rng: RandomNumberGenerator) -> AbilityDefinition:
	var best: AbilityDefinition = null
	var best_priority: int = -2147483648
	for index: int in range(definition.active_abilities.size()):
		var ability: AbilityDefinition = definition.active_abilities[index]
		if copy != null and copy.evolution < ability.minimum_evolution:
			continue
		if float(actor.ability_cooldowns.get(ability.id, 0.0)) > 0.0:
			continue
		if candidates(actor, actors, ability).is_empty() or not can_summon(actor, actors, ability):
			continue
		var priority: int = int(copy.ability_priorities.get(ability.id, 0)) if copy != null else 0
		if best == null or priority > best_priority:
			best = ability
			best_priority = priority
	if best != null:
		var target: CombatantState = target_for(actor, actors, best, copy, rng)
		actor.target_id = target.id
	return best

static func can_summon(actor: CombatantState, actors: Array[CombatantState], ability: AbilityDefinition) -> bool:
	for effect: AbilityEffectDefinition in ability.effects:
		if effect.kind != "summon":
			continue
		var count: int = 0
		for target: CombatantState in actors:
			if target.summoner_id == owner_id(actor) and target.alive() and target.definition_id == effect.summon.id:
				count += 1
		if count >= effect.summon_limit:
			return false
	return true

static func owner_id(actor: CombatantState) -> String:
	return actor.copy_id if not actor.copy_id.is_empty() else "entity_%d" % actor.id

static func begin(actor: CombatantState, ability: AbilityDefinition) -> void:
	actor.action = ability.id
	actor.action_left = ability.cast_time
	actor.pending_cooldown = maxf(ability.minimum_cooldown, ability.cooldown * 100.0 / (100.0 + actor.haste))

static func interrupt(actor: CombatantState) -> void:
	actor.ability_cooldowns[actor.action] = actor.pending_cooldown
	actor.clear_action()

static func complete(actor: CombatantState, actors: Array[CombatantState], ability: AbilityDefinition,
		copy: UnitProgress, rng: RandomNumberGenerator, damage: Dictionary, healing: Dictionary,
		requests: Array[Dictionary], events: Array[Dictionary]) -> void:
	actor.ability_cooldowns[ability.id] = actor.pending_cooldown
	var target: CombatantState = Targeting.by_id(actors, actor.target_id)
	# Range is checked at acquisition; a surviving locked target can move away.
	if not valid_locked_target(actor, target, ability):
		target = target_for(actor, actors, ability, copy, rng)
	if target == null:
		return
	var applications: int = actor.multi_cast if ability.supports_multi_cast else 1
	var radius: float = ability.area_radius * sqrt(1.0 + actor.area_bonus) if ability.supports_area else 0.0
	var affected: Array[CombatantState] = [target]
	if radius > 0.0:
		for other: CombatantState in actors:
			if other != target and valid_locked_target(actor, other, ability) and other.position.distance_to(target.position) <= radius:
				affected.append(other)
	# A local shadow makes ordered mark-then-hit possible without affecting other same-tick actions.
	var shadows: Dictionary = {}
	for application: int in range(applications):
		for effect: AbilityEffectDefinition in ability.effects:
			if effect.kind == "summon":
				requests.append({"kind": "summon", "actor": actor, "effect": effect})
				continue
			for recipient: CombatantState in affected:
				match effect.kind:
					"damage":
						var packet: Dictionary = CombatMath.create_damage(actor, effect.damage, 0.0, rng)
						if effect.damage_delay > 0.0:
							requests.append({"kind": "projectile", "data": {"target_id": recipient.id,
								"source_id": actor.id, "remaining": effect.damage_delay, "packet": packet,
								"from": actor.position, "allied": actor.allied}})
							continue
						var defense: CombatantState = shadows.get(recipient.id, recipient)
						var amount: float = CombatMath.damage_amount(packet, defense)
						damage[recipient.id] = float(damage.get(recipient.id, 0.0)) + amount
						events.append({"kind": "hit", "position": recipient.position, "from": actor.position,
							"source_id": actor.id, "target_id": recipient.id, "amount": amount,
							"allied": actor.allied, "critical_stage": packet.critical_stage})
					"heal":
						if recipient.alive():
							var amount: float = effect.flat_healing + recipient.max_health * effect.health_fraction + actor.ability_power * effect.healing_ap
							healing[recipient.id] = float(healing.get(recipient.id, 0.0)) + amount
							events.append({"kind": "heal", "position": recipient.position, "target_id": recipient.id, "amount": amount, "ability": ability.id})
					"resurrect":
						if not recipient.alive():
							requests.append({"kind": "resurrect", "target": recipient, "fraction": effect.resurrection_fraction})
					"status":
						requests.append({"kind": "status", "target": recipient, "definition": effect.status, "source_id": actor.id})
						if not shadows.has(recipient.id):
							shadows[recipient.id] = CombatantState.from_data(recipient.to_data())
						var shadow: CombatantState = shadows[recipient.id]
						StatusSystem.add(shadow, effect.status, actor.id)
						StatusSystem.apply_stats(shadow)
	events.append({"kind": "ability", "ability": ability.id, "position": target.position, "radius": radius, "source_id": actor.id})

static func valid_locked_target(actor: CombatantState, target: CombatantState, ability: AbilityDefinition) -> bool:
	if target == null or (target.support and not (target == actor and ability.target_kind == "self")) or (not ability.include_summons and not target.summoner_id.is_empty()):
		return false
	match ability.target_kind:
		"opponent": return target.alive() and target.allied != actor.allied
		"injured_ally": return target.alive() and target.allied == actor.allied and target.health < target.max_health
		"dead_ally": return not target.alive() and target.allied == actor.allied
		"ally": return target.alive() and target.allied == actor.allied
		"self": return target == actor and target.alive()
	return false
