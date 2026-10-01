extends Resource
## Atlas UV patches include one pose only. Original sheet pixels stay untouched.
@export var patches: Array[Rect2] = []
var meshes: Dictionary = {}

func mesh_for(region: Rect2, sheet_size: Vector2, seam: float = -1.0, lower: bool = false) -> ArrayMesh:
	var key: String = str(seam) + ":" + str(lower)
	if meshes.has(key): return meshes[key]
	var vertices: PackedVector3Array = []
	var uvs: PackedVector2Array = []
	var indices: PackedInt32Array = []
	for patch: Rect2 in patches:
		var rect: Rect2 = patch
		if seam >= 0.0:
			var cut: float = region.position.y + seam
			if lower:
				rect.position.y = maxf(rect.position.y, cut)
				rect.size.y = patch.end.y - rect.position.y
			else:
				rect.size.y = minf(patch.end.y, cut) - rect.position.y
		if rect.size.y <= 0.0: continue
		var base: int = vertices.size()
		for point: Vector2 in [rect.position, rect.position + Vector2(rect.size.x, 0), rect.end, rect.position + Vector2(0, rect.size.y)]:
			var local: Vector2 = point - region.position
			vertices.append(Vector3(local.x, local.y, 0))
			uvs.append(point / sheet_size)
		indices.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	if not vertices.is_empty(): mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	meshes[key] = mesh
	return mesh
