extends Control
## Composition root: connects the pure simulation, persistence and presentation.

@onready var arena: ArenaView = %ArenaView
@onready var wallet: Label = %Wallet
@onready var wave_label: Label = %Wave
@onready var battle_details: Label = %BattleDetails
@onready var stats: Label = %Stats
@onready var ability: Label = %Ability
@onready var start_button: Button = %Start
@onready var pause_button: Button = %Pause
@onready var auto_button: CheckButton = %Auto
@onready var defeat_button: CheckButton = %DefeatPause
@onready var posture: OptionButton = %Posture
@onready var priority: OptionButton = %Priority
@onready var repeat_wave: SpinBox = %RepeatWave
@onready var chrono: Button = %Chrono
@onready var chrono_confirm: ConfirmationDialog = %ChronoConfirm
@onready var save_status: Label = %SaveStatus
@onready var result_label: Label = %Result
@onready var upgrades: UpgradePanel = %UpgradePanel
@onready var panels: NavigationPanels = %Panels
@onready var global_shop: SharedShopPanel = %GlobalShop
@onready var chrono_shop: SharedShopPanel = %ChronoShop

@export var persist_progress: bool = true

var simulation: BattleSimulation
var save_store: SaveStore = SaveStore.new()
var save_pending: bool = false
var save_elapsed: float = 0.0
var refresh_elapsed: float = 0.0
var blocked: bool = false
var selected_copy_id: String = ""
var roster_buttons: Dictionary = {}
var evolve_button: Button
var evolve_dialog: ConfirmationDialog
var evolving_copy_id: String = ""
var offline_runner: OfflineSimulation
var offline_dialog: AcceptDialog
var ability_order: VBoxContainer
var ability_priority_controls: Dictionary = {}
var branch_choice: OptionButton
var branch_ids: Array[StringName] = []
var evolving_branch_id: StringName = &""
var role_choice: OptionButton

func _ready() -> void:
	get_tree().auto_accept_quit = false
	simulation = BattleSimulation.new(int(Time.get_unix_time_from_system()))
	var errors: PackedStringArray = simulation.config.validation_errors()
	if not errors.is_empty():
		blocked = true
		save_status.text = "; ".join(errors)
	var saved: Dictionary = save_store.load_state() if persist_progress else {}
	if not saved.is_empty():
		simulation.restore(saved)
		save_status.text = "Recovered backup" if save_store.recovered else "Progress restored"
	elif not save_store.last_error.is_empty():
		blocked = true
		save_status.text = save_store.last_error + " Original files preserved."
	selected_copy_id = simulation.unit().id
	if persist_progress and not blocked and not simulation.profile.content_grants.get("wizard_first_copy", false):
		simulation.profile.create_copy(&"would_be_wizard")
		simulation.profile.content_grants["wizard_first_copy"] = true
		save_pending = true
	arena.bind(simulation)
	upgrades.bind(simulation)
	global_shop.bind(simulation)
	chrono_shop.bind(simulation)
	arena.slot_selected.connect(_select_slot)
	arena.actor_selected.connect(_inspect_actor)
	simulation.state_changed.connect(_on_state_changed)
	simulation.attempt_finished.connect(_on_attempt_finished)
	start_button.pressed.connect(simulation.start)
	pause_button.pressed.connect(_toggle_pause_request)
	auto_button.toggled.connect(_set_auto)
	defeat_button.toggled.connect(_set_defeat_pause)
	posture.add_item("Mobile posture")
	posture.add_item("Hold slot")
	posture.item_selected.connect(_set_posture)
	for option: String in ["Nearest enemy", "Highest max health", "Lowest max health", "Farthest enemy"]:
		priority.add_item(option)
	priority.item_selected.connect(_set_priority)
	repeat_wave.value_changed.connect(_select_wave)
	chrono.pressed.connect(_ask_chrono)
	chrono_confirm.confirmed.connect(_chrono_break)
	%InspectJohn.pressed.connect(_show_john)
	%Formation.pressed.connect(_show_formation)
	%UnitCard.pressed.connect(_open_copy.bind(simulation.unit().id))
	%SummonButton.pressed.connect(_summon)
	%DeployToggle.pressed.connect(_toggle_deployment)
	evolve_button = Button.new()
	branch_choice = OptionButton.new()
	%UnitDetails.add_child(branch_choice)
	evolve_button.name = "Evolve"
	%UnitDetails.add_child(evolve_button)
	evolve_button.pressed.connect(_ask_evolution)
	evolve_dialog = ConfirmationDialog.new()
	evolve_dialog.title = "Evolve unit"
	add_child(evolve_dialog)
	evolve_dialog.confirmed.connect(_confirm_evolution)
	ability_order = VBoxContainer.new()
	var priority_title: Label = Label.new()
	priority_title.text = "Ability priorities · higher values act first"
	ability_order.add_child(priority_title)
	%UnitDetails.add_child(ability_order)
	role_choice = OptionButton.new()
	role_choice.add_item("Allied unit")
	role_choice.add_item("Enemy support · cannot be attacked")
	role_choice.item_selected.connect(_change_role)
	%UnitDetails.add_child(role_choice)
	%BackToUnits.pressed.connect(_show_roster)
	%StatsTab.pressed.connect(_show_unit_tab.bind(false))
	%UpgradesTab.pressed.connect(_show_unit_tab.bind(true))
	%ShopToUnits.pressed.connect(panels.show_section.bind(&"units"))
	for entry: Array in [[%MenuBattle, &"battle"], [%MenuUnits, &"units"], [%MenuChrono, &"chrono"], [%MenuShop, &"shop"]]:
		entry[0].pressed.connect(panels.toggle.bind(entry[1]))
	panels.section_changed.connect(_on_section_changed)
	_refresh()
	if not blocked and not saved.is_empty() and save_store.loaded_saved_at > 0.0:
		await _catch_up_offline(Time.get_unix_time_from_system() - save_store.loaded_saved_at)

func _catch_up_offline(elapsed: float) -> void:
	offline_runner = OfflineSimulation.new(simulation, elapsed)
	if offline_runner.finished:
		return
	blocked = true
	offline_dialog = AcceptDialog.new()
	offline_dialog.title = "While you were away"
	offline_dialog.get_ok_button().text = "Stop catch-up"
	offline_dialog.confirmed.connect(offline_runner.cancel)
	offline_dialog.canceled.connect(offline_runner.cancel)
	add_child(offline_dialog)
	offline_dialog.popup_centered(Vector2i(540, 180))
	while not offline_runner.pump():
		offline_dialog.dialog_text = "Simulating your squad · %.0f%%\nUp to %.0f minutes. Stops on defeat or a queued pause." % [
			100.0 * offline_runner.processed_steps / offline_runner.total_steps,
			simulation.config.offline_max_seconds / 60.0]
		await get_tree().process_frame
	blocked = false
	_save()
	var report: Dictionary = offline_runner.report
	var elapsed_text: String = "%.0f seconds" % report.seconds if report.seconds < 60.0 else "%.1f minutes" % (report.seconds / 60.0)
	offline_dialog.get_ok_button().text = "Continue"
	offline_dialog.dialog_text = "Simulated %s · %s\n%d victories · %d defeats\n+%.1f Gold · +%.1f XP per deployed copy · +%d Dust\nUnfinished attempt rewards remain pending." % [
		elapsed_text, report.reason, report.victories, report.defeats,
		report.gold, report.xp_per_copy, report.dust]
	offline_dialog.popup_centered(Vector2i(560, 220))
	_refresh()

func _on_section_changed(section: StringName) -> void:
	for entry: Array in [[%MenuBattle, &"battle"], [%MenuUnits, &"units"], [%MenuChrono, &"chrono"], [%MenuShop, &"shop"]]:
		entry[0].set_pressed_no_signal(section == entry[1])
	if section == &"units":
		_show_roster()

func _show_roster() -> void:
	for control: Control in [%CollectionSummary, %SummonButton, %SummonResult, %UnitCard, %RosterList]:
		control.show()
	%UnitDetails.hide()
	%PanelScroll.scroll_vertical = 0

func _open_copy(copy_id: String) -> void:
	if simulation.profile.copy_by_id(copy_id) == null:
		return
	selected_copy_id = copy_id
	upgrades.select_copy(copy_id)
	for control: Control in [%CollectionSummary, %SummonButton, %SummonResult, %UnitCard, %RosterList]:
		control.hide()
	%UnitDetails.show()
	var actor: CombatantState = simulation.actor_for_copy(copy_id)
	arena.selected_id = actor.id if actor != null else 0
	_show_unit_tab(false)
	_refresh()

func _show_unit_tab(show_upgrades: bool) -> void:
	for control: Control in [%Identity, stats, ability, posture, priority, %InspectJohn]:
		control.visible = not show_upgrades
	upgrades.visible = show_upgrades
	ability_order.visible = not show_upgrades
	role_choice.visible = not show_upgrades and simulation.config.definition_for(simulation.profile.copy_by_id(selected_copy_id)).enemy_support_role
	%StatsTab.set_pressed_no_signal(not show_upgrades)
	%UpgradesTab.set_pressed_no_signal(show_upgrades)
	%PanelScroll.scroll_vertical = 0

func _inspect_actor(id: int) -> void:
	var actor: CombatantState = Targeting.by_id(simulation.actors, id)
	if actor != null and not actor.copy_id.is_empty():
		panels.show_section(&"units")
		_open_copy(actor.copy_id)

func _show_john() -> void:
	var actor: CombatantState = simulation.actor_for_copy(selected_copy_id)
	arena.selected_id = actor.id if actor != null else 0
	panels.close()

func _show_formation() -> void:
	arena.formation_visible = not arena.formation_visible
	var actor: CombatantState = simulation.actor_for_copy(selected_copy_id)
	arena.selected_id = actor.id if arena.formation_visible and actor != null else 0
	panels.close()

func _select_slot(index: int) -> void:
	if not blocked:
		var copy: UnitProgress = simulation.profile.copy_by_id(selected_copy_id)
		if copy != null and not copy.deployed:
			simulation.set_copy_deployed(selected_copy_id, true, index)
		else:
			simulation.set_copy_slot(selected_copy_id, index)

func _physics_process(delta: float) -> void:
	if not blocked:
		simulation.advance(delta)

func _process(delta: float) -> void:
	if simulation == null:
		return
	refresh_elapsed += delta
	save_elapsed += delta
	if refresh_elapsed >= 0.1:
		refresh_elapsed = 0.0
		_refresh()
	if not blocked and (save_pending or save_elapsed >= 10.0):
		_save()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if simulation != null and not blocked:
			_save()
		get_tree().quit()

func _save() -> void:
	save_pending = false
	save_elapsed = 0.0
	if not persist_progress:
		return
	var error: Error = save_store.write_state(simulation.to_data())
	save_status.text = "Saved · offline enabled" if error == OK else save_store.last_error

func _on_state_changed() -> void:
	save_pending = true
	_refresh()

func _on_attempt_finished(summary: Dictionary) -> void:
	result_label.text = "%s · Wave %d · +%.1f Gold · +%.1f XP · +%.1f Souls" % [
		"Victory" if summary.victory else "Defeat", summary.wave, summary.gold, summary.xp, summary.souls]

func _toggle_pause_request() -> void:
	simulation.pause_requested = not simulation.pause_requested
	_on_state_changed()

func _set_auto(enabled: bool) -> void:
	simulation.auto_advance = enabled
	_on_state_changed()

func _set_defeat_pause(enabled: bool) -> void:
	simulation.pause_on_defeat = enabled
	_on_state_changed()

func _set_posture(index: int) -> void:
	simulation.set_copy_posture(selected_copy_id, index == 0)

func _set_priority(index: int) -> void:
	simulation.set_copy_priority(selected_copy_id, index)

func _summon() -> void:
	var result: Dictionary = simulation.summon()
	if not result.success:
		%SummonResult.text = result.reason
		return
	%SummonResult.text = "Summoned %s · %s" % [result.display_name, String(result.rarity).capitalize()]
	_sync_roster()
	_open_copy(result.copy_id)

func _toggle_deployment() -> void:
	var copy: UnitProgress = simulation.profile.copy_by_id(selected_copy_id)
	if copy == null:
		return
	if not simulation.set_copy_deployed(copy.id, not copy.deployed):
		%SummonResult.text = "Squad change unavailable"
		return
	var actor: CombatantState = simulation.actor_for_copy(copy.id)
	arena.selected_id = actor.id if actor != null else 0

func _select_wave(value: float) -> void:
	simulation.set_selected_wave(int(value))

func _ask_chrono() -> void:
	chrono_confirm.dialog_text = "End this run and restore your squad to full health?\nPending rewards from this attempt will be discarded.\nShards are calculated from the record when you confirm."
	chrono_confirm.popup_centered(Vector2i(520, 180))

func _chrono_break() -> void:
	simulation.chrono_break()
	arena.effects.clear()
	var actor: CombatantState = simulation.actor_for_copy(selected_copy_id)
	arena.selected_id = actor.id if actor != null else 0
	panels.close()
	arena.formation_visible = true
	result_label.text = "New run · Choose a slot and posture, then begin."

func _refresh() -> void:
	if simulation.profile.copy_by_id(selected_copy_id) == null:
		selected_copy_id = simulation.unit().id
		upgrades.select_copy(selected_copy_id)
	_sync_roster()
	upgrades.refresh(blocked)
	global_shop.refresh(blocked)
	chrono_shop.refresh(blocked)
	%MenuUnits.text = "Units · %d copies" % simulation.profile.copies.size()
	var copy: UnitProgress = simulation.profile.copy_by_id(selected_copy_id)
	var hero: CombatantState = simulation.preview_actor(selected_copy_id)
	var definition: CombatantDefinition = simulation.config.definition_for(copy)
	_refresh_ability_order(copy, definition)
	_refresh_evolution_choices(copy)
	role_choice.visible = definition.enemy_support_role and not upgrades.visible
	role_choice.disabled = blocked or simulation.phase == &"battle" or (not copy.deployed and simulation.phase != &"preparation")
	role_choice.select(1 if copy.enemy_support else 0)
	arena.formation_enemy_role = copy.enemy_support
	var in_battle: bool = simulation.phase == &"battle"
	%Record.text = "THE RUINED CROSSING  ·  Record %d" % simulation.record_wave
	%CollectionSummary.text = "%d owned · %d / %d deployed\nEvery copy keeps its own level and upgrades." % [
		simulation.profile.copies.size(), simulation.deployed_units().size(), simulation.allied_limit()]
	var offer: Dictionary = simulation.summon_offer()
	%SummonButton.text = "Summon · %d Dust" % offer.cost
	%SummonButton.disabled = blocked or not offer.available
	%Formation.disabled = in_battle or blocked
	%Formation.text = "Hide formation markers" if arena.formation_visible else "Arrange formation"
	%ChronoSummary.text = "Run record: %d\nChrono break reward: %.2f Shards\nOwned: %.2f Shards" % [simulation.record_wave, pow(float(simulation.record_wave) / 10.0, 2.0), simulation.profile.shards]
	wallet.text = "Gold %.1f   ·   Dust %d   ·   Shards %.2f" % [
		simulation.profile.gold, simulation.profile.dust, simulation.profile.shards]
	wave_label.text = "Wave %d  /  %s" % [simulation.wave, String(simulation.phase).capitalize()]
	battle_details.text = "%d / 12 appearances  ·  %d enemies  ·  %.1f s\nPending: %.1f Gold  ·  %.1f XP  |  Run record: %d" % [
		simulation.spawn_index, _enemy_count(), simulation.attempt_time,
		simulation.pending_gold, simulation.pending_xp if simulation.wave > simulation.record_wave and simulation.wave >= simulation.xp_block else 0.0,
		simulation.record_wave]
	stats.text = "Health  %.0f / %.0f\nAttack  %.0f    Armor  %.0f\nLevel %d  ·  XP %.0f / %.0f\nUnspent level points: %d" % [
		hero.health, hero.max_health, hero.attack, hero.armor, copy.level,
		copy.experience, copy.xp_required(simulation.config), copy.level_points]
	stats.text += "\nMagic Attack  %.1f  ·  Magic Resistance  %.1f\nAbility Power  %.2f\nCritical  %.1f%%  ×%.2f\nSuper  %.1f%%  ×%.2f  ·  Ultra  %.1f%%  ×%.2f" % [
		hero.magic_attack, hero.magic_resistance, hero.ability_power,
		hero.critical_chance * 100.0, hero.critical_multiplier,
		hero.super_critical_chance * 100.0, hero.super_critical_multiplier,
		hero.ultra_critical_chance * 100.0, hero.ultra_critical_multiplier]
	stats.text += "\nAttack speed  %.2f / s  ·  Range  %.0f\nHaste  %.0f  ·  Ability area  +%.0f%%" % [
		hero.attack_speed, hero.attack_range, hero.haste, hero.area_bonus * 100.0]
	if definition.kit != null:
		stats.text += "\nNext Sweep cooldown  %.2f s" % maxf(definition.kit.sweep_minimum_cooldown, hero.ability_cooldown(definition.ability.cooldown))
	stats.text += "\nMulti Hit  %d  ·  Multi Cast  %d" % [hero.multi_hit, hero.multi_cast]
	stats.text += "\nContribution per enemy defeated\n(before shared bonuses)\nGold +%.2f  ·  XP +%.2f  ·  Souls +%.2f" % [
		UnitStats.reward_contribution(copy, definition, simulation.config, "gold"),
		UnitStats.reward_contribution(copy, definition, simulation.config, "experience"),
		UnitStats.reward_contribution(copy, definition, simulation.config, "souls")]
	if definition.kit != null:
		ability.text = "Meatball Jab · 100%% Physical Attack\nMeatball Sweep · %.0f%% Physical Attack · up to 3 targets\nSweep: %s\nSlow Simmer · heals every 4 s\nNext tick: %.1f s" % [
			(definition.ability.damage_coefficient + hero.sweep_bonus) * 100.0,
			"Casting" if hero.action == &"sweep" else ("Ready" if hero.cooldown <= 0 else "%.1f s" % hero.cooldown),
			maxf(0.0, definition.kit.simmer_interval - float(hero.kit_state.simmer_elapsed))]
		if copy.evolution > 0:
			ability.text += "\n\nSauce Reserve · %d / 5\nSauce Guard · cooldown %.1f s · buff %.1f s" % [
				hero.kit_state.sauce, hero.kit_state.guard_cooldown, hero.kit_state.guard_duration]
		if copy.evolution > 1:
			ability.text += "\nGlassheart Surge · cooldown %.1f s · buff %.1f s" % [
				hero.kit_state.surge_cooldown, hero.kit_state.surge_duration]
	else:
		ability.text = _generic_ability_description(hero, definition)
	var evolution: Dictionary = simulation.evolution_offer(copy.id, _selected_branch())
	evolve_button.text = "Evolve → %s (Lv %d)" % [evolution.name, evolution.level] if evolution.has("name") else evolution.reason
	evolve_button.disabled = blocked or not evolution.available
	evolve_button.tooltip_text = "Refunds invested level points. Keeps level, XP and Gold upgrades." if evolution.available else evolution.reason
	start_button.disabled = in_battle or blocked or simulation.deployed_units().is_empty()
	start_button.tooltip_text = "Deploy at least one allied unit to begin." if simulation.deployed_units().is_empty() else ""
	start_button.text = "Resume" if simulation.phase == &"paused" else "Begin run"
	pause_button.disabled = not in_battle or blocked
	pause_button.text = "Cancel queued pause" if simulation.pause_requested else "Pause after attempt"
	posture.disabled = in_battle or blocked or copy.enemy_support
	posture.select(0 if copy.mobile else 1)
	priority.disabled = blocked
	priority.select(copy.priority)
	repeat_wave.set_block_signals(true)
	repeat_wave.min_value = simulation.minimum_wave()
	repeat_wave.max_value = simulation.record_wave + 1
	repeat_wave.value = simulation.selected_wave
	repeat_wave.editable = not in_battle and not blocked
	repeat_wave.set_block_signals(false)
	auto_button.set_pressed_no_signal(simulation.auto_advance)
	defeat_button.set_pressed_no_signal(simulation.pause_on_defeat)
	auto_button.disabled = blocked
	defeat_button.disabled = blocked
	chrono.disabled = blocked
	chrono.text = "Chrono break (+%.2f)" % pow(float(simulation.record_wave) / 10.0, 2.0)
	var selected_actor: CombatantState = simulation.actor_for_copy(copy.id)
	%InspectJohn.disabled = selected_actor == null
	%DeployToggle.text = "Move to reserve" if copy.deployed else "Deploy to first free slot"
	%DeployToggle.disabled = blocked or simulation.phase != &"preparation" or (
		not copy.deployed and ((not copy.enemy_support and simulation.deployed_units().size() >= simulation.allied_limit()) or (
			copy.enemy_support and simulation.profile.deployed_copies().size() > simulation.deployed_units().size())))
	for other: UnitProgress in simulation.profile.deployed_copies():
		if not copy.deployed and other.species_id == copy.species_id:
			%DeployToggle.disabled = true
	%DeployToggle.tooltip_text = "One copy per species. Composition changes during Chrono preparation only."
	%Name.text = definition.display_name
	%Portrait.texture = definition.visual.texture
	%Class.text = "%s · %s" % [_rarity_for_species(copy.species_id).to_upper(), definition.unit_class.to_upper()]

func _sync_roster() -> void:
	var valid: Dictionary = {}
	for index: int in range(simulation.profile.copies.size()):
		var copy: UnitProgress = simulation.profile.copies[index]
		var button: Button
		if index == 0:
			button = %UnitCard
		else:
			button = roster_buttons.get(copy.id)
			if button == null:
				button = Button.new()
				button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				button.pressed.connect(_open_copy.bind(copy.id))
				%RosterList.add_child(button)
				roster_buttons[copy.id] = button
		valid[copy.id] = true
		button.text = "%s · Copy %d\n%s · %s · Level %d · %s\nView stats, upgrades & formation" % [
			simulation.config.definition_for(copy).display_name, index + 1,
			_rarity_for_species(copy.species_id).capitalize(), simulation.config.definition_for(copy).unit_class.capitalize(), copy.level,
			("Enemy support %d" if copy.enemy_support else "Slot %d") % (copy.slot + 1) if copy.deployed else "Reserve"]
	for copy_id: String in roster_buttons.keys():
		if not valid.has(copy_id):
			roster_buttons[copy_id].queue_free()
			roster_buttons.erase(copy_id)

func _rarity_for_species(species_id: StringName) -> String:
	for entry: Resource in simulation.config.gacha.entries:
		if entry.unit != null and entry.unit.id == species_id:
			return entry.rarity
	return "common"

func _enemy_count() -> int:
	var count: int = 0
	for actor: CombatantState in simulation.actors:
		if not actor.allied:
			count += 1
	return count

func _ask_evolution() -> void:
	var offer: Dictionary = simulation.evolution_offer(selected_copy_id, _selected_branch())
	if blocked or not offer.available:
		return
	evolving_copy_id = selected_copy_id
	evolving_branch_id = offer.id
	var copy: UnitProgress = simulation.profile.copy_by_id(selected_copy_id)
	var unlocks: String = "Sauce Reserve and Sauce Guard. Higher upgrade caps." if copy.evolution == 0 else "Glassheart Surge, stronger Sweep and Slow Simmer. Higher upgrade caps."
	if simulation.config.definition_for(copy).kit == null:
		unlocks = offer.description
	evolve_dialog.dialog_text = "Evolve into %s?\n%s\nBase stats stay the same. Level points are refunded and level upgrades reset.\nLevel, XP and Gold upgrades are kept. This evolution is permanent." % [offer.name, unlocks]
	evolve_dialog.popup_centered(Vector2i(620, 220))

func _confirm_evolution() -> void:
	if not blocked:
		simulation.evolve_copy(evolving_copy_id, evolving_branch_id)
	evolving_copy_id = ""
	evolving_branch_id = &""

func _selected_branch() -> StringName:
	return branch_ids[branch_choice.selected] if branch_choice.selected >= 0 and branch_choice.selected < branch_ids.size() else &""

func _refresh_evolution_choices(copy: UnitProgress) -> void:
	var choices: Array[Dictionary] = simulation.evolution_choices(copy.id)
	var ids: Array[StringName] = []
	for option: Dictionary in choices:
		ids.append(option.id)
	if ids != branch_ids:
		branch_ids = ids
		branch_choice.clear()
		for option: Dictionary in choices:
			branch_choice.add_item("%s · Level %d" % [option.name, option.level])
	branch_choice.visible = ids.size() > 1
	branch_choice.disabled = blocked

func _change_role(index: int) -> void:
	if blocked:
		return
	var enemy_role: bool = index == 1
	var positions: PackedVector2Array = simulation.config.support_slots if enemy_role else simulation.config.slots
	for slot: int in range(positions.size()):
		if simulation.set_copy_role(selected_copy_id, enemy_role, slot):
			return
	_refresh()

func _refresh_ability_order(copy: UnitProgress, definition: CombatantDefinition) -> void:
	var kit_row: HBoxContainer = ability_order.get_node_or_null("KitIcons")
	if kit_row == null:
		kit_row = HBoxContainer.new()
		kit_row.name = "KitIcons"
		ability_order.add_child(kit_row)
		ability_order.move_child(kit_row, 0)
	if kit_row.get_meta("form", &"") != definition.id:
		for child: Node in kit_row.get_children():
			kit_row.remove_child(child)
			child.queue_free()
		kit_row.set_meta("form", definition.id)
		var textures: Array[Texture2D] = [definition.basic_icon]
		textures.append_array(definition.passive_icons)
		for index: int in range(textures.size()):
			if textures[index] == null: continue
			var icon: TextureRect = TextureRect.new()
			icon.texture = textures[index]
			icon.custom_minimum_size = Vector2(40, 40)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.tooltip_text = definition.basic_name if index == 0 else definition.passive_names[index - 1]
			kit_row.add_child(icon)
	kit_row.visible = definition.basic_icon != null
	var available: Array[StringName] = simulation.active_ability_ids(copy)
	for id: StringName in available:
		if not ability_priority_controls.has(id):
			var row: HBoxContainer = HBoxContainer.new()
			var label: Label = Label.new()
			var active: AbilityDefinition = AbilitySystem.definition_for(definition, id)
			if active != null and active.icon != null:
				var icon: TextureRect = TextureRect.new()
				icon.texture = active.icon
				icon.custom_minimum_size = Vector2(32, 32)
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.tooltip_text = active.description
				row.add_child(icon)
			label.text = active.display_name if active != null else definition.kit.action_name(id)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(label)
			var value: SpinBox = SpinBox.new()
			value.min_value = 0
			value.max_value = 100
			value.tooltip_text = "Ability priority: higher values act first. Changes apply to the next action."
			value.value_changed.connect(_change_ability_priority.bind(id))
			row.add_child(value)
			ability_order.add_child(row)
			ability_priority_controls[id] = value
	for id: StringName in ability_priority_controls:
		var value: SpinBox = ability_priority_controls[id]
		value.get_parent().visible = id in available
		value.editable = not blocked
		var default_priority: int = definition.kit.action_priority(copy, id) if definition.kit != null and AbilitySystem.definition_for(definition, id) == null else 0
		if not definition.wizard_role.is_empty(): default_priority = WizardSystem.priority(id)
		value.set_value_no_signal(int(copy.ability_priorities.get(id, default_priority)))

func _change_ability_priority(value: float, id: StringName) -> void:
	if not blocked:
		simulation.set_ability_priority(selected_copy_id, id, int(value))

func _generic_ability_description(actor: CombatantState, definition: CombatantDefinition) -> String:
	var lines: PackedStringArray = []
	if not definition.wizard_role.is_empty():
		lines.append(definition.basic_name + " · " + ("Magic projectile" if definition.wizard_role in ["acolyte", "archsage"] else ("Physical projectile" if definition.wizard_role == "archmage" else "Physical melee")))
		lines.append("Passives: " + ", ".join(definition.passive_names))
		var label: String = "Notes" if definition.wizard_role in ["acolyte", "archsage"] else ("Misdirection" if definition.wizard_role == "archmage" else ("Setup" if definition.wizard_role == "makeshift" else "Hard Lessons"))
		lines.append("%s · %d / %d" % [label, actor.kit_state.resource, WizardSystem.TUNE.notes_cap])
		if definition.wizard_role == "archsage": lines.append("The Story Continues · %.1f s" % actor.kit_state.rescue_left)
		if definition.wizard_role == "archmage": lines.append("Encore · %.1f s · %d / 3 different tricks" % [actor.kit_state.encore_left, actor.kit_state.sequence.size()])
	for active: AbilityDefinition in definition.active_abilities:
		var left: float = actor.ability_cooldowns.get(active.id, 0.0)
		lines.append("%s · %s · range %.0f" % [active.display_name,
			"Casting" if actor.action == active.id else ("Ready" if left <= 0.0 else "%.1f s" % left), active.range_radius])
		if not active.description.is_empty(): lines.append(active.description)
	for status: Dictionary in actor.statuses:
		lines.append("%s · %d stacks · %.1f s" % [status.id, status.stacks, status.remaining])
	return "\n".join(lines)
