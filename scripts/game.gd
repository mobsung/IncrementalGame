extends Node2D

const counterComponent = preload("res://scenes/counterComponent.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_buy_counter_pressed() -> void:
	var new_counter = counterComponent.instantiate()
	
	new_counter.counter_name = "Silver"
	new_counter.conversion = 50
	new_counter.increment_value = 10
	new_counter.base_timer_wait_time = 0.5
	new_counter.max_conversion = 5
	
	$CounterGridContainer.add_child(new_counter)
	
	
	
