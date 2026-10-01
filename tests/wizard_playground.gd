extends "res://scripts/app/demo_controller.gd"
## F6: isolated two-unit playground. Keys 1–5 choose Wizard forms; real save untouched.
var wizard_copy_id: String
const ROLES: Array[String] = ["apprentice", "acolyte", "archsage", "makeshift", "archmage"]

func _ready() -> void:
	persist_progress = false
	super._ready()
	simulation.profile.dust = 200
	simulation.profile.gold = 1500.0
	simulation.profile.shards = 100.0
	wizard_copy_id = simulation.profile.create_copy(&"would_be_wizard").id
	simulation.unit().level = 30
	simulation.unit().level_points = 29
	choose_form(0)
	save_status.text = "TEST ONLY · 1–5: Wizard forms · 200 Dust · player save untouched"
	if "capture" not in OS.get_cmdline_user_args(): return
	set_physics_process(false)
	for index: int in range(5):
		choose_form(index)
		var wizard: CombatantState = simulation.actor_for_copy(wizard_copy_id)
		simulation.hero().position = Vector2(475, 320)
		wizard.position = Vector2(350, 280)
		var enemy: CombatantState = CombatantState.create(simulation.config.balanced, simulation.next_id, false, Vector2(550, 320))
		simulation.next_id += 1
		simulation.actors.append(enemy)
		_open_copy(wizard_copy_id)
		_refresh()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://tests/wizard_%s_preview.png" % ROLES[index])
		var active: AbilityDefinition = simulation.config.definition_for(simulation.profile.copy_by_id(wizard_copy_id)).active_abilities[0]
		wizard.target_id = wizard.id if active.target_kind == "self" else (simulation.hero().id if active.target_kind == "injured_ally" else enemy.id)
		if active.target_kind == "injured_ally": simulation.hero().health *= 0.4
		AbilitySystem.begin(wizard, active)
		arena.motion_players.clear()
		arena._process(0.0)
		wizard.action_left *= 0.4
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://tests/wizard_%s_cast_preview.png" % ROLES[index])
	panels.show_section(&"units")
	_open_copy(wizard_copy_id)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tests/wizard_panel_preview.png")
	for index: int in [2, 4]:
		choose_form(index)
		simulation.start()
		simulation.advance(20.0)
		if not SaveStore.validate(simulation.to_data()):
			push_error("Wizard graphical battle smoke snapshot invalid")
			get_tree().quit(1)
			return
	print("WIZARD BATTLE SMOKE: both final branches with Golem, 20 seconds each, valid snapshots")
	print("WIZARD PREVIEW: ten two-unit form/cast captures plus kit panel; persist_progress=false")
	get_tree().quit()

func choose_form(index: int) -> void:
	simulation.chrono_break()
	var copy: UnitProgress = simulation.profile.copy_by_id(wizard_copy_id)
	copy.evolution = 0
	copy.evolution_path.clear()
	copy.upgrade_ranks.clear()
	copy.ability_priorities.clear()
	copy.level = 30
	copy.level_points = 29
	if index in [1, 2]: simulation.evolve_copy(copy.id, &"acolyte")
	if index in [3, 4]: simulation.evolve_copy(copy.id, &"makeshift")
	if index in [2, 4]: simulation.evolve_copy(copy.id)
	if not copy.deployed: simulation.set_copy_deployed(copy.id, true, 3)
	simulation._create_allies()
	arena.bind(simulation)
	selected_copy_id = copy.id
	upgrades.select_copy(copy.id)
	_refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode >= KEY_1 and event.keycode <= KEY_5:
		choose_form(event.keycode - KEY_1)
