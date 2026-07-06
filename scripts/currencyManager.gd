extends Node

signal currency_changed(new_amount: int)

var current_currency: int = 10000

func add_currency(amount: int ) -> void:
	current_currency += amount
	currency_changed.emit(current_currency)

func spend_currency(cost: int) -> bool:
	if current_currency >= cost:
		current_currency -= cost
		currency_changed.emit(current_currency)
		return true
	else:
		return false
