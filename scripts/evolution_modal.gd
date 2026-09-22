class_name EvolutionModal
extends Control

signal evolution_selected(creature_def: CreatureDefinition)
signal modal_closed()

var target_model: CounterModel = null

@onready var backdrop_button: Button = %BackdropButton
@onready var close_button: Button = %CloseButton
@onready var options_container: HBoxContainer = %OptionsContainer

# Option A references
@onready var opt_a_card: PanelContainer = %OptACard
@onready var opt_a_lineage: Label = %OptALineageBadge
@onready var opt_a_portrait: TextureRect = %OptAPortrait
@onready var opt_a_name: Label = %OptAName
@onready var opt_a_element: Label = %OptAElement
@onready var opt_a_desc: Label = %OptADesc
@onready var opt_a_proc: Label = %OptAProc
@onready var opt_a_stats: Label = %OptAStats
@onready var opt_a_button: Button = %OptAButton

# Option B references
@onready var opt_b_card: PanelContainer = %OptBCard
@onready var opt_b_lineage: Label = %OptBLineageBadge
@onready var opt_b_portrait: TextureRect = %OptBPortrait
@onready var opt_b_name: Label = %OptBName
@onready var opt_b_element: Label = %OptBElement
@onready var opt_b_desc: Label = %OptBDesc
@onready var opt_b_proc: Label = %OptBProc
@onready var opt_b_stats: Label = %OptBStats
@onready var opt_b_button: Button = %OptBButton

# Option C references
@onready var opt_c_card: PanelContainer = %OptCCard
@onready var opt_c_lineage: Label = %OptCLineageBadge
@onready var opt_c_portrait: TextureRect = %OptCPortrait
@onready var opt_c_name: Label = %OptCName
@onready var opt_c_element: Label = %OptCElement
@onready var opt_c_desc: Label = %OptCDesc
@onready var opt_c_proc: Label = %OptCProc
@onready var opt_c_stats: Label = %OptCStats
@onready var opt_c_button: Button = %OptCButton

var option_a_def: CreatureDefinition = null
var option_b_def: CreatureDefinition = null
var option_c_def: CreatureDefinition = null

func _ready() -> void:
	if backdrop_button != null:
		backdrop_button.pressed.connect(close_modal)
	if close_button != null:
		close_button.pressed.connect(close_modal)
		
	if opt_a_button != null:
		opt_a_button.pressed.connect(_on_opt_a_selected)
	if opt_b_button != null:
		opt_b_button.pressed.connect(_on_opt_b_selected)
	if opt_c_button != null:
		opt_c_button.pressed.connect(_on_opt_c_selected)
		
	visible = false

func open_for_model(p_model: CounterModel) -> void:
	target_model = p_model
	var options: Array[CreatureDefinition] = p_model.get_evolution_options()
	if options.is_empty():
		return
		
	option_a_def = options[0] if options.size() > 0 else null
	option_b_def = options[1] if options.size() > 1 else null
	option_c_def = options[2] if options.size() > 2 else null
	
	_populate_card(opt_a_card, option_a_def, opt_a_lineage, opt_a_portrait, opt_a_name, opt_a_element, opt_a_desc, opt_a_proc, opt_a_stats, opt_a_button)
	_populate_card(opt_b_card, option_b_def, opt_b_lineage, opt_b_portrait, opt_b_name, opt_b_element, opt_b_desc, opt_b_proc, opt_b_stats, opt_b_button)
	_populate_card(opt_c_card, option_c_def, opt_c_lineage, opt_c_portrait, opt_c_name, opt_c_element, opt_c_desc, opt_c_proc, opt_c_stats, opt_c_button)
	
	visible = true

func close_modal() -> void:
	visible = false
	modal_closed.emit()

func _populate_card(p_card: PanelContainer, def: CreatureDefinition, p_lineage: Label, p_portrait: TextureRect, p_name: Label, p_elem: Label, p_desc: Label, p_proc: Label, p_stats: Label, p_btn: Button) -> void:
	if def == null:
		if p_card != null:
			p_card.visible = false
		return
		
	if p_card != null:
		p_card.visible = true
		var csb: StyleBoxFlat = p_card.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		csb.border_color = def.element_color
		csb.border_width_left = 2
		csb.border_width_top = 2
		csb.border_width_right = 2
		csb.border_width_bottom = 2
		p_card.add_theme_stylebox_override("panel", csb)
		
	if p_lineage != null:
		if def.is_pure:
			p_lineage.text = "✦ PURE ANCESTRY"
			p_lineage.modulate = Color(1.0, 0.82, 0.25, 1.0)
		elif not def.tertiary_element.is_empty():
			p_lineage.text = "✦ TRI-ELEMENTAL APEX"
			p_lineage.modulate = Color(0.85, 0.55, 1.0, 1.0)
		else:
			p_lineage.text = "✦ DUAL HYBRID"
			p_lineage.modulate = Color(0.35, 0.85, 1.0, 1.0)
			
	if p_portrait != null:
		p_portrait.texture = def.portrait
	if p_name != null:
		p_name.text = def.display_name
		p_name.modulate = def.element_color
	if p_elem != null:
		p_elem.text = "✦ " + def.get_element_display()
		p_elem.modulate = def.element_color
	if p_desc != null:
		p_desc.text = def.description
	if p_proc != null:
		p_proc.text = "⚡ %s: %s" % [def.proc_name, def.proc_description]
		p_proc.modulate = def.proc_color
	if p_stats != null:
		p_stats.text = "Yield: x%.1f  •  Spd Cap: %.2fs\nFlow Cap: %d  •  Crit Cap: %d%%" % [
			def.yield_multiplier,
			def.speed_cap,
			int(def.flow_cap),
			int(round(def.crit_cap * 100.0))
		]
	if p_btn != null:
		p_btn.text = "Evolve to %s" % def.display_name

func _on_opt_a_selected() -> void:
	if option_a_def != null and target_model != null:
		target_model.evolve_to(option_a_def)
		evolution_selected.emit(option_a_def)
	close_modal()

func _on_opt_b_selected() -> void:
	if option_b_def != null and target_model != null:
		target_model.evolve_to(option_b_def)
		evolution_selected.emit(option_b_def)
	close_modal()

func _on_opt_c_selected() -> void:
	if option_c_def != null and target_model != null:
		target_model.evolve_to(option_c_def)
		evolution_selected.emit(option_c_def)
	close_modal()
