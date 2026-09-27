extends SceneTree

var failures: int = 0
var checks: int = 0
var host_tree: SceneTree

func _initialize() -> void:
	host_tree = self
	call_deferred("_run", true)

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func _run(quit_after: bool = false) -> void:
	check(BattleSimulation.CONFIG.validation_errors().is_empty(), "Content validates")
	_test_sequences()
	_test_combat()
	_test_actions_and_targeting()
	_test_transitions()
	_test_upgrades()
	_test_shared_shops()
	_test_combat_stat_upgrades()
	_test_individual_rewards()
	_test_damage_foundation()
	_test_damage_upgrades()
	_test_multi_hit_and_multi_cast()
	_test_v4_migration()
	_test_multi_copy_deployment()
	_test_gacha()
	_test_saves()
	await _test_upgrade_panel()
	await _test_navigation_and_field()
	print("RESULT: %d checks, %d failures" % [checks, failures])
	if quit_after:
		quit(0 if failures == 0 else 1)

func _test_sequences() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 573
	for index: int in range(100):
		check(WaveSequence.valid(WaveSequence.generate(rng)), "Six of each, maximum three consecutive")
	var sim: BattleSimulation = BattleSimulation.new(32)
	sim.start()
	check(sim.spawn_index == 1, "First spawn at time zero")
	sim.attempt_time = 10.0
	sim._spawn_due()
	check(sim.spawn_index == 12 and sim.actors.size() == 25, "12 appearances create 24 enemies")
	sim.wave = 10
	sim.attempt_time = 10.5
	sim._spawn_due()
	check(not sim.special_spawned, "Special waits beyond ordinary window")
	sim.attempt_time = 11.0
	sim._spawn_due()
	check(sim.special_spawned and sim.actors.size() == 26, "Special arrives at 11 seconds")

func _test_combat() -> void:
	check(is_equal_approx(CombatMath.mitigate(30, 20), 25), "Physical defense formula")
	check(is_equal_approx(CombatMath.mitigate(10, -100), 15), "Negative defense formula")
	check(CombatMath.mitigate(0.1, 100) == 0.05, "Fractional damage preserved")
	check(CombatMath.in_sector(Vector2.ZERO, Vector2.RIGHT, Vector2(100, 0), 180, 120), "Sector front")
	check(not CombatMath.in_sector(Vector2.ZERO, Vector2.RIGHT, Vector2(-100, 0), 180, 120), "Sector excludes behind")
	check(not CombatMath.in_sector(Vector2.ZERO, Vector2.RIGHT, Vector2(181, 0), 180, 120), "Sector radius")
	var sim: BattleSimulation = BattleSimulation.new()
	var hero: CombatantState = sim.hero()
	hero.health = 10
	var enemy: CombatantState = CombatantState.create(sim.config.balanced, 2, false, hero.position)
	enemy.health = 10
	var actors: Array[CombatantState] = [hero, enemy]
	var deaths: Array[int] = CombatMath.resolve(actors, {1: 10.0, 2: 10.0}, {1: 30.0})
	check(deaths.size() == 2 and hero.health == 0, "Simultaneous lethal hits; healing cannot rescue")
	hero.health = 200
	hero.action = &"basic"
	hero.action_left = BattleSimulation.STEP
	hero.target_id = 2
	hero.passive_count = 4
	hero.cooldown = 8
	enemy.health = 40
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	CombatSystem.step(actors, sim.config.definitions(), sim.copy_map(), sim.config, rng, BattleSimulation.STEP)
	check(hero.passive_count == 0 and hero.health == 230, "Fifth completed basic heals 30")
	hero.health = 300
	hero.passive_count = 4
	hero.action = &"basic"
	hero.action_left = BattleSimulation.STEP
	enemy.health = 40
	CombatSystem.step(actors, sim.config.definitions(), sim.copy_map(), sim.config, rng, BattleSimulation.STEP)
	check(hero.passive_count == 0 and hero.health == 300, "Passive consumed at full health")
	hero.action = &"basic"
	hero.action_left = 0.5
	hero.passive_count = 2
	enemy.position += Vector2(500, 0)
	CombatSystem.step(actors, sim.config.definitions(), sim.copy_map(), sim.config, rng, BattleSimulation.STEP)
	check(hero.action.is_empty() and hero.passive_count == 2, "Out-of-range interruption does not count")
	hero.position = hero.anchor + Vector2(100, 0)
	sim.unit().mobile = false
	var position_before: Vector2 = hero.position
	CombatSystem.step(actors, sim.config.definitions(), sim.copy_map(), sim.config, rng, BattleSimulation.STEP)
	check(hero.position.distance_to(hero.anchor) < position_before.distance_to(hero.anchor), "Stationary posture returns physically")

func _test_actions_and_targeting() -> void:
	var sim: BattleSimulation = BattleSimulation.new(91)
	var definition: CombatantDefinition = sim.config.ally.duplicate()
	definition.critical_chance = 0.0
	sim.config = sim.config.duplicate()
	sim.config.ally = definition
	sim._apply_progress(sim.hero())
	var definitions: Dictionary = sim.config.definitions()
	definitions[definition.id] = definition
	var hero: CombatantState = sim.hero()
	hero.cooldown = 99.0
	var enemy: CombatantState = CombatantState.create(sim.config.balanced, 2, false, hero.position + Vector2(100, 0))
	enemy.health = 100
	enemy.max_health = 100
	enemy.attack = 0
	var actors: Array[CombatantState] = [hero, enemy]
	for index: int in range(59):
		CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(enemy.health == 100, "First basic hit waits a full cycle")
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(enemy.health == 70, "First basic impact at one second")
	hero.clear_action()
	hero.cooldown = 0
	enemy.health = 100
	for index: int in range(35):
		CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(hero.action == &"sweep" and enemy.health == 100, "Sweep waits for execution")
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(enemy.health == 55 and hero.cooldown == 8, "Sweep damage and cooldown start at completion")
	hero.action = &"sweep"
	hero.action_left = BattleSimulation.STEP
	hero.pending_cooldown = 8
	enemy.position = hero.position + Vector2(200, 0)
	var hp_before: float = enemy.health
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(enemy.health == hp_before and hero.cooldown == 8, "Target outside sector avoids hit, cast consumed")
	enemy.health = 0
	hero.action = &"sweep"
	hero.action_left = BattleSimulation.STEP
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(hero.action.is_empty() and hero.cooldown == 8, "Lost target without replacement consumes cast")
	var near_enemy: CombatantState = CombatantState.create(sim.config.balanced, 3, false, hero.position + Vector2(50, 0))
	var far_enemy: CombatantState = CombatantState.create(sim.config.offensive, 4, false, hero.position + Vector2(100, 0))
	var candidates: Array[CombatantState] = [near_enemy, far_enemy]
	check(Targeting.choose(hero, candidates, 0, sim.rng).id == 3, "Nearest priority")
	check(Targeting.choose(hero, candidates, 1, sim.rng).id == 3, "Highest maximum health priority")
	check(Targeting.choose(hero, candidates, 2, sim.rng).id == 4, "Lowest maximum health priority")
	check(Targeting.choose(hero, candidates, 3, sim.rng).id == 4, "Farthest priority")
	far_enemy.position = near_enemy.position
	check(Targeting.choose(hero, candidates, 0, sim.rng, 4).id == 4, "Enemy keeps current target on ties")
	actors.assign([hero, near_enemy])
	hero.position = hero.anchor + Vector2(100, 0)
	hero.action = &"sweep"
	hero.action_left = 0.5
	hero.target_id = near_enemy.id
	sim.unit().mobile = false
	var before_position: Vector2 = hero.position
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(hero.position == before_position and hero.action == &"sweep", "Stationary return waits for already-running cast")
	var copy: UnitProgress = UnitProgress.new()
	copy.level = 9
	check(sim.unit().level == 1, "Owned copies have independent progress")
	var second: CombatantState = CombatantState.create(definition, 7, true, Vector2.ZERO)
	second.health = 12
	check(definition.max_health == 300 and hero.health != 12, "Shared definition does not share current health")

func _test_transitions() -> void:
	var sim: BattleSimulation = BattleSimulation.new(42)
	sim.hero().health = 123
	sim.hero().passive_count = 3
	sim.hero().cooldown = 2.5
	sim.start()
	sim.pause_requested = true
	sim.pending_gold = 3.5
	sim.pending_xp = 24
	sim.pending_souls = 60
	sim.hero().health = 0
	sim.hero().position += Vector2(20, 0)
	sim._finish(false)
	check(sim.phase == &"paused" and sim.profile.gold == 3.5, "Defeat pauses and pays Gold")
	check(sim.unit().experience == 0 and sim.xp_block == 1, "Defeat discards and blocks XP")
	check(sim.profile.dust == 2 and sim.souls == 0, "Soul thresholds 20 + 40")
	check(sim.hero().health == 123 and sim.hero().cooldown == 2.5 and sim.hero().passive_count == 3, "Defeat restores temporary state")
	check(sim.hero().position == sim.hero().anchor, "Defeat restores slot")
	var frozen: Dictionary = sim.to_data()
	sim.advance(20)
	check(sim.to_data() == frozen, "Pause freezes all simulation")
	sim.start()
	sim.pending_xp = 24
	sim.pause_requested = true
	sim._finish(true)
	check(sim.unit().experience == 24 and sim.xp_block == 0, "Beating blocking wave grants XP")
	sim.start()
	sim.pending_xp = 24
	sim.pause_requested = true
	sim._finish(true)
	check(sim.unit().experience == 24, "Previously won wave cannot grant XP again")
	sim.record_wave = 10
	check(sim.minimum_wave() == 11, "Retreat floor follows completed decade")
	sim.pending_gold = 100
	sim.pending_souls = 100
	var previous_gold: float = sim.profile.gold
	sim.chrono_break()
	check(sim.phase == &"preparation" and sim.hero().health == 300, "Chrono enters healthy preparation")
	check(sim.profile.gold == previous_gold and sim.profile.shards == 1 and sim.profile.dust == 2, "Chrono discards pending rewards and preserves balances")
	check(sim.souls == 0 and sim.dust_earned == 0 and sim.hero().cooldown == 0, "Chrono resets pool and cooldown")
	var lethal: BattleSimulation = BattleSimulation.new()
	lethal.start()
	lethal.pause_on_defeat = true
	lethal.spawn_index = 12
	var last_enemy: CombatantState = lethal.actors[1]
	lethal.actors.assign([lethal.hero(), last_enemy])
	last_enemy.position = lethal.hero().position
	last_enemy.health = 1
	last_enemy.attack = 1000
	last_enemy.action = &"basic"
	last_enemy.action_left = BattleSimulation.STEP
	last_enemy.target_id = 1
	lethal.hero().cooldown = 10
	lethal.hero().action = &"basic"
	lethal.hero().action_left = BattleSimulation.STEP
	lethal.hero().target_id = last_enemy.id
	lethal.step()
	check(not lethal.last_result.victory and lethal.record_wave == 0 and lethal.unit().experience == 0, "Simultaneous last deaths resolve to defeat")
	check(lethal.profile.gold > 0, "Simultaneous kill still pays Gold on defeat")

func _test_multi_copy_deployment() -> void:
	var sim: BattleSimulation = BattleSimulation.new(2027)
	var second: UnitProgress = UnitProgress.new()
	second.id = "test_john_0002"
	second.priority = 3
	second.mobile = false
	second.gold_ranks[&"gold"] = 1
	sim.profile.copies.append(second)
	check(not sim.set_copy_deployed(second.id, true, sim.unit().slot), "Deployment rejects an occupied slot")
	check(sim.set_copy_deployed(second.id, true, 0), "A second owned copy can be deployed in preparation")
	check(sim.allied_actors().size() == 2 and sim.actor_for_copy(second.id) != null, "Each deployed copy owns one combat actor")
	check(sim.actor_for_copy(second.id).copy_id == second.id and sim.actor_for_copy(second.id).anchor == sim.config.slots[0], "Actor identity and formation slot follow its copy")
	check(not sim.set_copy_slot(second.id, sim.unit().slot), "Formation keeps deployed slots unique")
	var third: UnitProgress = UnitProgress.new()
	third.id = "test_john_0003"
	sim.profile.copies.append(third)
	check(sim.set_copy_deployed(third.id, true, 1), "Third allied copy fits the initial deployment limit")
	var fourth: UnitProgress = UnitProgress.new()
	fourth.id = "test_john_0004"
	sim.profile.copies.append(fourth)
	check(not sim.set_copy_deployed(fourth.id, true, 2), "Fourth allied copy is rejected by the deployment limit")
	check(sim.set_copy_deployed(third.id, false) and sim.allied_actors().size() == 2, "Preparation can remove a deployed copy")
	sim.start()
	check(not sim.set_copy_deployed(second.id, false), "Battle locks composition changes")
	check(sim.attempt_snapshot.size() == 2, "Attempt snapshot captures every deployed ally")
	var first_health: float = sim.hero().health
	var second_health: float = sim.actor_for_copy(second.id).health
	sim.hero().health = 0.0
	check(sim.has_living_allies(), "One fallen ally does not defeat the team")
	sim.actor_for_copy(second.id).health = 0.0
	sim.pause_requested = true
	sim.step()
	check(not sim.last_result.victory and sim.allied_actors().size() == 2, "Defeat occurs when every deployed ally is down")
	check(sim.hero().health == first_health and sim.actor_for_copy(second.id).health == second_health, "Defeat restores every allied snapshot")
	sim.start()
	sim.actor_for_copy(second.id).health = 0.0
	sim.pending_xp = 12.0
	sim.pause_requested = true
	sim._finish(true)
	check(sim.unit().experience == 12.0 and second.experience == 12.0, "Every deployed copy receives full XP, including a fallen ally")
	check(is_equal_approx(sim.reward_value(sim.config.balanced, "gold"), 2.25), "Team reward contribution sums deployed copies")
	check(SaveStore.validate(sim.to_data()), "Multi-copy paused state validates")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(sim.to_data())
	check(clone.to_data() == sim.to_data(), "Multi-copy state restores without losing identity")
	sim.chrono_break()
	check(sim.allied_actors().size() == 2 and sim.hero().health == sim.hero().max_health and sim.actor_for_copy(second.id).health == sim.actor_for_copy(second.id).max_health, "Chrono revives all deployed copies")
	check(sim.set_copy_deployed(second.id, false) and not sim.set_copy_deployed(sim.unit().id, false), "At least one allied copy remains deployed")

func _test_saves() -> void:
	var sim: BattleSimulation = BattleSimulation.new(876)
	sim.auto_advance = true
	sim.start()
	for index: int in range(750):
		sim.step()
	check(SaveStore.validate(sim.to_data()), "Battle snapshot validates")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(sim.to_data())
	for index: int in range(1200):
		sim.step()
		clone.step()
	check(sim.to_data() == clone.to_data(), "Restored RNG, actions and battle continue identically")
	var snapshot: Dictionary = sim.to_data()
	var snapshot_clone: BattleSimulation = BattleSimulation.new()
	snapshot_clone.restore(snapshot)
	snapshot_clone.chrono_break()
	check(sim.to_data() == snapshot, "Snapshots own their nested state")
	var store: SaveStore = SaveStore.new("res://tests/demo_test_" + str(Time.get_ticks_usec()) + ".save")
	check(store.write_state(sim.to_data()) == OK, "Save writes")
	check(store.load_state() == sim.to_data(), "Binary save roundtrip")
	check(store.write_state(clone.to_data()) == OK, "Save replacement and backup")
	var file: FileAccess = FileAccess.open(store.path, FileAccess.WRITE)
	if file == null:
		check(false, "Test file could not be opened: " + store.last_error)
		return
	file.store_string("broken")
	file.close()
	check(store.load_state() == clone.to_data() and store.recovered, "Corrupt primary recovers backup")
	var broken: Dictionary = sim.to_data()
	broken.actors[0].health = -1.0
	check(not SaveStore.validate(broken), "Invalid health rejected")
	broken = sim.to_data()
	broken.actors[0].definition_id = &"missing"
	check(not SaveStore.validate(broken), "Missing content rejected")
	broken = sim.to_data()
	broken.profile.copies[0].upgrade_ranks[&"wide_sweep"] = 4
	check(not SaveStore.validate(broken), "Excessive upgrade ranks rejected")
	broken = sim.to_data()
	broken.profile.copies[0].gold_ranks[&"missing"] = 1
	check(not SaveStore.validate(broken), "Unknown Gold upgrade rejected")
	broken = sim.to_data()
	broken.profile.copies[0].gold_ranks[&"health"] = -1
	check(not SaveStore.validate(broken), "Negative Gold rank rejected")
	var legacy: Dictionary = _as_v4_layout(sim.to_data())
	legacy.profile.copies[0].erase(&"upgrade_ranks")
	legacy.profile.copies[0].erase(&"gold_ranks")
	_write_envelope(store.path, legacy, 1)
	var migrated: Dictionary = store.load_state()
	check(migrated == sim.to_data() and not store.recovered, "Version 1 migrates without altering battle state")
	var loaded: BattleSimulation = BattleSimulation.new()
	loaded.restore(migrated)
	check(loaded.to_data() == sim.to_data(), "Migrated load preserves health and timers")
	_write_envelope(store.path, sim.to_data(), SaveStore.VERSION + 1)
	check(store.load_state().is_empty() and store.last_error.begins_with("Unsupported"), "Future version blocks backup rollback")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)

func _test_gacha() -> void:
	var sim: BattleSimulation = BattleSimulation.new(1234)
	check(sim.config.gacha.cost_dust == 5 and sim.config.gacha.entries.size() == 1, "Initial summon pool is Resource-driven and costs five Dust")
	check(sim.config.gacha.entries[0].unit.id == &"john_the_meatball" and sim.config.gacha.entries[0].rarity == &"common", "Initial summon pool contains only Common John")
	var unchanged: Dictionary = sim.to_data()
	var failed: Dictionary = sim.summon()
	check(not failed.success and failed.reason == "Not enough Dust" and sim.to_data() == unchanged, "Unaffordable summon changes no state")
	sim.profile.dust = 10
	var combat_rng_before: int = sim.rng.state
	var first: Dictionary = sim.summon()
	var second: Dictionary = sim.summon()
	check(first.success and second.success and sim.profile.dust == 0 and sim.profile.copies.size() == 3, "Two summons spend exact Dust and add two owned copies")
	check(first.copy_id == "copy_00000002" and second.copy_id == "copy_00000003" and first.copy_id != second.copy_id, "Summoned copies receive stable unique IDs")
	check(sim.rng.state == combat_rng_before, "Summoning never consumes combat RNG")
	var first_copy: UnitProgress = sim.profile.copy_by_id(first.copy_id)
	var second_copy: UnitProgress = sim.profile.copy_by_id(second.copy_id)
	check(not first_copy.deployed and not second_copy.deployed and first_copy.level == 1 and first_copy.gold_ranks.is_empty(), "New copies start at base progress in reserve")
	first_copy.level = 4
	first_copy.gold_ranks[&"health"] = 2
	check(second_copy.level == 1 and second_copy.gold_ranks.is_empty() and sim.unit().level == 1, "Summoned copies keep independent permanent progress")
	check(sim.set_copy_deployed(first.copy_id, true) and sim.set_copy_deployed(second.copy_id, true), "Summoned copies can fill the three-unit squad")
	check(sim.allied_actors().size() == 3 and sim.actor_for_copy(first.copy_id).max_health == 360, "Each deployed summoned copy creates an actor with its own upgrades")
	check(SaveStore.validate(sim.to_data()), "Summoned collection and squad form a valid save snapshot")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(sim.to_data())
	check(clone.to_data() == sim.to_data() and clone.profile.next_copy_serial == 4, "Collection IDs and summon RNG survive restore")

	var legacy_sim: BattleSimulation = BattleSimulation.new(876)
	var expected: Dictionary = legacy_sim.to_data()
	var legacy: Dictionary = expected.duplicate(true)
	legacy.profile.erase(&"next_copy_serial")
	legacy.erase(&"summon_rng_seed")
	legacy.erase(&"summon_rng_state")
	var store: SaveStore = SaveStore.new("res://tests/gacha_migration_test.save")
	_write_envelope(store.path, legacy, 5)
	check(store.load_state() == expected, "Version 5 adds copy serial and isolated summon RNG without changing progress")
	var broken: Dictionary = sim.to_data()
	broken.profile.next_copy_serial = 1
	check(not SaveStore.validate(broken), "Invalid copy serial is rejected")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)

func _write_envelope(path: String, data: Dictionary, version: int) -> void:
	var bytes: PackedByteArray = var_to_bytes(data)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_var({"version": version, "payload": bytes, "checksum": SaveStore._hash(bytes)}, false)
	file.close()

func _as_v4_layout(data: Dictionary) -> Dictionary:
	data = data.duplicate(true)
	for copy: Dictionary in data.profile.copies:
		copy.erase(&"deployed")
	for actor: Dictionary in data.actors:
		actor.erase(&"copy_id")
	if data.attempt_snapshot is Array:
		data.attempt_snapshot = data.attempt_snapshot[0] if not data.attempt_snapshot.is_empty() else {}
	if not data.attempt_snapshot.is_empty():
		data.attempt_snapshot.erase(&"copy_id")
	return data

func _test_multi_hit_and_multi_cast() -> void:
	var sim: BattleSimulation = BattleSimulation.new(404)
	var hero: CombatantState = sim.hero()
	hero.critical_chance = 0.0
	hero.multi_hit = 2
	var first: CombatantState = CombatantState.create(sim.config.balanced, 2, false, hero.position + Vector2(20, 0))
	var second: CombatantState = CombatantState.create(sim.config.balanced, 3, false, hero.position + Vector2(40, 0))
	first.armor = 0.0
	first.max_health = 20.0
	first.health = 20.0
	second.armor = 0.0
	second.max_health = 100.0
	second.health = 100.0
	var actors: Array[CombatantState] = [hero, first, second]
	var damage: Dictionary = {}
	var events: Array[Dictionary] = []
	check(CombatSystem._complete_basic(hero, first, actors, sim.config.ally, sim.unit(), sim.rng, damage, events), "Multi Hit completes one basic-attack cycle")
	CombatMath.resolve(actors, damage, {})
	check(first.health == 0.0 and second.health == 70.0 and events.size() == 2, "Lethal first hit retargets the remaining hit in range")
	check(hero.passive_count == 0, "Low-level hit sequence does not mutate the passive counter itself")
	var lone_target: CombatantState = CombatantState.create(sim.config.balanced, 4, false, hero.position + Vector2(20, 0))
	lone_target.armor = 0.0
	lone_target.health = 20.0
	var out_of_range: CombatantState = CombatantState.create(sim.config.balanced, 5, false, hero.position + Vector2(500, 0))
	damage.clear()
	events.clear()
	CombatSystem._complete_basic(hero, lone_target, [hero, lone_target, out_of_range], sim.config.ally, sim.unit(), sim.rng, damage, events)
	check(events.size() == 1 and not damage.has(out_of_range.id), "Remaining Multi Hit strikes are lost when no valid replacement is in range")

	var cycle_sim: BattleSimulation = BattleSimulation.new(405)
	var cycle_hero: CombatantState = cycle_sim.hero()
	cycle_hero.cooldown = 99.0
	cycle_hero.multi_hit = 2
	cycle_hero.critical_chance = 0.0
	var durable: CombatantState = CombatantState.create(cycle_sim.config.balanced, 2, false, cycle_hero.position + Vector2(20, 0))
	durable.armor = 0.0
	durable.max_health = 200.0
	durable.health = 200.0
	var cycle_actors: Array[CombatantState] = [cycle_hero, durable]
	cycle_hero.action = &"basic"
	cycle_hero.action_left = BattleSimulation.STEP
	cycle_hero.target_id = durable.id
	CombatSystem.step(cycle_actors, cycle_sim.config.definitions(), cycle_sim.copy_map(), cycle_sim.config, cycle_sim.rng, BattleSimulation.STEP)
	check(durable.health == 140.0 and cycle_hero.passive_count == 1, "Two hits deal damage but advance Hearty Rhythm once per attack cycle")

	var critical_sim: BattleSimulation = BattleSimulation.new(406)
	var critical_hero: CombatantState = critical_sim.hero()
	critical_hero.multi_hit = 2
	critical_hero.critical_chance = 0.5
	var critical_target: CombatantState = CombatantState.create(critical_sim.config.balanced, 2, false, critical_hero.position + Vector2(20, 0))
	critical_target.health = 10000.0
	var expected_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	expected_rng.state = critical_sim.rng.state
	var expected_stages: Array[int] = [
		CombatMath.critical_chain(critical_hero, expected_rng).stage,
		CombatMath.critical_chain(critical_hero, expected_rng).stage]
	damage.clear()
	events.clear()
	CombatSystem._complete_basic(critical_hero, critical_target, [critical_hero, critical_target], critical_sim.config.ally, critical_sim.unit(), critical_sim.rng, damage, events)
	check(events[0].critical_stage == expected_stages[0] and events[1].critical_stage == expected_stages[1] and critical_sim.rng.state == expected_rng.state, "Every Multi Hit strike rolls an independent deterministic critical chain")

	var cast_sim: BattleSimulation = BattleSimulation.new(407)
	var caster: CombatantState = cast_sim.hero()
	caster.multi_cast = 2
	caster.critical_chance = 0.0
	caster.pending_cooldown = 6.5
	var sweep_first: CombatantState = CombatantState.create(cast_sim.config.balanced, 2, false, caster.position + Vector2(20, 0))
	var sweep_second: CombatantState = CombatantState.create(cast_sim.config.balanced, 3, false, caster.position + Vector2(40, 0))
	sweep_first.armor = 0.0
	sweep_first.health = 40.0
	sweep_second.armor = 0.0
	sweep_second.health = 100.0
	caster.target_id = sweep_first.id
	damage.clear()
	events.clear()
	CombatSystem._complete_sweep(caster, [caster, sweep_first, sweep_second], cast_sim.config.ally, cast_sim.unit(), cast_sim.rng, damage, events)
	CombatMath.resolve([caster, sweep_first, sweep_second], damage, {})
	var sweep_events: int = 0
	for event: Dictionary in events:
		if event.kind == "sweep":
			sweep_events += 1
	check(sweep_first.health == 0.0 and sweep_second.health == 10.0, "Multi Cast resolves applications in order and skips targets killed by an earlier application")
	check(sweep_events == 2 and events.size() == 5 and caster.cooldown == 6.5, "Two Sweep applications share geometry, execution and one cooldown")

	var incompatible: SweepDefinition = cast_sim.config.ally.ability.duplicate(true)
	incompatible.supports_multi_cast = false
	var incompatible_definition: CombatantDefinition = cast_sim.config.ally.duplicate(true)
	incompatible_definition.ability = incompatible
	var incompatible_target: CombatantState = CombatantState.create(cast_sim.config.balanced, 4, false, caster.position + Vector2(20, 0))
	incompatible_target.armor = 0.0
	incompatible_target.max_health = 100.0
	incompatible_target.health = 100.0
	caster.target_id = incompatible_target.id
	damage.clear()
	events.clear()
	CombatSystem._complete_sweep(caster, [caster, incompatible_target], incompatible_definition, cast_sim.unit(), cast_sim.rng, damage, events)
	CombatMath.resolve([caster, incompatible_target], damage, {})
	check(incompatible_target.health == 55.0, "Multi Cast affects only abilities that declare compatibility")

	var configured: BattleSimulation = BattleSimulation.new(408)
	configured.config = configured.config.duplicate(true)
	configured.config.ally = configured.config.ally.duplicate(true)
	configured.config.ally.multi_hit = 2
	configured.config.ally.multi_cast = 2
	configured._apply_progress(configured.hero())
	check(configured.hero().multi_hit == 2 and configured.hero().multi_cast == 2, "Effective repetition counts rebuild from immutable species data")

	var migration_sim: BattleSimulation = BattleSimulation.new(409)
	var expected: Dictionary = migration_sim.to_data()
	var legacy: Dictionary = expected.duplicate(true)
	for actor_data: Dictionary in legacy.actors:
		actor_data.erase(&"multi_hit")
		actor_data.erase(&"multi_cast")
	var store: SaveStore = SaveStore.new("res://tests/multi_migration_test.save")
	_write_envelope(store.path, legacy, 6)
	check(store.load_state() == expected, "Version 6 adds base Multi Hit and Multi Cast values without changing the attempt")
	var broken: Dictionary = expected.duplicate(true)
	broken.actors[0].multi_hit = 0
	check(not SaveStore.validate(broken), "Save validation rejects invalid repetition counts")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)

func _test_combat_stat_upgrades() -> void:
	var sim: BattleSimulation = BattleSimulation.new(345)
	sim.profile.gold = 10000
	var actor: CombatantState = sim.hero()
	actor.health = 123
	actor.action = &"basic"
	actor.action_left = 0.7
	actor.cooldown = 4
	for id: StringName in [&"speed", &"range", &"area", &"haste"]:
		check(sim.purchase_gold_upgrade(id), "Individual combat stat purchase: " + id)
	for id: StringName in [&"global_speed", &"global_area", &"global_haste"]:
		check(sim.purchase_shop_upgrade(&"global", id), "Global combat stat purchase: " + id)
	check(is_equal_approx(actor.attack_speed, 1.1) and actor.attack_range == 145, "Individual and global speed combine; range applies independently")
	check(actor.haste == 10 and is_equal_approx(actor.area_bonus, 0.1), "Haste and surface bonuses combine additively")
	check(actor.health == 123 and actor.action_left == 0.7 and actor.cooldown == 4, "Combat stat purchases preserve health and running timers")
	check(sim.config.ally.attack_speed == 1 and sim.config.ally.attack_range == 140, "Purchases never mutate shared species data")
	sim.unit().level = 5
	sim.unit().level_points = 10
	check(sim.purchase_upgrade(&"quick_stir"), "Quick Stir remains purchasable")
	check(is_equal_approx(actor.ability_cooldown(8), 7.5 * 100 / 110), "Quick Stir modifies base before Haste")
	var enemy: CombatantState = CombatantState.create(sim.config.balanced, 2, false, actor.position + Vector2(144, 0))
	check(Targeting.in_range(actor, enemy), "Purchased range reaches a previously unreachable target")
	var actors: Array[CombatantState] = [actor, enemy]
	actor.clear_action()
	actor.target_id = enemy.id
	CombatSystem.step(actors, sim.config.definitions(), sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(is_equal_approx(actor.action_left, 1 / 1.1 - BattleSimulation.STEP), "Next attack uses upgraded speed")
	actor.clear_action()
	actor.cooldown = 0
	CombatSystem.step(actors, sim.config.definitions(), sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	var captured: float = actor.pending_cooldown
	check(actor.action == &"sweep" and is_equal_approx(captured, 7.5 * 100 / 110), "Cast captures effective cooldown")
	sim.purchase_gold_upgrade(&"haste")
	check(actor.pending_cooldown == captured and actor.ability_cooldown(8) < captured, "Mid-cast Haste affects only later casts")
	enemy.position = actor.position + Vector2(184, 0)
	actor.action_left = BattleSimulation.STEP
	var result: Dictionary = CombatSystem.step(actors, sim.config.definitions(), sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	var sweep_radius: float = 0
	for event: Dictionary in result.events:
		if event.kind == "sweep":
			sweep_radius = event.radius
	check(is_equal_approx(sweep_radius, 180 * sqrt(1.1)) and enemy.health < enemy.max_health, "Purchased area expands actual Sweep surface and reaches beyond base radius")
	check(is_equal_approx(actor.cooldown, captured), "Completed cast uses its original captured cooldown")
	var snapshot: Dictionary = sim.to_data()
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(snapshot)
	check(clone.to_data() == snapshot and clone.hero().haste == 15 and is_equal_approx(clone.hero().area_bonus, 0.1), "Save reconstruction preserves new stats without schema changes")
	sim.chrono_break()
	check(sim.hero().haste == 15 and sim.hero().attack_range == 145, "Chrono break preserves combat stat purchases")
	var fresh: BattleSimulation = BattleSimulation.new()
	check(fresh.hero().haste == 0 and fresh.hero().attack_speed == 1, "New profile is unaffected by another profile's purchases")

func _reward_test_kill(sim: BattleSimulation, lethal_to_hero: bool = false) -> void:
	sim.actors.resize(1)
	var enemy: CombatantState = CombatantState.create(sim.config.balanced, sim.next_id, false, sim.hero().position + Vector2(20, 0))
	sim.next_id += 1
	enemy.health = 0.01
	sim.actors.append(enemy)
	sim.hero().action = &"basic"
	sim.hero().action_left = BattleSimulation.STEP
	sim.hero().target_id = enemy.id
	sim.hero().cooldown = 8
	if lethal_to_hero:
		sim.hero().health = 0.01
		enemy.action = &"basic"
		enemy.action_left = BattleSimulation.STEP
		enemy.target_id = sim.hero().id
	sim.step()

func _test_individual_rewards() -> void:
	var sim: BattleSimulation = BattleSimulation.new(456)
	check(sim.reward_value(sim.config.balanced, "gold") == 2 and sim.reward_value(sim.config.balanced, "experience") == 1 and sim.reward_value(sim.config.balanced, "souls") == 1, "Zero individual base contributions preserve existing rewards")
	for id: StringName in [&"gold", &"xp", &"souls"]:
		var before: Dictionary = sim.to_data()
		check(not sim.purchase_gold_upgrade(id) and sim.to_data() == before, "Unaffordable reward purchase leaves state intact: " + id)
	sim.profile.gold = 10000
	sim.profile.shards = 100
	sim.start()
	_reward_test_kill(sim)
	check(sim.pending_gold == 2 and sim.pending_xp == 1 and sim.pending_souls == 1, "Unmodified real kill keeps baseline reward")
	var actor_before: Dictionary = sim.hero().to_data()
	var rng_before: int = sim.rng.state
	var snapshot_before: Array[Dictionary] = sim.attempt_snapshot.duplicate(true)
	for id: StringName in [&"gold", &"xp", &"souls"]:
		var balance: float = sim.profile.gold
		var price: float = sim.config.gold_upgrade_by_id(id).cost_for_rank(0)
		check(sim.purchase_gold_upgrade(id) and sim.profile.gold == balance - price and sim.profile.shards == 100, "Individual reward purchase spends Gold only: " + id)
	check(sim.hero().to_data() == actor_before and sim.rng.state == rng_before and sim.attempt_snapshot == snapshot_before, "Reward purchases preserve health, actions, RNG and attempt snapshot")
	check(sim.pending_gold == 2 and sim.pending_xp == 1 and sim.pending_souls == 1, "Mid-attempt reward purchases do not reprice earlier kills")
	_reward_test_kill(sim)
	check(is_equal_approx(sim.pending_gold, 4.25) and is_equal_approx(sim.pending_xp, 2.1) and is_equal_approx(sim.pending_souls, 2.1), "Next actual kill includes fractional individual contributions")
	for id: StringName in [&"global_gold_base", &"global_gold_multiplier", &"global_xp_base", &"global_xp_multiplier", &"global_souls_base", &"global_souls_multiplier"]:
		sim.purchase_shop_upgrade(&"global", id)
	for id: StringName in [&"chrono_gold", &"chrono_xp", &"chrono_souls"]:
		sim.purchase_shop_upgrade(&"chrono", id)
	_reward_test_kill(sim)
	check(is_equal_approx(sim.pending_gold, 4.25 + 2.5 * 1.05 * 1.1), "Individual and shared Gold additions precede both multiplier pools")
	check(is_equal_approx(sim.pending_xp, 2.1 + 1.2 * 1.05 * 1.1) and is_equal_approx(sim.pending_souls, 2.1 + 1.2 * 1.05 * 1.1), "XP and Souls preserve fractions through shared pools")
	var other: UnitProgress = UnitProgress.new()
	check(UnitStats.reward_contribution(other, sim.config.ally, sim.config, "gold") == 0, "Another copy of the same species has independent contribution")
	other.gold_ranks[&"gold"] = 50
	sim.profile.copies.append(other)
	check(is_equal_approx(sim.reward_value(sim.config.balanced, "gold"), 2.5 * 1.05 * 1.1), "Owned but undeployed copy does not contribute")
	sim.profile.copies.remove_at(1)
	check(sim.config.ally.gold == 0 and sim.config.ally.experience == 0 and sim.config.ally.souls == 0, "Purchases never mutate base contributions")
	var snapshot: Dictionary = sim.to_data()
	var store: SaveStore = SaveStore.new("res://tests/individual_rewards_test.save")
	check(SaveStore.VERSION == 7 and store.write_state(snapshot) == OK and store.load_state() == snapshot, "Reward ranks and pending fractions roundtrip in v7")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(store.load_state())
	clone.restore(clone.to_data())
	check(clone.reward_value(clone.config.balanced, "gold") == sim.reward_value(sim.config.balanced, "gold"), "Repeated load reconstructs contributions without accumulating bonuses")
	for index: int in range(900):
		sim.step()
		clone.step()
	check(sim.to_data() == clone.to_data(), "Battle with individual reward purchases resumes deterministically")
	for id: StringName in [&"gold", &"xp", &"souls"]:
		for invalid: Variant in [-1, 1.5, 51]:
			var broken: Dictionary = snapshot.duplicate(true)
			broken.profile.copies[0].gold_ranks[id] = invalid
			check(not SaveStore.validate(broken), "Invalid individual reward rank rejected: %s / %s" % [id, invalid])
		var capped: BattleSimulation = BattleSimulation.new()
		capped.profile.gold = 1e9
		capped.unit().gold_ranks[id] = 50
		var capped_before: Dictionary = capped.to_data()
		check(not capped.purchase_gold_upgrade(id) and capped.to_data() == capped_before, "Capped individual reward purchase does not spend: " + id)
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)
	var outcome: BattleSimulation = BattleSimulation.new(567)
	outcome.profile.gold = 1000
	for id: StringName in [&"gold", &"xp", &"souls"]:
		outcome.purchase_gold_upgrade(id)
	outcome.start()
	outcome.pause_requested = true
	outcome.souls = 19.5
	var gold_before: float = outcome.profile.gold
	_reward_test_kill(outcome, true)
	check(outcome.phase == &"paused" and not outcome.last_result.victory and outcome.unit().experience == 0, "Simultaneous lethal exchange gives no XP")
	check(is_equal_approx(outcome.profile.gold, gold_before + 2.25) and is_equal_approx(outcome.last_result.souls, 1.1), "Dying deployed copy still contributes Gold and Souls to simultaneous kill")
	check(outcome.profile.dust == 1 and is_equal_approx(outcome.souls, 0.6), "Individual Souls cross Dust threshold and retain fractional overflow")
	check(outcome.unit().gold_rank(&"gold") == 1 and outcome.hero().health == 300, "Defeat preserves purchases and restores attempt health")
	outcome.start()
	_reward_test_kill(outcome)
	outcome.pause_requested = true
	outcome._finish(true)
	check(is_equal_approx(outcome.unit().experience, 1.1) and outcome.xp_block == 0, "Clearing blocking wave awards full upgraded XP")
	outcome.start()
	_reward_test_kill(outcome)
	outcome.pause_requested = true
	outcome._finish(true)
	check(is_equal_approx(outcome.unit().experience, 1.1) and outcome.last_result.xp == 0, "Repeating cleared wave does not bypass XP eligibility")
	outcome.start()
	_reward_test_kill(outcome)
	var profile_before: Dictionary = outcome.profile.to_data()
	outcome.chrono_break()
	check(outcome.profile.gold == profile_before.gold and outcome.profile.dust == profile_before.dust and outcome.unit().experience == 1.1, "Chrono discards pending individual rewards and preserves prior earnings")
	check(outcome.pending_gold == 0 and outcome.pending_xp == 0 and outcome.pending_souls == 0 and outcome.souls == 0, "Chrono clears all pending rewards and soul progress")
	check(outcome.unit().gold_ranks == profile_before.copies[0].gold_ranks and outcome.reward_value(outcome.config.balanced, "gold") == 2.25, "Chrono retains individual economic upgrades")

func _test_damage_foundation() -> void:
	var sim: BattleSimulation = BattleSimulation.new(667)
	var source: CombatantState = sim.hero()
	var target: CombatantState = CombatantState.create(sim.config.balanced, 2, false, source.position + Vector2(20, 0))
	var action: DamageDefinition = DamageDefinition.new()
	action.magic_coefficient = 1.0
	source.attack = 100
	source.magic_attack = 50
	target.armor = 100
	target.magic_resistance = 0
	var packet: Dictionary = CombatMath.create_damage(source, action, 0, sim.rng)
	check(CombatMath.damage_amount(packet, target) == 100, "Mixed damage mitigates physical and magic separately")
	target.magic_resistance = -100
	check(CombatMath.damage_amount(packet, target) == 125, "Negative magic resistance follows the same diminishing defense curve")
	target.armor = 0
	target.magic_resistance = 0
	source.attack = 0.1
	source.magic_attack = 0.2
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(is_equal_approx(CombatMath.damage_amount(packet, target), 0.3), "Mixed fractional components have no damage floor")
	source.attack = -10
	source.magic_attack = -20
	check(CombatMath.damage_amount(CombatMath.create_damage(source, action, 0, sim.rng), target) == 0, "Negative components cannot heal")
	source.attack = 100
	source.magic_attack = 50
	source.critical_chance = 1
	source.super_critical_chance = 1
	source.ultra_critical_chance = 1
	source.critical_multiplier = 2
	source.super_critical_multiplier = 3
	source.ultra_critical_multiplier = 4
	action.can_crit = true
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(packet.critical_stage == 3 and packet.physical == 2400 and packet.magic == 1200, "Ultra critical multiplies both components through one chain")
	var captured: Dictionary = packet.duplicate()
	source.attack = 900
	source.magic_attack = 700
	source.critical_multiplier = 9
	target.armor = 100
	target.magic_resistance = 100
	check(packet == captured and CombatMath.damage_amount(packet, target) == 1800, "Created effect keeps source power while impact reads current defenses")
	source.attack = 100
	source.magic_attack = 50
	source.critical_multiplier = 2
	var expected_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	expected_rng.state = sim.rng.state
	for index: int in range(3):
		expected_rng.randf()
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(sim.rng.state == expected_rng.state, "Mixed event draws one critical chain, not one chain per component")
	action.magic_can_crit = false
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(packet.physical == 2400 and packet.magic == 50, "Explicitly incompatible component skips the shared critical multiplier")
	action.can_crit = false
	var rng_before: int = sim.rng.state
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(packet.critical_stage == 0 and packet.physical == 100 and sim.rng.state == rng_before, "Noncritical action never rolls or applies critical stages")
	action.can_crit = true
	action.magic_can_crit = true
	source.critical_chance = 0
	expected_rng.state = sim.rng.state
	expected_rng.randf()
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(packet.critical_stage == 0 and packet.physical == 100 and sim.rng.state == expected_rng.state, "Failed normal critical never rolls super or ultra")
	source.critical_chance = 1
	source.super_critical_chance = 0
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(packet.critical_stage == 1 and packet.physical == 200, "Ultra cannot bypass unavailable super critical")
	source.super_critical_chance = 1
	source.ultra_critical_chance = 0
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(packet.critical_stage == 2 and packet.physical == 600, "Super critical applies only its reached stages")
	source.critical_chance = 2
	source.super_critical_chance = 2
	source.ultra_critical_chance = 2
	check(CombatMath.create_damage(source, action, 0, sim.rng).critical_stage == 3, "Chance above 100 percent cannot create additional critical stages")
	source.critical_chance = 0.5
	source.super_critical_chance = 0.5
	source.ultra_critical_chance = 0.5
	var stages: Array[int] = [0, 0, 0, 0]
	for index: int in range(20000):
		stages[CombatMath.critical_chain(source, sim.rng).stage] += 1
	check(absf(float(stages[3]) / 20000 - 0.125) < 0.015 and absf(float(stages[2] + stages[3]) / 20000 - 0.25) < 0.02, "Seeded critical frequencies follow conditional probabilities")
	source.ability_power = 100
	source.critical_chance = 0
	packet = CombatMath.create_damage(source, sim.config.ally.ability, 0, sim.rng)
	check(packet.physical == 300 and packet.magic == 0, "Sweep doubles physical damage at 100 Ability Power and has no magic component")
	packet = CombatMath.create_damage(source, sim.config.ally.basic_damage, 0, sim.rng)
	check(packet.physical == 100 and packet.magic == 0, "Punch ignores Ability Power and Magic Attack")
	action.can_crit = false
	action.ability_power_ratio = 0.01
	packet = CombatMath.create_damage(source, action, 0, sim.rng)
	check(packet.physical == 200 and packet.magic == 100, "Compatible mixed action scales both components with declared Ability Power ratio")
	var definition: CombatantDefinition = sim.config.balanced.duplicate()
	definition.magic_attack = 12
	definition.magic_resistance = 7
	definition.basic_damage = DamageDefinition.new()
	definition.basic_damage.damage_coefficient = 0
	definition.basic_damage.magic_coefficient = 1
	var mage: CombatantState = CombatantState.create(definition, 2, false, sim.hero().position + Vector2(20, 0), 2, 1.5)
	check(mage.magic_attack == 18 and mage.attack == 4.5 and mage.magic_resistance == 7, "Enemy growth scales both attacks but leaves defense unchanged")
	var isolated: BattleSimulation = BattleSimulation.new()
	var definitions: Dictionary = isolated.config.definitions()
	definitions[definition.id] = definition
	isolated.hero().cooldown = 99
	mage.position = isolated.hero().position + Vector2(20, 0)
	mage.action = &"basic"
	mage.action_left = BattleSimulation.STEP
	mage.target_id = isolated.hero().id
	var actors: Array[CombatantState] = [isolated.hero(), mage]
	CombatSystem.step(actors, definitions, isolated.copy_map(), isolated.config, isolated.rng, BattleSimulation.STEP)
	check(is_equal_approx(isolated.hero().health, 300 - 18.0 * 100 / 110), "Actual enemy magic attack uses John's authored magic resistance")
	definition.magic_attack = NAN
	check(not definition.validation_errors().is_empty(), "Nonfinite combat content is rejected")
	action.magic_coefficient = -1
	check(not action.validation_errors().is_empty(), "Negative action coefficients are rejected")
	check(sim.config.ally.physical_attack == 30 and sim.config.ally.magic_attack == 0, "Synthetic damage tests never mutate authored content")
	var sweep_sim: BattleSimulation = BattleSimulation.new(678)
	var caster: CombatantState = sweep_sim.hero()
	caster.critical_chance = 0.5
	caster.super_critical_chance = 0.5
	caster.ultra_critical_chance = 0.5
	var first: CombatantState = CombatantState.create(sweep_sim.config.balanced, 2, false, caster.position + Vector2(30, 0))
	var second: CombatantState = CombatantState.create(sweep_sim.config.balanced, 3, false, caster.position + Vector2(50, 0))
	var sweep_actors: Array[CombatantState] = [caster, first, second]
	caster.target_id = first.id
	expected_rng.state = sweep_sim.rng.state
	var first_stage: int = CombatMath.critical_chain(caster, expected_rng).stage
	var second_stage: int = CombatMath.critical_chain(caster, expected_rng).stage
	var events: Array[Dictionary] = []
	var damage: Dictionary = {}
	CombatSystem._complete_sweep(caster, sweep_actors, sweep_sim.config.ally, sweep_sim.unit(), sweep_sim.rng, damage, events)
	check(events.size() == 3 and events[1].critical_stage == first_stage and events[2].critical_stage == second_stage and sweep_sim.rng.state == expected_rng.state, "Sweep rolls an independent chain for each target and exposes the result to presentation")

func _test_damage_upgrades() -> void:
	var sim: BattleSimulation = BattleSimulation.new(778)
	sim.profile.gold = 100000
	sim.start()
	sim.hero().health = 123
	sim.hero().action = &"sweep"
	sim.hero().action_left = 0.4
	sim.hero().pending_cooldown = 8
	var rng_before: int = sim.rng.state
	var new_stats: Array[StringName] = [&"magic_attack", &"magic_resistance", &"ability_power", &"critical_chance", &"critical_multiplier", &"super_critical_chance", &"super_critical_multiplier", &"ultra_critical_chance", &"ultra_critical_multiplier"]
	for stat: StringName in new_stats:
		check(sim.purchase_gold_upgrade(stat), "Individual damage-stat purchase: " + stat)
		if stat != &"magic_attack":
			check(sim.purchase_shop_upgrade(&"global", StringName("global_" + stat)), "Shared damage-stat purchase: " + stat)
	check(sim.purchase_shop_upgrade(&"global", &"global_ability_power_multiplier"), "Global Ability Power multiplier purchase")
	check(sim.hero().magic_attack == 3 and sim.hero().magic_resistance == 14 and is_equal_approx(sim.hero().ability_power, 10.5), "Magic and Ability Power additions precede shared multiplier")
	check(is_equal_approx(sim.hero().critical_chance, 0.07) and is_equal_approx(sim.hero().critical_multiplier, 1.6), "Critical chance and damage combine individual and shared additions")
	check(is_equal_approx(sim.hero().super_critical_chance, 0.02) and is_equal_approx(sim.hero().ultra_critical_multiplier, 2.1), "Advanced critical purchases reach effective stats")
	check(sim.hero().health == 123 and sim.hero().action_left == 0.4 and sim.hero().pending_cooldown == 8 and sim.rng.state == rng_before, "Damage purchases preserve health, running action, captured cooldown and RNG")
	var chrono_power: StatUpgradeDefinition = StatUpgradeDefinition.new()
	chrono_power.id = &"test_chrono_power"
	chrono_power.stat = "ability_power"
	chrono_power.operation = "multiplier"
	chrono_power.increment = 0.2
	var test_config: BattleConfig = sim.config.duplicate()
	test_config.chrono_upgrades = sim.config.chrono_upgrades.duplicate()
	test_config.chrono_upgrades.append(chrono_power)
	var test_profile: PlayerProfile = PlayerProfile.from_data(sim.profile.to_data())
	test_profile.chrono_ranks[chrono_power.id] = 2
	check(is_equal_approx(ShopModifiers.value(5, "ability_power", test_profile, test_config), 10 * 1.05 * 1.4), "Ability Power keeps global and Chrono percentage pools distinct")
	sim.hero().critical_chance = 0
	sim.actors.resize(1)
	var enemy: CombatantState = CombatantState.create(sim.config.balanced, sim.next_id, false, sim.hero().position + Vector2(20, 0))
	sim.next_id += 1
	enemy.max_health = 1000
	enemy.health = 1000
	enemy.attack = 0
	sim.actors.append(enemy)
	sim.hero().target_id = enemy.id
	sim.hero().action_left = BattleSimulation.STEP
	sim.step()
	check(is_equal_approx(enemy.health, 1000 - 45 * 1.105), "Real Sweep reads purchased Ability Power when the effect is generated")
	sim.hero().action = &"basic"
	sim.hero().action_left = BattleSimulation.STEP
	sim.hero().passive_count = 4
	sim.step()
	check(is_equal_approx(sim.hero().health, 153), "Ability Power does not amplify Hearty Rhythm healing")
	for stat: StringName in [&"critical_chance", &"super_critical_chance", &"ultra_critical_chance"]:
		sim.unit().gold_ranks[stat] = 50
		sim.profile.global_ranks[StringName("global_" + stat)] = 50
	sim._apply_progress(sim.hero())
	check(sim.hero().critical_chance == 1 and sim.hero().super_critical_chance == 1 and sim.hero().ultra_critical_chance == 1, "Each effective critical chance is capped at 100 percent")
	var snapshot: Dictionary = sim.to_data()
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(snapshot)
	clone.restore(clone.to_data())
	check(clone.to_data() == snapshot, "Repeated restore preserves damage stats without stacking")
	for index: int in range(1200):
		sim.step()
		clone.step()
	check(sim.to_data() == clone.to_data(), "Advanced critical combat resumes deterministically")
	sim.pause_requested = true
	sim._finish(false)
	check(sim.hero().ability_power == 10.5 and sim.hero().super_critical_chance == 1, "Defeat snapshot reapplies permanent damage purchases")
	sim.chrono_break()
	check(sim.hero().ability_power == 10.5 and sim.hero().magic_attack == 3 and sim.hero().health == sim.hero().max_health, "Chrono preserves new upgrades and restores full health")
	for stat: StringName in new_stats:
		sim.unit().gold_ranks[stat] = 50
		var before: Dictionary = sim.to_data()
		check(not sim.purchase_gold_upgrade(stat) and sim.to_data() == before, "Damage upgrade cap prevents extra spending: " + stat)

func _test_v4_migration() -> void:
	var sim: BattleSimulation = BattleSimulation.new(889)
	sim.profile.gold = 1000
	sim.purchase_gold_upgrade(&"health")
	sim.purchase_gold_upgrade(&"haste")
	sim.start()
	sim.advance(13.25)
	var expected: Dictionary = sim.to_data()
	var legacy: Dictionary = expected.duplicate(true)
	legacy.profile.copies[0].erase(&"deployed")
	for actor: Dictionary in legacy.actors:
		actor.erase(&"copy_id")
		for stat: StringName in SaveStore.V4_STATS:
			actor.erase(stat)
	legacy.attempt_snapshot = legacy.attempt_snapshot[0]
	legacy.attempt_snapshot.erase(&"copy_id")
	for stat: StringName in SaveStore.V4_STATS:
		legacy.attempt_snapshot.erase(stat)
	var store: SaveStore = SaveStore.new("res://tests/damage_migration_test.save")
	_write_envelope(store.path, legacy, 3)
	var migrated: Dictionary = store.load_state()
	check(migrated == expected and not store.recovered, "True v3 actor and snapshot layout migrates without altering progress, timers or RNG")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(migrated)
	for index: int in range(600):
		sim.step()
		clone.step()
	check(sim.to_data() == clone.to_data(), "Migrated v3 attempt continues identically to its v4 equivalent")
	for version: int in [1, 2]:
		var old: Dictionary = legacy.duplicate(true)
		old.profile.erase("global_ranks")
		old.profile.erase("chrono_ranks")
		_write_envelope(store.path, old, version)
		check(store.load_state() == expected, "Version %d chains through all migrations without losing purchases" % version)
	var v4: Dictionary = expected.duplicate(true)
	v4.profile.copies[0].erase(&"deployed")
	for actor: Dictionary in v4.actors:
		actor.erase(&"copy_id")
	v4.attempt_snapshot = v4.attempt_snapshot[0]
	v4.attempt_snapshot.erase(&"copy_id")
	_write_envelope(store.path, v4, 4)
	check(store.load_state() == expected, "Version 4 migrates deployment and copy identity")
	check(store.write_state(sim.to_data()) == OK and store.load_state() == sim.to_data(), "Complete v7 combat snapshot roundtrips")
	for stat: StringName in SaveStore.V4_STATS:
		var broken: Dictionary = sim.to_data()
		broken.actors[0][stat] = NAN
		check(not SaveStore.validate(broken), "Nonfinite new combat stat rejected: " + stat)
	for stat: StringName in [&"critical_chance", &"super_critical_chance", &"ultra_critical_chance"]:
		var broken: Dictionary = sim.to_data()
		broken.attempt_snapshot[0][stat] = 1.01
		check(not SaveStore.validate(broken), "Snapshot chance above 100 percent rejected: " + stat)
	var malformed: Dictionary = legacy.duplicate(true)
	malformed.actors = [null]
	_write_envelope(store.path, malformed, 3)
	check(store._read(store.path).is_empty(), "Malformed legacy actors are rejected without a migration crash")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)

func _test_shared_shops() -> void:
	var sim: BattleSimulation = BattleSimulation.new(123)
	var before: Dictionary = sim.to_data()
	check(not sim.purchase_shop_upgrade(&"missing", &"global_armor"), "Unknown shop rejected")
	check(not sim.purchase_shop_upgrade(&"global", &"chrono_health"), "Cross-catalog purchase rejected")
	check(not sim.purchase_shop_upgrade(&"global", &"global_armor") and not sim.purchase_shop_upgrade(&"chrono", &"chrono_health"), "Both shops require their currency")
	check(sim.to_data() == before, "Rejected shared purchases preserve complete state")
	sim.profile.gold = 1000
	sim.profile.shards = 100
	sim.start()
	sim.hero().health = 123
	sim.hero().action = &"sweep"
	sim.hero().action_left = 0.4
	sim.hero().pending_cooldown = 8
	var rng_before: int = sim.rng.state
	var enemy_before: Dictionary = sim.actors[1].to_data()
	check(sim.purchase_shop_upgrade(&"global", &"global_armor") and sim.profile.gold == 950 and sim.profile.shards == 100, "Global purchase debits Gold only")
	check(sim.shop_offer(&"global", &"global_armor").cost == 60, "Shared price grows by configured rank")
	check(sim.purchase_shop_upgrade(&"chrono", &"chrono_health") and sim.profile.shards == 99 and sim.profile.gold == 950, "Chrono purchase debits Shards only")
	check(sim.hero().max_health == 360 and sim.hero().health == 123, "Chrono maximum health never heals")
	check(sim.hero().action_left == 0.4 and sim.hero().pending_cooldown == 8 and sim.rng.state == rng_before and sim.actors[1].to_data() == enemy_before, "Shared purchase preserves action, enemies and RNG")
	sim.unit().gold_ranks[&"armor"] = 1
	sim.unit().upgrade_ranks[&"reinforced_glass"] = 1
	sim.unit().level = 2
	sim.purchase_shop_upgrade(&"chrono", &"chrono_armor")
	check(is_equal_approx(sim.hero().armor, 27.4), "Individual amplifier excludes global and Chrono armor")
	sim.purchase_shop_upgrade(&"chrono", &"chrono_attack")
	check(is_equal_approx(sim.hero().attack, 33), "Chrono attack reaches combat state")
	for id: StringName in [&"global_gold_base", &"global_gold_multiplier", &"global_xp_base", &"global_xp_multiplier", &"global_souls_base", &"global_souls_multiplier"]:
		sim.profile.gold = 1000
		check(sim.purchase_shop_upgrade(&"global", id), "Global reward purchase: " + id)
	for id: StringName in [&"chrono_gold", &"chrono_xp", &"chrono_souls"]:
		check(sim.purchase_shop_upgrade(&"chrono", id), "Chrono reward purchase: " + id)
	check(is_equal_approx(ShopModifiers.value(2, "gold", sim.profile, sim.config), 2.59875), "Reward additions precede separate multiplier pools")
	sim.profile.global_ranks[&"global_gold_multiplier"] = 2
	check(is_equal_approx(ShopModifiers.value(2, "gold", sim.profile, sim.config), 2.7225), "Ranks within the same multiplier pool add")
	sim.pending_gold = 7.25
	sim.actors.resize(1)
	var enemy: CombatantState = CombatantState.create(sim.config.balanced, sim.next_id, false, sim.hero().position + Vector2(20, 0))
	sim.next_id += 1
	enemy.health = 0.01
	sim.actors.append(enemy)
	sim.hero().action = &"basic"
	sim.hero().action_left = BattleSimulation.STEP
	sim.hero().target_id = enemy.id
	sim.hero().cooldown = 8
	sim.step()
	check(is_equal_approx(sim.pending_gold, 9.9725), "Actual kill adds fractional modified reward without repricing previous kills")
	check(is_equal_approx(sim.pending_xp, 1.2705) and is_equal_approx(sim.pending_souls, 1.2705), "Actual kill applies XP and Soul reward pools")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(sim.to_data())
	clone.restore(clone.to_data())
	check(clone.to_data() == sim.to_data(), "Repeated restore does not accumulate shared bonuses")
	for index: int in range(300):
		sim.step()
		clone.step()
	check(sim.to_data() == clone.to_data(), "Purchased shared bonuses resume deterministically")
	var store: SaveStore = SaveStore.new("res://tests/shop_test.save")
	check(store.write_state(sim.to_data()) == OK and store.load_state() == sim.to_data(), "Version 5 roundtrip preserves shop ranks and attempt")
	for invalid: Variant in [-1, 1.5, 101]:
		var broken: Dictionary = sim.to_data()
		broken.profile.global_ranks[&"global_armor"] = invalid
		check(not SaveStore.validate(broken), "Invalid global rank rejected: " + str(invalid))
	var unknown: Dictionary = sim.to_data()
	unknown.profile.chrono_ranks[&"missing"] = 1
	check(not SaveStore.validate(unknown), "Unknown Chrono content rejected")
	var legacy: Dictionary = _as_v4_layout(BattleSimulation.new().to_data())
	legacy.profile.gold = 155.0
	var expected: Dictionary = BattleSimulation.new().to_data()
	expected.profile.gold = 155.0
	legacy.profile.erase("global_ranks")
	legacy.profile.erase("chrono_ranks")
	_write_envelope(store.path, legacy, 2)
	check(store.load_state() == expected, "Version 2 migration preserves progress and initializes empty shops")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)
	sim.profile.global_ranks[&"global_armor"] = 100
	before = sim.to_data()
	check(not sim.purchase_shop_upgrade(&"global", &"global_armor") and sim.to_data() == before, "Maximum shop rank blocks further spending")
	var ranks: Dictionary = sim.profile.to_data()
	sim.pause_on_defeat = true
	sim._finish(false)
	check(sim.hero().max_health == 360 and sim.profile.global_ranks == ranks.global_ranks, "Defeat reapplies permanent shared bonuses")
	sim.chrono_break()
	check(sim.profile.global_ranks == ranks.global_ranks and sim.profile.chrono_ranks == ranks.chrono_ranks and sim.hero().health == 360, "Chrono break preserves shop purchases and heals to upgraded maximum")

func _test_upgrades() -> void:
	var sim: BattleSimulation = BattleSimulation.new(51)
	var unchanged: Dictionary = sim.to_data()
	check(not sim.purchase_upgrade(&"missing") and not sim.purchase_gold_upgrade(&"missing"), "Unknown purchases refused")
	check(not sim.purchase_gold_upgrade(&"health") and not sim.purchase_upgrade(&"heavy_meatballs"), "Insufficient balances refused")
	check(sim.to_data() == unchanged, "Rejected purchases have no side effects")
	sim.unit().level_points = 10
	check(not sim.purchase_upgrade(&"heavy_meatballs"), "Level gate enforced with sufficient points")
	sim.unit().level = 2
	check(sim.purchase_upgrade(&"heavy_meatballs") and sim.unit().level_points == 9, "First level rank costs one point")
	check(not sim.purchase_upgrade(&"heavy_meatballs"), "Second rank has its own level gate")
	sim.unit().level = 5
	check(sim.purchase_upgrade(&"heavy_meatballs") and sim.unit().level_points == 7, "Second rank costs two points")
	sim.unit().level = 50
	sim.unit().level_points = 100
	sim.profile.gold = 10000
	sim.hero().health = 123
	sim.hero().cooldown = 4
	sim.hero().passive_count = 3
	sim.start()
	var hero: CombatantState = sim.hero()
	var enemy_count: int = sim.actors.size()
	var rng_state: int = sim.rng.state
	check(sim.purchase_upgrade(&"reinforced_glass") and hero.max_health == 300 and hero.armor == 20, "Reinforced Glass never amplifies base stats")
	check(sim.purchase_upgrade(&"strong_noodles") and hero.attack == 30, "Strong Noodles never amplifies base attack")
	check(sim.purchase_gold_upgrade(&"health") and hero.max_health == 336 and hero.health == 123, "Gold health amplified without healing during battle")
	check(sim.purchase_gold_upgrade(&"attack") and is_equal_approx(hero.attack, 33.6), "Gold attack amplified for this copy")
	check(sim.purchase_gold_upgrade(&"armor") and is_equal_approx(hero.armor, 22.4), "Gold armor amplified for this copy")
	check(sim.profile.gold == 9963, "Gold prices deducted once")
	check(sim.config.gold_upgrade_by_id(&"health").cost_for_rank(1) == 12, "Geometric Gold price rounds upward")
	check(sim.purchase_upgrade(&"reinforced_glass") and hero.max_health == 342 and is_equal_approx(hero.armor, 22.8), "Amplifier applies retroactively to previous Gold purchases")
	check(sim.hero() == hero and sim.actors.size() == enemy_count and sim.rng.state == rng_state, "Purchases preserve entities and RNG")
	check(hero.cooldown == 4 and hero.passive_count == 3 and hero.health == 123, "Purchases preserve transient state")
	for upgrade: LevelUpgradeDefinition in sim.config.upgrades:
		while sim.unit().purchased_rank(upgrade.id) < upgrade.max_ranks:
			check(sim.purchase_upgrade(upgrade.id), "Can buy unlocked rank: " + String(upgrade.id))
		var points: int = sim.unit().level_points
		check(not sim.purchase_upgrade(upgrade.id) and sim.unit().level_points == points, "Maximum level rank enforced")
	check(is_equal_approx(hero.basic_bonus, 0.3) and is_equal_approx(hero.sweep_bonus, 0.45), "Coefficient bonuses add to each action")
	check(is_equal_approx(180 * sqrt(1 + hero.area_bonus), 216.7487), "Wide Sweep scales surface, not radius")
	check(hero.cooldown_reduction == 1.5 and hero.cooldown == 4, "Quick Stir leaves current cooldown untouched")
	check(hero.max_health == 360 and hero.attack == 36 and hero.armor == 24, "Maximum amplifiers double only Gold increments")
	var another: BattleSimulation = BattleSimulation.new()
	check(another.hero().max_health == 300 and another.unit().gold_ranks.is_empty() and sim.config.ally.max_health == 300, "Other copies and shared definitions remain independent")
	var clone: BattleSimulation = BattleSimulation.new()
	check(SaveStore.validate(sim.to_data()), "Upgraded snapshot validates")
	clone.restore(sim.to_data())
	clone.restore(clone.to_data())
	check(clone.to_data() == sim.to_data() and clone.hero().area_bonus == hero.area_bonus, "Repeated restore neither heals nor compounds stats; derives ability effects")
	for index: int in range(300):
		sim.step()
		clone.step()
	check(clone.to_data() == sim.to_data(), "Upgraded simulation resumes deterministically")
	sim.pause_on_defeat = true
	sim._finish(false)
	check(sim.hero().health == 123 and sim.hero().max_health == 360 and sim.hero().cooldown == 4, "Defeat restores original health/timer with current purchased stats")
	check(sim.hero().area_bonus == hero.area_bonus and sim.unit().gold_rank(&"health") == 1, "Defeat preserves purchased ability effects and ranks")
	sim.chrono_break()
	check(sim.hero().health == 360 and sim.hero().attack == 36 and sim.hero().cooldown == 0, "Chrono heals to upgraded maximum and preserves purchases")
	sim.hero().health = 0
	sim.purchase_gold_upgrade(&"health")
	check(sim.hero().health == 0, "Stat refresh never resurrects a dead unit")
	sim.hero().health = 400
	sim.unit().gold_ranks.clear()
	sim._apply_progress(sim.hero())
	check(sim.hero().health == 300, "Lower maximum clamps current health")
	var limited: BattleSimulation = BattleSimulation.new()
	limited.unit().gold_ranks[&"health"] = 100
	limited.profile.gold = 1e15
	check(not limited.purchase_gold_upgrade(&"health") and limited.profile.gold == 1e15, "Gold maximum rank enforced without spending")
	_test_upgraded_actions()

func _test_upgraded_actions() -> void:
	var sim: BattleSimulation = BattleSimulation.new(71)
	sim.unit().level = 50
	sim.unit().level_points = 100
	sim.purchase_upgrade(&"heavy_meatballs")
	sim.purchase_upgrade(&"crushing_sweep")
	for index: int in range(3):
		sim.purchase_upgrade(&"wide_sweep")
	var definition: CombatantDefinition = sim.config.ally.duplicate()
	definition.critical_chance = 0.0
	sim.config = sim.config.duplicate()
	sim.config.ally = definition
	sim._apply_progress(sim.hero())
	var definitions: Dictionary = sim.config.definitions()
	definitions[definition.id] = definition
	var hero: CombatantState = sim.hero()
	var enemy: CombatantState = CombatantState.create(sim.config.balanced, 2, false, hero.position + Vector2(100, 0))
	enemy.health = 1000
	enemy.max_health = 1000
	enemy.attack = 0
	var actors: Array[CombatantState] = [hero, enemy]
	hero.cooldown = 20
	hero.action = &"basic"
	hero.target_id = 2
	hero.action_left = BattleSimulation.STEP
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(is_equal_approx(enemy.health, 967), "Heavy Meatballs affects actual Punch damage")
	hero.cooldown = 0
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(hero.pending_cooldown == 8 and hero.action == &"sweep", "Sweep captures cooldown on start")
	check(sim.purchase_upgrade(&"quick_stir") and hero.pending_cooldown == 8, "Purchase during cast preserves captured cooldown")
	enemy.position = hero.position + Vector2(210, 0)
	enemy.speed = 0
	hero.action_left = BattleSimulation.STEP
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(is_equal_approx(enemy.health, 917.5) and hero.cooldown == 8, "Expanded sector hits at 210 with upgraded coefficient and old cooldown")
	enemy.position = hero.position + Vector2(100, 0)
	hero.cooldown = 0
	CombatSystem.step(actors, definitions, sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	check(hero.pending_cooldown == 7.5, "Next cast uses purchased cooldown reduction")

func _test_upgrade_panel() -> void:
	var panel: UpgradePanel = preload("res://scenes/ui/upgrade_panel.tscn").instantiate()
	host_tree.root.add_child(panel)
	await host_tree.process_frame
	var sim: BattleSimulation = BattleSimulation.new()
	panel.bind(sim)
	panel.refresh(false)
	check(panel.gold_buttons.size() == sim.config.gold_upgrades.size() and panel.level_buttons.size() == 6, "UI renders configured catalogs")
	check(panel.gold_buttons[&"health"].disabled and panel.level_buttons[&"heavy_meatballs"].disabled, "UI disables unaffordable offers")
	sim.profile.gold = 10
	sim.unit().level = 2
	sim.unit().level_points = 1
	panel.refresh(false)
	check(not panel.gold_buttons[&"health"].disabled and not panel.level_buttons[&"heavy_meatballs"].disabled, "UI enables eligible offers")
	panel.gold_buttons[&"health"].pressed.emit()
	panel.level_buttons[&"heavy_meatballs"].pressed.emit()
	panel.refresh(false)
	check(sim.profile.gold == 0 and sim.hero().max_health == 330 and sim.hero().health == 300, "Gold button routes one purchase through model without healing")
	check(sim.unit().level_points == 0 and sim.unit().purchased_rank(&"heavy_meatballs") == 1, "Level button routes purchase through model")
	check(panel.level_buttons[&"heavy_meatballs"].text.contains("requires Lv 5"), "UI refresh shows next rank requirement")
	for id: StringName in [&"ability_power", &"critical_chance", &"magic_resistance"]:
		sim.profile.gold = sim.config.gold_upgrade_by_id(id).base_cost
		panel.refresh(false)
		panel.gold_buttons[id].pressed.emit()
		panel.refresh(false)
		check(sim.profile.gold == 0 and sim.unit().gold_rank(id) == 1, "New damage-stat button transacts once: " + id)
	for id: StringName in [&"gold", &"xp", &"souls"]:
		sim.profile.gold = sim.config.gold_upgrade_by_id(id).base_cost
		panel.refresh(false)
		check(not panel.gold_buttons[id].disabled and panel.gold_buttons[id].tooltip_text.contains("future kills"), "Reward UI exposes affordable offer and timing: " + id)
		panel.gold_buttons[id].pressed.emit()
		panel.refresh(false)
		check(sim.profile.gold == 0 and sim.unit().gold_rank(id) == 1 and panel.gold_buttons[id].text.contains("1/50"), "Reward UI buys once and refreshes rank: " + id)
	sim.profile.gold = 100
	panel.refresh(true)
	check(panel.gold_buttons[&"health"].disabled, "Save error blocks purchase controls")
	panel.queue_free()
	await host_tree.process_frame

func _test_navigation_and_field() -> void:
	for point: Vector2 in [Vector2.ZERO, Vector2(1280, 640), Vector2(340, 320), Vector2(1120, 240)]:
		check(FieldProjection.unproject(FieldProjection.project(point)).is_equal_approx(point), "Field projection roundtrip preserves logical position")
	var scene: Control = preload("res://scenes/main.tscn").instantiate()
	scene.persist_progress = false
	host_tree.root.add_child(scene)
	scene.set_physics_process(false)
	scene.set_process(false)
	await host_tree.process_frame
	await host_tree.process_frame
	var before: Dictionary = scene.simulation.to_data()
	check(not scene.panels.visible, "Field opens without permanent sidebar")
	scene.get_node("%MenuUnits").pressed.emit()
	check(scene.panels.visible and scene.panels.current_section == &"units" and scene.get_node("%UnitCard").visible, "Units navigation opens deployed roster")
	scene.get_node("%UnitCard").pressed.emit()
	check(scene.get_node("%UnitDetails").visible and not scene.upgrades.visible, "Unit selection opens stats")
	scene.get_node("%UpgradesTab").pressed.emit()
	check(scene.upgrades.visible and not scene.stats.visible, "Upgrade tab makes purchases directly accessible")
	scene.get_node("%MenuChrono").pressed.emit()
	check(scene.panels.current_section == &"chrono" and scene.chrono.is_visible_in_tree() and not scene.upgrades.is_visible_in_tree(), "Chrono page replaces unit page")
	scene.get_node("%MenuShop").pressed.emit()
	check(scene.panels.current_section == &"shop" and not scene.chrono.is_visible_in_tree(), "Global shop page opens independently")
	scene.get_node("%MenuShop").pressed.emit()
	check(not scene.panels.visible, "Second navigation click closes panel")
	check(scene.simulation.to_data() == before, "Navigation and inspection never mutate progress or battle")
	check(scene.global_shop.buttons.size() == scene.simulation.config.global_upgrades.size() and scene.chrono_shop.buttons.size() == 6, "Both shop panels instantiate their Resource catalogs")
	check(scene.global_shop.buttons[&"global_armor"].disabled and scene.chrono_shop.buttons[&"chrono_health"].disabled, "Unaffordable shop buttons are disabled")
	scene.simulation.profile.gold = 50
	scene.simulation.profile.shards = 1
	scene._refresh()
	check(not scene.global_shop.buttons[&"global_armor"].disabled and not scene.chrono_shop.buttons[&"chrono_health"].disabled, "Shop buttons react to independent balances")
	scene.global_shop.buttons[&"global_armor"].pressed.emit()
	scene.chrono_shop.buttons[&"chrono_health"].pressed.emit()
	scene._refresh()
	check(scene.simulation.profile.gold == 0 and scene.simulation.profile.shards == 0 and scene.simulation.hero().armor == 22 and scene.simulation.hero().max_health == 360, "Both UI purchases reach model and refresh stats")
	check(scene.global_shop.buttons[&"global_armor"].disabled and scene.chrono_shop.buttons[&"chrono_health"].text.contains("1/20"), "Shop UI refreshes rank and next affordability")
	scene.simulation.profile.gold = 140
	for id: StringName in [&"gold", &"xp", &"souls"]:
		scene.upgrades.gold_buttons[id].pressed.emit()
	scene._refresh()
	check(scene.stats.text.contains("Gold +0.25") and scene.stats.text.contains("XP +0.10") and scene.stats.text.contains("Souls +0.10"), "Unit stats display individual contributions separately from shared bonuses")
	scene.simulation.profile.gold = 1000
	scene.global_shop.buttons[&"global_ability_power"].pressed.emit()
	scene.global_shop.buttons[&"global_ability_power_multiplier"].pressed.emit()
	scene.global_shop.buttons[&"global_critical_chance"].pressed.emit()
	scene._refresh()
	check(scene.stats.text.contains("Ability Power  5.25") and scene.stats.text.contains("Critical  6.0%"), "Shared damage-stat buttons update effective unit stats")
	check(scene.stats.text.contains("Multi Hit  1") and scene.stats.text.contains("Multi Cast  1"), "Unit stats expose current repetition counts")
	scene.get_node("%MenuBattle").pressed.emit()
	scene.get_node("%Formation").pressed.emit()
	check(scene.arena.formation_visible and not scene.panels.visible, "Formation button returns to unobstructed field")
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.pressed = true
	click.button_index = MOUSE_BUTTON_LEFT
	scene.arena._update_transform()
	click.position = scene.arena.origin + FieldProjection.project(scene.simulation.config.slots[0]) * scene.arena.scale_factor
	scene.arena._gui_input(click)
	check(scene.simulation.unit().slot == 0, "Projected ground marker selects correct logical slot")
	scene.arena.formation_visible = false
	scene.arena.ordered_actors.assign(scene.simulation.actors)
	click.position = scene.arena.origin + scene.arena._actor_rect(scene.simulation.hero()).get_center() * scene.arena.scale_factor
	scene.arena._gui_input(click)
	check(scene.panels.current_section == &"units" and scene.get_node("%UnitDetails").visible, "Clicking full-body sprite opens its unit details")
	var escape: InputEventAction = InputEventAction.new()
	escape.action = &"ui_cancel"
	escape.pressed = true
	scene.panels._unhandled_key_input(escape)
	check(not scene.panels.visible, "Escape closes current panel")
	scene.get_node("%MenuUnits").pressed.emit()
	scene.simulation.profile.dust = 5
	scene._refresh()
	check(not scene.get_node("%SummonButton").disabled and scene.get_node("%SummonButton").text.contains("5 Dust"), "Collection exposes the configured summon cost")
	scene.get_node("%SummonButton").pressed.emit()
	check(scene.simulation.profile.dust == 0 and scene.simulation.profile.copies.size() == 2 and scene.get_node("%UnitDetails").visible, "Summon UI creates and selects a fresh John copy")
	check(scene.get_node("%DeployToggle").text.contains("Deploy") and not scene.get_node("%DeployToggle").disabled, "Fresh summon is shown in reserve and can be deployed")
	scene.get_node("%DeployToggle").pressed.emit()
	check(scene.simulation.deployed_units().size() == 2 and scene.simulation.allied_actors().size() == 2, "Collection UI deploys the summoned copy into the squad")
	scene.get_node("%BackToUnits").pressed.emit()
	check(scene.get_node("%RosterList").get_child_count() == 1 and scene.get_node("%CollectionSummary").text.contains("2 owned"), "Roster renders every independently owned copy")
	check(ArenaView.JOHN.texture.get_image().detect_alpha() != Image.ALPHA_NONE and ArenaView.STONE.texture.get_image().detect_alpha() != Image.ALPHA_NONE and ArenaView.EMBER.texture.get_image().detect_alpha() != Image.ALPHA_NONE, "Field sprite assets contain alpha transparency")
	scene.queue_free()
	await host_tree.process_frame
