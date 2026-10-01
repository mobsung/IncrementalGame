class_name Targeting
extends RefCounted

static func opponents(actor: CombatantState, actors: Array[CombatantState]) -> Array[CombatantState]:
	var result: Array[CombatantState] = []
	for candidate: CombatantState in actors:
		if candidate.alive() and not candidate.support and candidate.allied != actor.allied:
			result.append(candidate)
	return result

static func in_range(actor: CombatantState, target: CombatantState) -> bool:
	return target != null and target.alive() and actor.position.distance_to(target.position) <= actor.attack_range + 0.0001

static func by_id(actors: Array[CombatantState], id: int) -> CombatantState:
	for actor: CombatantState in actors:
		if actor.id == id:
			return actor
	return null

static func choose(actor: CombatantState, candidates: Array[CombatantState], priority: int,
		rng: RandomNumberGenerator, keep_id: int = 0) -> CombatantState:
	var best: float = INF
	var ties: Array[CombatantState] = []
	for candidate: CombatantState in candidates:
		var score: float = actor.position.distance_squared_to(candidate.position)
		match priority:
			1: score = -candidate.max_health
			2: score = candidate.max_health
			3: score = -score
		if ties.is_empty() or (score < best and not is_equal_approx(score, best)):
			best = score
			ties.assign([candidate])
		elif is_equal_approx(score, best):
			ties.append(candidate)
	for candidate: CombatantState in ties:
		if candidate.id == keep_id:
			return candidate
	if ties.is_empty():
		return null
	return ties[rng.randi_range(0, ties.size() - 1)]

static func acquire(actor: CombatantState, actors: Array[CombatantState],
		definition: CombatantDefinition, copy: UnitProgress, rng: RandomNumberGenerator,
		only_range: bool = false) -> CombatantState:
	var candidates: Array[CombatantState] = opponents(actor, actors)
	if not actor.allied and not only_range:
		var decoys: Array[CombatantState] = []
		for candidate: CombatantState in candidates:
			if candidate.definition_id in [&"clockwork_familiar", &"mirror_decoy"] and actor.position.distance_to(candidate.position) <= 280.0:
				decoys.append(candidate)
		if not decoys.is_empty(): return choose(actor, decoys, 0, rng, actor.target_id)
		return choose(actor, candidates, 0, rng, actor.target_id)
	var nearby: Array[CombatantState] = []
	for candidate: CombatantState in candidates:
		if in_range(actor, candidate):
			nearby.append(candidate)
	var priority: int = copy.priority if actor.allied and copy != null else 0
	if not nearby.is_empty():
		return choose(actor, nearby, priority, rng)
	if actor.allied and copy != null and copy.mobile and not only_range:
		for candidate: CombatantState in candidates:
			if actor.anchor.distance_to(candidate.position) <= definition.engagement_radius:
				nearby.append(candidate)
	return choose(actor, nearby, priority, rng)
