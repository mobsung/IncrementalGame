extends Control

@onready var main_label: RichTextLabel = %MainLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CurrencyManager.currency_changed.connect(_on_currency_changed)
	update_ui()

func update_ui() -> void:
	main_label.text = "Money: " + str(CurrencyManager.current_currency)
	
	
func _on_currency_changed(_current_currency: int) -> void:
	update_ui()
	
