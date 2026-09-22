class_name BuyUpgrade
extends Button

signal was_pressed

@export_group("Hold to Repeat")
@export var initial_hold_delay: float = 0.3
@export var initial_repeat_interval: float = 0.2
@export var min_repeat_interval: float = 0.03
@export var acceleration_factor: float = 0.85

var model: CounterModel = null
var definition: UpgradeDefinition = null

var is_holding: bool = false
var hold_duration: float = 0.0
var repeat_timer: float = 0.0
var current_interval: float = 0.2

var cached_cost: float = 0.0
var cached_is_max: bool = false

func _ready() -> void:
	set_process(false)
	current_interval = initial_repeat_interval
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	mouse_exited.connect(_on_mouse_exited)
	
	if model != null and definition != null:
		_update_ui_state()

func setup(p_model: CounterModel, p_definition: UpgradeDefinition) -> void:
	model = p_model
	definition = p_definition
	
	model.upgrade_purchased.connect(_on_upgrade_purchased)
	model.stats_changed.connect(_update_ui_state)
	
	if definition.cost_type == UpgradeDefinition.CostType.STAR_POINTS:
		model.star_points_changed.connect(_on_star_points_changed)
	else:
		CurrencyManager.currency_changed.connect(_on_currency_changed)
		
	_update_ui_state()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_EXIT_TREE:
		_stop_holding()

func _get_compact_name() -> String:
	if definition == null:
		return ""
	match definition.id:
		"speed_1", "speed": return "Spd"
		"value_1", "yield": return "Yld"
		"convert_1", "convert": return "Flw"
		"crit_1", "crit_chance": return "Crit"
		"crit_power_1", "crit_power": return "CPwr"
		"scrit_1", "super_crit_chance": return "Scrit"
		"scrit_power_1", "super_crit_power": return "SPwr"
		"mega_yield_1", "mega_yield": return "Mega"
		"xp_wisdom_1", "xp_wisdom": return "XP"
		_: return definition.display_name.substr(0, 4)

func _update_ui_state() -> void:
	if model == null or definition == null:
		return
		
	cached_is_max = model.is_upgrade_max_level(definition)
	var lvl: int = model.get_upgrade_level(definition.id)
	cached_cost = model.get_upgrade_cost(definition)
	var short_name: String = _get_compact_name()
	
	if cached_is_max:
		text = "%s [MAX]" % short_name
		disabled = true
		_stop_holding()
		return
		
	if definition.cost_type == UpgradeDefinition.CostType.STAR_POINTS:
		text = "%s %d • ★%d" % [short_name, lvl, int(cached_cost)]
	else:
		text = "%s %d • %s" % [short_name, lvl, GlobalData.format_number(cached_cost)]
		
	_update_affordability()

func _update_affordability() -> void:
	if cached_is_max or model == null or definition == null:
		return
	var can_afford: bool = false
	if definition.cost_type == UpgradeDefinition.CostType.STAR_POINTS:
		can_afford = model.star_points >= int(cached_cost)
	else:
		can_afford = CurrencyManager.current_currency >= cached_cost
		
	if disabled == can_afford:
		disabled = not can_afford
		if disabled:
			_stop_holding()

func _on_upgrade_purchased(upgrade_id: String, _level: int) -> void:
	if definition != null and definition.id == upgrade_id:
		_update_ui_state()

func _on_currency_changed(_amount: float) -> void:
	if definition != null and definition.cost_type == UpgradeDefinition.CostType.CURRENCY:
		_update_affordability()

func _on_star_points_changed(_amount: int) -> void:
	if definition != null and definition.cost_type == UpgradeDefinition.CostType.STAR_POINTS:
		_update_affordability()

func _on_button_down() -> void:
	if disabled or model == null or definition == null:
		return
	is_holding = true
	hold_duration = 0.0
	repeat_timer = 0.0
	current_interval = initial_repeat_interval
	set_process(true)
	_try_buy()

func _on_button_up() -> void:
	_stop_holding()

func _on_mouse_exited() -> void:
	_stop_holding()

func _stop_holding() -> void:
	if is_holding:
		is_holding = false
		hold_duration = 0.0
		repeat_timer = 0.0
		current_interval = initial_repeat_interval
		set_process(false)

func _process(delta: float) -> void:
	if not is_holding or disabled or model == null or definition == null:
		_stop_holding()
		return
		
	hold_duration += delta
	if hold_duration >= initial_hold_delay:
		repeat_timer += delta
		if repeat_timer >= current_interval:
			repeat_timer = 0.0
			var success: bool = _try_buy()
			if success:
				current_interval = maxf(min_repeat_interval, current_interval * acceleration_factor)
			else:
				_stop_holding()

func _try_buy() -> bool:
	if model == null or definition == null or disabled:
		_stop_holding()
		return false
		
	var success: bool = model.buy_upgrade(definition)
	if success:
		was_pressed.emit()
		_update_ui_state()
		return true
	else:
		_stop_holding()
		return false
