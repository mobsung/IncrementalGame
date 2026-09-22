class_name FloatingTextManager
extends Control

const FLOATING_TEXT_SCENE: PackedScene = preload("res://scenes/floating_text.tscn")
const POOL_SIZE: int = 40

var _available_pool: Array[FloatingText] = []
var _active_pool: Array[FloatingText] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_initialize_pool()

func _initialize_pool() -> void:
	for i in range(POOL_SIZE):
		var ft: FloatingText = FLOATING_TEXT_SCENE.instantiate() as FloatingText
		add_child(ft)
		ft.animation_completed.connect(_on_text_animation_completed)
		_available_pool.append(ft)

func spawn_text(txt: String, color: Color, spawn_pos: Vector2) -> void:
	var ft: FloatingText = null
	if not _available_pool.is_empty():
		ft = _available_pool.pop_back()
	elif not _active_pool.is_empty():
		# Recycle the oldest active text if pool is saturated
		ft = _active_pool.pop_front()
	else:
		return
		
	_active_pool.append(ft)
	ft.activate(txt, color, spawn_pos)

func _on_text_animation_completed(instance: FloatingText) -> void:
	_active_pool.erase(instance)
	if not _available_pool.has(instance):
		_available_pool.append(instance)
