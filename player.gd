class_name Player
extends CharacterBody3D

const SPEED := 6.0
const JUMP := 5.5
const GRAVITY := 18.0
const MOUSE_SENS := 0.0025
const REACH := 6.0

var camera: Camera3D
var _yaw := 0.0
var _pitch := 0.0
var _world: World

func _ready() -> void:
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.7
	col.shape = cap
	col.position.y = 0.85
	add_child(col)

	camera = Camera3D.new()
	camera.position.y = 1.55
	camera.fov = 80.0
	add_child(camera)

	_world = get_tree().current_scene.get_node("World")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if e is InputEventMouseMotion:
		_yaw -= e.relative.x * MOUSE_SENS
		_pitch = clampf(_pitch - e.relative.y * MOUSE_SENS, -1.5, 1.5)
		rotation.y = _yaw
		camera.rotation.x = _pitch
	elif e is InputEventMouseButton and e.pressed:
		var hit := _world.raycast_block(camera.global_position, -camera.global_transform.basis.z, REACH)
		if hit.is_empty():
			return
		if e.button_index == MOUSE_BUTTON_LEFT:
			_world.set_block(hit.pos, 0)
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			_world.set_block(hit.pos + hit.normal, 2)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP

	var fwd := -global_transform.basis.z
	fwd.y = 0
	fwd = fwd.normalized()
	var right := global_transform.basis.x
	right.y = 0
	right = right.normalized()

	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): dir += fwd
	if Input.is_key_pressed(KEY_S): dir -= fwd
	if Input.is_key_pressed(KEY_D): dir += right
	if Input.is_key_pressed(KEY_A): dir -= right

	velocity.x = dir.normalized().x * SPEED
	velocity.z = dir.normalized().z * SPEED
	move_and_slide()
