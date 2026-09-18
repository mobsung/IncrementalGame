extends Control
class_name CounterComponent

const BUY_UPGRADE_SCENE: PackedScene = preload("res://scenes/buyUpgrade.tscn")
const CounterModel = preload("res://scripts/counter_model.gd")
const UpgradeDefinition = preload("res://scripts/upgrade_definition.gd")
const TierDefinition = preload("res://scripts/tier_definition.gd")

@export var counter_name: String = "Gold"
@export var conversion: float = 100.0
@export var increment_value: float = 5.0
@export var base_timer_wait_time: float = 1.0
@export var max_conversion: float = 1.0

var model: CounterModel = null
var is_showing_star_upgrades: bool = false
var text_color: Color = Color.WHITE
var color_tween: Tween = null

# Backwards-compatible delegating properties
var counter_level: int:
	get: return model.counter_level if model != null else 1
	set(val): if model != null: model.counter_level = val

var current_xp: float:
	get: return model.current_xp if model != null else 0.0
	set(val): if model != null: model.current_xp = val

var xp_required: float:
	get: return model.xp_required if model != null else 10.0
	set(val): if model != null: model.xp_required = val

var star_points: int:
	get: return model.star_points if model != null else 0
	set(val): if model != null: model.star_points = val

var counter_value: float:
	get: return model.counter_value if model != null else 0.0
	set(val): if model != null: model.counter_value = val

var star_yield_bonus: float:
	get: return model.star_yield_bonus if model != null else 0.0
	set(val): if model != null: model.star_yield_bonus = val

var xp_per_conversion: float:
	get: return model.xp_per_conversion if model != null else 1.0
	set(val): if model != null: model.xp_per_conversion = val

@onready var counter_name_label: Label = %CounterNameLabel
@onready var star_button: Button = %StarButton
@onready var tier_badge: Label = %TierBadge
@onready var hero_value_label: RichTextLabel = %HeroValueLabel
@onready var conversion_progress: ProgressBar = %ConversionProgress
@onready var conversion_label: Label = %ConversionLabel
@onready var xp_progress: ProgressBar = %XPProgress
@onready var xp_label: Label = %XPLabel
@onready var stat_yield_label: Label = %StatYieldLabel
@onready var stat_speed_label: Label = %StatSpeedLabel
@onready var stat_rate_label: Label = %StatRateLabel
@onready var stat_crit_label: Label = %StatCritLabel
@onready var manual_click_button: Button = %ManualClickButton
@onready var timer: Timer = $Timer
@onready var upgrades_title: Label = %UpgradesTitle
@onready var upgrade_grid: GridContainer = %UpgradeGrid
@onready var star_upgrade_grid: GridContainer = %StarUpgradeGrid

func _ready() -> void:
	if model == null:
		var initial_defs: Array[UpgradeDefinition] = Global_data.load_default_upgrades()
		model = CounterModel.new()
		model.setup(counter_name, conversion, increment_value, base_timer_wait_time, max_conversion, initial_defs)
		
	_bind_model_signals()
	_populate_upgrade_grids()
	
	timer.wait_time = maxf(model.timer_wait_time, 0.05)
	timer.start()
	update_all_ui()

func setup_with_tier(tier_def: TierDefinition) -> void:
	counter_name = tier_def.tier_name
	conversion = tier_def.conversion
	increment_value = tier_def.increment_value
	base_timer_wait_time = tier_def.base_timer_wait_time
	max_conversion = tier_def.max_conversion
	
	var defs: Array[UpgradeDefinition] = tier_def.available_upgrades
	if defs.is_empty():
		defs = Global_data.load_default_upgrades()
		
	model = CounterModel.new()
	model.setup(
		tier_def.tier_name,
		tier_def.conversion,
		tier_def.increment_value,
		tier_def.base_timer_wait_time,
		tier_def.max_conversion,
		defs
	)
	
	if is_inside_tree():
		_bind_model_signals()
		_populate_upgrade_grids()
		timer.wait_time = maxf(model.timer_wait_time, 0.05)
		update_all_ui()

func setup_with_model(p_model: CounterModel) -> void:
	model = p_model
	if is_inside_tree():
		_bind_model_signals()
		_populate_upgrade_grids()
		timer.wait_time = maxf(model.timer_wait_time, 0.05)
		update_all_ui()

func _bind_model_signals() -> void:
	if model == null:
		return
	model.value_changed.connect(_on_model_value_changed)
	model.xp_changed.connect(_on_model_xp_changed)
	model.star_points_changed.connect(_on_model_star_points_changed)
	model.stats_changed.connect(_on_model_stats_changed)
	model.crit_occurred.connect(_on_model_crit_occurred)
	model.level_up.connect(_on_model_level_up)

func _populate_upgrade_grids() -> void:
	if upgrade_grid != null:
		for child in upgrade_grid.get_children():
			child.queue_free()
		for def in model.get_standard_upgrades():
			var btn: BuyUpgrade = BUY_UPGRADE_SCENE.instantiate() as BuyUpgrade
			btn.name = def.id
			upgrade_grid.add_child(btn)
			btn.setup(model, def)
			
	if star_upgrade_grid != null:
		for child in star_upgrade_grid.get_children():
			child.queue_free()
		for def in model.get_star_upgrades():
			var btn: BuyUpgrade = BUY_UPGRADE_SCENE.instantiate() as BuyUpgrade
			btn.name = def.id
			star_upgrade_grid.add_child(btn)
			btn.setup(model, def)

func update_all_ui() -> void:
	if model == null:
		return
	_on_model_value_changed(model.counter_value, fmod(model.counter_value, model.conversion) if model.conversion > 0.0 else 0.0, model.conversion)
	_on_model_xp_changed(model.current_xp, model.xp_required, model.counter_level)
	_on_model_star_points_changed(model.star_points)
	_on_model_stats_changed()

func _on_model_value_changed(c_value: float, progress: float, conv: float) -> void:
	if hero_value_label != null:
		var hex_color: String = text_color.to_html(false)
		hero_value_label.text = "[center][b][color=#%s]%s[/color][/b][/center]" % [
			hex_color,
			Global_data.format_number(c_value)
		]
	if conversion_progress != null:
		conversion_progress.max_value = conv
		conversion_progress.value = progress
	if conversion_label != null:
		conversion_label.text = "%s / %s to convert" % [
			Global_data.format_number(progress),
			Global_data.format_number(conv)
		]

func _on_model_xp_changed(c_xp: float, req_xp: float, lvl: int) -> void:
	if counter_name_label != null and model != null:
		counter_name_label.text = "%s [Lv. %d]" % [model.tier_name, lvl]
	if xp_progress != null:
		xp_progress.max_value = req_xp
		xp_progress.value = c_xp
	if xp_label != null:
		xp_label.text = "XP: %s / %s" % [
			Global_data.format_number(c_xp),
			Global_data.format_number(req_xp)
		]

func _on_model_star_points_changed(pts: int) -> void:
	if star_button != null:
		if pts > 0:
			star_button.text = "★ %d" % pts
			star_button.modulate = Color(1.0, 0.85, 0.2, 1.0)
		else:
			star_button.text = "☆"
			star_button.modulate = Color(0.65, 0.70, 0.80, 1.0)

func _on_model_stats_changed() -> void:
	if model == null:
		return
	if timer != null:
		timer.wait_time = maxf(model.timer_wait_time, 0.05)
	if stat_yield_label != null:
		stat_yield_label.text = "Yield: +%s" % Global_data.format_number(model.get_effective_yield())
	if stat_speed_label != null:
		stat_speed_label.text = "Speed: %.1fs" % model.timer_wait_time
	if stat_rate_label != null:
		stat_rate_label.text = "Rate: %s/s" % Global_data.format_number(model.ms_1)
	if stat_crit_label != null:
		if model.super_crit_chance > 0.0:
			stat_crit_label.text = "Crit: %d%% | S: %d%%" % [
				int(round(model.crit_chance * 100.0)),
				int(round(model.super_crit_chance * 100.0))
			]
		else:
			stat_crit_label.text = "Crit: %d%% (x%d)" % [
				int(round(model.crit_chance * 100.0)),
				int(round(model.crit_power))
			]
	if manual_click_button != null:
		manual_click_button.text = "Collect (+%s)" % Global_data.format_number(model.get_effective_yield())

func _on_model_crit_occurred(is_super: bool) -> void:
	if is_super:
		_flash_color(Color(1.0, 0.85, 0.2, 1.0))
	else:
		_flash_color(Color(1.0, 0.65, 0.3, 1.0))

func _on_model_level_up(_new_level: int) -> void:
	_flash_color(Color(1.0, 0.84, 0.0, 1.0))

func _on_manual_click_button_pressed() -> void:
	if model != null:
		model.manual_click()
	if manual_click_button != null:
		var btn_tween: Tween = create_tween()
		btn_tween.tween_property(manual_click_button, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.05)
		btn_tween.tween_property(manual_click_button, "modulate", Color.WHITE, 0.1)

func _on_timer_timeout() -> void:
	if model != null:
		model.tick()

func _on_star_button_pressed() -> void:
	is_showing_star_upgrades = not is_showing_star_upgrades
	_update_upgrade_views()

func _update_upgrade_views() -> void:
	if upgrade_grid != null:
		upgrade_grid.visible = not is_showing_star_upgrades
	if star_upgrade_grid != null:
		star_upgrade_grid.visible = is_showing_star_upgrades
	if upgrades_title != null:
		upgrades_title.text = "STAR PERKS" if is_showing_star_upgrades else "UPGRADES"

func _flash_color(color: Color) -> void:
	text_color = color
	if color_tween != null and color_tween.is_valid():
		color_tween.kill()
	color_tween = create_tween()
	color_tween.tween_property(self, "text_color", Color.WHITE, 0.35)
	color_tween.tween_callback(func() -> void:
		if hero_value_label != null and model != null:
			var hex_color: String = Color.WHITE.to_html(false)
			hero_value_label.text = "[center][b][color=#%s]%s[/color][/b]" % [
				hex_color,
				Global_data.format_number(model.counter_value)
			]
	)

# Backwards compatibility helper methods
func get_effective_yield() -> float:
	return model.get_effective_yield() if model != null else increment_value

func check_milestone() -> void:
	if model != null:
		model.check_milestone()

func _add_xp(amount: float) -> void:
	if model != null:
		model.add_xp(amount)
