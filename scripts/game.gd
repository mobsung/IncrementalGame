extends Control

signal counter_slots_changed(current_count: int, max_count: int)

const COUNTER_COMPONENT_SCENE: PackedScene = preload("res://scenes/counterComponent.tscn")

@onready var counter_grid: GridContainer = %CounterGridContainer
@onready var buy_counter_button: Button = %BuyCounter
@onready var slots_badge_label: Label = %SlotsBadgeLabel
@onready var prestige_button: Button = %PrestigeButton
@onready var prestige_modal: PrestigeModal = %PrestigeModal
@onready var evolution_modal: EvolutionModal = %EvolutionModal
@onready var floating_text_manager: FloatingTextManager = %FloatingTextManager

@export var base_max_counters: int = 3
var bonus_max_counters: int = 0
var counters_count: int = 0
var base_counter_cost: float = 50.0
var counter_cost_multiplier: float = 2.0

var _is_top_bar_dirty: bool = false
var _top_bar_accum: float = 0.0
const TOP_BAR_INTERVAL: float = 0.05

func _ready() -> void:
	CurrencyManager.currency_changed.connect(_on_currency_changed)
	CurrencyManager.prestige_points_changed.connect(_on_prestige_points_changed)
	CurrencyManager.prestige_upgrades_changed.connect(_on_prestige_upgrades_changed)
	CurrencyManager.prestige_performed.connect(_on_prestige_performed)
	
	buy_counter_button.pressed.connect(_on_buy_counter_pressed)
	if prestige_button != null:
		prestige_button.pressed.connect(_on_prestige_button_pressed)
	
	# Spawn initial starting Forest Sprite if none exist
	if counter_grid.get_child_count() == 0:
		_spawn_initial_creature()
	
	_update_buy_button()
	_update_prestige_button()

func _process(delta: float) -> void:
	if _is_top_bar_dirty:
		_top_bar_accum += delta
		if _top_bar_accum >= TOP_BAR_INTERVAL:
			_top_bar_accum = 0.0
			_is_top_bar_dirty = false
			_update_buy_button()
			_update_prestige_button()

func get_max_counters() -> int:
	return base_max_counters + bonus_max_counters + CurrencyManager.get_bonus_slots()

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
		buy_counter_button.text = "Sanctuary Full"
		buy_counter_button.disabled = true
		return
		
	var cost: float = get_current_counter_cost()
	buy_counter_button.text = "Summon Creature [%s]" % GlobalData.format_number(cost)
	buy_counter_button.disabled = not CurrencyManager.can_afford(cost)

func _update_prestige_button() -> void:
	if prestige_button == null:
		return
	var claimable: int = CurrencyManager.get_claimable_prestige_points()
	var current_pp: int = CurrencyManager.prestige_points
	if claimable > 0:
		prestige_button.text = "✦ %d AS (+%d)" % [current_pp, claimable]
		prestige_button.modulate = Color(1.2, 1.0, 1.35, 1.0)
	else:
		prestige_button.text = "✦ %d AS" % current_pp
		prestige_button.modulate = Color.WHITE

func _on_currency_changed(_amount: float) -> void:
	_is_top_bar_dirty = true

func _on_prestige_points_changed(_amount: int) -> void:
	_update_prestige_button()

func _on_prestige_upgrades_changed() -> void:
	_update_buy_button()
	counter_slots_changed.emit(counters_count, get_max_counters())

func _on_prestige_button_pressed() -> void:
	if prestige_modal != null:
		prestige_modal.open_modal()

func _on_prestige_performed(_points_gained: int) -> void:
	# Cleanly clear all existing creature cards
	for child in counter_grid.get_children():
		child.queue_free()
	counters_count = 0
	
	# Spawn 1 fresh starting Forest Sprite
	_spawn_initial_creature()
	_update_buy_button()
	_update_prestige_button()

func _on_buy_counter_pressed() -> void:
	if not has_available_slots():
		return
	var cost: float = get_current_counter_cost()
	if CurrencyManager.spend_currency(cost):
		_spawn_initial_creature()
		_update_buy_button()

func _spawn_initial_creature() -> void:
	var base_def: CreatureDefinition = GlobalData.get_starting_creature()
	var new_counter: CounterComponent = COUNTER_COMPONENT_SCENE.instantiate()
	new_counter.setup_with_creature(base_def)
	new_counter.evolution_requested.connect(_on_creature_evolution_requested)
	new_counter.floating_text_requested.connect(_on_floating_text_requested)
	counter_grid.add_child(new_counter)
	counters_count += 1
	counter_slots_changed.emit(counters_count, get_max_counters())

func _on_floating_text_requested(text: String, color: Color, spawn_pos: Vector2) -> void:
	if floating_text_manager != null:
		floating_text_manager.spawn_text(text, color, spawn_pos)

func _on_creature_evolution_requested(model: CounterModel) -> void:
	if evolution_modal != null:
		evolution_modal.open_for_model(model)
