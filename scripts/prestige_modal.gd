extends Control
class_name PrestigeModal

signal prestige_executed(points_gained: int)
signal modal_closed()

@onready var close_button: Button = %CloseButton
@onready var backdrop_button: Button = %BackdropButton
@onready var current_points_label: RichTextLabel = %CurrentPointsLabel

# Run stats & claim
@onready var run_currency_label: Label = %RunCurrencyLabel
@onready var claimable_points_label: Label = %ClaimablePointsLabel
@onready var next_point_label: Label = %NextPointLabel
@onready var prestige_progress_bar: ProgressBar = %PrestigeProgressBar
@onready var prestige_claim_button: Button = %PrestigeClaimButton

# Confirmation box
@onready var confirm_container: PanelContainer = %ConfirmContainer
@onready var confirm_label: Label = %ConfirmLabel
@onready var confirm_yes_button: Button = %ConfirmYesButton
@onready var confirm_no_button: Button = %ConfirmNoButton

# Upgrades
@onready var currency_upg_title: Label = %CurrencyUpgTitle
@onready var currency_upg_desc: Label = %CurrencyUpgDesc
@onready var currency_upg_btn: Button = %CurrencyUpgBtn

@onready var xp_upg_title: Label = %XpUpgTitle
@onready var xp_upg_desc: Label = %XpUpgDesc
@onready var xp_upg_btn: Button = %XpUpgBtn

@onready var slots_upg_title: Label = %SlotsUpgTitle
@onready var slots_upg_desc: Label = %SlotsUpgDesc
@onready var slots_upg_btn: Button = %SlotsUpgBtn

func _ready() -> void:
	close_button.pressed.connect(close_modal)
	if backdrop_button != null:
		backdrop_button.pressed.connect(close_modal)
		
	prestige_claim_button.pressed.connect(_on_claim_pressed)
	confirm_yes_button.pressed.connect(_on_confirm_prestige)
	confirm_no_button.pressed.connect(_on_cancel_prestige)
	
	currency_upg_btn.pressed.connect(func() -> void:
		CurrencyManager.buy_prestige_upgrade("currency")
		update_ui()
	)
	xp_upg_btn.pressed.connect(func() -> void:
		CurrencyManager.buy_prestige_upgrade("xp")
		update_ui()
	)
	slots_upg_btn.pressed.connect(func() -> void:
		CurrencyManager.buy_prestige_upgrade("slots")
		update_ui()
	)
	
	CurrencyManager.currency_changed.connect(func(_amount: float) -> void:
		if visible:
			_update_run_stats()
	)
	CurrencyManager.prestige_points_changed.connect(func(_pts: int) -> void:
		if visible:
			update_ui()
	)
	CurrencyManager.prestige_upgrades_changed.connect(func() -> void:
		if visible:
			update_ui()
	)
	
	confirm_container.visible = false
	update_ui()

func open_modal() -> void:
	confirm_container.visible = false
	visible = true
	update_ui()

func close_modal() -> void:
	confirm_container.visible = false
	visible = false
	modal_closed.emit()

func _on_claim_pressed() -> void:
	var claimable: int = CurrencyManager.get_claimable_prestige_points()
	if claimable <= 0:
		return
	confirm_label.text = "Sei sicuro di voler eseguire il Prestigio?\n\n• Riceverai: +%d Punti Prestigio\n• Verranno resettati i contatori e le monete correnti\n• I potenziamenti prestigio resteranno attivi per sempre!" % claimable
	confirm_container.visible = true

func _on_cancel_prestige() -> void:
	confirm_container.visible = false

func _on_confirm_prestige() -> void:
	confirm_container.visible = false
	var gained: int = CurrencyManager.execute_prestige()
	prestige_executed.emit(gained)
	update_ui()

func update_ui() -> void:
	_update_wallet()
	_update_run_stats()
	_update_upgrades()

func _update_wallet() -> void:
	if current_points_label != null:
		current_points_label.text = "[b]Punti Prestigio:[/b] [color=#c084fc]✦ %d PP[/color]" % CurrencyManager.prestige_points

func _update_run_stats() -> void:
	if run_currency_label != null:
		run_currency_label.text = "Monete Run Attuale: %s" % Global_data.format_number(CurrencyManager.run_currency_earned)
		
	var claimable: int = CurrencyManager.get_claimable_prestige_points()
	if claimable_points_label != null:
		claimable_points_label.text = "+%d PP" % claimable
		
	var next_tgt: float = CurrencyManager.get_next_point_target()
	var prev_tgt: float = CurrencyManager.get_current_point_threshold()
	if next_point_label != null:
		var needed: float = maxf(0.0, next_tgt - CurrencyManager.run_currency_earned)
		next_point_label.text = "Prossimo punto a: %s monete (mancano %s)" % [
			Global_data.format_number(next_tgt),
			Global_data.format_number(needed)
		]
		
	if prestige_progress_bar != null:
		prestige_progress_bar.max_value = 100.0
		prestige_progress_bar.value = CurrencyManager.get_prestige_progress() * 100.0
		
	if prestige_claim_button != null:
		if claimable > 0:
			prestige_claim_button.text = "✦ Esegui Prestigio (+%d PP)" % claimable
			prestige_claim_button.disabled = false
		else:
			prestige_claim_button.text = "✦ Prestigio Non Disponibile (minimo 100k monete)"
			prestige_claim_button.disabled = true

func _update_upgrades() -> void:
	# Currency upgrade
	var c_lvl: int = CurrencyManager.prestige_currency_level
	var c_mult: float = 1.0 + float(c_lvl) * 1.0
	var c_cost: int = CurrencyManager.get_upgrade_cost("currency")
	if currency_upg_title != null:
		currency_upg_title.text = "Moltiplicatore Valuta [Liv. %d]" % c_lvl
	if currency_upg_desc != null:
		currency_upg_desc.text = "Attuale: x%.1f monete  ➔  Prossimo: x%.1f monete" % [c_mult, c_mult + 1.0]
	if currency_upg_btn != null:
		currency_upg_btn.text = "Migliora [✦ %d PP]" % c_cost
		currency_upg_btn.disabled = not CurrencyManager.can_afford_prestige_upgrade("currency")

	# XP upgrade
	var x_lvl: int = CurrencyManager.prestige_xp_level
	var x_mult: float = 1.0 + float(x_lvl) * 1.0
	var x_cost: int = CurrencyManager.get_upgrade_cost("xp")
	if xp_upg_title != null:
		xp_upg_title.text = "Saggezza Globale XP [Liv. %d]" % x_lvl
	if xp_upg_desc != null:
		xp_upg_desc.text = "Attuale: x%.1f XP contatori  ➔  Prossimo: x%.1f XP" % [x_mult, x_mult + 1.0]
	if xp_upg_btn != null:
		xp_upg_btn.text = "Migliora [✦ %d PP]" % x_cost
		xp_upg_btn.disabled = not CurrencyManager.can_afford_prestige_upgrade("xp")

	# Slots upgrade
	var s_lvl: int = CurrencyManager.prestige_slots_level
	var s_bonus: int = s_lvl
	var s_cost: int = CurrencyManager.get_upgrade_cost("slots")
	if slots_upg_title != null:
		slots_upg_title.text = "Espansione Spazio Contatori [Liv. %d]" % s_lvl
	if slots_upg_desc != null:
		slots_upg_desc.text = "Attuale: +%d slot extra  ➔  Prossimo: +%d slot" % [s_bonus, s_bonus + 1]
	if slots_upg_btn != null:
		slots_upg_btn.text = "Migliora [✦ %d PP]" % s_cost
		slots_upg_btn.disabled = not CurrencyManager.can_afford_prestige_upgrade("slots")
