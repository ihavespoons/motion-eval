extends Node

# FOV
signal fov_changed(value: float)
var fov: float = 90.0:
	set(v):
		fov = clampf(v, 60.0, 120.0)
		fov_changed.emit(fov)

# Head bob: 0=Off, 1=Subtle, 2=Aggressive
signal head_bob_changed(value: int)
var head_bob: int = 0:
	set(v):
		head_bob = clampi(v, 0, 2)
		head_bob_changed.emit(head_bob)

# Mouse smoothing: 0=Off, 1=Low (3 frames), 2=High (8 frames)
signal mouse_smoothing_changed(value: int)
var mouse_smoothing: int = 0:
	set(v):
		mouse_smoothing = clampi(v, 0, 2)
		mouse_smoothing_changed.emit(mouse_smoothing)

# Motion blur: 0=Off, 1=Low, 2=High
signal motion_blur_changed(value: int)
var motion_blur: int = 0:
	set(v):
		motion_blur = clampi(v, 0, 2)
		motion_blur_changed.emit(motion_blur)

# Chromatic aberration: on/off
signal chromatic_aberration_changed(value: bool)
var chromatic_aberration: bool = false:
	set(v):
		chromatic_aberration = v
		chromatic_aberration_changed.emit(chromatic_aberration)

# Depth of field: 0=Off, 1=Subtle, 2=Aggressive
signal dof_changed(value: int)
var dof: int = 0:
	set(v):
		dof = clampi(v, 0, 2)
		dof_changed.emit(dof)

# Frame rate cap: 0=Uncapped, 1=60fps, 2=30fps, 3=Variable
signal frame_rate_cap_changed(value: int)
var frame_rate_cap: int = 0:
	set(v):
		frame_rate_cap = clampi(v, 0, 3)
		frame_rate_cap_changed.emit(frame_rate_cap)

# Frame pacing: 0=Consistent, 1=Jittery
signal frame_pacing_changed(value: int)
var frame_pacing: int = 0:
	set(v):
		frame_pacing = clampi(v, 0, 1)
		frame_pacing_changed.emit(frame_pacing)

# Movement speed: 0=Slow (3.0), 1=Normal (5.5), 2=Fast (10.0)
signal movement_speed_changed(value: int)
var movement_speed: int = 1:
	set(v):
		movement_speed = clampi(v, 0, 2)
		movement_speed_changed.emit(movement_speed)

# Acceleration: 0=Linear, 1=Smoothed, 2=Delayed
signal acceleration_changed(value: int)
var acceleration: int = 0:
	set(v):
		acceleration = clampi(v, 0, 2)
		acceleration_changed.emit(acceleration)

# Reference point: 0=None, 1=Weapon, 2=Body
signal reference_point_changed(value: int)
var reference_point: int = 0:
	set(v):
		reference_point = clampi(v, 0, 2)
		reference_point_changed.emit(reference_point)

# Resolution: 0=1280x720, 1=1920x1080, 2=2560x1440, 3=3840x2160
signal resolution_changed(value: int)
var resolution: int = 1:
	set(v):
		resolution = clampi(v, 0, 3)
		_apply_resolution()
		resolution_changed.emit(resolution)

# Fullscreen
signal fullscreen_changed(value: bool)
var fullscreen: bool = false:
	set(v):
		fullscreen = v
		_apply_fullscreen()
		fullscreen_changed.emit(fullscreen)

const RESOLUTION_VALUES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

const SPEED_VALUES := [3.0, 5.5, 10.0]

func get_speed_value() -> float:
	return SPEED_VALUES[movement_speed]

func get_resolution_value() -> Vector2i:
	return RESOLUTION_VALUES[resolution]

func _apply_resolution() -> void:
	if fullscreen:
		return
	var size := RESOLUTION_VALUES[resolution]
	get_window().size = size
	get_window().move_to_center()

func _apply_fullscreen() -> void:
	if fullscreen:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		_apply_resolution()

func reset_all() -> void:
	fov = 90.0
	head_bob = 0
	mouse_smoothing = 0
	motion_blur = 0
	chromatic_aberration = false
	dof = 0
	frame_rate_cap = 0
	frame_pacing = 0
	movement_speed = 1
	acceleration = 0
	reference_point = 0
