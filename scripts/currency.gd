extends Control
class_name CurrencyManager

signal currency_changed(new_amount: int)

@export var counter_components: Array[CounterComponent]
@onready var mainLabel: Label = %MainLabel
var current_currency: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for counter in counter_components:
		if counter != null: 
			counter.milestone_reached.connect(_on_milestone_reached)
		else:
			push_warning("You have an empty slot in your counter_components array!")
			
	update_ui()
	
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

func update_ui() -> void:
	mainLabel.text = "Money: " + str(current_currency)


func _on_milestone_reached() -> void:
	add_currency(1)
	update_ui()
