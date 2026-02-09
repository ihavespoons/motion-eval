extends CanvasLayer

@onready var motion_blur_rect: ColorRect = $MotionBlurRect
@onready var ca_rect: ColorRect = $ChromaticAberrationRect

var _camera: Camera3D

func _ready() -> void:
	SettingsManager.motion_blur_changed.connect(_on_motion_blur_changed)
	SettingsManager.chromatic_aberration_changed.connect(_on_ca_changed)
	SettingsManager.dof_changed.connect(_on_dof_changed)
	# Find camera after scene tree is ready
	call_deferred("_find_camera")
	# Apply initial state
	_on_motion_blur_changed(SettingsManager.motion_blur)
	_on_ca_changed(SettingsManager.chromatic_aberration)
	_on_dof_changed(SettingsManager.dof)

func _find_camera() -> void:
	var player := get_tree().current_scene.get_node_or_null("Player")
	if player:
		_camera = player.get_node("HeadPivot/Camera3D")

func set_camera(cam: Camera3D) -> void:
	_camera = cam

func _on_motion_blur_changed(value: int) -> void:
	motion_blur_rect.visible = (value > 0)
	if value == 0:
		return
	var strength: float
	match value:
		1: strength = 0.015
		2: strength = 0.04
		_: strength = 0.0
	motion_blur_rect.material.set_shader_parameter("blur_strength", strength)

func _on_ca_changed(value: bool) -> void:
	ca_rect.visible = value

func _on_dof_changed(value: int) -> void:
	var env := _get_world_environment()
	if not env:
		return
	var attrs: CameraAttributesPractical = env.camera_attributes as CameraAttributesPractical
	if not attrs:
		attrs = CameraAttributesPractical.new()
		env.camera_attributes = attrs

	match value:
		0:  # Off
			attrs.dof_blur_far_enabled = false
			attrs.dof_blur_near_enabled = false
		1:  # Subtle
			attrs.dof_blur_far_enabled = true
			attrs.dof_blur_far_distance = 30.0
			attrs.dof_blur_far_transition = 20.0
			attrs.dof_blur_amount = 0.02
			attrs.dof_blur_near_enabled = false
		2:  # Aggressive
			attrs.dof_blur_far_enabled = true
			attrs.dof_blur_far_distance = 10.0
			attrs.dof_blur_far_transition = 8.0
			attrs.dof_blur_amount = 0.08
			attrs.dof_blur_near_enabled = true
			attrs.dof_blur_near_distance = 1.5
			attrs.dof_blur_near_transition = 1.0

func _get_world_environment() -> WorldEnvironment:
	return get_tree().current_scene.get_node_or_null("WorldEnvironment") as WorldEnvironment

func _process(_delta: float) -> void:
	if not _camera or SettingsManager.motion_blur == 0:
		return
	# Feed camera angular velocity into motion blur shader direction
	var ang_vel: float = _camera.get_angular_velocity() if _camera.has_method("get_angular_velocity") else 0.0
	# Use camera basis to approximate blur direction (yaw-based)
	var cam_basis := _camera.global_transform.basis
	var yaw_dir := Vector2(-cam_basis.z.x, cam_basis.z.z).normalized()
	motion_blur_rect.material.set_shader_parameter("blur_direction", yaw_dir * clampf(ang_vel, 0.0, 5.0))
