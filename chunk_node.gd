class_name ChunkNode
extends StaticBody3D

const CHUNK := 16

const COLORS := {
	1: Color(0.35, 0.65, 0.25),
	2: Color(0.55, 0.35, 0.20),
}

const FACES := [
	[Vector3i(0, 0, 1),  [Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1), Vector3(0, 0, 1)]],
	[Vector3i(0, 0, -1), [Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 0, 0)]],
	[Vector3i(1, 0, 0),  [Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(1, 0, 1)]],
	[Vector3i(-1, 0, 0), [Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 0), Vector3(0, 0, 0)]],
	[Vector3i(0, 1, 0),  [Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(0, 1, 0)]],
	[Vector3i(0, -1, 0), [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)]],
]

var chunk_coord: Vector3i
var blocks: PackedByteArray

func build() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var origin := Vector3(chunk_coord.x * CHUNK, chunk_coord.y * CHUNK, chunk_coord.z * CHUNK)

	for x in CHUNK:
		for y in CHUNK:
			for z in CHUNK:
				var bt := _at(x, y, z)
				if bt == 0:
					continue
				var color: Color = COLORS.get(bt, Color.WHITE)
				for face in FACES:
					var n: Vector3i = face[0]
					if _at(x + n.x, y + n.y, z + n.z) != 0:
						continue
					var c: Array = face[1]
					var v0: Vector3 = c[0]
					var v1: Vector3 = c[1]
					var v2: Vector3 = c[2]
					var v3: Vector3 = c[3]
					for tri in [[v0, v1, v2], [v0, v2, v3]]:
						for v in tri:
							st.set_normal(Vector3(n))
							st.set_color(color)
							st.add_vertex(origin + v)

	var mesh := st.commit()
	if mesh.get_surface_count() == 0:
		return

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.9

	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	add_child(mi)

	var cs := CollisionShape3D.new()
	cs.shape = mesh.create_trimesh_shape()
	add_child(cs)

func _at(x: int, y: int, z: int) -> int:
	if x < 0 or y < 0 or z < 0 or x >= CHUNK or y >= CHUNK or z >= CHUNK:
		return 0
	return blocks[x + CHUNK * (z + CHUNK * y)]
