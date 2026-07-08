extends Button
class_name BuyUpgrade

signal was_pressed
 
@export var upgrade_cost: int = 1
@export var upgrade_name: Global_data.LVL1UpgradeType
@export var growth_factor: float = 1.05
@onready var parent_counter: CounterComponent = owner

var upgrade_level: int = 0
var max_level_reached: bool = false
var upgrade_name_as_string: String



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrade_name_as_string = Global_data.LVL1Upgrades[upgrade_name]
	pressed.connect(_on_pressed)
	CurrencyManager.currency_changed.connect(_on_currency_got)
	_on_currency_got(CurrencyManager.current_currency)
	parent_counter.max_level_reached.connect(_on_max_level_reached)
	_update_ui()

func _update_ui() -> void:
	if max_level_reached:
		text = upgrade_name_as_string + " (Lvl MAX)"
	else:
		text = upgrade_name_as_string + " (Lvl " + str(upgrade_level) + ")" + " (Cost " + str(upgrade_cost) + ")"

func _on_currency_got(current_amount: int) -> void:
	if current_amount >= upgrade_cost and not max_level_reached:
		disabled = false
	else:
		disabled = true

func _on_max_level_reached(max_upgrade_name: String) -> void:
	if max_upgrade_name == upgrade_name_as_string:
		disabled = true
		max_level_reached = true
		_update_ui()

func _on_pressed() -> void:
	var approved: bool = CurrencyManager.spend_currency(upgrade_cost)
	
	if approved == true and not max_level_reached:
		upgrade_level += 1
		upgrade_cost = int(upgrade_cost * pow(growth_factor, upgrade_level))
		was_pressed.emit()
		_on_currency_got(CurrencyManager.current_currency)
		_update_ui()
	
