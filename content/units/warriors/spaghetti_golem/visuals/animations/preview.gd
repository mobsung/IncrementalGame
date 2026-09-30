extends Control
## Sprite review and frame scrubbing: synthetic actors, no SaveStore or player profile access.

const STATES: Array[String] = ["Idle", "Walk", "Meatball Jab", "Meatball Sweep", "Slow Simmer", "Sauce Guard", "Glassheart Surge", "Hit", "Death"]
var models: Array[BattleSimulation] = []
var players: Array[RefCounted] = []
var elapsed: float = 0.0
var selected: int = 0
var previous: int = -1
var playing: bool = true
var mirrored: bool = false

func _ready() -> void:
	for stage: int in range(3):
		var model: BattleSimulation = BattleSimulation.new(1)
		model.unit().level = 25
		for index: int in range(stage):
			model.evolve_copy(model.unit().id)
		models.append(model)
		players.append(model.config.definition_for(model.unit()).visual.animation.create_player())
	if "idle-capture" in OS.get_cmdline_user_args():
		_capture_idle_review()
	elif "capture" in OS.get_cmdline_user_args():
		_capture_review()

func _capture_idle_review() -> void:
	await get_tree().process_frame
	set_process(false)
	var failures: int = 0
	var checks: int = 0
	for flip: bool in [false, true]:
		mirrored = flip
		selected = 0
		previous = -1
		elapsed = 0.0
		_process(0.0)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var baseline: Image = get_viewport().get_texture().get_image()
		baseline.save_png("res://tests/idle_%s_baseline_preview.png" % ("mirrored" if flip else "planted"))
		for target: float in [0.55, 1.1, 1.75, 2.35]:
			_process(target - elapsed)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var pixel_scale: Vector2 = Vector2(image.get_size()) / size
			for stage: int in range(3):
				var height: float = minf(size.y * 0.46, size.x / 3.0 * 0.48)
				var foot: Vector2 = Vector2(size.x * (stage + 0.5) / 3.0, size.y * 0.72)
				var feet: Rect2i = Rect2i((foot - Vector2(height * 0.26, height * 0.18)) * pixel_scale, Vector2(height * 0.52, height * 0.18 + 3) * pixel_scale)
				checks += 1
				if baseline.get_region(feet).get_data() != image.get_region(feet).get_data():
					failures += 1
					push_error("Idle feet changed: form %d, mirror %s, time %s" % [stage, flip, target])
				if is_equal_approx(target, 0.55):
					var body: Rect2i = Rect2i((foot - Vector2(height * 0.5, height)) * pixel_scale, Vector2(height, height * 0.7) * pixel_scale)
					checks += 1
					if baseline.get_region(body).get_data() == image.get_region(body).get_data():
						failures += 1
						push_error("Idle upper body did not breathe: form %d, mirror %s, clock %s" % [stage, flip, players[stage].clock])
					# Sample under the first fist separately from the upper body and feet.
					var player: RefCounted = players[stage]
					var frame: Texture2D = player.current_texture()
					var draw_height: float = height / player.rig.body_fraction * 2.0 * float(frame.get_meta(&"pose_scale", 1.0))
					var origin: Vector2 = player.rig.idle_drip_origins[0]
					var tip: Vector2 = foot + Vector2((origin.x - 0.5) * draw_height * (-1 if flip else 1), (origin.y - (player.rig.ground_fraction + 0.5) / 2.0) * draw_height)
					var drip: Rect2i = Rect2i((tip - Vector2(6, 4)) * pixel_scale, Vector2(12, 28) * pixel_scale)
					checks += 1
					if baseline.get_region(drip).get_data() == image.get_region(drip).get_data():
						failures += 1
						push_error("Idle sauce did not drip: form %d" % stage)
			if is_equal_approx(target, 0.55):
				image.save_png("res://tests/idle_%s_preview.png" % ("mirrored" if flip else "planted"))
		var frozen: Image = get_viewport().get_texture().get_image()
		for stage: int in range(3):
			players[stage].update(models[stage].hero(), 10.0, false)
		queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		checks += 1
		if frozen.get_data() != get_viewport().get_texture().get_image().get_data():
			failures += 1
			push_error("Paused idle pixels changed")
	print("IDLE PIXEL REVIEW: %d checks, %d failures; three forms, both facings, feet/body/drips/pause" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _capture_review() -> void:
	await get_tree().process_frame
	set_process(false)
	for state_index: int in range(STATES.size()):
		selected = state_index
		previous = -1
		elapsed = 0.0
		_process(0.0)
		var target: float = [0.0, 0.4, 0.25, 0.4, 0.2, 0.36, 0.52, 0.0, 0.7][selected]
		while elapsed < target:
			_process(minf(1.0 / 60.0, target - elapsed))
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://tests/refined_sheet_%d_preview.png" % selected)
	print("SPRITE REVIEW: nine states captured, three forms, isolated actors")
	get_tree().quit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			playing = not playing
		elif event.keycode == KEY_F:
			mirrored = not mirrored
		elif event.keycode == KEY_UP or event.keycode == KEY_DOWN:
			playing = false
			for player: RefCounted in players:
				var count: int = player.sprite_frames.get_frame_count(player.state)
				player.frame_index = posmod(player.frame_index + (1 if event.keycode == KEY_UP else -1), count)
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_LEFT:
			selected = posmod(selected + (1 if event.keycode == KEY_RIGHT else -1), STATES.size())
			elapsed = 0.0
			previous = -1
			var was_playing: bool = playing
			playing = true
			_process(0.0)
			playing = was_playing
		queue_redraw()

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
	draw_string(font, Vector2(40, 104), STATES[selected] + "   ·   Space: pause   ·   Left / Right: state   ·   Up / Down: frame   ·   F: mirror", HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	for stage: int in range(models.size()):
		var model: BattleSimulation = models[stage]
		var visual: CombatantVisual = model.config.definition_for(model.unit()).visual
		var height: float = minf(size.y * 0.46, size.x / 3.0 * 0.48)
		var width: float = height * visual.texture.get_width() / visual.texture.get_height()
		var foot: Vector2 = Vector2(size.x * (stage + 0.5) / 3.0, size.y * 0.72)
		draw_line(foot - Vector2(100, 0), foot + Vector2(100, 0), Color("45443b"), 2)
		players[stage].draw(self, visual.texture, Rect2(foot - Vector2(width * 0.5, height), Vector2(width, height)), Color.WHITE, mirrored)
		draw_string(font, foot + Vector2(-125, 42), model.config.definition_for(model.unit()).display_name, HORIZONTAL_ALIGNMENT_CENTER, 250, 22, Color("edce88"))
		if (selected == 5 and stage == 0) or (selected == 6 and stage != 2):
			draw_string(font, foot + Vector2(-125, 76), "Not unlocked in this form", HORIZONTAL_ALIGNMENT_CENTER, 250, 16, Color("aaaaaa"))
		var player: RefCounted = players[stage]
		var count: int = player.sprite_frames.get_frame_count(player.state)
		draw_string(font, foot + Vector2(-125, 105), "%s · frame %d / %d" % [player.state, player.frame_index + 1, count], HORIZONTAL_ALIGNMENT_CENTER, 250, 16)
		var slot_width: float = size.x / 3.0 / maxf(count, 4)
		var saved_frame: int = player.frame_index
		for index: int in range(count):
			var thumb_foot: Vector2 = Vector2(size.x * stage / 3.0 + slot_width * (index + 0.5), size.y * 0.96)
			var thumb_height: float = minf(slot_width * 0.72, size.y * 0.11)
			player.frame_index = index
			player.draw(self, visual.texture, Rect2(thumb_foot - Vector2(thumb_height * 0.5, thumb_height), Vector2(thumb_height, thumb_height)), Color.WHITE, mirrored)
			if index == saved_frame:
				draw_line(thumb_foot + Vector2(-slot_width * 0.3, 4), thumb_foot + Vector2(slot_width * 0.3, 4), Color("edce88"), 2)
		player.frame_index = saved_frame
