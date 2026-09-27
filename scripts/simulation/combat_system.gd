class_name CombatSystem
extends RefCounted
## Fixed-step movement and actions. Visuals consume events, never drive damage.

static func step(actors: Array[CombatantState], definitions: Dictionary, copies: Dictionary,
		config: BattleConfig, rng: RandomNumberGenerator, delta: float) -> Dictionary:
	var destinations: Dictionary = {}
	for actor: CombatantState in actors:
		actor.cooldown = maxf(0.0, actor.cooldown - delta)
		if actor.alive():
			var definition: CombatantDefinition = definitions[actor.definition_id]
			var copy: UnitProgress = copies.get(actor.copy_id) as UnitProgress
			destinations[actor.id] = _prepare(actor, actors, definition, copy, config, rng, delta)
	# Apply all movement after decisions, so scene/entity order cannot change distances.
	for actor: CombatantState in actors:
		if destinations.has(actor.id):
			actor.position = destinations[actor.id]
	var damage: Dictionary = {}
	var healing: Dictionary = {}
	var events: Array[Dictionary] = []
	for actor: CombatantState in actors:
		if not actor.alive() or actor.action.is_empty():
			continue
		var target: CombatantState = Targeting.by_id(actors, actor.target_id)
		if actor.action == &"basic" and not Targeting.in_range(actor, target):
			actor.clear_action()
			continue
		actor.action_left -= delta
		if actor.action_left > 0.000001:
			continue
		var definition: CombatantDefinition = definitions[actor.definition_id]
		var copy: UnitProgress = copies.get(actor.copy_id) as UnitProgress
		if actor.action == &"sweep":
			_complete_sweep(actor, actors, definition, copy, rng, damage, events)
		else:
			var completed: bool = _complete_basic(actor, target, actors, definition, copy, rng, damage, events)
			if completed and definition.heal_every_attacks > 0:
				actor.passive_count += 1
				if actor.passive_count >= definition.heal_every_attacks:
					actor.passive_count = 0
					healing[actor.id] = actor.max_health * definition.heal_fraction
					events.append({"kind": "heal", "position": actor.position, "amount": healing[actor.id]})
		actor.clear_action()
	var deaths: Array[int] = CombatMath.resolve(actors, damage, healing)
	for id: int in deaths:
		var actor: CombatantState = Targeting.by_id(actors, id)
		if actor.action == &"sweep":
			actor.cooldown = actor.pending_cooldown
		actor.clear_action()
	return {"deaths": deaths, "events": events}

static func _prepare(actor: CombatantState, actors: Array[CombatantState],
		definition: CombatantDefinition, copy: UnitProgress, config: BattleConfig,
		rng: RandomNumberGenerator, delta: float) -> Vector2:
	var target: CombatantState = Targeting.by_id(actors, actor.target_id)
	var priority_return: bool = actor.allied and copy != null and not copy.mobile and not actor.position.is_equal_approx(actor.anchor)
	if actor.action == &"sweep":
		return actor.position
	if actor.action == &"basic" and not Targeting.in_range(actor, target):
		actor.clear_action()
	# A posture change lets an already-started action finish before the mandatory return.
	if priority_return:
		if not actor.action.is_empty():
			return actor.position
		actor.target_id = 0
		return actor.position.move_toward(actor.anchor, actor.speed * delta)
	if definition.ability != null and actor.cooldown <= 0.0:
		var ability_target: CombatantState = target if Targeting.in_range(actor, target) else Targeting.acquire(actor, actors, definition, copy, rng, true)
		if ability_target != null:
			actor.target_id = ability_target.id
			actor.action = &"sweep"
			actor.action_left = definition.ability.cast_time
			actor.pending_cooldown = actor.ability_cooldown(definition.ability.cooldown)
			_face(actor, ability_target.position)
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

static func _complete_sweep(actor: CombatantState, actors: Array[CombatantState],
		definition: CombatantDefinition, copy: UnitProgress, rng: RandomNumberGenerator,
		damage: Dictionary, events: Array[Dictionary]) -> void:
	actor.cooldown = actor.pending_cooldown
	var target: CombatantState = Targeting.by_id(actors, actor.target_id)
	if target == null or not target.alive():
		target = Targeting.acquire(actor, actors, definition, copy, rng, true)
	if target == null:
		return
	_face(actor, target.position)
	var sweep: SweepDefinition = definition.ability
	var radius: float = sweep.radius * sqrt(1.0 + actor.area_bonus)
	var applications: int = actor.multi_cast if sweep.supports_multi_cast else 1
	var virtual_health: Dictionary = {}
	for application: int in range(applications):
		events.append({"kind": "sweep", "position": actor.position, "facing": actor.facing,
			"radius": radius, "angle": sweep.angle_degrees, "application": application + 1})
		for candidate: CombatantState in Targeting.opponents(actor, actors):
			var remaining: float = float(virtual_health.get(candidate.id, candidate.health))
			if remaining <= 0.0:
				continue
			if CombatMath.in_sector(actor.position, actor.facing, candidate.position, radius, sweep.angle_degrees):
				remaining -= _add_damage(actor, candidate, sweep, actor.sweep_bonus, rng, damage, events)
				virtual_health[candidate.id] = remaining

static func _complete_basic(actor: CombatantState, target: CombatantState,
		actors: Array[CombatantState], definition: CombatantDefinition, copy: UnitProgress,
		rng: RandomNumberGenerator, damage: Dictionary, events: Array[Dictionary]) -> bool:
	if target == null or not Targeting.in_range(actor, target):
		return false
	var hits: int = actor.multi_hit if definition.basic_damage.supports_multi_hit else 1
	var virtual_health: Dictionary = {}
	var current: CombatantState = target
	for hit: int in range(hits):
		if current == null:
			break
		var remaining: float = float(virtual_health.get(current.id, current.health))
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
		"amount": amount, "allied": actor.allied, "critical_stage": packet.critical_stage,
		"physical": packet.physical, "magic": packet.magic})
	return amount
