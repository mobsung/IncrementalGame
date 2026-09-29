extends SceneTree
## Current roster regression suite. All saves and UI profiles are isolated.

var checks: int = 0
var failures: int = 0
var host_tree: SceneTree

func _initialize() -> void:
	host_tree = self
	call_deferred("_run", true)

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + message)

func near(a: float, b: float, message: String) -> void:
	check(is_equal_approx(a, b), message + " (%f vs %f)" % [a, b])

func _run(quit_after: bool = false) -> void:
	_content_and_evolution()
	_actions()
	_defense_and_passives()
	_boundaries()
	_shared_systems()
	_persistence()
	_animations()
	await _ui()
	print("RESULT: %d checks, %d failures" % [checks, failures])
	if quit_after:
		quit(0 if failures == 0 else 1)

func model(stage: int = 0) -> BattleSimulation:
	var sim: BattleSimulation = BattleSimulation.new(382)
	if stage > 0:
		sim.unit().level = 25
		sim.unit().level_points = 24
		for index: int in range(stage):
			check(sim.evolve_copy(sim.unit().id), "Fixture evolves")
	sim.hero().critical_chance = 0.0
	return sim

func enemy(sim: BattleSimulation, distance: float = 80.0) -> CombatantState:
	var actor: CombatantState = CombatantState.create(sim.config.balanced, sim.next_id, false,
		sim.hero().position + Vector2(distance, 0))
	sim.next_id += 1
	actor.max_health = 1000
	actor.health = 1000
	actor.attack = 0
	actor.armor = 0
	actor.attack_speed = 0.01
	sim.actors.append(actor)
	return actor

func ticks(sim: BattleSimulation, count: int) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for index: int in range(count):
		var result: Dictionary = CombatSystem.step(sim.actors, sim.config.definitions(), sim.copy_map(), sim.config, sim.rng, BattleSimulation.STEP)
		events.append_array(result.events)
	return events

func _content_and_evolution() -> void:
	var sim: BattleSimulation = model()
	check(sim.config.validation_errors().is_empty(), "All authored content validates")
	check(sim.profile.copies.size() == 1 and sim.unit().evolution == 0, "Exactly one starter")
	check(sim.unit().species_id == &"spaghetti_golem" and sim.unit().level == 1, "Starter species and level")
	check(sim.config.definition_for(sim.unit()).display_name == "Noodle Squire", "Base name")
	near(sim.hero().max_health, 320, "Base health")
	near(sim.hero().attack, 20, "Base attack")
	near(sim.hero().armor, 12, "Base armor")
	near(sim.hero().ability_power, 20, "Base AP")
	check(not sim.evolve_copy(sim.unit().id), "Evolution level gate")
	sim.unit().level_points = 10
	check(sim.purchase_upgrade(&"sauce_infusion"), "First form upgrade")
	check(not sim.purchase_upgrade(&"sauce_infusion"), "First form cap")
	check(not sim.purchase_upgrade(&"thickened_glaze"), "Guard upgrade locked")
	sim.unit().level = 10
	sim.profile.gold = 100
	check(sim.purchase_gold_upgrade(&"health"), "Gold health")
	sim.hero().health = 100
	var xp: float = sim.unit().experience
	check(sim.evolve_copy(sim.unit().id), "Manual evolution at level 10")
	check(sim.unit().level_points == 10 and sim.unit().upgrade_ranks.is_empty(), "Evolution refunds points and resets ranks")
	check(sim.unit().gold_rank(&"health") == 1 and sim.unit().experience == xp, "Evolution preserves Gold and XP")
	near(sim.hero().health, 100, "Evolution does not heal")
	near(sim.hero().max_health, 350, "Evolution adds no base stats")
	check(sim.config.definition_for(sim.unit()).display_name == "Saucebound Knight", "Second form")
	check(sim.purchase_upgrade(&"thickened_glaze") and sim.purchase_upgrade(&"thickened_glaze"), "Second form guard cap")
	check(not sim.purchase_upgrade(&"thickened_glaze"), "Second form capped")
	sim.unit().level = 25
	sim.start()
	check(not sim.evolve_copy(sim.unit().id), "Deployed evolution blocked in battle")
	sim.pause_requested = true
	sim._finish(true)
	check(sim.evolve_copy(sim.unit().id), "Evolution allowed between attempts")
	check(sim.config.definition_for(sim.unit()).display_name == "Spaghetti Golem", "Final form")
	check(not sim.evolve_copy(sim.unit().id), "No fourth form")
	check(SaveStore.validate(sim.to_data()), "Evolved paused snapshot validates")
	for form: Resource in [sim.config.ally] + sim.config.ally.forms:
		check(form.validation_errors().is_empty(), "Form validates: " + form.display_name)
		check(form.visual.texture.get_image().detect_alpha() != Image.ALPHA_NONE, "Transparent sprite: " + form.display_name)

func _actions() -> void:
	var sim: BattleSimulation = model(1)
	var target: CombatantState = enemy(sim)
	sim.hero().cooldown = 99
	ticks(sim, 14)
	near(target.health, 1000, "Jab waits for impact")
	ticks(sim, 1)
	near(target.health, 980, "Jab impact at quarter cycle")
	check(sim.hero().kit_state.sauce == 1, "One Sauce per successful Jab")
	ticks(sim, 45)
	near(target.health, 980, "Recovery prevents repeated Jab damage")
	check(sim.hero().action.is_empty(), "Full action takes one second")
	sim = model(1)
	target = enemy(sim)
	sim.hero().cooldown = 99
	ticks(sim, 1)
	target.position += Vector2(500, 0)
	ticks(sim, 59)
	near(target.health, 1000, "Lost Jab target receives no damage")
	check(sim.hero().kit_state.sauce == 0, "Miss creates no Sauce")
	sim = model(1)
	target = enemy(sim)
	sim.hero().cooldown = 99
	sim.hero().multi_hit = 3
	ticks(sim, 15)
	near(target.health, 940, "Multi Hit damages three times")
	check(sim.hero().kit_state.sauce == 1, "Multi Hit creates one Sauce")
	sim = model(2)
	for index: int in range(4):
		enemy(sim, 60 + index * 10)
	ticks(sim, 23)
	near(sim.actors[1].health, 1000, "Sweep waits 0.4 seconds")
	ticks(sim, 1)
	for index: int in range(1, 4):
		near(sim.actors[index].health, 970, "Final Sweep coefficient")
	near(sim.actors[4].health, 1000, "Sweep cap is three targets")
	check(sim.hero().kit_state.sauce == 1, "AoE creates one Sauce")
	ticks(sim, 12)
	check(sim.hero().action.is_empty(), "Sweep recovery ends at 0.6 seconds")
	sim = model(1)
	target = enemy(sim, 150)
	sim.hero().multi_cast = 3
	ticks(sim, 24)
	near(target.health, 922, "Sweep reaches beyond Jab range and Multi Cast repeats")
	check(sim.hero().kit_state.sauce == 1, "Multi Cast creates one Sauce")
	sim = model(1)
	target = enemy(sim)
	sim.hero().cooldown = 99
	sim.hero().multi_hit = 3
	target.health = 1
	var second: CombatantState = enemy(sim, 90)
	ticks(sim, 15)
	check(not target.alive(), "First multi hit kills")
	near(second.health, 960, "Remaining multi hits retarget")
	check(sim.hero().kit_state.sauce == 1, "Retarget does not duplicate Sauce")
	sim = model(0)
	target = enemy(sim)
	ticks(sim, 240)
	check(sim.hero().kit_state.sauce == 0, "First form cannot generate Sauce")

func _defense_and_passives() -> void:
	var sim: BattleSimulation = model(0)
	sim.hero().health = 100
	ticks(sim, 239)
	near(sim.hero().health, 100, "Simmer waits four seconds")
	ticks(sim, 1)
	near(sim.hero().health, 106.8, "Base Simmer formula")
	sim = model(2)
	sim.hero().health = 200
	sim.hero().kit_state.sauce = 5
	sim.hero().kit_state.guard_cooldown = 12.0
	ticks(sim, 240)
	near(sim.hero().health, 212.4, "Final Simmer with five Sauce")
	sim = model(1)
	sim.hero().health = 200
	sim.hero().kit_state.sauce = 2
	ticks(sim, 20)
	near(sim.hero().health, 200, "Guard waits for cast")
	ticks(sim, 1)
	near(sim.hero().health, 214.6, "Guard heals HP plus AP")
	check(sim.hero().kit_state.sauce == 2, "Guard consumes no Sauce")
	near(sim.hero().attack, 22.4, "Stack and Guard attack bonuses add")
	near(sim.hero().armor, 13.68, "Guard armor bonus")
	check(sim.hero().kit_state.guard_duration > 5.9, "Guard buff duration")
	sim.hero().kit_state.simmer_elapsed = 4.0 - BattleSimulation.STEP
	ticks(sim, 1)
	near(sim.hero().health, 231.4, "Guard doubles Simmer tick")
	sim.profile.gold = 1000
	sim.purchase_gold_upgrade(&"attack")
	near(sim.hero().attack, 25.76, "Purchase during buff rebuilds once")
	sim._apply_progress(sim.hero())
	near(sim.hero().attack, 25.76, "Repeated rebuild does not compound")
	sim = model(2)
	sim.hero().health = 100
	sim.hero().kit_state.sauce = 5
	ticks(sim, 1)
	check(sim.hero().action == &"surge", "Surge has priority over Guard")
	ticks(sim, 29)
	near(sim.hero().health, 135.6, "Surge heal formula")
	check(sim.hero().kit_state.sauce == 1, "Surge consumes four stacks")
	near(sim.hero().attack, 24.2, "Surge immediately uses remaining Sauce")
	sim.hero().kit_state.sauce = 5
	sim.hero().kit_state.guard_duration = 6.0
	sim.unit().upgrade_ranks[&"thickened_glaze"] = 3
	sim._apply_progress(sim.hero())
	near(sim.hero().attack, 27.0, "Combined attack cap")
	near(sim.hero().armor, 16.56, "Combined armor with upgrades")
	sim = model(2)
	sim.hero().health = 100
	sim.hero().kit_state.sauce = 4
	ticks(sim, 1)
	sim.hero().kit_state.sauce = 3
	ticks(sim, 29)
	near(sim.hero().health, 100, "Surge rechecks Sauce at effect")
	check(sim.hero().kit_state.surge_cooldown == 0.0, "Cancelled effect starts no cooldown")
	sim = model(2)
	var attacker: CombatantState = enemy(sim, 20)
	sim.hero().health = 5
	sim.hero().kit_state.simmer_elapsed = 4.0 - BattleSimulation.STEP
	attacker.attack = 1000
	attacker.action = &"basic"
	attacker.action_left = BattleSimulation.STEP
	attacker.target_id = sim.hero().id
	ticks(sim, 1)
	check(not sim.hero().alive(), "Lethal damage wins over same-tick healing")
	check(sim.hero().kit_state.sauce == 0 and sim.hero().kit_state.simmer_elapsed == 0.0, "Death clears Sauce and tick progress")

func _boundaries() -> void:
	var sim: BattleSimulation = model(2)
	sim.hero().haste = 10000
	sim.hero().health = 100
	sim.hero().kit_state.sauce = 5
	ticks(sim, 30)
	near(sim.hero().kit_state.surge_cooldown, 16, "Surge cooldown floor")
	sim = model(1)
	sim.hero().haste = 10000
	sim.hero().health = 200
	sim.hero().kit_state.sauce = 2
	ticks(sim, 21)
	near(sim.hero().kit_state.guard_cooldown, 8, "Guard cooldown floor")
	sim = model(2)
	sim.hero().haste = 10000
	enemy(sim)
	ticks(sim, 24)
	near(sim.hero().cooldown, 4, "Sweep cooldown floor")
	sim = model(2)
	sim.hero().kit_state.sauce = 5
	sim.hero().kit_state.simmer_elapsed = 3.0
	sim.start()
	check(sim.hero().kit_state.sauce == 0 and sim.hero().kit_state.simmer_elapsed == 0.0, "Wave clears Sauce and Simmer progress")
	sim.hero().kit_state.sauce = 4
	check(sim.attempt_snapshot[0].kit_state.sauce == 0, "Snapshot owns independent kit dictionary")
	sim.pause_requested = true
	sim._finish(false)
	check(sim.hero().kit_state.sauce == 0, "Defeat restoration clears Sauce")
	sim = model(2)
	sim.profile.dust = 5
	var result: Dictionary = sim.summon()
	sim.set_copy_deployed(result.copy_id, true)
	sim.hero().kit_state.sauce = 5
	check(sim.allied_actors()[1].kit_state.sauce == 0, "Copies do not share Sauce")

func _shared_systems() -> void:
	var sim: BattleSimulation = model()
	for index: int in range(30):
		check(WaveSequence.valid(WaveSequence.generate(sim.rng)), "Valid spawn sequence")
	near(CombatMath.mitigate(30, 20), 25, "Armor formula")
	near(CombatMath.mitigate(10, -100), 15, "Negative armor")
	sim.hero().critical_chance = 1
	sim.hero().super_critical_chance = 1
	sim.hero().ultra_critical_chance = 1
	near(CombatMath.critical_chain(sim.hero(), sim.rng).multiplier, 6, "Three critical stages")
	sim.profile.dust = 15
	var rng_state: int = sim.rng.state
	for index: int in range(3):
		var result: Dictionary = sim.summon()
		check(result.success and result.rarity == &"rare", "Summon current Rare species")
		check(sim.profile.copy_by_id(result.copy_id).evolution == 0, "Summon always base form")
	check(sim.rng.state == rng_state, "Separate summon RNG")
	check(not sim.summon().success, "Insufficient Dust rejected")
	check(sim.set_copy_deployed(sim.profile.copies[1].id, true), "Second copy deploys")
	check(sim.set_copy_deployed(sim.profile.copies[2].id, true), "Third copy deploys")
	check(not sim.set_copy_deployed(sim.profile.copies[3].id, true), "Fourth copy blocked")
	sim.profile.copies[3].level = 25
	sim.start()
	check(sim.evolve_copy(sim.profile.copies[3].id), "Reserve copy evolves during battle")
	check(not sim.set_copy_deployed(sim.profile.copies[1].id, false), "Composition locked during battle")
	sim.hero().health = 0
	check(sim.has_living_allies(), "One fallen ally does not defeat team")
	sim.pending_xp = 20
	sim.pause_requested = true
	sim._finish(true)
	for copy: UnitProgress in sim.deployed_units():
		near(copy.experience, 20, "Every deployed copy earns full XP")
	var frozen: Dictionary = sim.to_data()
	sim.advance(100)
	check(sim.to_data() == frozen, "Pause freezes every timer")
	sim.chrono_break()
	check(sim.profile.copies[3].evolution == 1, "Chrono preserves evolution")
	for actor: CombatantState in sim.allied_actors():
		near(actor.health, actor.max_health, "Chrono restores all allies")
		check(actor.kit_state.sauce == 0, "Chrono clears Sauce")

func _persistence() -> void:
	var sim: BattleSimulation = model(2)
	sim._apply_progress(sim.hero())
	sim.start()
	sim.hero().health = 100
	sim.hero().kit_state.sauce = 5
	ticks(sim, 10)
	check(SaveStore.validate(sim.to_data()), "Mid-cast state validates")
	var clone: BattleSimulation = BattleSimulation.new()
	clone.restore(sim.to_data())
	check(clone.to_data() == sim.to_data(), "Snapshot restores exactly")
	ticks(sim, 500)
	ticks(clone, 500)
	check(clone.to_data() == sim.to_data(), "Restored timers and RNG remain deterministic")
	var store: SaveStore = SaveStore.new("res://tests/demo_test_spaghetti.save")
	check(store.write_state(sim.to_data()) == OK, "V8 save writes")
	check(store.load_state() == sim.to_data(), "V8 roundtrip")
	check(store.write_state(sim.to_data()) == OK, "Backup writes")
	var file: FileAccess = FileAccess.open(store.path, FileAccess.WRITE)
	file.store_string("broken")
	file.close()
	check(store.load_state() == sim.to_data() and store.recovered, "Corrupt primary recovers backup")
	for field: String in ["sauce", "guard_duration", "surge_cooldown"]:
		var bad: Dictionary = sim.to_data()
		if field == "sauce":
			bad.actors[0].kit_state[field] = 999
		else:
			bad.actors[0].kit_state[field] = 999.0
		check(not SaveStore.validate(bad), "Reject invalid " + field)
	var invalid: Dictionary = sim.to_data()
	invalid.profile.copies[0].evolution = 3
	check(not SaveStore.validate(invalid), "Reject unknown evolution")
	invalid = sim.to_data()
	invalid.profile.copies[0].level = 1
	check(not SaveStore.validate(invalid), "Reject evolution below required level")
	var old: Dictionary = sim.to_data()
	old.profile.gold = 123.5
	old.profile.dust = 17
	old.profile.shards = 4.5
	old.profile.global_ranks[&"global_armor"] = 2
	old.record_wave = 12
	var migrated: Dictionary = SaveStore._replace_legacy_roster(old)
	check(SaveStore.validate(migrated), "Legacy roster reset validates")
	check(migrated.profile.copies.size() == 1 and migrated.profile.copies[0].level == 1 and migrated.profile.copies[0].evolution == 0, "Legacy roster becomes one fresh base unit")
	check(migrated.profile.gold == 123.5 and migrated.profile.dust == 17 and migrated.profile.shards == 4.5, "Migration preserves currencies")
	check(migrated.profile.global_ranks[&"global_armor"] == 2 and migrated.record_wave == 12, "Migration preserves shared purchases and record")
	var payload: PackedByteArray = var_to_bytes(old)
	file = FileAccess.open(store.path, FileAccess.WRITE)
	file.store_var({"version": 7, "payload": payload, "checksum": SaveStore._hash(payload)}, false)
	file.close()
	check(store.load_state() == migrated, "Version 7 envelope migrates through real loader")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(store.path + suffix):
			DirAccess.remove_absolute(store.path + suffix)

func _animations() -> void:
	for stage: int in range(3):
		var sim: BattleSimulation = model(stage)
		var visual: CombatantVisual = sim.config.definition_for(sim.unit()).visual
		check(visual.animation != null, "Form has sprite-sheet animation")
		var player: RefCounted = visual.animation.create_player()
		var before: Dictionary = sim.to_data()
		player.update(sim.hero(), 0.1)
		var idle: int = player.frame_index
		player.update(sim.hero(), 0.3)
		check(player.frame_index != idle, "Idle advances authored frames")
		check(sim.to_data() == before, "Animation does not mutate simulation or RNG")
		var frozen: int = player.frame_index
		player.update(sim.hero(), 10.0, false)
		check(player.frame_index == frozen, "Paused animation freezes")
		sim.hero().position.x += 2
		player.update(sim.hero(), BattleSimulation.STEP)
		check(player.moving > 0 and player.state == &"walk", "Actual displacement drives walk")
		sim.hero().action = &"basic"
		sim.hero().action_left = 0.76
		sim.hero().impact_left = 0.01
		player.update(sim.hero(), BattleSimulation.STEP)
		check(player.frame_index == 3, "Jab anticipates impact without showing impact frame early")
		near(player.cycle, 1.0, "Cycle inferred from captured timers")
		sim.hero().attack_speed = 9
		player.update(sim.hero(), BattleSimulation.STEP)
		near(player.cycle, 1.0, "Mid-cycle speed purchase does not retime animation")
		sim.hero().impacted = true
		sim.hero().action_left = 0.75
		player.update(sim.hero(), 0.0)
		check(player.frame_index == 4, "Jab impact frame coincides with simulation impact")
		sim.hero().action_left = 0.01
		player.update(sim.hero(), BattleSimulation.STEP)
		check(player.frame_index == 7, "Jab reaches authored recovery frame")
		player.react({"kind":"heal", "ability":&"surge"})
		check(player.heal == 1.0 and (stage != 2 or player.surge == 1.0), "Healing event selects available sheet effect")
		sim.hero().health = 0
		player.update(sim.hero(), 0.7)
		check(player.state == &"death" and player.frame_index == 3, "Death reaches final drawn collapse")
		check(player.sprite_frames.get_frame_count(&"walk") == 8, "Eight drawn walking frames")
		check(player.sprite_frames.get_frame_count(&"basic") == 8 and player.sprite_frames.get_frame_count(&"sweep") == 8, "Eight frames per offensive action")
		check(player.sprite_frames.has_animation(&"guard") == (stage > 0), "Guard sheet unlock follows evolution")
		check(player.sprite_frames.has_animation(&"surge") == (stage == 2), "Surge sheet is final-only")
		for animation: StringName in player.sprite_frames.get_animation_names():
			for index: int in range(player.sprite_frames.get_frame_count(animation)):
				var frame: AtlasTexture = player.sprite_frames.get_frame_texture(animation, index)
				check(frame != null and Rect2(Vector2.ZERO, frame.atlas.get_size()).encloses(frame.region), "Frame region stays inside sheet")
		for sheet: Texture2D in [visual.animation.locomotion, visual.animation.attacks, visual.animation.abilities]:
			check(sheet.get_image().detect_alpha() != Image.ALPHA_NONE, "Sprite sheet has real alpha")
		var second: RefCounted = visual.animation.create_player()
		check(second.hurt == 0 and second.death == 0 and second != player, "Each copy owns independent animation state")
		check(second.sprite_frames == player.sprite_frames, "Copies share immutable atlas frames")
		var idle_frame: AtlasTexture = second.sprite_frames.get_frame_texture(&"idle", 0)
		var punch_frame: AtlasTexture = second.sprite_frames.get_frame_texture(&"basic", 4)
		check(idle_frame.get_size() == punch_frame.get_size(), "Wide attack retains fixed virtual canvas")
		check(punch_frame.region.size.x > punch_frame.atlas.get_width() / 4.0, "Extended fist region exceeds nominal cell")
		var actor: CombatantState = model(stage).hero()
		actor.action = &"sweep"
		actor.action_left = 0.21
		actor.impacted = false
		second.update(actor, 0.0)
		check(second.state == &"sweep" and second.frame_index == 3, "Sweep anticipates authoritative impact")
		actor.impacted = true
		actor.action_left = 0.2
		second.update(actor, 0.0)
		check(second.frame_index == 4, "Sweep impact switches to contact frame")
		actor.clear_action()
		second.react({"kind":"heal", "ability":&"simmer"})
		second.update(actor, 0.0)
		check(second.state == &"simmer", "Passive healing starts its own drawn sequence")
		if stage > 0:
			second.react({"kind":"heal", "ability":&"guard"})
			second.update(actor, 0.0)
			check(second.state == &"guard" and second.frame_index == (4 if stage == 1 else 2), "Guard effect starts after cast frames")

func _ui() -> void:
	var scene: Control = load("res://scenes/main.tscn").instantiate()
	scene.persist_progress = false
	host_tree.root.add_child(scene)
	scene.set_physics_process(false)
	await host_tree.process_frame
	scene._open_copy(scene.simulation.unit().id)
	check(scene.get_node("%Name").text == "Noodle Squire", "UI names base form")
	check(scene.upgrades.level_buttons.size() == 4, "UI shows four new upgrades")
	check(scene.evolve_button.disabled, "Evolution UI locked at level one")
	scene.simulation.unit().level = 10
	scene._refresh()
	check(not scene.evolve_button.disabled, "Evolution UI unlocks")
	scene.evolve_button.pressed.emit()
	check(scene.evolve_dialog.visible, "Evolution requires explicit confirmation")
	scene.evolve_dialog.confirmed.emit()
	check(scene.simulation.unit().evolution == 1, "Confirmed evolution changes selected copy")
	check(scene.get_node("%Name").text == "Saucebound Knight", "UI updates evolved name")
	check(scene.get_node("%Portrait").texture == scene.simulation.config.definition_for(scene.simulation.unit()).visual.texture, "Portrait matches current form")
	scene.get_node("%MenuShop").pressed.emit()
	check(scene.panels.current_section == &"shop", "Shop navigation preserved")
	scene.arena._process(0.016)
	check(scene.arena.motion_players.size() == 1, "Arena allocates one rig per ally")
	var player: RefCounted = scene.arena._motion(scene.simulation.hero())
	var healing_events: Array[Dictionary] = [{"kind":"heal", "target_id":scene.simulation.hero().id, "position":scene.simulation.hero().position, "amount":1.0, "ability":&"simmer"}]
	scene.arena._on_effects(healing_events)
	check(player.heal == 1.0, "Arena routes healing event to correct copy")
	scene.simulation.phase = &"paused"
	var clock_before: float = player.clock
	scene.arena._process(1.0)
	near(player.clock, clock_before, "Arena pause freezes rig time")
	scene.simulation.hero().health = 0
	var death_events: Array[Dictionary] = [{"kind":"death", "target_id":scene.simulation.hero().id, "position":scene.simulation.hero().position}]
	scene.arena._on_effects(death_events)
	check(scene.arena.death_echoes.size() == 1, "Lethal impact retains visual echo")
	scene.simulation._create_allies()
	scene.arena._process(0.1)
	check(scene.arena._motion(scene.simulation.hero()) != player, "Actor ID reuse resets rig")
	check(scene.arena.death_echoes[0].player.death > 0, "Death echo survives immediate model rollback")
	scene.arena._process(1.0)
	check(scene.arena.death_echoes.is_empty(), "Death echo expires without accumulation")
	scene.queue_free()
	await host_tree.process_frame
