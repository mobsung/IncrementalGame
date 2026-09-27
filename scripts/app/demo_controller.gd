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
	%BackToUnits.pressed.connect(_show_roster)
	%StatsTab.pressed.connect(_show_unit_tab.bind(false))
	%UpgradesTab.pressed.connect(_show_unit_tab.bind(true))
	%ShopToUnits.pressed.connect(panels.show_section.bind(&"units"))
	for entry: Array in [[%MenuBattle, &"battle"], [%MenuUnits, &"units"], [%MenuChrono, &"chrono"], [%MenuShop, &"shop"]]:
		entry[0].pressed.connect(panels.toggle.bind(entry[1]))
	panels.section_changed.connect(_on_section_changed)
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
	%StatsTab.set_pressed_no_signal(not show_upgrades)
	%UpgradesTab.set_pressed_no_signal(show_upgrades)
	%PanelScroll.scroll_vertical = 0

func _inspect_actor(id: int) -> void:
	var actor: CombatantState = Targeting.by_id(simulation.actors, id)
	if actor != null and actor.allied:
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
	save_status.text = "Saved · offline paused" if error == OK else save_store.last_error

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
	chrono_confirm.dialog_text = "End this run and restore John to full health?\nPending rewards from this attempt will be discarded.\nShards are calculated from the record when you confirm."
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
	var in_battle: bool = simulation.phase == &"battle"
	%Record.text = "THE RUINED CROSSING  ·  Record %d" % simulation.record_wave
	%CollectionSummary.text = "%d owned · %d / %d deployed\nEvery copy keeps its own level and upgrades." % [
		simulation.profile.copies.size(), simulation.deployed_units().size(), BattleSimulation.MAX_DEPLOYED_ALLIES]
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
	stats.text += "\nAttack speed  %.2f / s  ·  Range  %.0f\nHaste  %.0f  ·  Sweep area  +%.0f%%\nNext Sweep cooldown  %.2f s" % [
		hero.attack_speed, hero.attack_range, hero.haste, hero.area_bonus * 100.0,
		hero.ability_cooldown(simulation.config.ally.ability.cooldown)]
	stats.text += "\nMulti Hit  %d  ·  Multi Cast  %d" % [hero.multi_hit, hero.multi_cast]
	stats.text += "\nContribution per enemy defeated\n(before shared bonuses)\nGold +%.2f  ·  XP +%.2f  ·  Souls +%.2f" % [
		UnitStats.reward_contribution(copy, simulation.config.ally, simulation.config, "gold"),
		UnitStats.reward_contribution(copy, simulation.config.ally, simulation.config, "experience"),
		UnitStats.reward_contribution(copy, simulation.config.ally, simulation.config, "souls")]
	ability.text = "Spaghetti Sweep · %s\n\nHearty Rhythm  %d / 5\n5 basic attacks → heal 10%%.\n\nSouls  %.0f / %.0f" % [
		"Casting…" if hero.action == &"sweep" else ("Ready" if hero.cooldown <= 0 else "%.1f s cooldown" % hero.cooldown),
		hero.passive_count, simulation.souls, simulation.config.soul_threshold * (simulation.dust_earned + 1)]
	start_button.disabled = in_battle or blocked
	start_button.text = "Resume" if simulation.phase == &"paused" else "Begin run"
	pause_button.disabled = not in_battle or blocked
	pause_button.text = "Cancel queued pause" if simulation.pause_requested else "Pause after attempt"
	posture.disabled = in_battle or blocked
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
		copy.deployed and simulation.deployed_units().size() <= 1) or (
		not copy.deployed and simulation.deployed_units().size() >= BattleSimulation.MAX_DEPLOYED_ALLIES)
	%Name.text = simulation.config.definitions()[copy.species_id].display_name
	%Class.text = "%s · WARRIOR" % _rarity_for_species(copy.species_id).to_upper()

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
		button.text = "%s · Copy %d\n%s · Warrior · Level %d · %s\nView stats, upgrades & formation" % [
			simulation.config.definitions()[copy.species_id].display_name, index + 1,
			_rarity_for_species(copy.species_id).capitalize(), copy.level,
			"Slot %d" % (copy.slot + 1) if copy.deployed else "Reserve"]
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
