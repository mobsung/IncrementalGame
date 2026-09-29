extends RefCounted
## One soft-mesh rig per visible copy; never writes CombatantState or uses gameplay RNG.

const COLUMNS: int = 20
const ROWS: int = 24
var rig: Resource
var mesh: ArrayMesh = ArrayMesh.new()
var uv: PackedVector2Array = []
var indices: PackedInt32Array = []
var clock: float = 0.0
var stride: float = 0.0
var moving: float = 0.0
var hurt: float = 0.0
var heal: float = 0.0
var surge: float = 0.0
var death: float = 0.0
var initialized: bool = false
var previous_position: Vector2
var previous_health: float = 0.0
var previous_action: StringName = &""
var cycle: float = 1.0
var state: StringName = &"idle"
var extension: float = 0.0
var windup: float = 0.0
var brace: float = 0.0
var sweep: float = 0.0
var glow: float = 0.0

func _init(configuration: Resource) -> void:
	rig = configuration
	for y: int in range(ROWS + 1):
		for x: int in range(COLUMNS + 1):
			uv.append(Vector2(float(x) / COLUMNS, float(y) / ROWS))
	for y: int in range(ROWS):
		for x: int in range(COLUMNS):
			var a: int = y * (COLUMNS + 1) + x
			indices.append_array(PackedInt32Array([a, a + 1, a + COLUMNS + 1, a + 1, a + COLUMNS + 2, a + COLUMNS + 1]))

func react(event: Dictionary) -> void:
	if event.kind == "hit":
		hurt = 1.0
	elif event.kind == "heal":
		heal = 1.0
		if event.get("ability", &"") == &"surge":
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
	var distance: float = actor.position.distance_to(previous_position)
	# Teleports/formation edits are not walking; movement affects only the rig.
	var walking: bool = distance > 0.001 and distance < maxf(25.0, actor.speed * delta * 3.0) and actor.action.is_empty()
	moving = move_toward(moving, 1.0 if walking else 0.0, delta * 12.0)
	stride += distance * 0.12 if walking else delta * 5.0 * moving
	if actor.health < previous_health and actor.alive():
		hurt = 1.0
	previous_health = actor.health
	previous_position = actor.position
	hurt = maxf(0.0, hurt - delta * 5.0)
	heal = maxf(0.0, heal - delta * 1.8)
	surge = maxf(0.0, surge - delta * 1.25)
	death = move_toward(death, 0.0 if actor.alive() else 1.0, delta / 0.65)
	if actor.action == &"basic" and not actor.impacted:
		# Both timers capture the original attack speed, including mid-cycle purchases.
		cycle = maxf(0.001, (actor.action_left - actor.impact_left) / 0.75)
	elif actor.action == &"basic" and previous_action != &"basic":
		cycle = maxf(actor.action_left / 0.75, 1.0 / actor.attack_speed)
	previous_action = actor.action
	state = actor.action if not actor.action.is_empty() else (&"walk" if moving > 0.1 else &"idle")
	if not actor.alive():
		state = &"death"
	extension = 0.0
	windup = 0.0
	brace = 0.0
	sweep = 0.0
	if state == &"basic":
		if not actor.impacted:
			var p: float = clampf(1.0 - actor.impact_left / (cycle * 0.25), 0.0, 1.0)
			windup = sin(p * PI)
			extension = smoothstep(0.55, 1.0, p)
		else:
			extension = pow(clampf(actor.action_left / (cycle * 0.75), 0.0, 1.0), 3.0)
	elif state == &"sweep":
		var p: float = clampf((0.6 - actor.action_left) / 0.6, 0.0, 1.0)
		windup = sin(minf(p / 0.6667, 1.0) * PI)
		sweep = sin(smoothstep(0.2, 1.0, p) * PI)
		extension = smoothstep(0.35, 0.6667, p) * (1.0 - smoothstep(0.6667, 1.0, p))
	elif state == &"guard" or state == &"surge":
		var duration: float = 0.35 if state == &"guard" else 0.5
		brace = sin(clampf(1.0 - actor.action_left / duration, 0.0, 1.0) * PI * 0.5)
	glow = heal * 0.6 + surge
	if not actor.kit_state.is_empty() and actor.alive():
		if actor.kit_state.guard_duration > 0.0:
			brace = maxf(brace, 0.22)
		if actor.kit_state.surge_duration > 0.0:
			glow += 0.25 + 0.1 * sin(clock * 10.0)

func deform(point: Vector2) -> Vector2:
	var p: Vector2 = point
	var upper: float = 1.0 - smoothstep(0.7, 1.0, p.y)
	# Broad plateaus carry the fist and its hanging sauce as one mass, avoiding
	# sharp radial pinches through the illustrated texture.
	var arm_band: float = smoothstep(0.20, 0.43, p.y) * (1.0 - smoothstep(0.83, 1.0, p.y))
	var left: float = (1.0 - smoothstep(rig.near_fist.x + 0.08, rig.near_fist.x + 0.32, p.x)) * arm_band
	var right: float = smoothstep(rig.far_fist.x - 0.30, rig.far_fist.x - 0.06, p.x) * arm_band
	var feet: float = smoothstep(0.73, 1.0, p.y)
	var side: float = -1.0 if p.x < 0.54 else 1.0
	var step: float = sin(stride + (0.0 if side < 0.0 else PI)) * moving
	p.x += sin(clock * (2.5 / rig.weight) + p.y * 5.0) * 0.006 * upper
	p.y -= sin(clock * 2.5 / rig.weight) * 0.004 * upper
	p.x += feet * step * 0.035
	p.y -= feet * maxf(0.0, step) * 0.04
	p.x -= upper * moving * 0.014
	p.y -= upper * absf(sin(stride)) * moving * 0.012
	# Elastic arms, weighted away from the glass torso; both fists sweep together.
	p += left * Vector2(extension * 0.09 - windup * 0.035 + brace * 0.04, -extension * 0.035 - sweep * 0.045 - brace * 0.06)
	p += right * Vector2(extension * 0.055 - windup * 0.02 - brace * 0.025, -sweep * 0.04 - brace * 0.055)
	p.x += upper * (extension * 0.02 - windup * 0.015 - hurt * 0.015)
	var compression: float = hurt * 0.065 + brace * 0.035
	p = Vector2(0.5 + (p.x - 0.5) * (1.0 + compression), 1.0 + (p.y - 1.0) * (1.0 - compression))
	# Collapse towards planted feet, with limp arms; does not move the actor/hitbox.
	p.x += (p.x - 0.5) * death * 0.3
	p.y = lerpf(p.y, 0.94 + (p.y - 0.5) * 0.10, death)
	return p

func draw(canvas: CanvasItem, texture: Texture2D, rect: Rect2, tint: Color, flip: bool) -> void:
	var vertices: PackedVector2Array = []
	for point: Vector2 in uv:
		var p: Vector2 = deform(point)
		if flip:
			p.x = 1.0 - p.x
		vertices.append(rect.position + p * rect.size)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uv
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var color: Color = tint.lerp(Color(1.6, 0.85, 0.65, tint.a), hurt * 0.65)
	color = color.lerp(Color(0.35, 0.29, 0.25, tint.a * 0.45), death)
	canvas.draw_mesh(mesh, texture, Transform2D.IDENTITY, color)
	if death > 0.01:
		return
	var heart_point: Vector2 = deform(rig.heart)
	if flip:
		heart_point.x = 1.0 - heart_point.x
	var center: Vector2 = rect.position + heart_point * rect.size
	var radius: float = rect.size.y * 0.065
	if glow > 0.01:
		for ring: int in range(3, 0, -1):
			canvas.draw_circle(center, radius * ring * (1.0 + 0.15 * sin(clock * 12)), Color(1.0, 0.24, 0.07, minf(0.16, glow * 0.09)))
	if heal > 0.0:
		for index: int in range(6):
			var angle: float = index * TAU / 6.0 + clock
			var bubble: Vector2 = center + Vector2(cos(angle) * radius * 2.0, -sin(angle) * radius - (1.0 - heal) * radius * 4)
			canvas.draw_circle(bubble, 2.0 + heal * 2.0, Color(1, 0.58, 0.22, heal * 0.8), false, 1.5, true)
	if brace > 0.1:
		var shield_angle: float = PI if flip else 0.0
		canvas.draw_arc(center, rect.size.y * 0.30, shield_angle - PI * 0.6, shield_angle + PI * 0.6, 24, Color(0.95, 0.24, 0.08, brace * 0.75), 3.0, true)
	if sweep > 0.1:
		var attack_angle: float = PI if flip else 0.0
		canvas.draw_arc(center, rect.size.y * 0.36, attack_angle - 1.3, attack_angle - 1.3 + sweep * 2.6, 24, Color(1.0, 0.73, 0.32, sweep * 0.7), 4.0, true)
	# Small sauce drops, deterministic and local to this rig (no gameplay RNG).
	for index: int in range(2):
		var drop: float = fposmod(clock * 0.65 + index * 0.5, 1.0)
		var point: Vector2 = deform(rig.near_fist if index == 0 else rig.far_fist)
		if flip:
			point.x = 1.0 - point.x
		point = rect.position + point * rect.size + Vector2(0, rect.size.y * (0.1 + drop * 0.13))
		canvas.draw_circle(point, 1.8 * (1.0 - drop), Color(0.8, 0.15, 0.035, (1.0 - drop) * 0.65))
