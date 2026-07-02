extends Button
class_name BuyUpgrade

signal was_pressed

@export var currencyManager: CurrencyManager
@export var upgrade_cost: int = 1
@export var upgrade_name: String = "Default"
@export var upgrade_value: float = 1.0

var upgrade_level: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	currencyManager = get_tree().get_first_node_in_group("bank")
	
	text = upgrade_name
	pressed.connect(_on_pressed)
	
	if currencyManager != null:
		currencyManager.currency_changed.connect(_on_currency_got)
		_on_currency_got(currencyManager.current_currency)


func _on_currency_got(current_amount: int) -> void:
	if current_amount >= upgrade_cost:
		disabled = false
	else:
		disabled = true


func _on_pressed() -> void:
	var approved: bool = currencyManager.spend_currency(upgrade_cost)
	
	if approved == true:
		upgrade_level += 1
		upgrade_cost += 5
		text = upgrade_name + " (Lvl " + str(upgrade_level) + ")"
		was_pressed.emit()
	
	
