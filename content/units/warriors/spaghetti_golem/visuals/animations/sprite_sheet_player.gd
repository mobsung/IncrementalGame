extends RefCounted
## Frame selection only. No mesh deformation, generated poses, combat writes or RNG.

var rig: Resource
var sprite_frames: SpriteFrames
var state: StringName = &"idle"
var frame_index: int = 0
var clock: float = 0.0
var stride: float = 0.0
var moving: float = 0.0
var hurt: float = 0.0
var heal: float = 0.0
var surge: float = 0.0
var death: float = 0.0
var cycle: float = 1.0
var initialized: bool = false
var previous_position: Vector2
var previous_health: float = 0.0
var previous_action: StringName = &""
var effect: StringName = &""
var effect_elapsed: float = 0.0
var pending_simmer: bool = false

func _init(configuration: Resource) -> void:
	rig = configuration
	sprite_frames = rig.frames()

func react(event: Dictionary) -> void:
	if event.kind == "hit":
		hurt = 1.0
	elif event.kind == "heal":
		heal = 1.0
		var ability: StringName = event.get("ability", &"simmer")
		if ability == &"simmer":
			pending_simmer = true
		elif sprite_frames.has_animation(ability):
			effect = ability
			effect_elapsed = 0.0
			if ability == &"surge":
				surge = 1.0

func update(actor: CombatantState, delta: float, animate: bool = true) -> void:
	if not initialized:
		previous_position = actor.position
		previous_health = actor.health
		death = 1.0 if not actor.alive() else 0.0
		initialized = true
	if not animate:
		return
	clock += delta
	hurt = maxf(0.0, hurt - delta * 5.0)
	heal = maxf(0.0, heal - delta)
	surge = maxf(0.0, surge - delta)
	var distance: float = actor.position.distance_to(previous_position)
	var walking: bool = distance > 0.001 and distance < maxf(25.0, actor.speed * delta * 3.0) and actor.action.is_empty()
	moving = move_toward(moving, 1.0 if walking else 0.0, delta * 12.0)
	if walking:
		stride += distance / 80.0
	if actor.health < previous_health and actor.alive():
		hurt = 1.0
	previous_position = actor.position
	previous_health = actor.health
	death = move_toward(death, 0.0 if actor.alive() else 1.0, delta / 0.65)
	if not effect.is_empty():
		effect_elapsed += delta
		if effect_elapsed >= 0.65:
			effect = &""
	if actor.action == &"basic" and not actor.impacted:
		cycle = maxf(0.001, (actor.action_left - actor.impact_left) / 0.75)
	elif actor.action == &"basic" and previous_action != &"basic":
		cycle = maxf(actor.action_left / 0.75, 1.0 / actor.attack_speed)
	previous_action = actor.action
	if not actor.alive():
		_select(&"death", mini(3, int(death * 4.0)))
		pending_simmer = false
	elif actor.action == &"basic":
		var progress: float = 1.0 - actor.impact_left / (cycle * 0.25)
		var index: int = mini(3, int(clampf(progress, 0.0, 1.0) * 4.0))
		if actor.impacted:
			index = 4 + mini(3, int(clampf(1.0 - actor.action_left / (cycle * 0.75), 0.0, 1.0) * 4.0))
		_select(&"basic", index)
	elif actor.action == &"sweep":
		var index: int = mini(3, int(clampf((0.6 - actor.action_left) / 0.4, 0.0, 1.0) * 4.0))
		if actor.impacted:
			index = 4 + mini(3, int(clampf(1.0 - actor.action_left / 0.2, 0.0, 1.0) * 4.0))
		_select(&"sweep", index)
	elif actor.action in [&"guard", &"surge"] and sprite_frames.has_animation(actor.action):
		var half: int = floori(sprite_frames.get_frame_count(actor.action) / 2.0)
		var duration: float = 0.35 if actor.action == &"guard" else 0.5
		_select(actor.action, mini(half - 1, int(clampf(1.0 - actor.action_left / duration, 0.0, 1.0) * half)))
	elif moving > 0.1:
		_select(&"walk", int(stride * 8.0) % 8)
	elif not effect.is_empty():
		var count: int = sprite_frames.get_frame_count(effect)
		var first: int = 0 if effect == &"simmer" else floori(count / 2.0)
		_select(effect, first + mini(count - first - 1, int(effect_elapsed / 0.65 * (count - first))))
	elif pending_simmer:
		pending_simmer = false
		effect = &"simmer"
		effect_elapsed = 0.0
		_select(&"simmer", 0)
	elif hurt > 0.0:
		_select(&"hit", 0)
	else:
		_select(&"idle", int(clock * 5.0) % 4)

func _select(animation: StringName, index: int) -> void:
	state = animation
	frame_index = clampi(index, 0, sprite_frames.get_frame_count(animation) - 1)

func current_texture() -> Texture2D:
	return sprite_frames.get_frame_texture(state, frame_index)

func draw(canvas: CanvasItem, _texture: Texture2D, rect: Rect2, tint: Color, flip: bool) -> void:
	var frame: Texture2D = current_texture()
	var height: float = rect.size.y / rig.body_fraction * 2.0
	var size: Vector2 = Vector2(height * frame.get_width() / frame.get_height(), height)
	var foot: Vector2 = rect.position + Vector2(rect.size.x * 0.5, rect.size.y)
	var destination: Rect2 = Rect2(foot - Vector2(size.x * 0.5, size.y * (rig.ground_fraction + 0.5) / 2.0), size)
	if flip:
		destination.position.x += size.x
		destination.size.x = -size.x
	canvas.draw_texture_rect(frame, destination, false, tint)
