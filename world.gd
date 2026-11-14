class_name World
extends Node3D

const CHUNK := 16
const CHUNKS_X := 6
const CHUNKS_Z := 6
const GROUND_H := 4

var _chunks: Dictionary = {}
var _blocks: Dictionary = {}

func _ready() -> void:
	for cx in CHUNKS_X:
		for cz in CHUNKS_Z:
			_gen_chunk(Vector3i(cx, 0, cz))

func _gen_chunk(cc: Vector3i) -> void:
	var data := PackedByteArray()
	data.resize(CHUNK * CHUNK * CHUNK)
	for x in CHUNK:
		for z in CHUNK:
			for y in CHUNK:
				var wy := cc.y * CHUNK + y
				data[_idx(x, y, z)] = 2 if wy < GROUND_H else 0
	_blocks[cc] = data
	_build_chunk(cc)

func _idx(x: int, y: int, z: int) -> int:
	return x + CHUNK * (z + CHUNK * y)

func _chunk_of(p: Vector3i) -> Vector3i:
	return Vector3i(
		floori(float(p.x) / CHUNK),
		floori(float(p.y) / CHUNK),
		floori(float(p.z) / CHUNK))

func get_block(p: Vector3i) -> int:
	var data = _blocks.get(_chunk_of(p))
	if data == null:
		return 0
	return data[_idx(posmod(p.x, CHUNK), posmod(p.y, CHUNK), posmod(p.z, CHUNK))]

func set_block(p: Vector3i, v: int) -> void:
	var cc := _chunk_of(p)
	var data = _blocks.get(cc)
	if data == null:
		return
	data[_idx(posmod(p.x, CHUNK), posmod(p.y, CHUNK), posmod(p.z, CHUNK))] = v
	_build_chunk(cc)

func _build_chunk(cc: Vector3i) -> void:
	var old = _chunks.get(cc)
	if old != null:
		old.queue_free()
	var node := ChunkNode.new()
	node.chunk_coord = cc
	node.blocks = _blocks[cc]
	node.build()
	_chunks[cc] = node
	add_child(node)

func raycast_block(origin: Vector3, dir: Vector3, max_dist: float) -> Dictionary:
	dir = dir.normalized()
	var pos := Vector3i(floori(origin.x), floori(origin.y), floori(origin.z))
	var step := Vector3i(
		1 if dir.x > 0 else -1,
		1 if dir.y > 0 else -1,
		1 if dir.z > 0 else -1)

	var t_delta := Vector3(
		absf(1.0 / dir.x) if dir.x != 0.0 else INF,
		absf(1.0 / dir.y) if dir.y != 0.0 else INF,
		absf(1.0 / dir.z) if dir.z != 0.0 else INF)

	var t_max := Vector3(
		_bound(origin.x, dir.x, step.x),
		_bound(origin.y, dir.y, step.y),
		_bound(origin.z, dir.z, step.z))

	var normal := Vector3i.ZERO
	var t := 0.0
	while t <= max_dist:
		if get_block(pos) != 0:
			return {"pos": pos, "normal": normal}
		if t_max.x < t_max.y and t_max.x < t_max.z:
			pos.x += step.x
			t = t_max.x
			t_max.x += t_delta.x
			normal = Vector3i(-step.x, 0, 0)
		elif t_max.y < t_max.z:
			pos.y += step.y
			t = t_max.y
			t_max.y += t_delta.y
			normal = Vector3i(0, -step.y, 0)
		else:
			pos.z += step.z
			t = t_max.z
			t_max.z += t_delta.z
			normal = Vector3i(0, 0, -step.z)
	return {}

func _bound(o: float, d: float, s: int) -> float:
	if d == 0.0: return INF
	var boundary := float(floori(o)) + (1.0 if s > 0 else 0.0)
	return (boundary - o) / d
