extends RefCounted
## Real two-species content, isolated profiles, mechanics and deterministic save coverage.
var suite: Variant
var wizard_id: String

func check(value: bool, text: String) -> void: suite.check(value, "Wizard: " + text)
func near(a: float, b: float, text: String) -> void: suite.near(a, b, "Wizard: " + text)

func fixture(role: String = "apprentice") -> BattleSimulation:
	var sim: BattleSimulation = BattleSimulation.new(151)
	var copy: UnitProgress = sim.profile.create_copy(&"would_be_wizard")
	wizard_id = copy.id
	copy.level = 30
	copy.level_points = 29
	if role != "apprentice":
		check(sim.evolve_copy(copy.id, &"acolyte" if role in ["acolyte", "archsage"] else &"makeshift"), "first branch evolves")
	if role in ["archsage", "archmage"]: check(sim.evolve_copy(copy.id), "final branch evolves")
	check(sim.set_copy_deployed(copy.id, true, 5), "second species deploys")
	return sim

func opponent(sim: BattleSimulation, point: Vector2) -> CombatantState:
	var target: CombatantState = CombatantState.create(sim.config.balanced, sim.next_id, false, point)
	sim.next_id += 1
	target.health = 500.0
	target.max_health = 500.0
	target.attack = 0.0
	target.critical_chance = 0.0
	sim.actors.append(target)
	return target

func cast(sim: BattleSimulation, action: StringName, target: CombatantState) -> Dictionary:
	var actor: CombatantState = sim.actor_for_copy(wizard_id)
	var copy: UnitProgress = sim.profile.copy_by_id(wizard_id)
	var definition: CombatantDefinition = sim.config.definition_for(copy)
	var ability: AbilityDefinition = AbilitySystem.definition_for(definition, action)
	actor.target_id = target.id
	AbilitySystem.begin(actor, ability)
	var damage: Dictionary = {}
	var healing: Dictionary = {}
	var requests: Array[Dictionary] = []
	var events: Array[Dictionary] = []
	WizardSystem.complete(actor, sim.actors, ability, copy, sim.rng, damage, healing, requests, events)
	actor.clear_action()
	return {"damage": damage, "healing": healing, "requests": requests, "events": events}

func run(runner: Variant) -> void:
	suite = runner
	_formation()
	_content()
	_healer()
	_gadgets()
	_roundtrip()

func _formation() -> void:
	var sim: BattleSimulation = BattleSimulation.new()
	check(sim.set_copy_deployed(sim.unit().id, false), "last ally can enter reserve during preparation")
	check(sim.actors.is_empty() and SaveStore.validate(sim.to_data()), "empty preparation saves")
	var frozen: Dictionary = sim.to_data()
	sim.start()
	check(sim.to_data() == frozen, "empty squad cannot start, no RNG or wave mutation")
	check(sim.set_copy_deployed(sim.unit().id, true, 0), "deploy exact field slot")
	var duplicate: UnitProgress = sim.profile.create_copy(&"spaghetti_golem")
	check(not sim.set_copy_deployed(duplicate.id, true, 1), "Golem duplicate refused")
	var wizard: UnitProgress = sim.profile.create_copy(&"would_be_wizard")
	check(sim.set_copy_deployed(wizard.id, true, 1), "Golem and Wizard coexist")
	var another: UnitProgress = sim.profile.create_copy(&"would_be_wizard")
	another.level = 30
	check(sim.evolve_copy(another.id, &"makeshift"), "reserve alternate evolves")
	check(not sim.set_copy_deployed(another.id, true, 2), "different branch shares species restriction")
	sim.start()
	check(not sim.set_copy_deployed(wizard.id, false), "battle composition locked")
	sim.pause_requested = true
	sim._finish(true)
	check(not sim.set_copy_deployed(wizard.id, false), "between-attempt composition remains locked")
	check(sim.set_copy_slot(wizard.id, 2), "between-attempt repositioning works")
	sim.chrono_break()
	check(sim.set_copy_deployed(wizard.id, false), "Chrono preparation allows removal")

func _content() -> void:
	for role: String in ["apprentice", "acolyte", "archsage", "makeshift", "archmage"]:
		var sim: BattleSimulation = fixture(role)
		var copy: UnitProgress = sim.profile.copy_by_id(wizard_id)
		var actor: CombatantState = sim.actor_for_copy(wizard_id)
		var definition: CombatantDefinition = sim.config.definition_for(copy)
		check(definition.validation_errors().is_empty(), role + " valid definition")
		check(definition.basic_icon != null and definition.passive_icons.size() == definition.passive_names.size(), role + " kit icons authored")
		check(definition.active_abilities.size() == (3 if role in ["archsage", "archmage"] else 1), role + " active budget")
		check(definition.passive_names.size() == (2 if role in ["archsage", "archmage"] else 1), role + " passive budget")
		near(actor.max_health, 250.0, role + " evolution never increases base HP")
		near(actor.attack, 18.0, role + " base attack unchanged")
		check(SaveStore.validate(sim.to_data()), role + " formation saves")
		check(not sim.purchase_copy_upgrade(copy.id, &"sauce_infusion"), "Golem upgrade cannot affect Wizard")
		check(sim.purchase_copy_upgrade(copy.id, &"wizard_mastery"), "Wizard point upgrade works")
		var rig: Resource = definition.visual.animation
		check(rig.regions.size() == rig.row_count * 6, role + " atlas complete")
		check(rig.isolated_frames.size() == rig.regions.size(), role + " isolated frame coverage")
		for pose: int in range(rig.regions.size()):
			var frame: Resource = rig.isolated_frames[pose]
			var bounded: bool = not frame.patches.is_empty()
			for patch: Rect2 in frame.patches:
				bounded = bounded and rig.regions[pose].encloses(patch)
			check(bounded, role + " all UV patches bounded")
			var mesh: ArrayMesh = frame.mesh_for(rig.regions[pose], rig.sheet.get_size())
			check(mesh.get_surface_count() == 1 and mesh == frame.mesh_for(rig.regions[pose], rig.sheet.get_size()), role + " cached frame mesh")
		var probes: Array = []
		if role == "archmage": probes = [[20, 21, Vector2(777, 600)], [22, 23, Vector2(1250, 560)], [23, 22, Vector2(1450, 550)]]
		if role == "makeshift": probes = [[21, 22, Vector2(1095, 630)], [26, 27, Vector2(829, 788)]]
		if role == "apprentice": probes = [[14, 15, Vector2(790, 432)]]
		for probe: Array in probes:
			var included: bool = false
			var leaked: bool = false
			for patch: Rect2 in rig.isolated_frames[probe[0]].patches:
				included = included or patch.has_point(probe[2])
			for patch: Rect2 in rig.isolated_frames[probe[1]].patches:
				leaked = leaked or patch.has_point(probe[2])
			check(included and not leaked, role + " extended prop belongs to its own frame")
		var image: Image = rig.sheet.get_image()
		check(image.detect_alpha() != Image.ALPHA_NONE, role + " transparent sheet")
		for action: StringName in [&"idle", &"walk", &"basic", &"hit", &"deploy", &"death"]:
			for pose: int in rig.clip(action):
				check(pose < rig.regions.size() and Rect2(Vector2.ZERO, rig.sheet.get_size()).encloses(rig.regions[pose]), role + " bounded pose")
		for active: AbilityDefinition in definition.active_abilities:
			check(rig.clip(active.id).size() >= 3, role + " active animated")
			check(active.icon != null, role + " active icon authored")
		var player: RefCounted = rig.create_player()
		player.update(actor, 0.7)
		var before: float = player.clock
		player.update(actor, 1.0, false)
		near(player.clock, before, "visual pause freezes clock")
	var gacha_sim: BattleSimulation = BattleSimulation.new(29)
	gacha_sim.profile.dust = 1000
	var seen: Dictionary = {}
	var combat_rng: int = gacha_sim.rng.state
	for index: int in range(100):
		var draw: Dictionary = gacha_sim.summon()
		seen[draw.species_id] = true
		check(draw.success and draw.rarity == &"rare" and gacha_sim.profile.copy_by_id(draw.copy_id).evolution == 0, "gacha independent base copy")
	check(seen.size() == 2 and gacha_sim.rng.state == combat_rng and gacha_sim.profile.dust == 500, "two-species gacha, cost and isolated RNG")

func _healer() -> void:
	var sim: BattleSimulation = fixture("acolyte")
	var actor: CombatantState = sim.actor_for_copy(wizard_id)
	var golem: CombatantState = sim.hero()
	golem.health = 100.0
	actor.kit_state.resource = 3
	var result: Dictionary = cast(sim, &"first_remedy", golem)
	check(float(result.healing.get(golem.id, 0.0)) > 0.0 and actor.kit_state.resource == 0, "Remedy consumes Notes and heals")
	check(actor.kit_state.recoveries.size() == 1, "Margin Notes leaves annotation")
	var damage: Dictionary = {golem.id: 20.0}
	var healing: Dictionary = {}
	var events: Array[Dictionary] = []
	WizardSystem.before_resolve(sim.actors, damage, healing, events)
	check(healing.get(golem.id, 0.0) > 0.0 and actor.kit_state.recoveries[0].budget == 0.0, "Annotation reacts once to damage")
	sim = fixture("archsage")
	actor = sim.actor_for_copy(wizard_id)
	golem = sim.hero()
	golem.health = 100.0
	actor.kit_state.resource = 10
	result = cast(sim, &"rewrite_wounds", golem)
	check(result.healing[golem.id] > 60.0 and actor.kit_state.resource == 1, "Completed Page consumes cap, primary useful heal generates one Note")
	cast(sim, &"shared_margins", actor)
	damage = {golem.id: 100.0}
	healing = {}
	events.clear()
	WizardSystem.before_resolve(sim.actors, damage, healing, events)
	near(damage[golem.id], 70.0, "Shared Margins transfers once")
	near(damage[actor.id], 30.0, "already mitigated transfer has no extra defense")
	actor.kit_state.link_left = 0.0
	actor.kit_state.resource = 6
	actor.kit_state.rescue_left = 0.0
	damage = {golem.id: 1000.0}
	healing = {golem.id: 200.0}
	events.clear()
	WizardSystem.before_resolve(sim.actors, damage, healing, events)
	var deaths: Array[int] = CombatMath.resolve(sim.actors, damage, healing)
	near(golem.health, 1.0, "Story Continues prevents death at exactly 1 HP")
	check(deaths.is_empty() and actor.kit_state.resource == 0 and actor.kit_state.rescue_left == 30.0, "rescue consumes resource and locks cooldown")
	golem.health = 80.0
	actor.kit_state.history = [{"target_id": golem.id, "amount": 100.0, "time": actor.kit_state.clock}]
	result = cast(sim, &"final_revision", actor)
	near(result.healing[golem.id], 50.0, "Final Revision uses remaining recent wounds")
	check(actor.kit_state.history.is_empty(), "Revision cannot restore same wounds twice")
	actor.kit_state.resource = 0
	for index: int in range(3): WizardSystem.basic(actor, null)
	check(actor.kit_state.resource == 4, "Living Script bonus every third cycle")
	actor.kit_state.resource = 9
	WizardSystem.gain(actor, 100)
	check(actor.kit_state.resource == 10, "Notes cap")

func _gadgets() -> void:
	var sim: BattleSimulation = fixture("apprentice")
	var actor: CombatantState = sim.actor_for_copy(wizard_id)
	var target: CombatantState = opponent(sim, actor.position + Vector2(80, 0))
	for index: int in range(4): WizardSystem.basic(actor, target)
	check(actor.kit_state.resource == 1, "Hard Lessons charged")
	var result: Dictionary = cast(sim, &"headlong_swing", target)
	check(result.damage[target.id] > 30.0 and actor.kit_state.resource == 0, "empowered physical Swing")
	sim = fixture("makeshift")
	actor = sim.actor_for_copy(wizard_id)
	target = opponent(sim, actor.position + Vector2(150, 0))
	actor.kit_state.resource = 4
	var ability: AbilityDefinition = sim.config.definition_for(sim.profile.copy_by_id(wizard_id)).active_abilities[0]
	AbilitySystem.begin(actor, ability)
	near(actor.action_left, ability.cast_time * 0.4, "Setup speeds next gadget")
	check(actor.kit_state.resource == 0, "quick cast consumes Setup")
	actor.clear_action()
	sim = fixture("archmage")
	actor = sim.actor_for_copy(wizard_id)
	target = opponent(sim, actor.position + Vector2(100, 0))
	actor.kit_state.resource = 10
	cast(sim, &"rigged_sigil", target)
	check(actor.kit_state.traps.size() == 1 and actor.kit_state.resource == 0, "They Bought It empowers next gadget")
	var damage: Dictionary = {}
	var events: Array[Dictionary] = []
	WizardSystem.advance(sim.actors, BattleSimulation.STEP, sim.rng, damage, events)
	check(damage.is_empty(), "trap has arming grace")
	WizardSystem.advance(sim.actors, BattleSimulation.STEP, sim.rng, damage, events)
	check(damage.get(target.id, 0.0) > 0.0 and actor.kit_state.traps.is_empty(), "entry trap detonates and removes")
	check(actor.kit_state.resource == 1, "trick generates Misdirection")
	actor.kit_state.encore_left = 10.0
	cast(sim, &"rigged_sigil", target)
	check(actor.kit_state.traps.size() == 2 and actor.kit_state.encore_left == 0.0, "Encore creates two traps and consumes once")
	result = cast(sim, &"clockwork_familiar", actor)
	for request: Dictionary in result.requests: sim._spawn_wizard_summon(request)
	var familiar: CombatantState = sim.actors.back()
	check(familiar.definition_id == &"clockwork_familiar" and familiar.reward_multiplier == 0.0, "mechanical familiar is real targetable nonreward entity")
	var chosen: CombatantState = Targeting.acquire(target, sim.actors, sim.config.balanced, null, sim.rng)
	check(chosen == familiar, "local decoy priority influences enemies")
	familiar.kit_state.split = true
	damage = {familiar.id: familiar.health}
	events.clear()
	var requests: Array[Dictionary] = []
	WizardSystem.decoy_events(sim.actors, damage, events, requests, sim.rng)
	check(requests.size() == 2, "Planned Failure Encore produces two small decoys")
	check(damage.get(target.id, 0.0) > 0.0, "familiar destruction physically explodes")
	cast(sim, &"grand_illusion", target)
	check(actor.kit_state.encore_left > 0.0, "three distinct actions earn Encore")
	check(actor.kit_state.retreat and actor.kit_state.charges.size() == 1, "illusion queues delayed physical charges and retreat")
	check(SaveStore.validate(sim.to_data()), "traps charges familiars and Encore save")

func _roundtrip() -> void:
	for role: String in ["archsage", "archmage"]:
		var sim: BattleSimulation = fixture(role)
		sim.start()
		sim.advance(2.0)
		var saved: Dictionary = sim.to_data()
		check(SaveStore.validate(saved), role + " in-flight validates")
		var restored: BattleSimulation = BattleSimulation.new()
		restored.restore(saved)
		for index: int in range(120):
			sim.step()
			restored.step()
		check(sim.to_data() == restored.to_data(), role + " resumed simulation deterministic")
		var invalid: Dictionary = saved.duplicate(true)
		for data: Dictionary in invalid.actors:
			if data.copy_id == wizard_id: data.kit_state.resource = 11
		check(not SaveStore.validate(invalid), "invalid resource rejected")
