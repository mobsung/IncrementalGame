class_name NavigationPanels
extends PanelContainer

signal section_changed(section: StringName)

var current_section: StringName = &""
const TITLES: Dictionary = {&"battle": "Battle controls", &"units": "Collection & squad", &"chrono": "Chrono", &"shop": "Global shop"}

func _ready() -> void:
	%ClosePanel.pressed.connect(close)
	hide()

func toggle(section: StringName) -> void:
	if visible and current_section == section:
		close()
	else:
		show_section(section)

func show_section(section: StringName) -> void:
	if not TITLES.has(section):
		return
	current_section = section
	for page: Control in %Pages.get_children():
		page.visible = String(page.name).to_lower() == String(section)
	%PanelTitle.text = TITLES[section]
	%PanelScroll.scroll_vertical = 0
	show()
	section_changed.emit(section)
	%ClosePanel.grab_focus()

func close() -> void:
	hide()
	current_section = &""
	section_changed.emit(current_section)

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
