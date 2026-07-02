extends Button
class_name BuyUpgrade

signal was_pressed

@export var currencyManager: CurrencyManager
@export var upgrade_cost: int = 1
@export var upgrade_name: String = "Default"



var upgrade_level: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	text = upgrade_name
	
	if currencyManager != null:
		currencyManager.currency_changed.connect(_on_currency_got)


func _on_currency_got(current_currency: int) -> void:
	pass


func _on_pressed() -> bool:
	return true # Replace with function body.
