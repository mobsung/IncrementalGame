extends Control

signal counter_slots_changed(current_count: int, max_count: int)

const COUNTER_COMPONENT_SCENE: PackedScene = preload("res://scenes/counterComponent.tscn")
const TierDefinition = preload("res://scripts/tier_definition.gd")

@onready var counter_grid: GridContainer = %CounterGridContainer
@onready var buy_counter_button: Button = %BuyCounter
@onready var slots_badge_label: Label = %SlotsBadgeLabel

@export var base_max_counters: int = 3
var bonus_max_counters: int = 0
var counters_count: int = 0
var base_counter_cost: float = 50.0
var counter_cost_multiplier: float = 2.0

func _ready() -> void:
	CurrencyManager.currency_changed.connect(_on_currency_changed)
	buy_counter_button.pressed.connect(_on_buy_counter_pressed)
	
	# Spawn initial starting counter if none exist
	if counter_grid.get_child_count() == 0:
		_spawn_counter(0)
	
	_update_buy_button()

func get_max_counters() -> int:
	return base_max_counters + bonus_max_counters

func has_available_slots() -> bool:
	return counters_count < get_max_counters()

func add_max_counters_bonus(amount: int) -> void:
	bonus_max_counters += amount
	counter_slots_changed.emit(counters_count, get_max_counters())
	_update_buy_button()

func get_current_counter_cost() -> float:
	var purchase_index: int = max(0, counters_count - 1)
	return base_counter_cost * pow(counter_cost_multiplier, purchase_index)

func _update_buy_button() -> void:
	var max_cnt: int = get_max_counters()
	if slots_badge_label != null:
		slots_badge_label.text = "Slots: %d / %d" % [counters_count, max_cnt]
		if counters_count >= max_cnt:
			slots_badge_label.modulate = Color(1.0, 0.75, 0.3, 1.0)
		else:
			slots_badge_label.modulate = Color(0.85, 0.90, 1.0, 1.0)
			
	if not has_available_slots():
		buy_counter_button.text = "Max Reached"
		buy_counter_button.disabled = true
		return
		
	var cost: float = get_current_counter_cost()
	var next_tier_data: Dictionary = Global_data.get_counter_tier(counters_count)
	buy_counter_button.text = "Buy %s [%s]" % [next_tier_data["name"], Global_data.format_number(cost)]
	buy_counter_button.disabled = not CurrencyManager.can_afford(cost)

func _on_currency_changed(_amount: float) -> void:
	_update_buy_button()

func _on_buy_counter_pressed() -> void:
	if not has_available_slots():
		return
	var cost: float = get_current_counter_cost()
	if CurrencyManager.spend_currency(cost):
		_spawn_counter(counters_count)
		_update_buy_button()

func _spawn_counter(tier_index: int) -> void:
	var tier_def: TierDefinition = Global_data.get_tier_definition(tier_index)
	var new_counter: CounterComponent = COUNTER_COMPONENT_SCENE.instantiate()
	new_counter.setup_with_tier(tier_def)
	counter_grid.add_child(new_counter)
	counters_count += 1
	counter_slots_changed.emit(counters_count, get_max_counters())
