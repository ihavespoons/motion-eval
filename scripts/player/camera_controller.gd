extends Camera3D

const MOUSE_SENS: float = 0.002

var _bob_time: float = 0.0
var _mouse_buffer: Array[Vector2] = []
var _prev_basis: Basis
var _angular_velocity: float = 0.0

@onready var player: CharacterBody3D = get_parent().get_parent()
@onready var head_pivot: Node3D = get_parent()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_prev_basis = global_transform.basis
	SettingsManager.fov_changed.connect(_on_fov_changed)
	SettingsManager.reference_point_changed.connect(_on_reference_point_changed)
	_on_fov_changed(SettingsManager.fov)
	_on_reference_point_changed(SettingsManager.reference_point)

func _on_fov_changed(value: float) -> void:
	fov = value

func _on_reference_point_changed(value: int) -> void:
	var weapon := get_node_or_null("WeaponModel")
	var body_mesh := get_node_or_null("BodyModel")
	if weapon:
		weapon.visible = (value == 1)
	if body_mesh:
		body_mesh.visible = (value == 2)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion: Vector2 = event.relative
		var smoothed := _apply_mouse_smoothing(motion)
		# Yaw on player root
		player.rotate_y(-smoothed.x * MOUSE_SENS)
		# Pitch on head pivot
		head_pivot.rotate_x(-smoothed.y * MOUSE_SENS)
		head_pivot.rotation.x = clampf(head_pivot.rotation.x, -PI / 2.0, PI / 2.0)

func _apply_mouse_smoothing(delta: Vector2) -> Vector2:
	match SettingsManager.mouse_smoothing:
		0:  # Off
			_mouse_buffer.clear()
			return delta
		1:  # Low (3 frames)
			return _buffer_average(delta, 3)
		2:  # High (8 frames)
			return _buffer_average(delta, 8)
	return delta

func _buffer_average(delta: Vector2, size: int) -> Vector2:
	_mouse_buffer.append(delta)
	while _mouse_buffer.size() > size:
		_mouse_buffer.remove_at(0)
	var avg := Vector2.ZERO
	for d in _mouse_buffer:
		avg += d
	return avg / float(_mouse_buffer.size())

func _process(delta: float) -> void:
	_update_head_bob(delta)
	_update_angular_velocity(delta)

func _update_head_bob(delta: float) -> void:
	var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
	if SettingsManager.head_bob == 0 or horizontal_speed < 0.5:
		position.y = lerpf(position.y, 0.0, 10.0 * delta)
		position.x = lerpf(position.x, 0.0, 10.0 * delta)
		return

	_bob_time += delta * horizontal_speed
	var amplitude_y: float
	var amplitude_x: float
	var freq: float
	match SettingsManager.head_bob:
		1:  # Subtle
			amplitude_y = 0.02
			amplitude_x = 0.01
			freq = 2.0
		2:  # Aggressive
			amplitude_y = 0.08
			amplitude_x = 0.04
			freq = 2.5
		_:
			return

	position.y = sin(_bob_time * freq) * amplitude_y
	position.x = cos(_bob_time * freq * 0.5) * amplitude_x

func _update_angular_velocity(delta: float) -> void:
	var current_basis := global_transform.basis
	# Approximate angular velocity from basis change
	var diff := _prev_basis.inverse() * current_basis
	var angle := diff.get_euler()
	_angular_velocity = angle.length() / maxf(delta, 0.001)
	_prev_basis = current_basis

func get_angular_velocity() -> float:
	return _angular_velocity
