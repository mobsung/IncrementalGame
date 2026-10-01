class_name UpgradePanel
extends VBoxContainer
## Displays catalog offers; all transactions go through the simulation.

var simulation: BattleSimulation
var copy_id: String = ""
var gold_buttons: Dictionary = {}
var level_buttons: Dictionary = {}

func bind(model: BattleSimulation) -> void:
	simulation = model
	copy_id = simulation.unit().id
	for upgrade: GoldUpgradeDefinition in simulation.config.gold_upgrades:
		var button: Button = _button(%GoldOffers, upgrade.display_name)
		button.pressed.connect(_buy_gold.bind(upgrade.id))
		gold_buttons[upgrade.id] = button
	for upgrade: LevelUpgradeDefinition in simulation.config.upgrades:
		var button: Button = _button(%LevelOffers, upgrade.display_name)
		button.tooltip_text = upgrade.description
		button.pressed.connect(_buy_level.bind(upgrade.id))
		level_buttons[upgrade.id] = button

func _button(parent: Node, label: String) -> Button:
	var button: Button = Button.new()
	button.text = label
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 14)
	parent.add_child(button)
	return button

func _buy_gold(id: StringName) -> void:
	simulation.purchase_copy_gold_upgrade(copy_id, id)

func _buy_level(id: StringName) -> void:
	simulation.purchase_copy_upgrade(copy_id, id)

func select_copy(value: String) -> void:
	copy_id = value

func refresh(blocked: bool) -> void:
	var copy: UnitProgress = simulation.profile.copy_by_id(copy_id)
	if copy == null:
		return
	for upgrade: GoldUpgradeDefinition in simulation.config.gold_upgrades:
		var button: Button = gold_buttons[upgrade.id]
		var rank: int = copy.gold_rank(upgrade.id)
		var cost: float = upgrade.cost_for_rank(rank)
		var capped: bool = rank >= upgrade.max_ranks
		button.text = "%s  %d/%d\n%s" % [upgrade.display_name, rank, upgrade.max_ranks,
			"Maximum rank" if capped else "Buy · %.0f Gold" % cost]
		button.tooltip_text = upgrade.description if not upgrade.description.is_empty() else "+%.2f base gain per rank. Applicable level upgrades amplify this copy's gains. Health increases do not heal." % upgrade.increment
		button.disabled = blocked or capped or simulation.profile.gold < cost
	%Points.text = "Level upgrades · %d points" % copy.level_points
	for upgrade: LevelUpgradeDefinition in simulation.config.upgrades:
		var button: Button = level_buttons[upgrade.id]
		button.visible = upgrade.applies_to(copy, simulation.config.definition_for(copy))
		var rank: int = copy.purchased_rank(upgrade.id)
		var cap: int = upgrade.cap_for(copy.evolution)
		var capped: bool = rank >= cap
		var cost: int = upgrade.cost_for_rank(rank)
		var offer: String = "Maximum rank"
		if cap == 0:
			offer = "Unlocks with evolution"
		if not capped:
			offer = "%d points · requires Lv %d" % [cost, upgrade.required_levels[rank]]
		button.text = "%s  %d/%d\n%s" % [upgrade.display_name, rank, cap, offer]
		button.disabled = blocked or capped or not upgrade.unlocked_for(rank, copy.level) or copy.level_points < cost
