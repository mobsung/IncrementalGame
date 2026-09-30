extends Resource
## Immutable, shared SpriteFrames with authored cell bounds and stable ground registration.

@export var locomotion: Texture2D
@export var attacks: Texture2D
@export var abilities: Texture2D
@export_range(0, 2) var evolution: int = 0
@export var body_fraction: float = 0.85
@export var ground_fraction: float = 0.95
@export var canvas_size: Vector2 = Vector2(640.0, 640.0)
## Authored row separators accommodate extended fists outside nominal grid cells.
@export var attack_row_cuts: PackedVector3Array = PackedVector3Array()
@export var locomotion_row_cuts: PackedVector3Array = PackedVector3Array()
@export var locomotion_y_cuts: Vector3 = Vector3(0.25, 0.5, 0.75)
@export var attack_y_cuts: Vector3 = Vector3(0.25, 0.5, 0.75)
@export var ability_y_cuts: Vector3 = Vector3(0.25, 0.5, 0.75)
@export var ability_row_cuts: PackedVector3Array = PackedVector3Array()
## Per source pose: ground/root anchor in full-sheet UV coordinates, uniform draw scale.
## Authored once from the artwork; no pixel scanning at runtime.
@export var locomotion_registration: PackedVector3Array = PackedVector3Array()
@export var attack_registration: PackedVector3Array = PackedVector3Array()
@export var ability_registration: PackedVector3Array = PackedVector3Array()
@export var guard_pose_order: PackedInt32Array = PackedInt32Array()
## Idle uses one planted pose, with breathing above this virtual-canvas join only.
@export_range(0.0, 1.0) var idle_breath_split: float = 0.625
@export_range(0.0, 0.02) var idle_breath_amount: float = 0.006
## Sauce tips in normalized virtual-canvas coordinates, calibrated for source pose 0.
@export var idle_drip_origins: PackedVector2Array = PackedVector2Array()
var _frames: SpriteFrames
const Player = preload("res://content/units/warriors/spaghetti_golem/visuals/animations/sprite_sheet_player.gd")

func create_player() -> RefCounted:
	return Player.new(self)

func frames() -> SpriteFrames:
	if _frames != null:
		return _frames
	_frames = SpriteFrames.new()
	_frames.remove_animation(&"default")
	_add(&"idle", locomotion, 0, 1, 1.0, true)
	_add(&"walk", locomotion, 4, 8, 12.0, true)
	_add(&"hit", locomotion, 12, 1, 8.0, false)
	_add(&"death", locomotion, 12, 4, 6.0, false)
	_add(&"basic", attacks, 0, 8, 12.0, false)
	_add(&"sweep", attacks, 8, 8, 14.0, false)
	_add(&"simmer", abilities, 0, 16 if evolution == 0 else (8 if evolution == 1 else 4), 16.0, false)
	if evolution > 0:
		_add(&"guard", abilities, 8 if evolution == 1 else 4, 8 if evolution == 1 else 4, 12.0, false, guard_pose_order)
	if evolution == 2:
		_add(&"surge", abilities, 8, 8, 12.0, false)
	return _frames

func _add(name: StringName, sheet: Texture2D, first: int, count: int, fps: float, looped: bool, pose_order: PackedInt32Array = PackedInt32Array()) -> void:
	_frames.add_animation(name)
	_frames.set_animation_speed(name, fps)
	_frames.set_animation_loop(name, looped)
	var cell: Vector2 = sheet.get_size() / 4.0
	for local_index: int in range(count):
		var index: int = pose_order[local_index] if pose_order.size() == count else first + local_index
		var frame: AtlasTexture = AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(Vector2(index % 4, floori(index / 4.0)) * cell, cell)
		var nominal_position: Vector2 = frame.region.position
		var row_cuts: PackedVector3Array = locomotion_row_cuts
		var y_cuts: Vector3 = locomotion_y_cuts
		var registration: PackedVector3Array = locomotion_registration
		if sheet == attacks:
			row_cuts = attack_row_cuts
			y_cuts = attack_y_cuts
			registration = attack_registration
		elif sheet == abilities:
			row_cuts = ability_row_cuts
			y_cuts = ability_y_cuts
			registration = ability_registration
		if row_cuts.size() == 4:
			var cuts: Vector3 = row_cuts[floori(index / 4.0)]
			var boundaries: Array[float] = [0.0, cuts.x, cuts.y, cuts.z, 1.0]
			var column: int = index % 4
			frame.region.position.x = roundf(boundaries[column] * sheet.get_width())
			frame.region.size.x = roundf(boundaries[column + 1] * sheet.get_width()) - frame.region.position.x
		var boundaries: Array[float] = [0.0, y_cuts.x, y_cuts.y, y_cuts.z, 1.0]
		var row: int = floori(index / 4.0)
		frame.region.position.y = roundf(boundaries[row] * sheet.get_height())
		frame.region.size.y = roundf(boundaries[row + 1] * sheet.get_height()) - frame.region.position.y
		# Equal virtual canvases retain the nominal actor pivot while allowing wide poses.
		# AtlasTexture reports integer dimensions; round both edges before computing margins.
		var pixel_end: Vector2 = frame.region.end.round()
		frame.region.position = frame.region.position.round()
		frame.region.size = pixel_end - frame.region.position
		frame.margin = Rect2(cell * 0.5 + frame.region.position - nominal_position, cell * 2.0 - frame.region.size)
		if registration.size() == 16:
			var pose: Vector3 = registration[index]
			var canvas: Vector2 = canvas_size.round()
			var pivot: Vector2 = Vector2(canvas.x * 0.5, canvas.y * (ground_fraction + 0.5) / 2.0)
			var anchor: Vector2 = Vector2(pose.x, pose.y) * sheet.get_size()
			frame.margin = Rect2((pivot - anchor + frame.region.position).round(), canvas - frame.region.size)
			frame.set_meta(&"pose_scale", pose.z)
		frame.filter_clip = true
		_frames.add_frame(name, frame)
