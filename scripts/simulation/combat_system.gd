class_name CombatSystem
extends RefCounted
## Fixed-step movement and actions. Visuals consume events, never drive damage.

static func step(actors: Array[CombatantState], definitions: Dictionary, copies: Dictionary,
		config: BattleConfig, rng: RandomNumberGenerator, delta: float,
		projectiles: Array[Dictionary] = []) -> Dictionary:
	var destinations: Dictionary = {}
	for actor: CombatantState in actors:
		actor.cooldown = maxf(0.0, actor.cooldown - delta)
		for id: Variant in actor.ability_cooldowns:
			actor.ability_cooldowns[id] = maxf(0.0, float(actor.ability_cooldowns[id]) - delta)
		StatusSystem.advance(actor, delta)
		var definition: CombatantDefinition = definitions[actor.definition_id]
		var copy: UnitProgress = copies.get(actor.copy_id) as UnitProgress
		if copy != null:
			definition = config.definition_for(copy)
		if definition.kit != null and copy != null:
			definition.kit.advance_timers(actor, copy, delta)
		if actor.alive():
			StatusSystem.apply_stats(actor)
			destinations[actor.id] = _prepare(actor, actors, definition, copy, config, rng, delta)
	# Apply all movement after decisions, so scene/entity order cannot change distances.
	for actor: CombatantState in actors:
		if destinations.has(actor.id):
			actor.position = destinations[actor.id]
	var damage: Dictionary = {}
	var healing: Dictionary = {}
	var events: Array[Dictionary] = []
	var requests: Array[Dictionary] = []
	WizardSystem.advance(actors, delta, rng, damage, events, definitions)
	for index: int in range(projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = projectiles[index]
		projectile.remaining = maxf(0.0, projectile.remaining - delta)
		if projectile.remaining > 0.000001:
			continue
		var recipient: CombatantState = Targeting.by_id(actors, projectile.target_id)
		if recipient != null and recipient.alive() and not recipient.support:
			var amount: float = CombatMath.damage_amount(projectile.packet, recipient)
			damage[recipient.id] = float(damage.get(recipient.id, 0.0)) + amount
			events.append({"kind": "hit", "position": recipient.position, "from": projectile.from,
				"source_id": projectile.source_id, "target_id": recipient.id, "amount": amount,
				"allied": projectile.allied, "critical_stage": projectile.packet.critical_stage})
		projectiles.remove_at(index)
	for actor: CombatantState in actors:
		var copy: UnitProgress = copies.get(actor.copy_id)
		if actor.alive() and copy != null:
			var definition: CombatantDefinition = config.definition_for(copy)
			if definition.kit != null:
				definition.kit.periodic_healing(actor, copy, healing, events)
	for actor: CombatantState in actors:
		if not actor.alive() or actor.action.is_empty():
			continue
		var target: CombatantState = Targeting.by_id(actors, actor.target_id)
		var copy: UnitProgress = copies.get(actor.copy_id) as UnitProgress
		var definition: CombatantDefinition = config.definition_for(copy) if copy != null else definitions[actor.definition_id]
		var active: AbilityDefinition = AbilitySystem.definition_for(definition, actor.action)
		if active != null:
			actor.action_left -= delta
			if actor.action_left <= 0.000001:
				AbilitySystem.complete(actor, actors, active, copy, rng, damage, healing, requests, events)
				actor.clear_action()
			continue
		if definition.kit != null:
			_tick_kit_action(actor, target, actors, definition, copy, rng, delta, damage, healing, events)
			continue
		if actor.action == &"basic" and not Targeting.in_range(actor, target):
			actor.clear_action()
			continue
		actor.action_left -= delta
		if actor.action_left > 0.000001:
			continue
		if actor.action == &"sweep":
			_complete_sweep(actor, actors, definition, copy, rng, damage, events)
		else:
			var completed: bool = _complete_basic(actor, target, actors, definition, copy, rng, damage, events, requests)
			if completed and not definition.wizard_role.is_empty(): WizardSystem.basic(actor, target)
			if completed and definition.heal_every_attacks > 0:
				actor.passive_count += 1
				if actor.passive_count >= definition.heal_every_attacks:
					actor.passive_count = 0
					healing[actor.id] = actor.max_health * definition.heal_fraction
					events.append({"kind": "heal", "position": actor.position, "amount": healing[actor.id]})
		actor.clear_action()
	WizardSystem.decoy_events(actors, damage, events, requests, rng)
	WizardSystem.before_resolve(actors, damage, healing, events)
	for actor: CombatantState in actors:
		actor.position = actor.position.clamp(config.arena.position, config.arena.end)
	var deaths: Array[int] = CombatMath.resolve(actors, damage, healing)
	var death_statuses: Dictionary = {}
	for id: int in deaths:
		var actor: CombatantState = Targeting.by_id(actors, id)
		death_statuses[id] = actor.statuses.duplicate(true)
		var copy: UnitProgress = copies.get(actor.copy_id)
		var definition: CombatantDefinition = config.definition_for(copy) if copy != null else definitions[actor.definition_id]
		if AbilitySystem.definition_for(definition, actor.action) != null:
			AbilitySystem.interrupt(actor)
		if definition.kit != null:
			definition.kit.on_death(actor, copy)
			events.append({"kind": "death", "target_id": actor.id, "position": actor.position})
		elif not definition.wizard_role.is_empty():
			actor.kit_state.clear()
			WizardSystem.ensure_state(actor, definition.wizard_role)
			events.append({"kind": "death", "target_id": actor.id, "position": actor.position})
		elif actor.action == &"sweep":
			actor.cooldown = actor.pending_cooldown
		actor.clear_action()
		StatusSystem.on_death(actor)
	for request: Dictionary in requests:
		if request.kind == "projectile":
			projectiles.append(request.data)
		elif request.kind == "status":
			StatusSystem.add(request.target, request.definition, request.source_id)
		elif request.kind == "resurrect" and not request.target.alive():
			request.target.health = request.target.max_health * request.fraction
			request.target.clear_action()
			events.append({"kind": "resurrect", "position": request.target.position, "target_id": request.target.id})
	for actor: CombatantState in actors:
		var copy: UnitProgress = copies.get(actor.copy_id)
		if copy != null:
			var definition: CombatantDefinition = config.definition_for(copy)
			if definition.kit != null:
				StatusSystem.remove_stats(actor)
				definition.kit.apply_stats(actor, copy)
		StatusSystem.apply_stats(actor)
	return {"deaths": deaths, "events": events, "requests": requests, "death_statuses": death_statuses}

static func _prepare(actor: CombatantState, actors: Array[CombatantState],
		definition: CombatantDefinition, copy: UnitProgress, config: BattleConfig,
		rng: RandomNumberGenerator, delta: float) -> Vector2:
	var target: CombatantState = Targeting.by_id(actors, actor.target_id)
	var priority_return: bool = actor.allied and copy != null and not copy.mobile and not actor.position.is_equal_approx(actor.anchor)
	if actor.kit_state.get("retreat", false) and actor.action.is_empty():
		actor.target_id = 0
		var destination: Vector2 = actor.position.move_toward(actor.anchor, actor.speed * delta)
		if destination.is_equal_approx(actor.anchor): actor.kit_state.retreat = false
		return destination
	if not definition.active_abilities.is_empty():
		if not actor.action.is_empty() and actor.action != &"basic":
			return actor.position
		var active: AbilityDefinition = AbilitySystem.select(actor, actors, definition, copy, rng)
		if active != null:
			AbilitySystem.begin(actor, active)
			return actor.position
	if actor.support:
		return actor.position
	var self_action: StringName = &""
	if definition.kit != null:
		if not actor.action.is_empty():
			return actor.position
		self_action = definition.kit.select_action(actor, copy)
	if actor.action == &"sweep":
		return actor.position
	if actor.action == &"basic" and not Targeting.in_range(actor, target):
		actor.clear_action()
	# A posture change lets an already-started action finish before the mandatory return.
	if priority_return and self_action.is_empty():
		if not actor.action.is_empty():
			return actor.position
		actor.target_id = 0
		return actor.position.move_toward(actor.anchor, actor.speed * delta)
	if definition.ability != null and actor.cooldown <= 0.0:
		var ability_target: CombatantState = target if Targeting.in_range(actor, target) else Targeting.acquire(actor, actors, definition, copy, rng, true)
		if definition.kit != null:
			var candidates: Array[CombatantState] = []
			for candidate: CombatantState in Targeting.opponents(actor, actors):
				if actor.position.distance_to(candidate.position) <= definition.ability.radius * sqrt(1.0 + actor.area_bonus):
					candidates.append(candidate)
			ability_target = Targeting.choose(actor, candidates, copy.priority, rng)
		if ability_target != null and (self_action.is_empty() or definition.kit.priority(copy, &"sweep") >= definition.kit.priority(copy, self_action)):
			actor.target_id = ability_target.id
			actor.action = &"sweep"
			actor.action_left = definition.ability.cast_time
			actor.pending_cooldown = actor.ability_cooldown(definition.ability.cooldown)
			if definition.kit != null:
				actor.pending_cooldown = maxf(definition.kit.sweep_minimum_cooldown, actor.pending_cooldown)
				actor.impact_left = definition.kit.sweep_impact_time
				actor.impacted = false
			_face(actor, ability_target.position)
			return actor.position
	if not self_action.is_empty():
		var ability: SelfBuffDefinition = definition.kit.self_ability(self_action)
		actor.action = self_action
		actor.action_left = ability.cast_time
		actor.impact_left = ability.cast_time
		actor.impacted = false
		actor.pending_cooldown = maxf(ability.minimum_cooldown, ability.cooldown * 100.0 / (100.0 + actor.haste))
		return actor.position
	if actor.action == &"basic":
		return actor.position
	if not actor.allied:
		target = Targeting.acquire(actor, actors, definition, copy, rng)
	elif target == null or not target.alive() or (not Targeting.in_range(actor, target) and (
			copy == null or not copy.mobile or actor.anchor.distance_to(target.position) > definition.engagement_radius)):
		target = Targeting.acquire(actor, actors, definition, copy, rng)
	actor.target_id = target.id if target != null else 0
	if target != null:
		actor.return_wait = 0.0
		actor.returning = false
		_face(actor, target.position)
		if Targeting.in_range(actor, target):
			actor.action = &"basic"
			actor.action_left = 1.0 / actor.attack_speed
			if definition.kit != null:
				actor.impact_left = actor.action_left * definition.kit.jab_impact_fraction
				actor.impacted = false
			return actor.position
		var distance: float = actor.position.distance_to(target.position)
		var destination: Vector2 = actor.position.move_toward(target.position, minf(actor.speed * delta, maxf(0.0, distance - actor.attack_range)))
		if actor.allied:
			destination = actor.anchor + (destination - actor.anchor).limit_length(definition.engagement_radius)
		return destination.clamp(config.arena.position, config.arena.end)
	if actor.allied and not actor.position.is_equal_approx(actor.anchor):
		if not actor.returning:
			actor.return_wait += delta
			actor.returning = actor.return_wait >= config.return_delay
		if actor.returning:
			return actor.position.move_toward(actor.anchor, actor.speed * delta)
	return actor.position

static func _face(actor: CombatantState, point: Vector2) -> void:
	var direction: Vector2 = point - actor.position
	if not direction.is_zero_approx():
		actor.facing = direction.normalized()

static func _tick_kit_action(actor: CombatantState, target: CombatantState,
		actors: Array[CombatantState], definition: CombatantDefinition, copy: UnitProgress,
		rng: RandomNumberGenerator, delta: float, damage: Dictionary, healing: Dictionary,
		events: Array[Dictionary]) -> void:
	actor.action_left -= delta
	actor.impact_left = maxf(0.0, actor.impact_left - delta)
	if not actor.impacted and actor.impact_left <= 0.000001:
		actor.impacted = true
		if actor.action in [&"guard", &"surge"]:
			definition.kit.complete_self(actor, copy, healing, events)
		elif actor.action == &"basic":
			if _complete_basic(actor, target, actors, definition, copy, rng, damage, events):
				definition.kit.successful_action(actor, copy)
		elif actor.action == &"sweep":
			if _complete_sweep(actor, actors, definition, copy, rng, damage, events):
				definition.kit.successful_action(actor, copy)
	if actor.action_left <= 0.000001:
		actor.clear_action()

static func _complete_sweep(actor: CombatantState, actors: Array[CombatantState],
		definition: CombatantDefinition, copy: UnitProgress, rng: RandomNumberGenerator,
	damage: Dictionary, events: Array[Dictionary]) -> bool:
	actor.cooldown = actor.pending_cooldown
	var target: CombatantState = Targeting.by_id(actors, actor.target_id)
	if definition.kit == null and (target == null or not target.alive()):
		target = Targeting.acquire(actor, actors, definition, copy, rng, true)
	if definition.kit == null:
		if target == null:
			return false
		_face(actor, target.position)
	var sweep: SweepDefinition = definition.ability
	var radius: float = sweep.radius * sqrt(1.0 + actor.area_bonus)
	var applications: int = actor.multi_cast if sweep.supports_multi_cast else 1
	var virtual_health: Dictionary = {}
	var hit_any: bool = false
	for application: int in range(applications):
		var hit_count: int = 0
		events.append({"kind": "sweep", "position": actor.position, "facing": actor.facing,
			"radius": radius, "angle": sweep.angle_degrees, "application": application + 1})
		for candidate: CombatantState in Targeting.opponents(actor, actors):
			var remaining: float = float(virtual_health.get(candidate.id, candidate.health))
			if remaining <= 0.0:
				continue
			if CombatMath.in_sector(actor.position, actor.facing, candidate.position, radius, sweep.angle_degrees):
				if definition.kit != null and hit_count >= definition.kit.sweep_max_targets:
					break
				remaining -= _add_damage(actor, candidate, sweep, actor.sweep_bonus, rng, damage, events)
				virtual_health[candidate.id] = remaining
				hit_count += 1
				if application == 0:
					hit_any = true
	return hit_any

static func _complete_basic(actor: CombatantState, target: CombatantState,
		actors: Array[CombatantState], definition: CombatantDefinition, copy: UnitProgress,
		rng: RandomNumberGenerator, damage: Dictionary, events: Array[Dictionary], requests: Array[Dictionary] = []) -> bool:
	if target == null or not Targeting.in_range(actor, target):
		return false
	var hits: int = actor.multi_hit if definition.basic_damage.supports_multi_hit else 1
	var virtual_health: Dictionary = {}
	var current: CombatantState = target
	for hit: int in range(hits):
		if current == null:
			break
		var remaining: float = float(virtual_health.get(current.id, current.health))
		if definition.basic_projectile_speed > 0.0:
			var basic: DamageDefinition = definition.basic_damage
			if not definition.wizard_role.is_empty() and basic.magic_coefficient > 0.0:
				basic = basic.duplicate()
				basic.magic_coefficient += actor.basic_bonus
			var packet: Dictionary = CombatMath.create_damage(actor, basic, actor.basic_bonus, rng)
			var travel: float = actor.position.distance_to(current.position) / definition.basic_projectile_speed
			requests.append({"kind": "projectile", "data": {"target_id": current.id, "source_id": actor.id, "remaining": travel, "duration": travel, "packet": packet, "from": actor.position, "allied": actor.allied, "visual": "dart" if definition.wizard_role == "archmage" else "ink"}})
			remaining -= CombatMath.damage_amount(packet, current)
		else:
			remaining -= _add_damage(actor, current, definition.basic_damage, actor.basic_bonus, rng, damage, events)
		virtual_health[current.id] = remaining
		if remaining <= 0.0 and hit + 1 < hits:
			current = _acquire_basic_target(actor, actors, copy, rng, virtual_health)
	return true

static func _acquire_basic_target(actor: CombatantState, actors: Array[CombatantState],
		copy: UnitProgress, rng: RandomNumberGenerator, virtual_health: Dictionary) -> CombatantState:
	var candidates: Array[CombatantState] = []
	for candidate: CombatantState in Targeting.opponents(actor, actors):
		if float(virtual_health.get(candidate.id, candidate.health)) > 0.0 and Targeting.in_range(actor, candidate):
			candidates.append(candidate)
	var priority: int = copy.priority if actor.allied and copy != null else 0
	return Targeting.choose(actor, candidates, priority, rng)

static func _add_damage(actor: CombatantState, target: CombatantState,
		definition: DamageDefinition, physical_bonus: float, rng: RandomNumberGenerator,
		damage: Dictionary, events: Array[Dictionary]) -> float:
	var packet: Dictionary = CombatMath.create_damage(actor, definition, physical_bonus, rng)
	var amount: float = CombatMath.damage_amount(packet, target)
	damage[target.id] = float(damage.get(target.id, 0.0)) + amount
	events.append({"kind": "hit", "position": target.position, "from": actor.position,
		"source_id": actor.id, "target_id": target.id,
		"amount": amount, "allied": actor.allied, "critical_stage": packet.critical_stage,
		"physical": packet.physical, "magic": packet.magic})
	return amount
