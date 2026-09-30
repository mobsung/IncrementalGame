extends SceneTree
## Offline atlas inspection. Reads PNG pixels only; never changes raster artwork or saves.

const FORMS: Array[String] = ["noodle_squire", "saucebound_knight", "spaghetti_golem"]
const ROOT: String = "res://content/units/warriors/spaghetti_golem/visuals/spritesheets/"

func _initialize() -> void:
	var folder: String = "refined/" if "refined" in OS.get_cmdline_user_args() else ""
	for form: String in FORMS:
		for kind: String in ["locomotion", "attacks", "abilities"]:
			var path: String = ROOT + folder + form + "_" + kind + ".png"
			if not FileAccess.file_exists(path):
				continue
			var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
			image.convert(Image.FORMAT_RGBA8)
			var pixels: PackedByteArray = image.get_data()
			var width: int = image.get_width()
			var height: int = image.get_height()
			var ys: Array[int] = [0]
			for row: int in range(1, 4):
				ys.append(_cut(pixels, width, height, true, int(height * row / 4.0), 0, width))
			ys.append(height)
			var rows: Array = []
			var poses: Array = []
			for row: int in range(4):
				var xs: Array[int] = [0]
				for col: int in range(1, 4):
					xs.append(_cut(pixels, width, height, false, int(width * col / 4.0), ys[row], ys[row + 1]))
				xs.append(width)
				rows.append(xs)
				for col: int in range(4):
					var points: Array[Vector2i] = []
					for y: int in range(ys[row], ys[row + 1]):
						for x: int in range(xs[col], xs[col + 1]):
							var index: int = (y * width + x) * 4
							if pixels[index + 3] < 230:
								continue
							points.append(Vector2i(x, y))
					# Ignore detached speckles: retain densely occupied scanlines for extents.
					var dense_y: Array[int] = []
					for y: int in range(ys[row], ys[row + 1]):
						var count: int = 0
						for x: int in range(xs[col], xs[col + 1]):
							if pixels[(y * width + x) * 4 + 3] >= 230:
								count += 1
						if count >= 12:
							dense_y.append(y)
					if dense_y.is_empty():
						continue
					var bottom: int = dense_y.back()
					var top: int = dense_y.front()
					var foot_left: int = xs[col + 1]
					var foot_right: int = xs[col]
					var foot_y: int = top
					for point: Vector2i in points:
						if point.y < bottom - (bottom - top) * 0.20:
							continue
						var index: int = (point.y * width + point.x) * 4
						var r: int = pixels[index]
						var g: int = pixels[index + 1]
						var b: int = pixels[index + 2]
						if r > g * 1.15 and g > b * 1.15 and r < 215 and g < 175 and b < 145 and g > 35:
							foot_left = mini(foot_left, point.x)
							foot_right = maxi(foot_right, point.x)
							foot_y = maxi(foot_y, point.y)
					poses.append({"index": row * 4 + col, "top": top, "bottom": bottom, "feet_x": [foot_left, foot_right], "foot_y": foot_y})
			print(JSON.stringify({"file": form + "_" + kind, "size": [width, height], "y_cuts": ys, "x_cuts": rows, "poses": poses}))
	quit()

func _cut(pixels: PackedByteArray, width: int, height: int, horizontal: bool, nominal: int, start: int, end: int) -> int:
	var extent: int = height if horizontal else width
	var best: int = nominal
	var score: float = INF
	for coordinate: int in range(maxi(1, nominal - int(extent * 0.045)), mini(extent - 1, nominal + int(extent * 0.045))):
		var count: int = 0
		for other: int in range(start, end):
			var index: int = ((coordinate * width + other) if horizontal else (other * width + coordinate)) * 4
			if pixels[index + 3] > 64:
				count += 1
		var candidate: float = count + absf(coordinate - nominal) * 0.01
		if candidate < score:
			score = candidate
			best = coordinate
	return best
