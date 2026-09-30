extends RefCounted
## Synthetic content exists only in these fixtures. No new character enters the roster.
var suite: Variant

func run(runner: Variant) -> void:
	suite = runner
	_chrono()
	_priorities()
	_healing_and_resurrection()
	_statuses()
	_summons_and_support()
	_offline()
	_migration()
	_branches()
	_projectiles_and_ordering()
	_death_and_reward_effects()

func check(value: bool, message: String) -> void:
	suite.check(value, message)

func near(a: float, b: float, message: String) -> void:
	suite.near(a, b, message)

func fixture() -> BattleSimulation:
	var sim: BattleSimulation = BattleSimulation.new(732)
	sim.config = sim.config.duplicate(true)
	sim.config.ally = sim.config.ally.duplicate(true)
	sim.config.ally.kit = null
	sim.config.ally.forms.clear()
	sim.config.ally.ability = null
	sim.config.ally.active_abilities.clear()
	sim.config.ally.critical_chance = 0.0
	sim._create_allies()
	sim.hero().critical_chance = 0.0
	return sim

func action(id: StringName, kind: String, target: String = "self") -> AbilityDefinition:
	var ability: AbilityDefinition = AbilityDefinition.new()
	ability.id = id
	ability.display_name = String(id)
	ability.target_kind = target
	ability.range_radius = 1000
	var effect: AbilityEffectDefinition = AbilityEffectDefinition.new()
	effect.kind = kind
	ability.effects.append(effect)
	return ability

func tick(sim: BattleSimulation, count: int = 1) -> Dictionary:
	var result: Dictionary = {}
	for index: int in range(count):
		result = CombatSystem.step(sim.actors, sim.config.definitions(), sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
	return result

func second(sim: BattleSimulation) -> CombatantState:
	var copy: UnitProgress = sim.profile.create_copy(sim.unit().species_id)
	check(sim.set_copy_deployed(copy.id, true), "Fixture deploys independent second copy")
	return sim.actor_for_copy(copy.id)

func _chrono() -> void:
	var sim: BattleSimulation = BattleSimulation.new()
	check(sim.config.chrono_upgrades.size() == 23, "Complete initial Chrono catalog")
	sim.profile.shards = 1000.0
	check(sim.purchase_shop_upgrade(&"chrono", &"chrono_multi_hit"), "Buy Multi Hit")
	check(sim.purchase_shop_upgrade(&"chrono", &"chrono_multi_cast"), "Buy Multi Cast")
	check(sim.hero().multi_hit == 2 and sim.hero().multi_cast == 2, "Chrono repetitions apply")
	check(not sim.purchase_shop_upgrade(&"chrono", &"chrono_multi_hit"), "Multi Hit has one rank")
	check(sim.purchase_shop_upgrade(&"chrono", &"chrono_allied_slot") and sim.allied_limit() == 4, "Fourth allied position unlocks")
	for index: int in range(3):
		var copy: UnitProgress = sim.profile.create_copy(sim.unit().species_id)
		check(sim.set_copy_deployed(copy.id, true), "Expanded squad deploys")
	check(SaveStore.validate(sim.to_data()), "Four-copy snapshot validates")
	sim.chrono_break()
	check(sim.allied_limit() == 4 and sim.hero().multi_hit == 2, "Chrono keeps structural purchases")
	var cost: float = sim.profile.shards
	check(not sim.purchase_shop_upgrade(&"chrono", &"chrono_allied_slot") and sim.profile.shards == cost, "Slot cap never charges twice")
	sim.config = sim.config.duplicate(true)
	var gated: StatUpgradeDefinition = sim.config.shop_upgrade(&"chrono", &"chrono_magic_attack").duplicate(true)
	for index: int in range(sim.config.chrono_upgrades.size()):
		if sim.config.chrono_upgrades[index].id == gated.id:
			sim.config.chrono_upgrades[index] = gated
	gated.required_record = 10
	check(not sim.shop_offer(&"chrono", &"chrono_magic_attack").available, "Configurable shop record gate")
	sim.record_wave = 10
	check(sim.purchase_shop_upgrade(&"chrono", &"chrono_magic_attack"), "Shop gate unlocks at record")

func _priorities() -> void:
	var sim: BattleSimulation = suite.model(2)
	suite.enemy(sim)
	sim.hero().health = 100
	sim.hero().kit_state.sauce = 5
	check(sim.set_ability_priority(sim.unit().id, &"sweep", 100), "Player sets ability priority")
	tick(sim)
	check(sim.hero().action == &"sweep", "Higher Sweep priority overrides emergency default")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(sim.to_data())
	check(clone.unit().ability_priorities == sim.unit().ability_priorities, "Priorities restore per copy")
	check(not sim.set_ability_priority(sim.unit().id, &"fake", 50), "Unknown ability priority rejected")
	check(not sim.set_ability_priority(sim.unit().id, &"surge", 101), "Invalid priority rejected")
	sim = suite.model(2)
	suite.enemy(sim)
	sim.hero().health = 100
	sim.hero().kit_state.sauce = 5
	for id: StringName in [&"sweep", &"guard", &"surge"]:
		sim.set_ability_priority(sim.unit().id, id, 50)
	tick(sim)
	check(sim.hero().action == &"sweep", "Equal priorities prefer first unlocked active")
	sim.hero().clear_action()
	sim.hero().cooldown = 99
	tick(sim)
	check(sim.hero().action == &"guard", "Equal personal priorities prefer Guard before Surge")

func _healing_and_resurrection() -> void:
	var sim: BattleSimulation = fixture()
	var other: CombatantState = second(sim)
	var heal: AbilityDefinition = action(&"fixture_heal", "heal", "injured_ally")
	heal.effects[0].flat_healing = 10.0
	sim.config.ally.active_abilities.append(heal)
	sim.hero().health = 160
	other.health = 32
	tick(sim)
	near(other.health, 52, "Both healers choose lowest health percentage")
	near(sim.hero().health, 160, "Higher percentage ally not healed")
	check(sim.hero().ability_cooldowns[heal.id] > 4.9, "Independent healing cooldown starts at completion")
	other.health = 0
	check(AbilitySystem.target_for(sim.hero(), sim.actors, heal, sim.unit(), sim.rng) == sim.hero(), "Ordinary heal excludes dead ally")
	var revive: AbilityDefinition = action(&"fixture_revive", "resurrect", "dead_ally")
	sim.config.ally.active_abilities.append(revive)
	tick(sim)
	near(other.health, other.max_health * 0.1, "Explicit resurrection restores ten percent")
	check(other.action.is_empty(), "Revival clears interrupted action")
	sim.hero().health = sim.hero().max_health
	other.health = other.max_health
	sim.hero().ability_cooldowns.clear()
	other.ability_cooldowns.clear()
	tick(sim)
	check(sim.hero().ability_cooldowns.is_empty(), "No injured/dead target leaves spells ready")
	# A ready valid active interrupts an ordinary basic cycle.
	other.health = 1
	sim.hero().action = &"basic"
	sim.hero().action_left = 10
	heal.cast_time = 0.5
	tick(sim)
	check(sim.hero().action == heal.id, "Healing active interrupts basic attack")
	var locked_cooldown: float = sim.hero().pending_cooldown
	sim.hero().haste = 1000
	tick(sim, 29)
	near(sim.hero().ability_cooldowns[heal.id], locked_cooldown, "Haste changes do not change pending cooldown")
	var damage: Dictionary = {other.id: other.health}
	CombatMath.resolve(sim.actors, damage, {other.id: 10000.0})
	check(not other.alive(), "Lethal damage wins over simultaneous ordinary healing")

func _statuses() -> void:
	var sim: BattleSimulation = fixture()
	var mark: StatusDefinition = StatusDefinition.new()
	mark.id = &"fixture_mark"
	mark.display_name = "Fixture mark"
	mark.duration = 0.05
	mark.max_stacks = 2
	mark.additive["armor"] = -10.0
	mark.multiplier["attack"] = 0.2
	check(mark.validation_errors().is_empty(), "Configurable status validates")
	var base_attack: float = sim.hero().attack
	StatusSystem.add(sim.hero(), mark, 123)
	StatusSystem.add(sim.hero(), mark, 123)
	StatusSystem.add(sim.hero(), mark, 123)
	StatusSystem.apply_stats(sim.hero())
	near(sim.hero().attack, base_attack * 1.4, "Status stacks respect cap")
	StatusSystem.apply_stats(sim.hero())
	near(sim.hero().attack, base_attack * 1.4, "Status rebuild does not compound")
	check(SaveStore.validate(sim.to_data(), sim.config), "Active status snapshot validates")
	var clone: BattleSimulation = fixture()
	clone.restore(sim.to_data())
	check(clone.to_data() == sim.to_data(), "Status snapshot restores without multiplication")
	tick(sim, 4)
	near(sim.hero().attack, base_attack, "Expired status restores baseline")
	check(sim.hero().statuses.is_empty(), "Expired status removed")
	var bad: Dictionary = clone.to_data()
	bad.actors[0].statuses[0].remaining = NAN
	check(not SaveStore.validate(bad, sim.config), "Invalid status timer rejected")
	bad = clone.to_data()
	bad.actors[0].ability_cooldowns[&"unknown"] = 1.0
	check(not SaveStore.validate(bad, sim.config), "Unknown serialized cooldown rejected")

func _summons_and_support() -> void:
	var sim: BattleSimulation = fixture()
	sim.config.ally.enemy_support_role = true
	var support: CombatantState = second(sim)
	var support_id: String = support.copy_id
	check(sim.set_copy_role(support_id, true), "Dual-role copy moves to enemy support")
	check(support.support and not support.allied, "Enemy support role is explicit")
	check(Targeting.opponents(sim.hero(), sim.actors).is_empty(), "Enemy support is not attackable")
	var summon: AbilityDefinition = action(&"fixture_summon", "summon")
	summon.effects[0].summon = sim.config.balanced
	summon.effects[0].summon_count = 3
	summon.effects[0].summon_limit = 2
	summon.effects[0].summon_duration = 60.0
	sim.config.ally.active_abilities.append(summon)
	check(summon.validation_errors().is_empty(), "Summoning contract validates")
	sim._spawn_summons(support, summon.effects[0])
	check(sim.actors.size() == 4, "Summoning capped by owner")
	check(not AbilitySystem.can_summon(support, sim.actors, summon), "Full summon limit leaves ability ready")
	check(not sim.has_living_enemies(), "Summons do not hold the natural wave open")
	var summoned: CombatantState = sim.actors[2]
	var health: float = summoned.max_health
	sim.wave = 5
	near(summoned.max_health, health, "Surviving summon keeps spawn-wave stats")
	check(SaveStore.validate(sim.to_data(), sim.config), "Support and summons serialize")
	check(sim.set_copy_role(support_id, false, 1), "Support can return to allied role during preparation")
	check(sim.actors.size() == 2, "Role switch removes all owned summons")
	sim._spawn_summons(sim.hero(), summon.effects[0])
	sim.hero().health = 0
	support.health = 0
	check(not sim.has_living_allies(), "Allied summons cannot prevent deployed-squad defeat")
	sim.chrono_break()
	check(sim.actors.size() == 2, "Chrono removes all summons")

func _offline() -> void:
	var sim: BattleSimulation = BattleSimulation.new(456)
	sim.start()
	var online: BattleSimulation = BattleSimulation.new()
	online.restore(sim.to_data())
	var catchup: OfflineSimulation = OfflineSimulation.new(sim, 2.0)
	while not catchup.pump(20):
		pass
	online.advance(2.0)
	var offline_data: Dictionary = sim.to_data()
	var online_data: Dictionary = online.to_data()
	near(offline_data.accumulator, online_data.accumulator, "Offline preserves fractional step accumulator")
	offline_data.accumulator = online_data.accumulator
	check(offline_data == online_data, "Offline uses exact online simulation and RNG")
	near(catchup.report.seconds, 2.0, "Offline processes requested elapsed time")
	sim.config = sim.config.duplicate(true)
	sim.config.offline_max_seconds = 0.1
	catchup = OfflineSimulation.new(sim, 1000000.0)
	check(catchup.total_steps == 6, "Offline time cap is configurable")
	catchup.cancel()
	check(catchup.finished and not sim.offline_running, "Player can stop catch-up")
	var frozen: Dictionary = sim.to_data()
	catchup = OfflineSimulation.new(sim, -100)
	check(catchup.finished and sim.to_data() == frozen, "Clock rollback grants no time")
	sim.chrono_break()
	frozen = sim.to_data()
	catchup = OfflineSimulation.new(sim, 900)
	check(catchup.finished and sim.to_data() == frozen, "Preparation does not progress offline")
	sim = BattleSimulation.new()
	sim.start()
	sim.hero().health = 0
	catchup = OfflineSimulation.new(sim, 900)
	catchup.pump()
	check(catchup.finished and sim.phase == &"paused" and catchup.report.defeats == 1, "Offline stops at first defeat regardless of online setting")
	check(not sim.pause_on_defeat, "Offline does not change persistent defeat preference")
	sim = BattleSimulation.new()
	sim.start()
	sim.pause_requested = true
	sim.spawn_index = 12
	sim.actors.resize(1)
	catchup = OfflineSimulation.new(sim, 900)
	catchup.pump()
	check(catchup.finished and catchup.report.victories == 1 and sim.phase == &"paused", "Offline respects queued boundary pause")

func _migration() -> void:
	var sim: BattleSimulation = BattleSimulation.new()
	sim.profile.gold = 123.5
	sim.unit().level = 10
	sim.evolve_copy(sim.unit().id)
	sim.start()
	var old: Dictionary = sim.to_data()
	for copy: Dictionary in old.profile.copies:
		copy.erase(&"ability_priorities")
		copy.erase(&"enemy_support")
		copy.erase(&"evolution_path")
	old.erase(&"projectiles")
	for actor: Dictionary in old.actors + old.attempt_snapshot:
		for key: StringName in [&"ability_cooldowns", &"statuses", &"status_base", &"summoner_id", &"summon_remaining", &"reward_multiplier", &"support"]:
			actor.erase(key)
	var migrated: Dictionary = SaveStore._migrate_v8(old)
	check(SaveStore.validate(migrated), "V8 migration adds independent runtime defaults")
	near(migrated.profile.gold, 123.5, "V8 migration preserves wallet")
	check(migrated.profile.copies[0].evolution == 1 and migrated.phase == &"battle", "V8 migration preserves evolution and attempt")
	var store: SaveStore = SaveStore.new("res://tests/demo_test_base.save")
	check(store.write_state(migrated) == OK, "V9 save writes")
	check(store.load_state() == migrated and store.loaded_saved_at > 0, "V9 timestamp and payload roundtrip")
	var payload: PackedByteArray = var_to_bytes(old)
	var file: FileAccess = FileAccess.open(store.path, FileAccess.WRITE)
	file.store_var({"version": 8, "saved_at": 1.0, "payload": payload, "checksum": SaveStore._hash(payload)}, false)
	file.close()
	check(store.load_state() == migrated and store.loaded_saved_at == 0.0, "V8 never receives retroactive offline progress")
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)

func _branches() -> void:
	var sim: BattleSimulation = fixture()
	second(sim)
	for id: StringName in [&"left", &"right"]:
		var branch: EvolutionDefinition = EvolutionDefinition.new()
		branch.id = id
		branch.required_level = 2
		branch.form = sim.config.ally.duplicate(true)
		branch.form.evolution_options.clear()
		branch.form.display_name = String(id)
		# Evolution cannot silently increase authored base stats.
		branch.form.max_health = 9999.0
		sim.config.ally.evolution_options.append(branch)
	check(sim.evolution_choices(sim.unit().id).size() == 2, "Branch choices are visible")
	check(not sim.evolve_copy(sim.unit().id, &"left"), "Branch level gate")
	sim.unit().level = 2
	sim.profile.copies[1].level = 2
	check(not sim.evolve_copy(sim.unit().id), "Multiple branches require explicit selection")
	check(sim.evolve_copy(sim.unit().id, &"left"), "Copy chooses first permanent branch")
	check(sim.evolve_copy(sim.profile.copies[1].id, &"right"), "Another copy chooses different branch")
	check(sim.config.definition_for(sim.unit()).display_name == "left", "Branch resolves by stable ID")
	near(sim.hero().max_health, 320.0, "Branch adds no base maximum health")
	check(not sim.evolve_copy(sim.unit().id, &"right"), "Permanent branch cannot be switched")
	check(SaveStore.validate(sim.to_data(), sim.config), "Branched profile validates")
	var clone: BattleSimulation = fixture()
	clone.config = sim.config
	clone.restore(sim.to_data())
	check(clone.to_data() == sim.to_data(), "Independent branches survive restore")
	var bad: Dictionary = sim.to_data()
	bad.profile.copies[0].evolution_path[0] = "unknown"
	check(not SaveStore.validate(bad, sim.config), "Unknown branch rejected")
	# Existing linear species can acquire authored branches later without resetting copies.
	sim = BattleSimulation.new()
	sim.config = sim.config.duplicate(true)
	sim.config.ally = sim.config.ally.duplicate(true)
	sim.config.ally.forms[0] = sim.config.ally.forms[0].duplicate(true)
	var appended: EvolutionDefinition = EvolutionDefinition.new()
	appended.id = &"future_branch"
	appended.required_level = 10
	appended.form = sim.config.ally.forms[0].duplicate(true)
	appended.form.evolution_options.clear()
	sim.config.ally.forms[0].evolution_options.append(appended)
	sim.unit().level = 10
	check(sim.evolve_copy(sim.unit().id), "Existing copy keeps legacy linear evolution")
	check(sim.evolve_copy(sim.unit().id, appended.id), "Branch can be added after a legacy form")
	check(sim.unit().evolution_path == PackedStringArray(["__linear_1", "future_branch"]), "Legacy stage becomes stable branch prefix")
	check(SaveStore.validate(sim.to_data(), sim.config), "Legacy-to-branch path validates")

func _projectiles_and_ordering() -> void:
	var sim: BattleSimulation = fixture()
	var spell: AbilityDefinition = action(&"fixture_projectile", "damage", "opponent")
	spell.effects[0].damage = DamageDefinition.new()
	spell.effects[0].damage.can_crit = false
	spell.effects[0].damage_delay = 0.1
	sim.config.ally.active_abilities.append(spell)
	var opponent: CombatantState = CombatantState.create(sim.config.balanced, sim.next_id, false, sim.hero().position + Vector2(20, 0))
	sim.next_id += 1
	opponent.health = 100
	opponent.max_health = 100
	opponent.armor = 0
	sim.actors.append(opponent)
	CombatSystem.step(sim.actors, sim.config.definitions(), sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP, sim.projectiles)
	check(sim.projectiles.size() == 1, "Projectile generated as independent packet")
	near(opponent.health, 100, "Delayed projectile causes no immediate damage")
	check(SaveStore.validate(sim.to_data(), sim.config), "In-flight projectile validates")
	sim.hero().health = 0
	sim.hero().attack = 9999
	opponent.armor = 100
	for index: int in range(6):
		CombatSystem.step(sim.actors, sim.config.definitions(), sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP, sim.projectiles)
	near(opponent.health, 90, "Launched potency survives source death; impact reads current defense")
	check(sim.projectiles.is_empty(), "Resolved projectile removed")
	sim.chrono_break()
	check(sim.projectiles.is_empty(), "Chrono clears generated effects")
	# Explicit internal order sees the mark; unrelated same-tick hit sees old defense.
	sim = fixture()
	var mark_spell: AbilityDefinition = action(&"fixture_mark_hit", "status", "opponent")
	mark_spell.effects[0].status = StatusDefinition.new()
	mark_spell.effects[0].status.id = &"armor_mark"
	mark_spell.effects[0].status.display_name = "Armor mark"
	mark_spell.effects[0].status.additive["armor"] = -100.0
	var hit: AbilityEffectDefinition = AbilityEffectDefinition.new()
	hit.kind = "damage"
	hit.damage = DamageDefinition.new()
	hit.damage.can_crit = false
	mark_spell.effects.append(hit)
	sim.config.ally.active_abilities.append(mark_spell)
	opponent = CombatantState.create(sim.config.balanced, sim.next_id, false, sim.hero().position + Vector2(20, 0))
	sim.next_id += 1
	opponent.max_health = 1000
	opponent.health = 1000
	opponent.armor = 100
	opponent.attack = 0
	sim.actors.append(opponent)
	tick(sim)
	near(opponent.health, 980, "Explicit mark-then-hit order uses new defense")
	near(opponent.armor, 0, "Mark becomes active after simultaneous resolution")

func _death_and_reward_effects() -> void:
	var sim: BattleSimulation = fixture()
	var mark: StatusDefinition = StatusDefinition.new()
	mark.id = &"reward_mark"
	mark.display_name = "Reward mark"
	mark.additive["gold"] = 0.5
	mark.multiplier["gold"] = 0.25
	mark.multiplier["attack"] = 0.1
	StatusSystem.add(sim.hero(), mark, 123)
	sim.hero().health = 0
	sim.hero().ability_cooldowns[&"test_timer"] = 1.0
	tick(sim, 6)
	near(sim.hero().ability_cooldowns[&"test_timer"], 0.9, "Dead-copy cooldown still advances")
	near(sim.hero().statuses[0].remaining, 4.9, "Dead-copy status duration still advances")
	StatusSystem.on_death(sim.hero())
	check(sim.hero().statuses.size() == 1, "Generic status persists through death by default")
	mark.ends_on_death = true
	mark.id = &"death_only"
	StatusSystem.add(sim.hero(), mark, 123)
	# add() rejects dead recipients; fixture revives explicitly before adding.
	sim.hero().health = 1
	StatusSystem.add(sim.hero(), mark, 123)
	StatusSystem.on_death(sim.hero())
	check(sim.hero().statuses.size() == 1, "Only declared death-ending effect is removed")
	var base: float = sim.reward_value(sim.config.balanced, "gold")
	near(sim.reward_value(sim.config.balanced, "gold", sim.hero().statuses), (base + 0.5) * 1.25, "Reward marks preserve fractional additive and multiplier pools")
	var other: CombatantState = second(sim)
	sim.config.ally.enemy_support_role = true
	check(sim.set_copy_role(other.copy_id, true), "Reward fixture switches support role")
	sim.profile.copy_by_id(other.copy_id).gold_ranks[&"gold_income"] = 1
	var gold_upgrade: GoldUpgradeDefinition = null
	for offer: GoldUpgradeDefinition in sim.config.gold_upgrades:
		if offer.stat == "gold":
			gold_upgrade = offer
			break
	sim.profile.copy_by_id(other.copy_id).gold_ranks.clear()
	sim.profile.copy_by_id(other.copy_id).gold_ranks[gold_upgrade.id] = 1
	near(sim.reward_value(sim.config.balanced, "gold"), base + gold_upgrade.increment, "Enemy-support copy contributes Gold")
	sim.start()
	sim.pending_xp = 2.0
	sim.pause_requested = true
	sim._finish(true)
	near(sim.profile.copy_by_id(other.copy_id).experience, 2, "Enemy-support copy receives full eligible XP")
	check(SaveStore.validate(sim.to_data(), sim.config), "Support paused snapshot validates")
