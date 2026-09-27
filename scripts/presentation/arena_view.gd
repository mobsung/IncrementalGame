class_name ArenaView
extends Control
## Full field artwork with an invertible ground projection. Combat stays in logical space.

signal slot_selected(index: int)
signal actor_selected(id: int)

const BACKGROUND: Texture2D = preload("res://assets/battle/field_concept_v1.jpeg")
const JOHN: CombatantVisual = preload("res://resources/ui/john_visual.tres")
const STONE: CombatantVisual = preload("res://resources/ui/stone_visual.tres")
const EMBER: CombatantVisual = preload("res://resources/ui/ember_visual.tres")
const WARDEN: CombatantVisual = preload("res://resources/ui/warden_visual.tres")
const GOLD: Color = Color("#edce88")

var simulation: BattleSimulation
var selected_id: int = 0
var formation_visible: bool = false
var effects: Array[Dictionary] = []
var scale_factor: float = 1.0
var origin: Vector2 = Vector2.ZERO
var elapsed: float = 0.0
var ordered_actors: Array[CombatantState] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true

func bind(model: BattleSimulation) -> void:
	simulation = model
	simulation.effects_emitted.connect(_on_effects)
	queue_redraw()

func _on_effects(events: Array[Dictionary]) -> void:
	for event: Dictionary in events:
		var visual: Dictionary = event.duplicate()
		visual["life"] = 0.55 if event.kind == "sweep" else 0.7
		effects.append(visual)

func _process(delta: float) -> void:
	elapsed += delta
	for index: int in range(effects.size() - 1, -1, -1):
		effects[index].life -= delta
		if effects[index].life <= 0.0:
			effects.remove_at(index)
	queue_redraw()

func _update_transform() -> void:
	scale_factor = maxf(size.x / FieldProjection.CANVAS.x, size.y / FieldProjection.CANVAS.y)
	origin = (size - FieldProjection.CANVAS * scale_factor) * 0.5

func _draw() -> void:
	_update_transform()
	draw_set_transform(origin, 0.0, Vector2.ONE * scale_factor)
	draw_texture_rect(BACKGROUND, Rect2(Vector2.ZERO, FieldProjection.CANVAS), false)
	if simulation == null:
		draw_set_transform(Vector2.ZERO)
		return
	if formation_visible:
		var occupied_slots: Dictionary = {}
		for copy: UnitProgress in simulation.deployed_units():
			occupied_slots[copy.slot] = true
		for index: int in range(simulation.config.slots.size()):
			var point: Vector2 = FieldProjection.project(simulation.config.slots[index])
			var occupied: bool = occupied_slots.has(index)
			_ellipse(point, Vector2(30, 11), GOLD if occupied else Color(0.95, 0.9, 0.72, 0.65), false)
			_text(point + Vector2(-5, 26), str(index + 1), 17, GOLD)
	var selected: CombatantState = Targeting.by_id(simulation.actors, selected_id)
	if selected != null:
		_range(selected.position, selected.attack_range, Color(0.6, 0.95, 0.86, 0.8), false)
		if selected.allied:
			_range(selected.anchor, simulation.config.ally.engagement_radius, Color(0.95, 0.8, 0.5, 0.75), true)
			draw_dashed_line(FieldProjection.project(selected.anchor), FieldProjection.project(selected.position), GOLD, 2, 8)
	ordered_actors.assign(simulation.actors)
	ordered_actors.sort_custom(func(a: CombatantState, b: CombatantState) -> bool:
		return _visual_position(a).y < _visual_position(b).y)
	for actor: CombatantState in ordered_actors:
		_draw_actor(actor)
	for effect: Dictionary in effects:
		_draw_effect(effect)
	draw_set_transform(Vector2.ZERO)

func _visual(actor: CombatantState) -> CombatantVisual:
	if actor.allied:
		return JOHN
	if actor.definition_id == simulation.config.offensive.id:
		return EMBER
	if actor.definition_id == simulation.config.special.id:
		return WARDEN
	return STONE

func _visual_position(actor: CombatantState) -> Vector2:
	var point: Vector2 = FieldProjection.project(actor.position)
	if not actor.allied:
		# Only artwork separates overlapping enemies; hit tests use this same offset.
		point += Vector2.from_angle(float(actor.id) * 2.39996) * (8 + actor.id % 4 * 5)
	return point

func _actor_rect(actor: CombatantState) -> Rect2:
	var visual: CombatantVisual = _visual(actor)
	var height: float = visual.height * FieldProjection.depth_scale(actor.position)
	var width: float = height * visual.texture.get_width() / visual.texture.get_height()
	var foot: Vector2 = _visual_position(actor)
	return Rect2(foot - Vector2(width * 0.5, height), Vector2(width, height))

func _draw_actor(actor: CombatantState) -> void:
	var visual: CombatantVisual = _visual(actor)
	var rect: Rect2 = _actor_rect(actor)
	var foot: Vector2 = _visual_position(actor)
	_ellipse(foot, Vector2(rect.size.x * 0.34, 9), Color(0.05, 0.035, 0.02, 0.5), true)
	if actor.allied:
		_ellipse(foot, Vector2(28, 9), GOLD, false)
	else:
		draw_line(foot + Vector2(-8, 3), foot + Vector2(0, 8), Color("#e9947a"), 2)
		draw_line(foot + Vector2(0, 8), foot + Vector2(8, 3), Color("#e9947a"), 2)
	var bob: float = sin(elapsed * 2.5 + actor.id) * 1.5 if actor.alive() else 0.0
	rect.position.y += bob
	var tint: Color = visual.tint if actor.alive() else Color(0.45, 0.45, 0.45, 0.65)
	if (actor.facing.x > 0.0) != visual.faces_right:
		rect.position.x += rect.size.x
		rect.size.x = -rect.size.x
	draw_texture_rect(visual.texture, rect, false, tint)
	var bar: Rect2 = Rect2(foot + Vector2(-32, -absf(rect.size.y) - 12), Vector2(64, 5))
	draw_rect(bar.grow(2), Color(0.04, 0.04, 0.04, 0.85))
	bar.size.x *= actor.health / actor.max_health
	draw_rect(bar, Color("#b7d5a2") if actor.allied else Color("#db7860"))
	if actor.id == selected_id:
		_text(foot + Vector2(-42, 32), "%.0f / %.0f" % [actor.health, actor.max_health], 17, Color.WHITE)
	if actor.action == &"sweep":
		var progress: float = 1.0 - actor.action_left / simulation.config.ally.ability.cast_time
		draw_line(foot + Vector2(-32, 15), foot + Vector2(-32 + 64 * progress, 15), GOLD, 4)

func _ellipse(center: Vector2, radius: Vector2, color: Color, filled: bool) -> void:
	var points: PackedVector2Array = []
	for index: int in range(41):
		points.append(center + Vector2.from_angle(TAU * index / 40.0) * radius)
	if filled:
		draw_colored_polygon(points, color)
	else:
		draw_polyline(points, color, 2.0, true)

func _range(center: Vector2, radius: float, color: Color, dashed: bool) -> void:
	for index: int in range(96):
		if dashed and index % 4 >= 2:
			continue
		var a: Vector2 = center + Vector2.from_angle(TAU * index / 96.0) * radius
		var b: Vector2 = center + Vector2.from_angle(TAU * (index + 1) / 96.0) * radius
		if simulation.config.arena.has_point(a) and simulation.config.arena.has_point(b):
			draw_line(FieldProjection.project(a), FieldProjection.project(b), color, 2, true)

func _draw_effect(effect: Dictionary) -> void:
	var alpha: float = clampf(effect.life / 0.55, 0, 1)
	var point: Vector2 = FieldProjection.project(effect.position)
	if effect.kind == "sweep":
		var polygon: PackedVector2Array = [point]
		var half: float = deg_to_rad(effect.angle * 0.5)
		var facing: Vector2 = effect.facing
		for index: int in range(25):
			polygon.append(FieldProjection.project(effect.position + Vector2.from_angle(facing.angle() - half + half * 2 * index / 24.0) * float(effect.radius)))
		draw_colored_polygon(polygon, Color(0.96, 0.8, 0.5, alpha * 0.35))
		draw_polyline(polygon, Color(1, 0.92, 0.7, alpha), 3, true)
	else:
		var color: Color = Color(0.65, 1, 0.6, alpha) if effect.kind == "heal" else Color(1, 0.93, 0.8, alpha)
		_text(point + Vector2(-8, -100 - (0.7 - effect.life) * 50), ("+" if effect.kind == "heal" else "") + "%.0f" % effect.amount, 23, color)

func _text(point: Vector2, text: String, font_size: int, color: Color) -> void:
	draw_string_outline(ThemeDB.fallback_font, point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color(0.05, 0.04, 0.03, color.a))
	draw_string(ThemeDB.fallback_font, point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _gui_input(event: InputEvent) -> void:
	if simulation == null or not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	_update_transform()
	var point: Vector2 = (event.position - origin) / scale_factor
	if formation_visible and simulation.phase != &"battle":
		for index: int in range(simulation.config.slots.size()):
			if point.distance_to(FieldProjection.project(simulation.config.slots[index])) < 30:
				slot_selected.emit(index)
				return
	# Frontmost sprite gets the click; the lower body is not a top-down token.
	for index: int in range(ordered_actors.size() - 1, -1, -1):
		var actor: CombatantState = ordered_actors[index]
		if _actor_rect(actor).has_point(point):
			selected_id = actor.id
			actor_selected.emit(actor.id)
			return
	selected_id = 0
