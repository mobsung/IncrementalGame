extends RefCounted
## Simulation owns timing; visual pose clocks freeze in pause and remain per copy.
var rig: Resource
var state: StringName = &"deploy"
var frame_index: int = 0
var clock: float = 0.0
var elapsed: float = 0.0
var action_duration: float = 0.0
var previous_action: StringName = &""
var previous_position: Vector2
var previous_health: float = 0.0
var initialized: bool = false
var hurt: float = 0.0
var death: float = 0.0
var moving: float = 0.0

func _init(configuration: Resource) -> void:
	rig = configuration

func react(event: Dictionary) -> void:
	if event.kind == "hit": hurt = 0.2

func update(actor: CombatantState, delta: float, animate: bool = true) -> void:
	if not initialized:
		previous_position = actor.position
		previous_health = actor.health
		initialized = true
	if not animate: return
	clock += delta
	hurt = maxf(0.0, hurt - delta)
	if actor.health < previous_health and actor.alive(): hurt = 0.2
	previous_health = actor.health
	var distance: float = actor.position.distance_to(previous_position)
	previous_position = actor.position
	moving = 1.0 if distance > 0.001 and distance < maxf(25.0, actor.speed * delta * 3.0) else 0.0
	if actor.action != previous_action:
		action_duration = actor.action_left
		previous_action = actor.action
	if not actor.alive():
		state = &"death"
		death = minf(1.0, death + delta / 0.8)
		frame_index = mini(5, int(death * 6.0))
	elif not actor.action.is_empty():
		death = 0.0
		state = actor.action
		var count: int = rig.clip(state).size()
		frame_index = mini(count - 1, int(clampf(1.0 - actor.action_left / maxf(0.001, action_duration), 0.0, 1.0) * count))
	elif moving > 0.0:
		state = &"walk"
		frame_index = int(clock * 9.0) % 6
	elif hurt > 0.0:
		state = &"hit"
		frame_index = 0
	elif clock < 0.45:
		state = &"deploy"
		frame_index = mini(2, int(clock / 0.15))
	else:
		state = &"idle"
		frame_index = int(clock * 6.0) % rig.clip(state).size()

func current_texture() -> Texture2D:
	var indices: PackedInt32Array = rig.clip(state)
	var pose: int = indices[clampi(frame_index, 0, indices.size() - 1)]
	var texture: AtlasTexture = AtlasTexture.new()
	texture.atlas = rig.sheet
	texture.region = rig.regions[pose]
	return texture

func draw(canvas: CanvasItem, _portrait: Texture2D, rect: Rect2, tint: Color, flip: bool) -> void:
	var indices: PackedInt32Array = rig.clip(state)
	var pose: int = indices[clampi(frame_index, 0, indices.size() - 1)]
	var region: Rect2 = rig.regions[pose]
	var pivot: Vector2 = rig.pivots[pose]
	var factor: float = rect.size.y / rig.body_pixels
	var foot: Vector2 = rect.position + Vector2(rect.size.x * 0.5, rect.size.y)
	if flip: canvas.draw_set_transform(Vector2(foot.x * 2.0, 0), 0.0, Vector2(-1, 1))
	var destination: Rect2 = Rect2(foot - pivot * factor, region.size * factor)
	if not rig.isolated_frames.is_empty():
		var frame: Resource = rig.isolated_frames[pose]
		if state == &"idle":
			var split: float = clampf(pivot.y - rig.body_pixels * 0.22, 1.0, region.size.y - 1.0)
			var breathing: float = 1.0 + sin(clock * TAU / 3.2) * 0.006
			var upper_transform: Transform2D = Transform2D(0.0, Vector2(factor, factor * breathing), 0.0, destination.position + Vector2(0, split * factor * (1.0 - breathing)))
			canvas.draw_mesh(frame.mesh_for(region, rig.sheet.get_size(), split), rig.sheet, upper_transform, tint)
			canvas.draw_mesh(frame.mesh_for(region, rig.sheet.get_size(), split, true), rig.sheet, Transform2D(0.0, Vector2(factor, factor), 0.0, destination.position), tint)
		else:
			canvas.draw_mesh(frame.mesh_for(region, rig.sheet.get_size()), rig.sheet, Transform2D(0.0, Vector2(factor, factor), 0.0, destination.position), tint)
		if flip: canvas.draw_set_transform(Vector2.ZERO)
		return
	if state == &"idle" and rig.role not in ["familiar", "mirror"]:
		# Keep the lower body and feet planted; breathe only above the fixed seam.
		var seam: float = clampf(pivot.y - rig.body_pixels * 0.22, 1.0, region.size.y - 1.0)
		var breath: float = 1.0 + sin(clock * TAU / 3.2) * 0.006
		var upper: Rect2 = Rect2(destination.position, Vector2(destination.size.x, seam * factor))
		upper.position.y += upper.size.y * (1.0 - breath)
		upper.size.y *= breath
		canvas.draw_texture_rect_region(rig.sheet, upper, Rect2(region.position, Vector2(region.size.x, seam)), tint, false, true)
		var lower: Rect2 = Rect2(destination.position + Vector2(0, seam * factor), Vector2(destination.size.x, (region.size.y - seam) * factor))
		canvas.draw_texture_rect_region(rig.sheet, lower, Rect2(region.position + Vector2(0, seam), Vector2(region.size.x, region.size.y - seam)), tint, false, true)
	else:
		canvas.draw_texture_rect_region(rig.sheet, destination, region, tint, false, true)
	if flip: canvas.draw_set_transform(Vector2.ZERO)
