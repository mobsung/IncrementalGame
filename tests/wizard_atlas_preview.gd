extends Node2D
## Draw every isolated source pose, including frames not reached by a short battle.
const ROLES: Array[String] = ["apprentice", "acolyte", "archsage", "makeshift", "archmage"]
var rig: Resource

func _ready() -> void:
	get_tree().root.content_scale_size = Vector2i(1536, 1024)
	for role: String in ROLES:
		rig = load("res://content/units/supports/would_be_wizard/visuals/%s_sheet.tres" % role)
		queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://tests/wizard_atlas_%s_preview.png" % role)
	print("WIZARD ATLAS PREVIEW: all 174 source poses rendered with isolated UV meshes")
	get_tree().quit()

func _draw() -> void:
	if rig == null: return
	draw_rect(Rect2(0, 0, 1536, 1024), Color(0.12, 0.16, 0.2))
	var font: Font = ThemeDB.fallback_font
	for index: int in range(rig.regions.size()):
		var cell: Vector2 = Vector2(index % 6 * 256, index / 6 * 168)
		draw_string(font, cell + Vector2(8, 20), "%s · %d" % [rig.role, index], HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		var region: Rect2 = rig.regions[index]
		var factor: float = 130.0 / rig.body_pixels
		var origin: Vector2 = cell + Vector2(128, 162) - rig.pivots[index] * factor
		draw_mesh(rig.isolated_frames[index].mesh_for(region, rig.sheet.get_size()), rig.sheet,
			Transform2D(0.0, Vector2(factor, factor), 0.0, origin))
