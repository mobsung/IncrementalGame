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
	&"sequence", &"attempt_snapshot", &"last_result"]

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

func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value
	summon_rng.seed = seed_value ^ 0x5A17C9E3
	_create_allies()

func hero() -> CombatantState:
	return actor_for_copy(unit().id)

func unit() -> UnitProgress:
	return profile.copies[0]

func deployed_units() -> Array[UnitProgress]:
	return profile.deployed_copies()

func copy_map() -> Dictionary:
	var result: Dictionary = {}
	for copy: UnitProgress in profile.copies:
		result[copy.id] = copy
	return result

func actor_for_copy(copy_id: String) -> CombatantState:
	for actor: CombatantState in actors:
		if actor.allied and actor.copy_id == copy_id:
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
	for copy: UnitProgress in deployed_units():
		var definition: CombatantDefinition = config.definition_for(copy)
		if definition == null:
			continue
		var actor: CombatantState = CombatantState.create(definition, entity_id, true, config.slots[copy.slot])
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
	for actor: CombatantState in allied_actors():
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
	var result: Dictionary = CombatSystem.step(actors, config.definitions(), copy_map(), config, rng, STEP)
	if not result.events.is_empty():
		effects_emitted.emit(result.events)
	for id: int in result.deaths:
		var actor: CombatantState = Targeting.by_id(actors, id)
		if not actor.allied:
			var definition: CombatantDefinition = config.definitions()[actor.definition_id]
			# Price/reward changes affect subsequent kills, never rewards already earned.
			pending_gold += reward_value(definition, "gold")
			pending_xp += reward_value(definition, "experience")
			pending_souls += reward_value(definition, "souls")
	# Keep the deployed dead unit; defeated enemies can now be removed.
	for index: int in range(actors.size() - 1, -1, -1):
		if not actors[index].allied and not actors[index].alive():
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
		if actor.allied:
			result.append(actor)
	return result

func has_living_allies() -> bool:
	for actor: CombatantState in actors:
		if actor.allied and actor.alive():
			return true
	return false

func has_living_enemies() -> bool:
	for actor: CombatantState in actors:
		if not actor.allied and actor.alive():
			return true
	return false

func reward_value(enemy: CombatantDefinition, stat: String) -> float:
	# Read permanent progress so a deployed copy still contributes after dying.
	var contribution: float = 0.0
	for copy: UnitProgress in deployed_units():
		var definition: CombatantDefinition = config.definitions().get(copy.species_id)
		if definition != null:
			contribution += UnitStats.reward_contribution(copy, definition, config, stat)
	return ShopModifiers.value(float(enemy.get(stat)) + contribution, stat, profile, config)

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

func _finish(victory: bool) -> void:
	var xp: float = pending_xp if victory and wave > record_wave and wave >= xp_block else 0.0
	profile.gold += pending_gold
	souls += pending_souls
	while souls >= config.soul_threshold * (dust_earned + 1):
		souls -= config.soul_threshold * (dust_earned + 1)
		dust_earned += 1
		profile.dust += 1
	for copy: UnitProgress in deployed_units():
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
		actors.clear()
		for actor_data: Dictionary in attempt_snapshot:
			var restored: CombatantState = CombatantState.from_data(actor_data)
			var copy: UnitProgress = profile.copy_by_id(restored.copy_id)
			if copy == null:
				continue
			_apply_progress(restored)
			restored.position = config.slots[copy.slot]
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
	var should_pause: bool = pause_requested or (not victory and pause_on_defeat)
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

func set_slot(index: int) -> void:
	set_copy_slot(unit().id, index)

func set_copy_slot(copy_id: String, index: int) -> bool:
	if phase == &"battle" or index < 0 or index >= config.slots.size():
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null or not copy.deployed:
		return false
	for other: UnitProgress in deployed_units():
		if other.id != copy_id and other.slot == index:
			return false
	var actor: CombatantState = actor_for_copy(copy_id)
	if actor == null:
		return false
	copy.slot = index
	actor.anchor = config.slots[index]
	actor.position = actor.anchor
	actor.target_id = 0
	actor.return_wait = 0.0
	actor.returning = false
	if actor.action == &"basic":
		actor.clear_action()
	state_changed.emit()
	return true

func set_copy_deployed(copy_id: String, deployed: bool, slot: int = -1) -> bool:
	if phase != &"preparation":
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null or copy.deployed == deployed:
		return false
	var current: Array[UnitProgress] = deployed_units()
	if deployed and current.size() >= MAX_DEPLOYED_ALLIES:
		return false
	if not deployed and current.size() <= 1:
		return false
	if deployed:
		var destination: int = slot if slot >= 0 else _first_free_slot()
		if destination < 0 or destination >= config.slots.size():
			return false
		for other: UnitProgress in current:
			if other.slot == destination:
				return false
		copy.slot = destination
	copy.deployed = deployed
	_create_allies()
	state_changed.emit()
	return true

func _first_free_slot() -> int:
	var occupied: Dictionary = {}
	for copy: UnitProgress in deployed_units():
		occupied[copy.slot] = true
	for index: int in range(config.slots.size()):
		if not occupied.has(index):
			return index
	return -1

func purchase_upgrade(upgrade_id: StringName) -> bool:
	return purchase_copy_upgrade(unit().id, upgrade_id)

func evolution_offer(copy_id: String) -> Dictionary:
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	if copy == null:
		return {"available": false, "reason": "Unknown copy"}
	var base: CombatantDefinition = config.definitions()[copy.species_id]
	if copy.evolution >= base.forms.size():
		return {"available": false, "reason": "Final evolution"}
	var next: CombatantDefinition = base.forms[copy.evolution]
	var reason: String = ""
	if copy.deployed and phase == &"battle":
		reason = "Pause after the attempt to evolve"
	elif copy.level < next.evolution_level:
		reason = "Requires level %d" % next.evolution_level
	return {"available": reason.is_empty(), "reason": reason,
		"name": next.display_name, "level": next.evolution_level}

func evolve_copy(copy_id: String) -> bool:
	if not evolution_offer(copy_id).available:
		return false
	var copy: UnitProgress = profile.copy_by_id(copy_id)
	for id: Variant in copy.upgrade_ranks:
		var upgrade: LevelUpgradeDefinition = config.upgrade_by_id(id)
		for rank: int in range(copy.purchased_rank(id)):
			copy.level_points += upgrade.cost_for_rank(rank)
	copy.upgrade_ranks.clear()
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
	for actor: CombatantState in allied_actors():
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
		if field != &"attempt_snapshot":
			set(field, data[field])
	attempt_snapshot.assign(data.attempt_snapshot)
	actors.clear()
	for actor_data: Dictionary in data.actors:
		actors.append(CombatantState.from_data(actor_data))
	for actor: CombatantState in actors:
		if actor.allied:
			_apply_progress(actor)
	rng.seed = data.rng_seed
	rng.state = data.rng_state
	summon_rng.seed = data.summon_rng_seed
	summon_rng.state = data.summon_rng_state
