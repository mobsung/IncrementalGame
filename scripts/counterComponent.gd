extends Control
class_name CounterComponent

signal max_level_reached(upgrade_name: String)

@export var counter_name: String = "Gold"
@export var conversion: int = 100
@export var increment_value: int = 5
@export var base_timer_wait_time: float = 1.0
@export var max_conversion: int = 1

var crit_chance: float = 0.0
var crit_power: int = 2
var super_crit_chance: float = 0.0
var super_crit_power: int = 2
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
		CurrencyManager.add_currency(current_milestone - last_milestone)

		last_milestone = current_milestone

func _on_manual_click_button_pressed() -> void:
	counter_value += 10
	update_ui()

func _on_timer_timeout() -> void:
	counter_value += calculate_increment_value()
	calculate_m_s()
	update_ui()

func calculate_m_s():
	var p_normal: float = 1.0 - crit_chance
	var p_crit_only: float = crit_chance * (1.0 - super_crit_chance)
	var p_super: float = crit_chance * super_crit_chance

	var expected_yield: float = 0.0
	expected_yield += increment_value * p_normal
	expected_yield += (increment_value * crit_power) * p_crit_only
	expected_yield += (increment_value * crit_power * super_crit_power) * p_super

	var value_per_second: float = expected_yield / timer.wait_time
	ms_1 = value_per_second
	

func calculate_increment_value() -> int:
	var final_value: int = increment_value
	if randf() <= crit_chance:
		final_value = increment_value * crit_power
		text_color = Color.RED
		if randf() <= super_crit_chance:
			final_value = final_value * super_crit_power
			text_color = Color.YELLOW
	else:
		text_color = Color.WHITE
	return final_value
	
func _on_speed_1_was_pressed() -> void:
	if snapped(timer.wait_time, 0.1) > 0.1:
		timer.wait_time = snapped(timer.wait_time - 0.1, 0.1)
		update_ui()
		if snapped(timer.wait_time, 0.1) <= 0.1:
			max_level_reached.emit(Global_data.LVL1Upgrades.get(Global_data.LVL1UpgradeType.SPEED_1))

func _on_value_1_was_pressed() -> void:
	increment_value += 1
	update_ui()

func _on_convert_1_was_pressed() -> void:
	if conversion - 1 >= max_conversion:
		conversion -= 1
		update_ui()
		if conversion <= max_conversion:
			max_level_reached.emit(Global_data.LVL1Upgrades.get(Global_data.LVL1UpgradeType.CONVERT_1))
	
func _on_crit_1_was_pressed() -> void:
	if snapped(crit_chance, 0.1) < 1.0:
		crit_chance += 0.1
		if snapped(crit_chance, 0.1) == 1.0:
			max_level_reached.emit(Global_data.LVL1Upgrades.get(Global_data.LVL1UpgradeType.CRIT_1))

func _on_crit_power_1_was_pressed() -> void:
	crit_power += 1

func _on_super_crit_1_was_pressed() -> void:
	if snapped(super_crit_chance, 0.1) < 1.0:
		super_crit_chance += 0.1
		if snapped(super_crit_chance, 0.1) == 1.0:
			max_level_reached.emit(Global_data.LVL1Upgrades.get(Global_data.LVL1UpgradeType.S_CRIT_1))

func _on_super_crit_power_1_was_pressed() -> void:
	super_crit_power += 1
