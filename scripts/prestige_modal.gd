class_name PrestigeModal
extends Control

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
	confirm_label.text = "Are you sure you want to Transcend?\n\n• Gain: +%d Astral Shards\n• Your active creatures and current Mana will reset\n• Permanent Astral Relics will boost all future runs forever!" % claimable
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
		current_points_label.text = "[b]Astral Shards:[/b] [color=#c084fc]✦ %d AS[/color]" % CurrencyManager.prestige_points

func _update_run_stats() -> void:
	if run_currency_label != null:
		run_currency_label.text = "Current Run Mana: %s" % GlobalData.format_number(CurrencyManager.run_currency_earned)
		
	var claimable: int = CurrencyManager.get_claimable_prestige_points()
	if claimable_points_label != null:
		claimable_points_label.text = "+%d AS" % claimable
		
	var next_tgt: float = CurrencyManager.get_next_point_target()
	if next_point_label != null:
		var needed: float = maxf(0.0, next_tgt - CurrencyManager.run_currency_earned)
		next_point_label.text = "Next Astral Shard at: %s Mana (%s remaining)" % [
			GlobalData.format_number(next_tgt),
			GlobalData.format_number(needed)
		]
		
	if prestige_progress_bar != null:
		prestige_progress_bar.max_value = 100.0
		prestige_progress_bar.value = CurrencyManager.get_prestige_progress() * 100.0
		
	if prestige_claim_button != null:
		if claimable > 0:
			prestige_claim_button.text = "✦ Transcend & Claim (+%d Astral Shards)" % claimable
			prestige_claim_button.disabled = false
		else:
			prestige_claim_button.text = "✦ Transcendence Locked (Requires %s Mana)" % GlobalData.format_number(CurrencyManager.PRESTIGE_BASE_CURRENCY)
			prestige_claim_button.disabled = true

func _update_upgrades() -> void:
	# Currency upgrade
	var c_lvl: int = CurrencyManager.prestige_currency_level
	var c_mult: float = 1.0 + float(c_lvl) * 1.0
	var c_cost: int = CurrencyManager.get_upgrade_cost("currency")
	if currency_upg_title != null:
		currency_upg_title.text = "Mana Resonance [Lv. %d]" % c_lvl
	if currency_upg_desc != null:
		currency_upg_desc.text = "Current: x%.1f Mana  ➔  Next: x%.1f Mana" % [c_mult, c_mult + 1.0]
	if currency_upg_btn != null:
		currency_upg_btn.text = "Attune [✦ %d AS]" % c_cost
		currency_upg_btn.disabled = not CurrencyManager.can_afford_prestige_upgrade("currency")

	# XP upgrade
	var x_lvl: int = CurrencyManager.prestige_xp_level
	var x_mult: float = 1.0 + float(x_lvl) * 1.0
	var x_cost: int = CurrencyManager.get_upgrade_cost("xp")
	if xp_upg_title != null:
		xp_upg_title.text = "Ancient Creature Wisdom [Lv. %d]" % x_lvl
	if xp_upg_desc != null:
		xp_upg_desc.text = "Current: x%.1f Creature XP  ➔  Next: x%.1f XP" % [x_mult, x_mult + 1.0]
	if xp_upg_btn != null:
		xp_upg_btn.text = "Attune [✦ %d AS]" % x_cost
		xp_upg_btn.disabled = not CurrencyManager.can_afford_prestige_upgrade("xp")

	# Slots upgrade
	var s_lvl: int = CurrencyManager.prestige_slots_level
	var s_bonus: int = s_lvl
	var s_cost: int = CurrencyManager.get_upgrade_cost("slots")
	if slots_upg_title != null:
		slots_upg_title.text = "Sanctuary Slot Expansion [Lv. %d]" % s_lvl
	if slots_upg_desc != null:
		slots_upg_desc.text = "Current: +%d extra slots  ➔  Next: +%d slots" % [s_bonus, s_bonus + 1]
	if slots_upg_btn != null:
		slots_upg_btn.text = "Attune [✦ %d AS]" % s_cost
		slots_upg_btn.disabled = not CurrencyManager.can_afford_prestige_upgrade("slots")
