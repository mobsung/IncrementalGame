class_name BattleSimulation
extends RefCounted
## Scene-independent application model. advance() is also the future offline entry point.

signal effects_emitted(events: Array[Dictionary])
signal attempt_finished(summary: Dictionary)
signal state_changed

const STEP: float = 1.0 / 60.0
const MAX_DEPLOYED_ALLIES: int = 3
const CONFIG: BattleConfig = preload("res://resources/battle/first_arena.tres")
const FIELDS: Array[StringName] = [
	&"phase", &"wave", &"selected_wave", &"record_wave", &"xp_block",
	&"auto_advance", &"pause_on_defeat", &"pause_requested", &"attempt_time",
	&"spawn_index", &"special_spawned", &"next_id", &"souls", &"dust_earned",
	&"pending_gold", &"pending_xp", &"pending_souls", &"accumulator", &"tick",
	&"sequence", &"attempt_snapshot", &"last_result", &"projectiles"]

var config: BattleConfig = CONFIG
var profile: PlayerProfile = PlayerProfile.new()
var actors: Array[CombatantState] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var summon_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var phase: StringName = &"preparation"
var wave: int = 1
var selected_wave: int = 1
var record_wave: int = 0
var xp_block: int = 0
var auto_advance: bool = false
var pause_on_defeat: bool = false
var pause_requested: bool = false
var attempt_time: float = 0.0
var spawn_index: int = 0
var special_spawned: bool = false
var next_id: int = 2
var souls: float = 0.0
var dust_earned: int = 0
var pending_gold: float = 0.0
var pending_xp: float = 0.0
var pending_souls: float = 0.0
var accumulator: float = 0.0
var tick: int = 0
var sequence: Array[int] = []
var attempt_snapshot: Array[Dictionary] = []
var last_result: Dictionary = {}
var offline_running: bool = false
var projectiles: Array[Dictionary] = []

func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value
	summon_rng.seed = seed_value ^ 0x5A17C9E3
	_create_allies()

func hero() -> CombatantState:
	return actor_for_copy(unit().id)

func unit() -> UnitProgress:
	return profile.copies[0]

func deployed_units() -> Array[UnitProgress]:
	var result: Array[UnitProgress] = []
	for copy: UnitProgress in profile.deployed_copies():
		if not copy.enemy_support:
			result.append(copy)
	return result

func allied_limit() -> int:
	return mini(config.slots.size(), MAX_DEPLOYED_ALLIES + roundi(ShopModifiers.value(0.0, "allied_slots", profile, config)))

func copy_map() -> Dictionary:
	var result: Dictionary = {}
	for copy: UnitProgress in profile.copies:
		result[copy.id] = copy
	return result

func actor_for_copy(copy_id: String) -> CombatantState:
	for actor: CombatantState in actors:
		if actor.copy_id == copy_id:
			return actor
	return null

func preview_actor(copy_id: String) -> CombatantState:
	var actor: CombatantState = actor_for_copy(copy_id)
	if actor != null:
		return actor
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null:
		return null
	var definition: CombatantDefinition = config.definition_for(copy)
	if definition == null:
		return null
	actor = CombatantState.create(definition, 0, true, config.slots[copy.slot])
	actor.definition_id = copy.species_id
	actor.copy_id = copy.id
	actor.speed = copy.movement_speed
	_apply_progress(actor)
	actor.health = actor.max_health
	return actor

func summon_offer() -> Dictionary:
	if config.gacha == null:
		return {"available": false, "reason": "Summoning unavailable", "cost": 0}
	var reason: String = "" if profile.dust >= config.gacha.cost_dust else "Not enough Dust"
	return {"available": reason.is_empty(), "reason": reason, "cost": config.gacha.cost_dust}

func summon() -> Dictionary:
	var offer: Dictionary = summon_offer()
	if not offer.available:
		return {"success": false, "reason": offer.reason}
	var entry: Resource = config.gacha.draw(summon_rng)
	if entry == null or entry.unit == null:
		return {"success": false, "reason": "Summon pool unavailable"}
	profile.dust -= offer.cost
	var copy: UnitProgress = profile.create_copy(entry.unit.id)
	state_changed.emit()
	return {"success": true, "copy_id": copy.id, "species_id": copy.species_id,
		"display_name": entry.unit.display_name, "rarity": entry.rarity, "cost": offer.cost}

func _create_allies() -> void:
	actors.clear()
	var entity_id: int = 1
	for copy: UnitProgress in profile.deployed_copies():
		var definition: CombatantDefinition = config.definition_for(copy)
		if definition == null:
			continue
		var positions: PackedVector2Array = config.support_slots if copy.enemy_support else config.slots
		var actor: CombatantState = CombatantState.create(definition, entity_id, not copy.enemy_support, positions[copy.slot])
		actor.definition_id = copy.species_id
		actor.support = copy.enemy_support
		actor.copy_id = copy.id
		actor.speed = copy.movement_speed
		_apply_progress(actor)
		actor.health = actor.max_health
		actors.append(actor)
		entity_id += 1
	next_id = maxi(next_id, entity_id)

func _apply_progress(actor: CombatantState) -> void:
	var copy: UnitProgress = profile.copy_by_id(actor.copy_id)
	if copy != null:
		UnitStats.apply(actor, copy, config, profile)

func start() -> void:
	if phase == &"preparation" or phase == &"paused":
		_begin_attempt()
		state_changed.emit()

func _begin_attempt() -> void:
	phase = &"battle"
	attempt_time = 0.0
	spawn_index = 0
	special_spawned = false
	pending_gold = 0.0
	pending_xp = 0.0
	pending_souls = 0.0
	attempt_snapshot.clear()
	for actor: CombatantState in owned_actors():
		var copy: UnitProgress = profile.copy_by_id(actor.copy_id)
		var definition: CombatantDefinition = config.definition_for(copy)
		if definition.kit != null:
			definition.kit.reset_wave(actor, copy)
		attempt_snapshot.append(actor.to_data())
	sequence = WaveSequence.generate(rng)
	_spawn_due()

func advance(seconds: float) -> void:
	if phase != &"battle":
		return
	accumulator += seconds
	while accumulator + 0.0000001 >= STEP and phase == &"battle":
		accumulator = maxf(0.0, accumulator - STEP)
		step()
	if phase != &"battle":
		accumulator = 0.0

func step() -> void:
	if phase != &"battle":
		return
	tick += 1
	for index: int in range(actors.size() - 1, -1, -1):
		var actor: CombatantState = actors[index]
		if not actor.summoner_id.is_empty():
			actor.summon_remaining = maxf(0.0, actor.summon_remaining - STEP)
			if actor.summon_remaining <= 0.0:
				actors.remove_at(index)
	var result: Dictionary = CombatSystem.step(actors, config.definitions(), copy_map(), config, rng, STEP, projectiles)
	for request: Dictionary in result.requests:
		if request.kind == "summon":
			_spawn_summons(request.actor, request.effect)
	if not offline_running and not result.events.is_empty():
		effects_emitted.emit(result.events)
	for id: int in result.deaths:
		var actor: CombatantState = Targeting.by_id(actors, id)
		if not actor.allied and not actor.support:
			var definition: CombatantDefinition = config.definitions()[actor.definition_id]
			# Price/reward changes affect subsequent kills, never rewards already earned.
			pending_gold += reward_value(definition, "gold", result.death_statuses[id]) * actor.reward_multiplier
			pending_xp += reward_value(definition, "experience", result.death_statuses[id]) * actor.reward_multiplier
			pending_souls += reward_value(definition, "souls", result.death_statuses[id]) * actor.reward_multiplier
	# Keep the deployed dead unit; defeated enemies can now be removed.
	for index: int in range(actors.size() - 1, -1, -1):
		if not actors[index].alive() and (not actors[index].allied or not actors[index].summoner_id.is_empty()):
			actors.remove_at(index)
	if not has_living_allies():
		_finish(false)
		return
	attempt_time += STEP
	_spawn_due()
	if spawn_index == 12 and (wave % 10 != 0 or special_spawned) and not has_living_enemies():
		_finish(true)

func allied_actors() -> Array[CombatantState]:
	var result: Array[CombatantState] = []
	for actor: CombatantState in actors:
		if actor.allied and not actor.copy_id.is_empty():
			result.append(actor)
	return result

func owned_actors() -> Array[CombatantState]:
	var result: Array[CombatantState] = []
	for actor: CombatantState in actors:
		if not actor.copy_id.is_empty():
			result.append(actor)
	return result

func has_living_allies() -> bool:
	for actor: CombatantState in actors:
		if actor.allied and not actor.copy_id.is_empty() and actor.alive():
			return true
	return false

func has_living_enemies() -> bool:
	for actor: CombatantState in actors:
		if not actor.allied and not actor.support and actor.summoner_id.is_empty() and actor.alive():
			return true
	return false

func reward_value(enemy: CombatantDefinition, stat: String, statuses: Array = []) -> float:
	# Read permanent progress so a deployed copy still contributes after dying.
	var contribution: float = 0.0
	for copy: UnitProgress in profile.deployed_copies():
		var definition: CombatantDefinition = config.definitions().get(copy.species_id)
		if definition != null:
			contribution += UnitStats.reward_contribution(copy, definition, config, stat)
	var addition: float = 0.0
	var percentage: float = 0.0
	for status: Dictionary in statuses:
		addition += float(status.additive.get(stat, 0.0)) * status.stacks
		percentage += float(status.multiplier.get(stat, 0.0)) * status.stacks
	return maxf(0.0, ShopModifiers.value(float(enemy.get(stat)) + contribution + addition, stat, profile, config) * maxf(0.0, 1.0 + percentage))

func _spawn_due() -> void:
	while spawn_index < 12 and attempt_time + 0.000001 >= float(spawn_index) * config.spawn_window / 11.0:
		var type: int = sequence[spawn_index]
		var definition: CombatantDefinition = config.balanced if type == 0 else config.offensive
		for group_index: int in range(1 if type == 0 else 3):
			_spawn(definition, Vector2(0, (group_index - 1) * config.spawn_spread) if type == 1 else Vector2.ZERO)
		spawn_index += 1
	if wave % 10 == 0 and not special_spawned and attempt_time + 0.000001 >= config.spawn_window + config.special_delay:
		_spawn(config.special, Vector2.ZERO)
		special_spawned = true

func _spawn(definition: CombatantDefinition, offset: Vector2) -> void:
	var actor: CombatantState = CombatantState.create(definition, next_id, false,
		config.spawn_position + offset, pow(config.health_growth, wave - 1), pow(config.attack_growth, wave - 1))
	next_id += 1
	actors.append(actor)

func _spawn_summons(source: CombatantState, effect: AbilityEffectDefinition) -> void:
	var owner: String = AbilitySystem.owner_id(source)
	var count: int = 0
	for actor: CombatantState in actors:
		if actor.summoner_id == owner and actor.definition_id == effect.summon.id and actor.alive():
			count += 1
	for index: int in range(mini(effect.summon_count, effect.summon_limit - count)):
		var position: Vector2 = (source.position + Vector2(0, (index - 0.5) * config.spawn_spread)).clamp(config.arena.position, config.arena.end)
		var health_scale: float = 1.0 if source.allied else pow(config.health_growth, wave - 1)
		var attack_scale: float = 1.0 if source.allied else pow(config.attack_growth, wave - 1)
		var actor: CombatantState = CombatantState.create(effect.summon, next_id, source.allied, position, health_scale, attack_scale)
		actor.summoner_id = owner
		actor.summon_remaining = effect.summon_duration
		actor.reward_multiplier = effect.summon_reward_multiplier
		next_id += 1
		actors.append(actor)

func _finish(victory: bool) -> void:
	var xp: float = pending_xp if victory and wave > record_wave and wave >= xp_block else 0.0
	profile.gold += pending_gold
	souls += pending_souls
	while souls >= config.soul_threshold * (dust_earned + 1):
		souls -= config.soul_threshold * (dust_earned + 1)
		dust_earned += 1
		profile.dust += 1
	for copy: UnitProgress in profile.deployed_copies():
		copy.grant_experience(xp, config)
	last_result = {"victory": victory, "wave": wave, "gold": pending_gold, "xp": xp, "souls": pending_souls}
	if victory:
		record_wave = maxi(record_wave, wave)
		if wave >= xp_block:
			xp_block = 0
		selected_wave = maxi(selected_wave, minimum_wave())
		wave = wave + 1 if auto_advance else selected_wave
	else:
		xp_block = maxi(xp_block, wave)
		projectiles.clear()
		actors.clear()
		for actor_data: Dictionary in attempt_snapshot:
			var restored: CombatantState = CombatantState.from_data(actor_data)
			var copy: UnitProgress = profile.copy_by_id(restored.copy_id)
			if copy == null:
				continue
			_apply_progress(restored)
			restored.position = (config.support_slots if copy.enemy_support else config.slots)[copy.slot]
			restored.anchor = restored.position
			restored.target_id = 0
			restored.return_wait = 0.0
			restored.returning = false
			restored.clear_action()
			var definition: CombatantDefinition = config.definition_for(copy)
			if definition.kit != null:
				definition.kit.reset_wave(restored, copy)
			actors.append(restored)
		wave = selected_wave
	pending_gold = 0.0
	pending_xp = 0.0
	pending_souls = 0.0
	phase = &"paused"
	var should_pause: bool = pause_requested or (not victory and (pause_on_defeat or offline_running))
	pause_requested = false
	if not should_pause:
		_begin_attempt()
	attempt_finished.emit(last_result.duplicate())
	state_changed.emit()

func minimum_wave() -> int:
	return floori(float(record_wave) / 10.0) * 10 + 1

func set_selected_wave(value: int) -> void:
	if phase == &"battle":
		return
	selected_wave = clampi(value, minimum_wave(), record_wave + 1)
	wave = selected_wave
	state_changed.emit()

func set_posture(mobile: bool) -> void:
	set_copy_posture(unit().id, mobile)

func set_copy_posture(copy_id: String, mobile: bool) -> bool:
	if phase == &"battle":
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null:
		return false
	copy.mobile = mobile
	state_changed.emit()
	return true

func set_copy_priority(copy_id: String, priority: int) -> bool:
	if priority < 0 or priority > 3:
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null:
		return false
	copy.priority = priority
	state_changed.emit()
	return true

func set_ability_priority(copy_id: String, ability_id: StringName, value: int) -> bool:
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null or value < 0 or value > 100:
		return false
	var definition: CombatantDefinition = config.definition_for(copy)
	var active: AbilityDefinition = AbilitySystem.definition_for(definition, ability_id)
	if active == null and (definition.kit == null or ability_id not in definition.kit.available_actions(copy)):
		return false
	copy.ability_priorities[ability_id] = value
	state_changed.emit()
	return true

func active_ability_ids(copy: UnitProgress) -> Array[StringName]:
	var definition: CombatantDefinition = config.definition_for(copy)
	var result: Array[StringName] = []
	if definition.kit != null:
		result.assign(definition.kit.available_actions(copy))
	for active: AbilityDefinition in definition.active_abilities:
		if copy.evolution >= active.minimum_evolution:
			result.append(active.id)
	return result

func set_slot(index: int) -> void:
	set_copy_slot(unit().id, index)

func set_copy_slot(copy_id: String, index: int) -> bool:
	if phase == &"battle" or index < 0:
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null or not copy.deployed:
		return false
	var positions: PackedVector2Array = config.support_slots if copy.enemy_support else config.slots
	if index >= positions.size():
		return false
	for other: UnitProgress in profile.deployed_copies():
		if other.id != copy_id and other.enemy_support == copy.enemy_support and other.slot == index:
			return false
	var actor: CombatantState = actor_for_copy(copy_id)
	if actor == null:
		return false
	copy.slot = index
	actor.anchor = positions[index]
	actor.position = actor.anchor
	actor.target_id = 0
	actor.return_wait = 0.0
	actor.returning = false
	if actor.action == &"basic":
		actor.clear_action()
	state_changed.emit()
	return true

func set_copy_role(copy_id: String, enemy_support: bool, slot: int = 0) -> bool:
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if phase == &"battle" or copy == null or copy.enemy_support == enemy_support:
		return false
	if not copy.deployed and phase != &"preparation":
		return false
	if enemy_support and (not config.definition_for(copy).enemy_support_role or (copy.deployed and deployed_units().size() <= 1)):
		return false
	if copy.deployed and not enemy_support and deployed_units().size() >= allied_limit():
		return false
	var positions: PackedVector2Array = config.support_slots if enemy_support else config.slots
	if slot < 0 or slot >= positions.size():
		return false
	if not copy.deployed:
		copy.enemy_support = enemy_support
		copy.slot = slot
		state_changed.emit()
		return true
	for other: UnitProgress in profile.deployed_copies():
		if other.id != copy_id and other.enemy_support == enemy_support and (other.slot == slot or enemy_support):
			return false
	var actor: CombatantState = actor_for_copy(copy_id)
	if actor == null:
		return false
	var definition: CombatantDefinition = config.definition_for(copy)
	if AbilitySystem.definition_for(definition, actor.action) != null:
		AbilitySystem.interrupt(actor)
	elif actor.action == &"sweep":
		actor.cooldown = actor.pending_cooldown
	actor.clear_action()
	for index: int in range(projectiles.size() - 1, -1, -1):
		if projectiles[index].source_id == actor.id:
			projectiles.remove_at(index)
	for index: int in range(actors.size() - 1, -1, -1):
		if actors[index].summoner_id == copy_id:
			actors.remove_at(index)
	copy.enemy_support = enemy_support
	copy.slot = slot
	actor.allied = not enemy_support
	actor.support = enemy_support
	actor.position = positions[slot]
	actor.anchor = actor.position
	actor.target_id = 0
	actor.return_wait = 0.0
	actor.returning = false
	state_changed.emit()
	return true

func set_copy_deployed(copy_id: String, deployed: bool, slot: int = -1) -> bool:
	if phase != &"preparation":
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null or copy.deployed == deployed:
		return false
	var current: Array[UnitProgress] = []
	for other: UnitProgress in profile.deployed_copies():
		if other.enemy_support == copy.enemy_support:
			current.append(other)
	var limit: int = 1 if copy.enemy_support else allied_limit()
	if deployed and current.size() >= limit:
		return false
	if not deployed and not copy.enemy_support and current.size() <= 1:
		return false
	if deployed:
		var positions: PackedVector2Array = config.support_slots if copy.enemy_support else config.slots
		var destination: int = slot if slot >= 0 else _first_free_slot(copy.enemy_support)
		if destination < 0 or destination >= positions.size():
			return false
		for other: UnitProgress in current:
			if other.slot == destination:
				return false
		copy.slot = destination
	copy.deployed = deployed
	_create_allies()
	state_changed.emit()
	return true

func _first_free_slot(enemy_support: bool = false) -> int:
	var occupied: Dictionary = {}
	for copy: UnitProgress in profile.deployed_copies():
		if copy.enemy_support == enemy_support:
			occupied[copy.slot] = true
	var positions: PackedVector2Array = config.support_slots if enemy_support else config.slots
	for index: int in range(positions.size()):
		if not occupied.has(index):
			return index
	return -1

func purchase_upgrade(upgrade_id: StringName) -> bool:
	return purchase_copy_upgrade(unit().id, upgrade_id)

func evolution_choices(copy_id: String) -> Array[Dictionary]:
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	var result: Array[Dictionary] = []
	if copy == null:
		return result
	var current: CombatantDefinition = config.definition_for(copy)
	for option: EvolutionDefinition in current.evolution_options:
		result.append({"id": option.id, "name": option.form.display_name, "level": option.required_level, "description": option.description})
	if result.is_empty() and copy.evolution_path.is_empty():
		var base: CombatantDefinition = config.definitions()[copy.species_id]
		if copy.evolution < base.forms.size():
			var next: CombatantDefinition = base.forms[copy.evolution]
			result.append({"id": &"linear", "name": next.display_name, "level": next.evolution_level})
	return result

func evolution_offer(copy_id: String, branch_id: StringName = &"") -> Dictionary:
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null:
		return {"available": false, "reason": "Unknown copy"}
	var choices: Array[Dictionary] = evolution_choices(copy_id)
	if choices.is_empty():
		return {"available": false, "reason": "Final evolution"}
	if branch_id.is_empty() and choices.size() > 1:
		return {"available": false, "reason": "Choose an evolution branch"}
	var choice: Dictionary = {}
	for option: Dictionary in choices:
		if branch_id.is_empty() or option.id == branch_id:
			choice = option
			break
	if choice.is_empty():
		return {"available": false, "reason": "Unknown evolution branch"}
	var reason: String = ""
	if copy.deployed and phase == &"battle":
		reason = "Pause after the attempt to evolve"
	elif copy.level < choice.level:
		reason = "Requires level %d" % choice.level
	return {"available": reason.is_empty(), "reason": reason,
		"name": choice.name, "level": choice.level, "id": choice.id, "description": choice.get("description", "")}

func evolve_copy(copy_id: String, branch_id: StringName = &"") -> bool:
	var offer: Dictionary = evolution_offer(copy_id, branch_id)
	if not offer.available:
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	for id: Variant in copy.upgrade_ranks:
		var upgrade: LevelUpgradeDefinition = config.upgrade_by_id(id)
		for rank: int in range(copy.purchased_rank(id)):
			copy.level_points += upgrade.cost_for_rank(rank)
	copy.upgrade_ranks.clear()
	if offer.id != &"linear":
		if copy.evolution_path.is_empty():
			for index: int in range(copy.evolution):
				copy.evolution_path.append("__linear_%d" % (index + 1))
		copy.evolution_path.append(String(offer.id))
	copy.evolution += 1
	var actor: CombatantState = actor_for_copy(copy_id)
	if actor != null:
		actor.clear_action()
		_apply_progress(actor)
		# An evolution made between attempts must also update rollback state.
		for index: int in range(attempt_snapshot.size()):
			if attempt_snapshot[index].copy_id == copy_id:
				attempt_snapshot[index] = actor.to_data()
	state_changed.emit()
	return true

func purchase_copy_upgrade(copy_id: String, upgrade_id: StringName) -> bool:
	var upgrade: LevelUpgradeDefinition = config.upgrade_by_id(upgrade_id)
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if upgrade == null or copy == null or not copy.purchase_upgrade(upgrade):
		return false
	var actor: CombatantState = actor_for_copy(copy_id)
	if actor != null:
		_apply_progress(actor)
	state_changed.emit()
	return true

func purchase_gold_upgrade(upgrade_id: StringName) -> bool:
	return purchase_copy_gold_upgrade(unit().id, upgrade_id)

func purchase_copy_gold_upgrade(copy_id: String, upgrade_id: StringName) -> bool:
	var upgrade: GoldUpgradeDefinition = config.gold_upgrade_by_id(upgrade_id)
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if upgrade == null or copy == null:
		return false
	var rank: int = copy.gold_rank(upgrade.id)
	var cost: float = upgrade.cost_for_rank(rank)
	if rank >= upgrade.max_ranks or not is_finite(cost) or profile.gold < cost:
		return false
	profile.gold -= cost
	copy.gold_ranks[upgrade.id] = rank + 1
	var actor: CombatantState = actor_for_copy(copy_id)
	if actor != null:
		_apply_progress(actor)
	state_changed.emit()
	return true

func chrono_break() -> void:
	profile.shards += pow(float(record_wave) / 10.0, 2.0)
	phase = &"preparation"
	wave = 1
	selected_wave = 1
	record_wave = 0
	xp_block = 0
	souls = 0.0
	dust_earned = 0
	pending_gold = 0.0
	pending_xp = 0.0
	pending_souls = 0.0
	pause_requested = false
	accumulator = 0.0
	attempt_time = 0.0
	spawn_index = 0
	sequence.clear()
	attempt_snapshot.clear()
	last_result.clear()
	projectiles.clear()
	_create_allies()
	state_changed.emit()

func shop_offer(shop: StringName, upgrade_id: StringName) -> Dictionary:
	var upgrade: StatUpgradeDefinition = config.shop_upgrade(shop, upgrade_id)
	if upgrade == null:
		return {"available": false, "reason": "Unknown upgrade"}
	var rank: int = int(profile.shop_ranks(shop).get(upgrade.id, 0))
	var cost: float = upgrade.cost_for_rank(rank)
	var balance: float = profile.gold if shop == &"global" else profile.shards
	var reason: String = ""
	if rank >= upgrade.max_ranks:
		reason = "Maximum rank"
	elif record_wave < upgrade.required_record:
		reason = "Requires run record %d" % upgrade.required_record
	elif not is_finite(cost) or balance < cost:
		reason = "Not enough Gold" if shop == &"global" else "Not enough Shards"
	return {"available": reason.is_empty(), "reason": reason, "rank": rank, "cost": cost}

func purchase_shop_upgrade(shop: StringName, upgrade_id: StringName) -> bool:
	var offer: Dictionary = shop_offer(shop, upgrade_id)
	if not offer.available:
		return false
	if shop == &"global":
		profile.gold -= offer.cost
	else:
		profile.shards -= offer.cost
	profile.shop_ranks(shop)[upgrade_id] = offer.rank + 1
	for actor: CombatantState in owned_actors():
		_apply_progress(actor)
	state_changed.emit()
	return true

func to_data() -> Dictionary:
	var data: Dictionary = {"profile": profile.to_data(), "rng_state": rng.state, "rng_seed": rng.seed,
		"summon_rng_state": summon_rng.state, "summon_rng_seed": summon_rng.seed}
	for field: StringName in FIELDS:
		data[field] = get(field)
	var entities: Array[Dictionary] = []
	for actor: CombatantState in actors:
		entities.append(actor.to_data())
	data["actors"] = entities
	return data.duplicate(true)

func restore(data: Dictionary) -> void:
	data = data.duplicate(true)
	profile = PlayerProfile.from_data(data.profile)
	for field: StringName in FIELDS:
		if field not in [&"attempt_snapshot", &"projectiles"]:
			set(field, data[field])
	attempt_snapshot.assign(data.attempt_snapshot)
	projectiles.assign(data.get("projectiles", []))
	actors.clear()
	for actor_data: Dictionary in data.actors:
		actors.append(CombatantState.from_data(actor_data))
	for actor: CombatantState in actors:
		if not actor.copy_id.is_empty():
			_apply_progress(actor)
	rng.seed = data.rng_seed
	rng.state = data.rng_state
	summon_rng.seed = data.summon_rng_seed
	summon_rng.state = data.summon_rng_state
