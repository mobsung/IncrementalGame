class_name FieldProjection
extends RefCounted
## Invertible presentation mapping; gameplay distances remain in logical space.

const CANVAS: Vector2 = Vector2(1600, 900)

static func project(point: Vector2) -> Vector2:
	return Vector2(140.0 + point.x * 1320.0 / 1280.0, 505.0 + point.y * 230.0 / 640.0)

static func unproject(point: Vector2) -> Vector2:
	return Vector2((point.x - 140.0) * 1280.0 / 1320.0, (point.y - 505.0) * 640.0 / 230.0)

static func depth_scale(point: Vector2) -> float:
	return lerpf(0.82, 1.04, clampf(point.y / 640.0, 0.0, 1.0))
