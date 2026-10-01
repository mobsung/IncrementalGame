extends Resource
## Authored atlas regions and ground anchors; no artwork processing at runtime.
@export var sheet: Texture2D
@export var role: String
@export var regions: Array[Rect2] = []
@export var pivots: PackedVector2Array = []
@export var row_count: int = 6
@export var body_pixels: float = 175.0
@export var isolated_frames: Array[Resource] = []
const Player = preload("res://content/units/supports/would_be_wizard/visuals/wizard_sheet_player.gd")

func create_player() -> RefCounted:
	return Player.new(self)

func clip(action: StringName) -> PackedInt32Array:
	if role == "familiar":
		return PackedInt32Array([2]) if action in [&"hit", &"death"] else PackedInt32Array([0, 1])
	match action:
		&"idle": return PackedInt32Array([0])
		&"walk": return PackedInt32Array([6, 7, 8, 9, 10, 11])
		&"basic": return PackedInt32Array([12, 13, 14, 15, 16, 17])
		&"headlong_swing", &"prototype_trick": return PackedInt32Array([18, 19, 20, 21, 22, 23])
		&"first_remedy", &"rewrite_wounds", &"rigged_sigil": return PackedInt32Array([18, 19, 20])
		&"shared_margins", &"clockwork_familiar": return PackedInt32Array([21, 22, 23])
		&"final_revision", &"grand_illusion": return PackedInt32Array([24, 25, 26])
		&"hit": return PackedInt32Array([24 if row_count == 5 else 27, 0])
		&"deploy": return PackedInt32Array([1, 2, 0])
		&"death":
			var first: int = (row_count - 1) * 6
			return PackedInt32Array([first, first + 1, first + 2, first + 3, first + 4, first + 5])
	return PackedInt32Array([0])
