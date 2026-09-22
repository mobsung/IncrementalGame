class_name FloatingText
extends Label

signal animation_completed(instance: FloatingText)

var _tween: Tween = null

func _ready() -> void:
	top_level = true
	z_index = 50
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func activate(p_text: String, p_color: Color, p_start_pos: Vector2) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
		
	text = p_text
	modulate = p_color
	modulate.a = 1.0
	global_position = p_start_pos
	visible = true
	
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "global_position:y", global_position.y - 45.0, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 0.0, 0.65).set_ease(Tween.EASE_IN)
	_tween.set_parallel(false)
	_tween.tween_callback(deactivate)

func deactivate() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	visible = false
	animation_completed.emit(self)
