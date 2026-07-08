extends Node

signal currency_changed(new_amount: int)

var current_currency: int = 10000
var presige_multiplier: float = 2.0
var global_multiplier: float = 1.0

func add_currency(amount: int ) -> void:
	current_currency += (amount * presige_multiplier * global_multiplier)
	currency_changed.emit(current_currency)

func spend_currency(cost: int) -> bool:
	if current_currency >= cost:
		current_currency -= cost
		currency_changed.emit(current_currency)
		return true
	else:
		return false
