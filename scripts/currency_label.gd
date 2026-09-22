extends Control

@onready var main_label: RichTextLabel = %MainLabel

var _is_dirty: bool = false
var _accum_time: float = 0.0
const REFRESH_INTERVAL: float = 0.05

func _ready() -> void:
	CurrencyManager.currency_changed.connect(_on_currency_changed)
	update_ui()

func _process(delta: float) -> void:
	if _is_dirty:
		_accum_time += delta
		if _accum_time >= REFRESH_INTERVAL:
			_accum_time = 0.0
			_is_dirty = false
			update_ui()

func update_ui() -> void:
	if main_label != null:
		main_label.text = "[b]Mana:[/b] [color=#38bdf8]✦ %s[/color]" % GlobalData.format_number(CurrencyManager.current_currency)

func _on_currency_changed(_current_currency: float) -> void:
	_is_dirty = true
