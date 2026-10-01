class_name WizardSystem
extends RefCounted
## Content strategy operating only on serializable model state. Derived heals never recurse.
const TUNE = preload("res://content/units/supports/would_be_wizard/abilities/tuning.tres")

static func priority(id: StringName) -> int:
	if id in [&"final_revision", &"grand_illusion"]: return 30
	if id in [&"rewrite_wounds", &"clockwork_familiar"]: return 20
	return 10

static func valid_state(state: Dictionary, role: String) -> bool:
	var actor: CombatantState = CombatantState.new()
	ensure_state(actor, role)
	for key: String in actor.kit_state:
		if not state.has(key) or typeof(state[key]) != typeof(actor.kit_state[key]): return false
	if state.wizard_role != role or state.resource < 0 or state.resource > TUNE.notes_cap or state.basic_count < 0: return false
	for key: String in ["clock", "rescue_left", "encore_left", "link_left"]:
		if not is_finite(state[key]) or state[key] < 0.0: return false
	if state.has("cast_duration") and (not state.cast_duration is float or not is_finite(state.cast_duration) or state.cast_duration < 0.0): return false
	for key: String in ["sequence", "recoveries", "history", "traps", "charges", "links"]:
		if state[key].size() > 1000: return false
	for id: Variant in state.links:
		if not id is int or id <= 0: return false
	for key: String in ["recoveries", "history", "sequence", "traps", "charges"]:
		for item: Variant in state[key]:
			if not item is Dictionary: return false
			var fields: Array = ["target_id", "budget", "remaining"] if key == "recoveries" else (["target_id", "amount", "time"] if key == "history" else (["id", "time"] if key == "sequence" else ["position", "remaining", "power", "radius"]))
			if not item.has_all(fields): return false
			for field: String in fields:
				if field == "position":
					if not item[field] is Vector2 or not item[field].is_finite(): return false
				elif field == "target_id":
					if not item[field] is int or item[field] <= 0: return false
				elif field == "id":
					if not item[field] is String: return false
				elif not item[field] is float or not is_finite(item[field]) or item[field] < 0.0: return false
			if key == "traps" and (not item.has("armed") or not item.armed is bool): return false
	return true

static func ensure_state(actor: CombatantState, role: String) -> void:
	if actor.kit_state.get("wizard_role", "") == role:
		return
	actor.kit_state = {"wizard_role": role, "resource": 0, "basic_count": 0, "clock": 0.0,
		"rescue_left": 0.0, "encore_left": 0.0, "sequence": [], "recoveries": [],
		"links": [], "link_left": 0.0, "history": [], "traps": [], "charges": [], "retreat": false}

static func allies(source: CombatantState, actors: Array[CombatantState]) -> Array[CombatantState]:
	var result: Array[CombatantState] = []
	for actor: CombatantState in actors:
		if actor.alive() and actor.allied == source.allied and not actor.copy_id.is_empty() and not actor.support and source.position.distance_to(actor.position) <= 700.0:
			result.append(actor)
	result.sort_custom(func(a: CombatantState, b: CombatantState) -> bool: return a.id < b.id)
	return result

static func gain(actor: CombatantState, amount: int) -> void:
	actor.kit_state.resource = mini(TUNE.notes_cap, int(actor.kit_state.resource) + amount)

static func mark(target: CombatantState, source_id: int) -> void:
	var status: StatusDefinition = StatusDefinition.new()
	status.id = &"misdirected"
	status.display_name = "Misdirected"
	status.ends_on_death = true
	status.duration = 4.0
	StatusSystem.add(target, status, source_id)

static func basic(actor: CombatantState, target: CombatantState) -> void:
	var state: Dictionary = actor.kit_state
	state.basic_count += 1
	match state.wizard_role:
		"apprentice":
			if state.basic_count % TUNE.lesson_attacks == 0: gain(actor, 1)
		"acolyte": gain(actor, 1)
		"archsage": gain(actor, 2 if state.basic_count % 3 == 0 else 1)
		"makeshift":
			if state.basic_count % 3 == 0: gain(actor, 1)
		"archmage":
			var tricked: bool = false
			if target != null:
				for status: Dictionary in target.statuses:
					if status.id == &"misdirected": tricked = true
			gain(actor, 2 if tricked else 1)

static func eligible(actor: CombatantState, actors: Array[CombatantState], ability: AbilityDefinition) -> bool:
	var party: Array[CombatantState] = allies(actor, actors)
	match ability.wizard_action:
		"revision":
			var injured: int = 0
			for member: CombatantState in party:
				if member.health / member.max_health < 0.15: return true
				if member.health / member.max_health < 0.4: injured += 1
			return injured >= 2
		"margins": return party.size() >= 2 and actor.kit_state.link_left <= 0.0
		"sigil": return actor.kit_state.traps.size() < 2
		"familiar":
			for member: CombatantState in actors:
				if member.summoner_id == actor.copy_id and member.definition_id == &"clockwork_familiar" and member.alive(): return false
		"illusion":
			var count: int = 0
			for opponent: CombatantState in Targeting.opponents(actor, actors):
				if actor.position.distance_to(opponent.position) <= ability.range_radius: count += 1
			return count >= 3
	return true

static func begin(actor: CombatantState, _ability: AbilityDefinition) -> void:
	var state: Dictionary = actor.kit_state
	var quick: bool = state.wizard_role == "makeshift" and state.resource >= TUNE.setup_threshold
	if quick: state.resource = 0
	actor.action_left *= 0.4 if quick else 1.0
	state["cast_duration"] = actor.action_left

static func upgrade_power(copy: UnitProgress) -> float:
	return 1.0 + 0.12 * copy.purchased_rank(&"wizard_mastery")

static func heal(source: CombatantState, target: CombatantState, amount: float, healing: Dictionary, events: Array[Dictionary], name: String) -> float:
	var useful: float = minf(maxf(0.0, target.max_health - target.health - float(healing.get(target.id, 0.0))), maxf(0.0, amount))
	if useful > 0.0:
		healing[target.id] = float(healing.get(target.id, 0.0)) + useful
		events.append({"kind": "heal", "source_id": source.id, "target_id": target.id, "position": target.position, "amount": useful, "ability": name})
	return useful

static func hit(source: CombatantState, target: CombatantState, coefficient: float, rng: RandomNumberGenerator, damage: Dictionary, events: Array[Dictionary], name: String) -> void:
	var attack: DamageDefinition = DamageDefinition.new()
	attack.damage_coefficient = coefficient
	attack.ability_power_ratio = 0.005
	var packet: Dictionary = CombatMath.create_damage(source, attack, 0.0, rng)
	var amount: float = CombatMath.damage_amount(packet, target)
	damage[target.id] = float(damage.get(target.id, 0.0)) + amount
	events.append({"kind": "hit", "source_id": source.id, "target_id": target.id, "position": target.position, "from": source.position, "amount": amount, "allied": source.allied, "critical_stage": packet.critical_stage, "ability": name})

static func recovery(source: CombatantState, target: CombatantState, budget: float, duration: float) -> void:
	var entries: Array = source.kit_state.recoveries
	for entry: Dictionary in entries:
		if entry.target_id == target.id:
			entry.budget = maxf(entry.budget, budget)
			entry.remaining = duration
			return
	entries.append({"target_id": target.id, "budget": budget, "remaining": duration})

static func summon(source: CombatantState, requests: Array[Dictionary], id: String, duration: float, position: Vector2, multiplier: float = 1.0, split: bool = false) -> void:
	requests.append({"kind": "wizard_summon", "source": source, "definition_id": id, "duration": duration, "position": position, "multiplier": multiplier, "split": split})

static func complete(actor: CombatantState, actors: Array[CombatantState], ability: AbilityDefinition, copy: UnitProgress, rng: RandomNumberGenerator, damage: Dictionary, healing: Dictionary, requests: Array[Dictionary], events: Array[Dictionary]) -> void:
	actor.ability_cooldowns[ability.id] = actor.pending_cooldown
	var target: CombatantState = Targeting.by_id(actors, actor.target_id)
	if not AbilitySystem.valid_locked_target(actor, target, ability): target = AbilitySystem.target_for(actor, actors, ability, copy, rng)
	if target == null: return
	var state: Dictionary = actor.kit_state
	var empowered: bool = state.resource >= TUNE.notes_cap and state.wizard_role in ["archsage", "archmage"]
	var encore: bool = state.encore_left > 0.0 and state.wizard_role == "archmage"
	if empowered: state.resource = 0
	if encore: state.encore_left = 0.0
	var power: float = upgrade_power(copy) * (1.5 if empowered else 1.0)
	var party: Array[CombatantState] = allies(actor, actors)
	var times: int = actor.multi_cast if ability.supports_multi_cast else 1
	var useful_heal: bool = false
	for application: int in range(times):
		match ability.wizard_action:
			"swing":
				var learned: bool = state.resource > 0
				if learned and application == 0: state.resource -= 1
				# Hold slot never performs the short physical step.
				if copy.mobile: actor.position = actor.position.move_toward(target.position, minf(30.0, maxf(0.0, actor.position.distance_to(target.position) - 80.0)))
				for opponent: CombatantState in Targeting.opponents(actor, actors):
					if CombatMath.in_sector(actor.position, (target.position - actor.position).normalized(), opponent.position, ability.area_radius * sqrt(1.0 + actor.area_bonus), 120.0): hit(actor, opponent, 1.3 * power * (1.5 if learned else 1.0), rng, damage, events, "headlong_swing")
			"remedy", "rewrite":
				var notes: int = mini(3, int(state.resource)) if ability.wizard_action == "remedy" else 0
				if application == 0: state.resource -= notes
				var amount: float = (TUNE.heal_flat + actor.ability_power * TUNE.heal_ap) * power * (1.0 + notes * 0.15)
				useful_heal = heal(actor, target, amount, healing, events, String(ability.id)) > 0.0 or useful_heal
				if notes > 0 or ability.wizard_action == "rewrite": recovery(actor, target, amount * (0.8 if empowered else 0.5), TUNE.recovery_duration)
			"margins":
				state.links.clear()
				for member: CombatantState in party: state.links.append(member.id)
				state.link_left = TUNE.link_duration * (1.5 if empowered else 1.0)
			"revision":
				for member: CombatantState in party:
					var lost: float = 0.0
					var window: float = TUNE.revision_window + (2.0 if empowered else 0.0)
					for item: Dictionary in state.history:
						if item.target_id == member.id and state.clock - item.time <= window: lost += item.amount
					useful_heal = heal(actor, member, lost * TUNE.revision_fraction * upgrade_power(copy), healing, events, "final_revision") > 0.0 or useful_heal
				# A wound cannot be revised twice; prior ordinary healing consumes oldest wounds.
				state.history.clear()
			"prototype":
				for opponent: CombatantState in Targeting.opponents(actor, actors):
					if opponent.position.distance_to(target.position) <= ability.area_radius * sqrt(1.0 + actor.area_bonus): hit(actor, opponent, 1.6 * power, rng, damage, events, "prototype_trick")
				if application == 0: gain(actor, 1)
			"sigil":
				for index: int in range(2 if encore else 1):
					if state.traps.size() >= 2: state.traps.pop_front()
					state.traps.append({"position": target.position + Vector2(40 + index * 100, 0), "remaining": TUNE.trap_duration, "power": power, "radius": TUNE.trap_radius * sqrt(1.0 + actor.area_bonus), "armed": false})
			"familiar": summon(actor, requests, "clockwork_familiar", TUNE.familiar_duration, actor.position + Vector2(100, 0), power, encore)
			"illusion":
				for opponent: CombatantState in Targeting.opponents(actor, actors):
					if opponent.position.distance_to(target.position) <= ability.area_radius * sqrt(1.0 + actor.area_bonus):
						opponent.target_id = 0
						mark(opponent, actor.id)
						gain(actor, 1)
				for index: int in range(2): summon(actor, requests, "mirror_decoy", 5.0 if encore else 3.0, target.position + Vector2(-60, -45 + index * 90), power)
				state.charges.append({"remaining": 1.0, "position": target.position, "power": power, "radius": ability.area_radius * sqrt(1.0 + actor.area_bonus)})
				if encore: state.charges.append({"remaining": 2.0, "position": target.position, "power": power, "radius": ability.area_radius * sqrt(1.0 + actor.area_bonus)})
				state.retreat = copy.mobile
	if useful_heal and state.wizard_role == "archsage": gain(actor, 1)
	if state.wizard_role == "archmage":
		var retained: Array = []
		for item: Dictionary in state.sequence:
			if state.clock - item.time <= TUNE.encore_window and item.id != String(ability.id): retained.append(item)
		retained.append({"id": String(ability.id), "time": state.clock})
		if retained.size() >= 3:
			state.encore_left = TUNE.encore_duration
			retained.clear()
		state.sequence = retained
	events.append({"kind": "wizard_vfx", "ability": String(ability.id), "position": target.position, "source_id": actor.id, "radius": ability.area_radius, "empowered": empowered, "encore": encore})

static func advance(actors: Array[CombatantState], delta: float, rng: RandomNumberGenerator, damage: Dictionary, events: Array[Dictionary], definitions: Dictionary = {}) -> void:
	for actor: CombatantState in actors:
		if not actor.kit_state.has("wizard_role") or not actor.alive(): continue
		var state: Dictionary = actor.kit_state
		state.clock += delta
		for key: String in ["rescue_left", "encore_left", "link_left"]: state[key] = maxf(0.0, float(state[key]) - delta)
		for index: int in range(state.recoveries.size() - 1, -1, -1):
			state.recoveries[index].remaining -= delta
			if state.recoveries[index].remaining <= 0.0: state.recoveries.remove_at(index)
		for index: int in range(state.history.size() - 1, -1, -1):
			if state.clock - state.history[index].time > 6.0: state.history.remove_at(index)
		for index: int in range(state.traps.size() - 1, -1, -1):
			var trap: Dictionary = state.traps[index]
			trap.remaining -= delta
			var trigger: bool = false
			for opponent: CombatantState in Targeting.opponents(actor, actors):
				if opponent.position.distance_to(trap.position) <= trap.radius: trigger = true
			if trap.armed and trigger:
				for opponent: CombatantState in Targeting.opponents(actor, actors):
					if opponent.position.distance_to(trap.position) <= trap.radius:
						hit(actor, opponent, 2.0 * trap.power, rng, damage, events, "rigged_sigil")
						var definition: CombatantDefinition = definitions.get(opponent.definition_id)
						if definition == null or not definition.knockback_immune: opponent.position += Vector2(TUNE.knockback, 0)
						mark(opponent, actor.id)
						gain(actor, 1)
					events.append({"kind": "wizard_vfx", "ability": "explosion", "position": trap.position, "source_id": actor.id, "radius": trap.radius})
				state.traps.remove_at(index)
			elif trap.remaining <= 0.0: state.traps.remove_at(index)
			else: trap.armed = true
		for index: int in range(state.charges.size() - 1, -1, -1):
			var charge: Dictionary = state.charges[index]
			charge.remaining -= delta
			if charge.remaining <= 0.0:
				# Acquire the most populated local group at detonation, stable ID tie-break.
				var center: Vector2 = charge.position
				var best: int = 0
				for candidate: CombatantState in Targeting.opponents(actor, actors):
					var count: int = 0
					for opponent: CombatantState in Targeting.opponents(actor, actors):
						if opponent.position.distance_to(candidate.position) <= charge.radius: count += 1
					if count > best:
						best = count
						center = candidate.position
				for opponent: CombatantState in Targeting.opponents(actor, actors):
					if opponent.position.distance_to(center) <= charge.radius: hit(actor, opponent, 2.5 * charge.power, rng, damage, events, "hidden_charges")
				events.append({"kind": "wizard_vfx", "ability": "explosion", "position": center, "source_id": actor.id, "radius": charge.radius})
				state.charges.remove_at(index)

static func before_resolve(actors: Array[CombatantState], damage: Dictionary, healing: Dictionary, events: Array[Dictionary]) -> void:
	for source: CombatantState in actors:
		if not source.alive() or source.kit_state.get("wizard_role", "") not in ["acolyte", "archsage"]: continue
		var state: Dictionary = source.kit_state
		var party: Array[CombatantState] = allies(source, actors)
		# Share already-mitigated primary damage once. Transfers receive no second mitigation.
		if state.link_left > 0.0:
			var transfers: Dictionary = {}
			for member: CombatantState in party:
				if member.id not in state.links: continue
				var others: Array[CombatantState] = []
				for other: CombatantState in party:
					if other.id in state.links and other != member: others.append(other)
				if others.is_empty(): continue
				var share: float = float(damage.get(member.id, 0.0)) * TUNE.share_fraction
				damage[member.id] = float(damage.get(member.id, 0.0)) - share
				for other: CombatantState in others: transfers[other.id] = float(transfers.get(other.id, 0.0)) + share / others.size()
			for id: int in transfers: damage[id] = float(damage.get(id, 0.0)) + transfers[id]
			var echoes: Dictionary = {}
			for member: CombatantState in party:
				if member.id not in state.links: continue
				var amount: float = minf(member.max_health - member.health, float(healing.get(member.id, 0.0))) * TUNE.echo_fraction
				for other: CombatantState in party:
					if other.id in state.links and other != member: echoes[other.id] = float(echoes.get(other.id, 0.0)) + amount
			for member: CombatantState in party: heal(source, member, float(echoes.get(member.id, 0.0)), healing, events, "shared_echo")
		for member: CombatantState in party:
			var incoming: float = float(damage.get(member.id, 0.0))
			var rescued: bool = false
			if state.wizard_role == "archsage" and incoming >= member.health and incoming > 0.0 and state.resource >= TUNE.rescue_threshold and state.rescue_left <= 0.0:
				state.resource = 0
				state.rescue_left = TUNE.rescue_cooldown
				damage[member.id] = maxf(0.0, member.health - 1.0)
				# Rescue is exactly 1 HP this tick, ordinary simultaneous healing is suppressed.
				healing.erase(member.id)
				recovery(source, member, member.max_health * 0.25, TUNE.recovery_duration)
				rescued = true
				events.append({"kind": "wizard_vfx", "ability": "the_story_continues", "position": member.position, "source_id": source.id, "target_id": member.id, "radius": 50.0})
			if incoming > 0.0 and incoming < member.health and not rescued:
				for entry: Dictionary in state.recoveries:
					if entry.target_id == member.id and entry.budget > 0.0:
						var amount: float = minf(entry.budget, incoming * TUNE.recovery_fraction)
						healing[member.id] = float(healing.get(member.id, 0.0)) + amount
						entry.budget -= amount
						if state.wizard_role == "acolyte": entry.budget = 0.0
						if state.wizard_role == "archsage": gain(source, 1)
						events.append({"kind": "heal", "position": member.position, "target_id": member.id, "source_id": source.id, "amount": amount, "ability": "written_recovery"})
			if state.wizard_role == "archsage":
				var loss: float = minf(member.health, float(damage.get(member.id, 0.0)))
				if loss > 0.0: state.history.append({"target_id": member.id, "amount": loss, "time": state.clock})
				var recovered: float = float(healing.get(member.id, 0.0))
				for item: Dictionary in state.history:
					if item.target_id == member.id:
						var consumed: float = minf(item.amount, recovered)
						item.amount -= consumed
						recovered -= consumed
			while state.history.size() > 1000: state.history.pop_front()

static func decoy_events(actors: Array[CombatantState], damage: Dictionary, events: Array[Dictionary], requests: Array[Dictionary], rng: RandomNumberGenerator) -> void:
	for decoy: CombatantState in actors:
		if decoy.definition_id not in [&"clockwork_familiar", &"mirror_decoy"] or not decoy.alive(): continue
		var owner: CombatantState = null
		for member: CombatantState in actors:
			if member.copy_id == decoy.summoner_id and member.alive(): owner = member
		if owner == null: continue
		if float(damage.get(decoy.id, 0.0)) > 0.0: gain(owner, 1)
		if float(damage.get(decoy.id, 0.0)) >= decoy.health and decoy.definition_id == &"clockwork_familiar":
			for opponent: CombatantState in Targeting.opponents(decoy, actors):
				if opponent.position.distance_to(decoy.position) <= 100.0: hit(owner, opponent, 2.0, rng, damage, events, "planned_failure")
			if decoy.kit_state.get("split", false):
				for index: int in range(2): summon(owner, requests, "mirror_decoy", 3.0, decoy.position + Vector2(0, -35 + index * 70))
			events.append({"kind": "wizard_vfx", "ability": "explosion", "position": decoy.position, "source_id": owner.id, "radius": 100.0})
