extends Control
@export var counter_components: Array[CounterComponent]
@onready var mainLabel: Label = %MainLabel
@onready var currency_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for counter in counter_components:
		if counter != null: 
			counter.milestone_reached.connect(_on_milestone_reached)
		else:
			push_warning("You have an empty slot in your counter_components array!")

func update_ui() -> void:
	mainLabel.text = "Money: " + str(currency_counter)


func _on_milestone_reached() -> void:
	currency_counter += 1
	update_ui()
