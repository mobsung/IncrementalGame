class_name SharedShopPanel
extends VBoxContainer
## The same catalog UI handles Gold and Shards; model quotes decide availability.

@export_enum("global", "chrono") var shop: String = "global"
var simulation: BattleSimulation
var buttons: Dictionary = {}

func bind(model: BattleSimulation) -> void:
	simulation = model
	for upgrade: StatUpgradeDefinition in simulation.config.shop_catalog(shop):
		var button: Button = Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 15)
		button.tooltip_text = upgrade.description
		button.pressed.connect(_buy.bind(upgrade.id))
		add_child(button)
		buttons[upgrade.id] = button

func _buy(id: StringName) -> void:
	simulation.purchase_shop_upgrade(shop, id)

func refresh(blocked: bool) -> void:
	for upgrade: StatUpgradeDefinition in simulation.config.shop_catalog(shop):
		var offer: Dictionary = simulation.shop_offer(shop, upgrade.id)
		var button: Button = buttons[upgrade.id]
		var currency: String = "Gold" if shop == "global" else "Shards"
		var effect: String = "+%.2f per rank" % upgrade.increment if upgrade.operation == "additive" else "+%.0f%% per rank" % (upgrade.increment * 100.0)
		if upgrade.stat == "area":
			effect = "+%.0f%% area per rank" % (upgrade.increment * 100.0)
		elif upgrade.stat.ends_with("_chance") and upgrade.operation == "additive":
			effect = "+%.1f percentage points per rank" % (upgrade.increment * 100.0)
		elif upgrade.stat == "allied_slots":
			effect = "+%d deployed ally" % roundi(upgrade.increment)
		var price: String = "Maximum rank" if offer.rank >= upgrade.max_ranks else "Buy · %.0f %s" % [offer.cost, currency]
		button.text = "%s  %d/%d\n%s · %s" % [upgrade.display_name, offer.rank, upgrade.max_ranks, effect, price]
		button.disabled = blocked or not offer.available
		button.tooltip_text = upgrade.description + ("\n" + offer.reason if not offer.available else "")
