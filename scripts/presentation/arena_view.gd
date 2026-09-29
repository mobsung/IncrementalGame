class_name ArenaView
extends Control
## Full field artwork with an invertible ground projection. Combat stays in logical space.

signal slot_selected(index: int)
signal actor_selected(id: int)

const BACKGROUND: Texture2D = preload("res://assets/battle/field_concept_v1.jpeg")
const STONE: CombatantVisual = preload("res://content/enemies/balanced/visuals/stone_visual.tres")
const EMBER: CombatantVisual = preload("res://content/enemies/offensive/visuals/ember_visual.tres")
const WARDEN: CombatantVisual = preload("res://content/enemies/special/visuals/warden_visual.tres")
const GOLD: Color = Color("#edce88")

var simulation: BattleSimulation
var selected_id: int = 0
var formation_visible: bool = false
var effects: Array[Dictionary] = []
var scale_factor: float = 1.0
var origin: Vector2 = Vector2.ZERO
var elapsed: float = 0.0
var ordered_actors: Array[CombatantState] = []
var motion_players: Dictionary = {}
var motion_actors: Dictionary = {}
var death_echoes: Array[Dictionary] = []
var retired_motion_players: Array[RefCounted] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true

func bind(model: BattleSimulation) -> void:
	if simulation != null and simulation.effects_emitted.is_connected(_on_effects):
		simulation.effects_emitted.disconnect(_on_effects)
	for player: RefCounted in motion_players.values():
		retired_motion_players.append(player)
	for echo: Dictionary in death_echoes:
		retired_motion_players.append(echo.player)
	motion_players.clear()
	motion_actors.clear()
	effects.clear()
	death_echoes.clear()
	simulation = model
	simulation.effects_emitted.connect(_on_effects)
	queue_redraw()

func _on_effects(events: Array[Dictionary]) -> void:
	for event: Dictionary in events:
		var actor: CombatantState = Targeting.by_id(simulation.actors, int(event.get("target_id", 0)))
		if event.kind == "death":
			if actor != null and _visual(actor).animation != null:
				var ghost: CombatantState = CombatantState.from_data(actor.to_data())
				var visual_definition: CombatantVisual = _visual(actor)
				var death_player: RefCounted = visual_definition.animation.create_player()
				ghost.health = ghost.max_health
				death_player.update(ghost, 0.0)
				ghost.health = 0.0
				death_echoes.append({"actor":ghost, "original":actor, "visual":visual_definition, "player":death_player, "life":0.85})
			continue
		if actor != null:
			var player: RefCounted = _motion(actor)
			if player != null:
				player.react(event)
		var visual: Dictionary = event.duplicate()
		visual["life"] = 0.55 if event.kind == "sweep" else 0.7
		effects.append(visual)

func _process(delta: float) -> void:
	var animate: bool = simulation == null or simulation.phase != &"paused"
	var visual_delta: float = delta if animate else 0.0
	# Let a lethal impact finish visually even when the model immediately rolls back.
	for index: int in range(death_echoes.size() - 1, -1, -1):
		var echo: Dictionary = death_echoes[index]
		echo.life -= delta
		echo.player.update(echo.actor, delta)
		if echo.life <= 0.0:
			retired_motion_players.append(echo.player)
			death_echoes.remove_at(index)
	elapsed += visual_delta
	if simulation != null:
		var retained: Dictionary = {}
		for actor: CombatantState in simulation.actors:
			var player: RefCounted = _motion(actor)
			if player != null:
				player.update(actor, visual_delta, animate)
				retained[actor.id] = true
		for id: int in motion_players.keys():
			if not retained.has(id):
				retired_motion_players.append(motion_players[id])
				motion_players.erase(id)
				motion_actors.erase(id)
	for index: int in range(effects.size() - 1, -1, -1):
		effects[index].life -= visual_delta
		if effects[index].life <= 0.0:
			effects.remove_at(index)
	queue_redraw()

func _motion(actor: CombatantState) -> RefCounted:
	var visual: CombatantVisual = _visual(actor)
	if visual.animation == null:
		return null
	if motion_actors.get(actor.id) != actor or not motion_players.has(actor.id) or motion_players[actor.id].rig != visual.animation:
		if motion_players.has(actor.id):
			retired_motion_players.append(motion_players[actor.id])
		motion_players[actor.id] = visual.animation.create_player()
		motion_actors[actor.id] = actor
		motion_players[actor.id].update(actor, 0.0)
	return motion_players[actor.id]

func _update_transform() -> void:
	scale_factor = maxf(size.x / FieldProjection.CANVAS.x, size.y / FieldProjection.CANVAS.y)
	origin = (size - FieldProjection.CANVAS * scale_factor) * 0.5

func _draw() -> void:
	# Release only after the old CanvasItem draw commands have been cleared.
	retired_motion_players.clear()
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
			_range(selected.anchor, simulation.config.definition_for(simulation.profile.copy_by_id(selected.copy_id)).engagement_radius, Color(0.95, 0.8, 0.5, 0.75), true)
			draw_dashed_line(FieldProjection.project(selected.anchor), FieldProjection.project(selected.position), GOLD, 2, 8)
	ordered_actors.assign(simulation.actors)
	for echo: Dictionary in death_echoes:
		var current: CombatantState = Targeting.by_id(simulation.actors, echo.actor.id)
		if current == echo.original and not current.alive():
			continue
		var height: float = echo.visual.height * FieldProjection.depth_scale(echo.actor.position)
		var width: float = height * echo.visual.texture.get_width() / echo.visual.texture.get_height()
		var rect: Rect2 = Rect2(FieldProjection.project(echo.actor.position) - Vector2(width * 0.5, height), Vector2(width, height))
		echo.player.draw(self, echo.visual.texture, rect, Color(1, 1, 1, minf(1.0, echo.life * 3.0)), (echo.actor.facing.x > 0.0) != echo.visual.faces_right)
	ordered_actors.sort_custom(func(a: CombatantState, b: CombatantState) -> bool:
		return _visual_position(a).y < _visual_position(b).y)
	for actor: CombatantState in ordered_actors:
		_draw_actor(actor)
	for effect: Dictionary in effects:
		_draw_effect(effect)
	draw_set_transform(Vector2.ZERO)

func _visual(actor: CombatantState) -> CombatantVisual:
	if actor.allied:
		return simulation.config.definition_for(simulation.profile.copy_by_id(actor.copy_id)).visual
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
	if actor.alive() and not actor.kit_state.is_empty():
		if actor.kit_state.surge_duration > 0.0:
			tint = Color(1.2, 0.8, 0.65, 1.0)
		elif actor.kit_state.guard_duration > 0.0:
			tint = Color(1.05, 0.85, 0.8, 1.0)
	var flip: bool = (actor.facing.x > 0.0) != visual.faces_right
	var player: RefCounted = _motion(actor)
	if player != null:
		# The animation player owns idle frames; UI/selection stay anchored to the feet.
		rect.position.y -= bob
		player.draw(self, visual.texture, rect, tint, flip)
	else:
		if flip:
			rect.position.x += rect.size.x
			rect.size.x = -rect.size.x
		draw_texture_rect(visual.texture, rect, false, tint)
	var bar: Rect2 = Rect2(foot + Vector2(-32, -absf(rect.size.y) - 12), Vector2(64, 5))
	draw_rect(bar.grow(2), Color(0.04, 0.04, 0.04, 0.85))
	bar.size.x *= actor.health / actor.max_health
	draw_rect(bar, Color("#b7d5a2") if actor.allied else Color("#db7860"))
	if actor.allied and not actor.kit_state.is_empty():
		var copy: UnitProgress = simulation.profile.copy_by_id(actor.copy_id)
		if copy.evolution > 0:
			for index: int in range(5):
				draw_circle(foot + Vector2(-24 + index * 12, -absf(rect.size.y) - 22), 3.5,
					Color("#e54d2f") if index < int(actor.kit_state.sauce) else Color("#42332b"))
	if actor.id == selected_id:
		_text(foot + Vector2(-42, 32), "%.0f / %.0f" % [actor.health, actor.max_health], 17, Color.WHITE)
	if actor.action == &"sweep":
		var definition: CombatantDefinition = simulation.config.definition_for(simulation.profile.copy_by_id(actor.copy_id)) if actor.allied else simulation.config.definitions()[actor.definition_id]
		var progress: float = 1.0 - actor.action_left / definition.ability.cast_time
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
