extends Node

signal currency_changed(new_amount: float)

var current_currency: float = 0.0
var prestige_multiplier: float = 1.0
var global_multiplier: float = 1.0

func can_afford(cost: float) -> bool:
	return current_currency >= cost

func add_currency(amount: float) -> void:
	var added: float = amount * prestige_multiplier * global_multiplier
	current_currency += added
	currency_changed.emit(current_currency)

func spend_currency(cost: float) -> bool:
	if can_afford(cost):
		current_currency -= cost
		currency_changed.emit(current_currency)
		return true
	return false
