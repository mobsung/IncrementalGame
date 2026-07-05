extends Control
class_name CounterComponent

signal milestone_reached

@export var counter_name: String = "Gold"
@export var conversion: int = 100
@export var increment_value: int = 5
@export var base_timer_wait_time: float = 1.0
var crit_chance: float = 0.0
var crit_power: int = 2
var text_color: Color = Color.WHITE


var counter_value: int = 0
var last_milestone: int = 0 
var ms_1: float = 0.0

@onready var counter_label: RichTextLabel = %Counter_label
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = base_timer_wait_time
	update_ui()
	timer.start()
	

func update_ui() -> void:
	ms_1 = float(increment_value) / timer.wait_time
	var hex_color: String = text_color.to_html(false)
	counter_label.text = """%s: [color=#%s]%d[/color]
Value: %d
Conversion: %d
Speed: %.1f
M/s: %.1f""" % [counter_name, hex_color, counter_value, increment_value, conversion, timer.wait_time, ms_1]
	
	check_milestone()

func check_milestone() -> void:
	var current_milestone: int = counter_value / conversion
	
	if current_milestone > last_milestone:
		var milestones_passed = current_milestone - last_milestone
		last_milestone = current_milestone
		
		for i in range(milestones_passed):
			milestone_reached.emit()

func _on_manual_click_button_pressed() -> void:
	counter_value += 10
	update_ui()

func _on_timer_timeout() -> void:
	counter_value += calculate_increment_value()
	update_ui()

func calculate_increment_value() -> int:
	var final_value: int = increment_value
	if randf() <= crit_chance:
		final_value = increment_value * crit_power
		text_color = Color.RED
	else:
		text_color = Color.WHITE
	return final_value
	
func _on_speed_1_was_pressed() -> void:
	if snapped(timer.wait_time, 0.1) > 0.1:
		timer.wait_time = snapped(timer.wait_time - 0.1, 0.1)
		update_ui()


func _on_value_1_was_pressed() -> void:
	increment_value += 1
	update_ui()


func _on_convert_1_was_pressed() -> void:
	if conversion - 1 >= 1:
		conversion -= 1
		update_ui()
	
	
func _on_crit_1_was_pressed() -> void:
	crit_chance += 0.1
	print(crit_chance)


func _on_crit_power_1_was_pressed() -> void:
	crit_power += 1
