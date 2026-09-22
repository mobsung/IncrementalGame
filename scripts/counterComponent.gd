class_name CounterComponent
extends Control

signal evolution_requested(model: CounterModel)
signal floating_text_requested(text: String, color: Color, spawn_pos: Vector2)

const BUY_UPGRADE_SCENE: PackedScene = preload("res://scenes/buyUpgrade.tscn")

const MIN_CRIT_TEXT_INTERVAL: float = 0.08
const MIN_PROC_TEXT_INTERVAL: float = 0.08
const HERO_LABEL_UPDATE_INTERVAL_MS: int = 40

var _last_crit_text_time: float = -1.0
var _last_proc_text_time: float = -1.0
var _last_hero_label_update_ms: int = 0

@export var counter_name: String = "Forest Sprite"
@export var conversion: float = 100.0
@export var increment_value: float = 5.0
@export var base_timer_wait_time: float = 1.0
@export var max_conversion: float = 1.0

var model: CounterModel = null
var is_showing_star_upgrades: bool = false
var text_color: Color = Color.WHITE
var color_tween: Tween = null

@onready var card_panel: PanelContainer = %CardPanel
@onready var full_art_background: TextureRect = %FullArtBackground
@onready var counter_name_label: Label = %CounterNameLabel
@onready var star_button: Button = %StarButton
@onready var element_badge: Label = %ElementBadge
@onready var creature_portrait: TextureRect = %CreaturePortrait
@onready var evolution_button: Button = %EvolutionButton
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

@onready var elemental_particles: CPUParticles2D = %ElementalParticles
@onready var portrait_frame: PanelContainer = $CardPanel/VBoxContainer/PortraitCenter/PortraitFrame

func _ready() -> void:
	if model == null:
		var start_def: CreatureDefinition = GlobalData.get_starting_creature()
		model = CounterModel.new()
		model.setup_from_definition(start_def)
		
	_bind_model_signals()
	_populate_upgrade_grids()
	
	timer.wait_time = maxf(model.timer_wait_time, 0.05)
	timer.start()
	update_all_ui()

func setup_with_creature(def: CreatureDefinition) -> void:
	model = CounterModel.new()
	model.setup_from_definition(def)
	
	if is_inside_tree():
		_bind_model_signals()
		_populate_upgrade_grids()
		timer.wait_time = maxf(model.timer_wait_time, 0.05)
		update_all_ui()

func setup_with_tier(_tier_def: Variant) -> void:
	var start_def: CreatureDefinition = GlobalData.get_starting_creature()
	setup_with_creature(start_def)

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
	model.elemental_proc_triggered.connect(_on_elemental_proc_triggered)
	model.evolution_ready.connect(_on_evolution_ready)
	model.evolved.connect(_on_creature_evolved)

func _populate_upgrade_grids() -> void:
	if upgrade_grid != null:
		for child in upgrade_grid.get_children():
			upgrade_grid.remove_child(child)
			child.queue_free()
		for def in model.get_standard_upgrades():
			var btn: BuyUpgrade = BUY_UPGRADE_SCENE.instantiate() as BuyUpgrade
			btn.name = def.id
			upgrade_grid.add_child(btn)
			btn.setup(model, def)
			
	if star_upgrade_grid != null:
		for child in star_upgrade_grid.get_children():
			star_upgrade_grid.remove_child(child)
			child.queue_free()
		for def in model.get_star_upgrades():
			var btn: BuyUpgrade = BUY_UPGRADE_SCENE.instantiate() as BuyUpgrade
			btn.name = def.id
			star_upgrade_grid.add_child(btn)
			btn.setup(model, def)

func update_all_ui() -> void:
	if model == null:
		return
	_update_creature_visuals()
	_on_model_value_changed(model.total_energy_accumulated, model.cycle_progress, model.conversion)
	_on_model_xp_changed(model.current_xp, model.xp_required, model.counter_level)
	_on_model_star_points_changed(model.star_points)
	_on_model_stats_changed()
	_on_evolution_ready(model.can_evolve())

func _update_creature_visuals() -> void:
	if model == null or model.definition == null:
		return
	var def: CreatureDefinition = model.definition
	if full_art_background != null:
		full_art_background.texture = def.portrait
	if creature_portrait != null:
		creature_portrait.texture = null
	if element_badge != null:
		element_badge.text = "✦ " + def.get_element_display()
		element_badge.modulate = def.element_color
	if counter_name_label != null:
		counter_name_label.text = "%s [Lv. %d]" % [def.display_name, model.counter_level]
		counter_name_label.modulate = def.element_color
	text_color = def.element_color

	# 1. Responsive Card Border & Glow based on Tier & Element
	if card_panel != null:
		var sb: StyleBoxFlat = card_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		var border_c: Color = def.element_color
		var shadow_c: Color = def.element_color
		shadow_c.a = 0.35
		
		match def.tier_rank:
			0:
				sb.border_width_left = 1
				sb.border_width_top = 1
				sb.border_width_right = 1
				sb.border_width_bottom = 1
				sb.border_color = Color(0.25, 0.35, 0.45, 0.8)
				sb.shadow_size = 6
			1:
				sb.border_width_left = 2
				sb.border_width_top = 2
				sb.border_width_right = 2
				sb.border_width_bottom = 2
				sb.border_color = border_c * 0.9
				sb.shadow_size = 10
				sb.shadow_color = shadow_c
			2:
				sb.border_width_left = 2
				sb.border_width_top = 2
				sb.border_width_right = 2
				sb.border_width_bottom = 2
				sb.border_color = border_c * 1.15
				sb.shadow_size = 14
				sb.shadow_color = shadow_c
			3:
				sb.border_width_left = 3
				sb.border_width_top = 3
				sb.border_width_right = 3
				sb.border_width_bottom = 3
				sb.border_color = Color(1.0, 0.85, 0.3, 1.0) # Mythic Gold trim
				sb.shadow_size = 20
				sb.shadow_color = shadow_c
				
		card_panel.add_theme_stylebox_override("panel", sb)

	# 2. Transparent Portrait Frame (shows full-art background cleanly)
	if portrait_frame != null:
		var psb: StyleBoxFlat = portrait_frame.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		psb.bg_color = Color(0, 0, 0, 0)
		psb.border_width_left = 0
		psb.border_width_top = 0
		psb.border_width_right = 0
		psb.border_width_bottom = 0
		portrait_frame.add_theme_stylebox_override("panel", psb)

	# 3. Responsive Conversion Progress Bar Fill
	if conversion_progress != null:
		var fsb: StyleBoxFlat = conversion_progress.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
		fsb.bg_color = def.element_color
		conversion_progress.add_theme_stylebox_override("fill", fsb)

	# 4. Responsive Elemental Particles
	if elemental_particles != null:
		elemental_particles.color = def.element_color
		match def.primary_element:
			"Fire":
				elemental_particles.gravity = Vector2(0, -50)
				elemental_particles.spread = 35.0
				elemental_particles.initial_velocity_min = 15.0
				elemental_particles.initial_velocity_max = 35.0
			"Water":
				elemental_particles.gravity = Vector2(0, -20)
				elemental_particles.spread = 20.0
				elemental_particles.initial_velocity_min = 8.0
				elemental_particles.initial_velocity_max = 20.0
			"Ice":
				elemental_particles.gravity = Vector2(0, 15)
				elemental_particles.spread = 45.0
				elemental_particles.initial_velocity_min = 5.0
				elemental_particles.initial_velocity_max = 15.0
			"Lightning":
				elemental_particles.gravity = Vector2(0, 0)
				elemental_particles.spread = 180.0
				elemental_particles.initial_velocity_min = 25.0
				elemental_particles.initial_velocity_max = 50.0
			"Earth":
				elemental_particles.gravity = Vector2(0, -10)
				elemental_particles.spread = 90.0
				elemental_particles.initial_velocity_min = 5.0
				elemental_particles.initial_velocity_max = 15.0
			"Darkness":
				elemental_particles.gravity = Vector2(0, -25)
				elemental_particles.spread = 60.0
				elemental_particles.initial_velocity_min = 10.0
				elemental_particles.initial_velocity_max = 25.0
			_:
				elemental_particles.gravity = Vector2(0, -15)
				elemental_particles.spread = 45.0
				elemental_particles.initial_velocity_min = 10.0
				elemental_particles.initial_velocity_max = 25.0
		elemental_particles.restart()

func _on_elemental_proc_triggered(p_name: String, p_color: Color, p_mana: float) -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	if _last_proc_text_time >= 0.0 and now - _last_proc_text_time < MIN_PROC_TEXT_INTERVAL:
		return
	_last_proc_text_time = now
	_flash_color(p_color)
	_spawn_floating_text("✨ %s (+%s)" % [p_name, GlobalData.format_number(p_mana)], p_color)

func _on_model_value_changed(_total: float, progress: float, conv: float) -> void:
	if conversion_progress != null:
		conversion_progress.max_value = conv
		conversion_progress.value = progress

	var now_ms: int = Time.get_ticks_msec()
	if now_ms - _last_hero_label_update_ms >= HERO_LABEL_UPDATE_INTERVAL_MS or progress >= conv or progress == 0.0:
		_last_hero_label_update_ms = now_ms
		if hero_value_label != null:
			var hex_color: String = text_color.to_html(false)
			hero_value_label.text = "[center][b][color=#%s]%s / %s[/color][/b][/center]" % [
				hex_color,
				GlobalData.format_number(progress),
				GlobalData.format_number(conv)
			]
		if conversion_label != null:
			conversion_label.text = "%s / %s to discharge Mana" % [
				GlobalData.format_number(progress),
				GlobalData.format_number(conv)
			]

func _on_model_xp_changed(c_xp: float, req_xp: float, lvl: int) -> void:
	if counter_name_label != null and model != null:
		counter_name_label.text = "%s [Lv. %d]" % [model.tier_name, lvl]
	if xp_progress != null:
		xp_progress.max_value = req_xp
		xp_progress.value = c_xp
	if xp_label != null:
		xp_label.text = "XP: %s / %s" % [
			GlobalData.format_number(c_xp),
			GlobalData.format_number(req_xp)
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
		stat_yield_label.text = "Yield: +%s" % GlobalData.format_number(model.get_effective_yield())
	if stat_speed_label != null:
		stat_speed_label.text = "Speed: %.2fs" % model.timer_wait_time
	if stat_rate_label != null:
		stat_rate_label.text = "Rate: %s/s" % GlobalData.format_number(model.ms_1)
	if stat_crit_label != null:
		if model.super_crit_chance > 0.0:
			stat_crit_label.add_theme_font_size_override("font_size", 9)
			stat_crit_label.text = "Crit: %d%% | SC: %d%% (x%.1f)" % [
				int(round(model.crit_chance * 100.0)),
				int(round(model.super_crit_chance * 100.0)),
				model.crit_power * model.super_crit_power
			]
		else:
			stat_crit_label.add_theme_font_size_override("font_size", 10)
			stat_crit_label.text = "Crit: %d%% (x%.1f)" % [
				int(round(model.crit_chance * 100.0)),
				model.crit_power
			]
	if manual_click_button != null:
		manual_click_button.text = "Channel (+%s)" % GlobalData.format_number(model.get_effective_yield())

func _on_model_crit_occurred(is_super: bool, multiplier: float, energy_added: float) -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	if not is_super and _last_crit_text_time >= 0.0 and now - _last_crit_text_time < MIN_CRIT_TEXT_INTERVAL:
		return
	_last_crit_text_time = now
	var color: Color = Color("#f59e0b") if not is_super else Color("#c084fc")
	_flash_color(color)
	var formatted_energy: String = GlobalData.format_number(energy_added)
	var tag: String = "CRIT x%.1f (+%s)" % [multiplier, formatted_energy] if not is_super else "SUPER CRIT x%.1f (+%s)" % [multiplier, formatted_energy]
	_spawn_floating_text(tag, color)

func _on_model_level_up(new_level: int) -> void:
	_flash_color(Color("#eab308"))
	_spawn_floating_text("LEVEL UP! [Lv. %d]" % new_level, Color("#eab308"))

func _on_evolution_ready(is_ready: bool) -> void:
	if evolution_button != null:
		evolution_button.visible = is_ready

func _on_creature_evolved(_new_def: CreatureDefinition) -> void:
	_update_creature_visuals()
	_populate_upgrade_grids()
	_on_model_stats_changed()
	_spawn_floating_text("✨ ASCENDED & EVOLVED!", Color("#f59e0b"))

func _spawn_floating_text(txt: String, color: Color) -> void:
	if manual_click_button == null or not is_inside_tree():
		return
	var spawn_pos: Vector2 = manual_click_button.global_position + Vector2(randf_range(20.0, 120.0), -10.0)
	floating_text_requested.emit(txt, color, spawn_pos)

func _on_manual_click_button_pressed() -> void:
	if model != null:
		var res: Dictionary = model.manual_click()
		if not res["is_crit"]:
			_spawn_floating_text("+%s" % GlobalData.format_number(res["value"]), Color("#38bdf8"))
	if manual_click_button != null:
		var btn_tween: Tween = create_tween()
		btn_tween.tween_property(manual_click_button, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.05)
		btn_tween.tween_property(manual_click_button, "modulate", Color.WHITE, 0.1)

func _on_evolution_button_pressed() -> void:
	if model != null:
		evolution_requested.emit(model)

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
		upgrades_title.text = "STAR TALENTS" if is_showing_star_upgrades else "UPGRADES"

func _flash_color(color: Color) -> void:
	text_color = color
	if color_tween != null and color_tween.is_valid():
		return
	color_tween = create_tween()
	color_tween.tween_property(self, "text_color", model.element_color if model != null else Color.WHITE, 0.35)
