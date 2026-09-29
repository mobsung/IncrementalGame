extends Control
## Visual rehearsal only: synthetic actors, no SaveStore, no player profile access.

const STATES: Array[String] = ["Idle", "Walk", "Meatball Jab", "Meatball Sweep", "Slow Simmer", "Sauce Guard", "Glassheart Surge", "Hit", "Death"]
var models: Array[BattleSimulation] = []
var players: Array[RefCounted] = []
var elapsed: float = 0.0
var selected: int = 0
var previous: int = -1
var playing: bool = true

func _ready() -> void:
	for stage: int in range(3):
		var model: BattleSimulation = BattleSimulation.new(1)
		model.unit().level = 25
		for index: int in range(stage):
			model.evolve_copy(model.unit().id)
		models.append(model)
		players.append(model.config.definition_for(model.unit()).visual.animation.create_player())

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			playing = not playing
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_LEFT:
			selected = posmod(selected + (1 if event.keycode == KEY_RIGHT else -1), STATES.size())
			elapsed = 0.0
			previous = -1
			var was_playing: bool = playing
			playing = true
			_process(0.0)
			playing = was_playing

func _process(delta: float) -> void:
	if not playing:
		return
	elapsed += delta
	if elapsed >= 2.4:
		elapsed = 0.0
		selected = (selected + 1) % STATES.size()
	var entering: bool = previous != selected
	previous = selected
	for stage: int in range(3):
		var actor: CombatantState = models[stage].hero()
		actor.clear_action()
		actor.health = actor.max_health
		actor.kit_state.guard_duration = 0.0
		actor.kit_state.surge_duration = 0.0
		var t: float = fposmod(elapsed, 1.2)
		if entering:
			players[stage] = models[stage].config.definition_for(models[stage].unit()).visual.animation.create_player()
			players[stage].update(actor, 0.0)
		match selected:
			1:
				actor.position.x += delta * 80.0
			2:
				if t < 1.0:
					actor.action = &"basic"
					actor.action_left = 1.0 - t
					actor.impact_left = maxf(0, 0.25 - t)
					actor.impacted = t >= 0.25
			3:
				if t < 0.6:
					actor.action = &"sweep"
					actor.action_left = 0.6 - t
					actor.impacted = t >= 0.4
			4:
				if entering:
					players[stage].react({"kind":"heal", "ability":&"simmer"})
			5:
				if stage > 0:
					actor.action = &"guard" if elapsed < 0.35 else &""
					actor.action_left = maxf(0, 0.35 - elapsed)
					actor.kit_state.guard_duration = 6.0 if elapsed >= 0.35 else 0.0
					if elapsed >= 0.35 and elapsed - delta < 0.35:
						players[stage].react({"kind":"heal", "ability":&"guard"})
			6:
				if stage == 2:
					actor.action = &"surge" if elapsed < 0.5 else &""
					actor.action_left = maxf(0, 0.5 - elapsed)
					actor.kit_state.surge_duration = 5.0 if elapsed >= 0.5 else 0.0
					if elapsed >= 0.5 and elapsed - delta < 0.5:
						players[stage].react({"kind":"heal", "ability":&"surge"})
			7:
				if entering:
					players[stage].react({"kind":"hit"})
			8:
				actor.health = 0
		players[stage].update(actor, delta)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("171c24"))
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(40, 60), "SPAGHETTI GOLEM / SPRITE SHEETS", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("edce88"))
	draw_string(font, Vector2(40, 104), STATES[selected] + "   ·   Space: pause   ·   Left / Right: select", HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	for stage: int in range(models.size()):
		var model: BattleSimulation = models[stage]
		var visual: CombatantVisual = model.config.definition_for(model.unit()).visual
		var height: float = minf(size.y * 0.56, size.x / 3.0 * 0.75)
		var width: float = height * visual.texture.get_width() / visual.texture.get_height()
		var foot: Vector2 = Vector2(size.x * (stage + 0.5) / 3.0, size.y * 0.78)
		draw_line(foot - Vector2(100, 0), foot + Vector2(100, 0), Color("45443b"), 2)
		players[stage].draw(self, visual.texture, Rect2(foot - Vector2(width * 0.5, height), Vector2(width, height)), Color.WHITE, false)
		draw_string(font, foot + Vector2(-125, 42), model.config.definition_for(model.unit()).display_name, HORIZONTAL_ALIGNMENT_CENTER, 250, 22, Color("edce88"))
		if (selected == 5 and stage == 0) or (selected == 6 and stage != 2):
			draw_string(font, foot + Vector2(-125, 76), "Not unlocked in this form", HORIZONTAL_ALIGNMENT_CENTER, 250, 16, Color("aaaaaa"))
