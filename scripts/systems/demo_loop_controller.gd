extends Node

signal demo_started
signal demo_stopped(step: int, total: int, elapsed: float, active_effects: Array)
signal step_advanced(step: int, total: int, label: String)

enum State { IDLE, RUNNING }

const STEP_INTERVAL := 8.0

const WAYPOINT_ARRIVAL_DIST := 1.0

const WAYPOINTS: Array[Vector3] = [
	Vector3(2, 0.1, 2),       # spawn
	Vector3(2, 0.1, -14),     # corridor 1 exit, well past wall at z=-12
	Vector3(6, 0.1, -13),     # junction south half (avoids wall corner)
	Vector3(16, 0.1, -12),    # corridor 2
	Vector3(50, 0.1, -12),    # outdoor
]

const ESCALATION_STEPS: Array[Dictionary] = [
	{"setting": "fov", "value": 70.0, "label": "FOV → 70°"},
	{"setting": "head_bob", "value": 1, "label": "Head Bob → Subtle"},
	{"setting": "mouse_smoothing", "value": 1, "label": "Mouse Smoothing → Low"},
	{"setting": "reference_point", "value": 1, "label": "Reference Point → Weapon"},
	{"setting": "movement_speed", "value": 2, "label": "Movement Speed → Fast"},
	{"setting": "chromatic_aberration", "value": true, "label": "Chromatic Aberration → On"},
	{"setting": "dof", "value": 1, "label": "Depth of Field → Subtle"},
	{"setting": "motion_blur", "value": 1, "label": "Motion Blur → Low"},
	{"setting": "head_bob", "value": 2, "label": "Head Bob → Aggressive"},
	{"setting": "motion_blur", "value": 2, "label": "Motion Blur → High"},
	{"setting": "fov", "value": 60.0, "label": "FOV → 60°"},
	{"setting": "frame_rate_cap", "value": 2, "label": "Frame Rate → 30 FPS"},
	{"setting": "frame_pacing", "value": 1, "label": "Frame Pacing → Jittery"},
	{"setting": "acceleration", "value": 2, "label": "Acceleration → Delayed"},
	{"setting": "dof", "value": 2, "label": "Depth of Field → Aggressive"},
]

var state: State = State.IDLE
var current_step: int = 0
var step_timer: float = 0.0
var elapsed_time: float = 0.0

var _waypoint_index: int = 0
var _waypoint_direction: int = 1  # 1 = forward, -1 = backward (ping-pong)
var _player: CharacterBody3D
var _turn_tween: Tween
var _sway_time: float = 0.0
var _active_effects: Dictionary = {}

func _ready() -> void:
	set_process(false)
	# Defer signal wiring so sibling nodes are ready
	call_deferred("_connect_signals")

func _connect_signals() -> void:
	var root := get_tree().current_scene
	var hud = root.get_node_or_null("DemoHUD")
	var results = root.get_node_or_null("DemoResultsScreen")
	var debug = root.get_node_or_null("DebugOverlay")

	if hud:
		demo_started.connect(hud.show_hud)
		demo_stopped.connect(func(_s, _t, _e, _a): hud.hide_hud())
		step_advanced.connect(hud.update_step)

	if results:
		demo_stopped.connect(results.show_results)
		results.closed.connect(func():
			if debug:
				debug.on_demo_ended()
		)

	if debug:
		demo_started.connect(func(): debug._demo_active = true)
		demo_stopped.connect(func(_s, _t, _e, _a):
			if not results:
				debug.on_demo_ended()
		)

func start_demo() -> void:
	if state == State.RUNNING:
		return

	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		var root := get_tree().current_scene
		_player = root.get_node_or_null("Player")
	if not _player:
		push_warning("DemoLoopController: Player node not found")
		return

	_player.demo_mode = true
	_player.demo_direction = Vector3.ZERO

	SettingsManager.reset_all()
	SettingsManager.movement_speed = 0  # Start at Slow (3.0 m/s)
	_active_effects.clear()
	current_step = 0
	step_timer = 0.0
	elapsed_time = 0.0
	_sway_time = 0.0

	# Find closest waypoint to start from
	_waypoint_index = _find_closest_waypoint(_player.global_position)
	_waypoint_direction = 1
	# Advance to next waypoint to walk toward
	_advance_waypoint()

	state = State.RUNNING
	set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Face the first target waypoint immediately
	_turn_toward(WAYPOINTS[_waypoint_index])

	demo_started.emit()

	# Apply first step after a brief delay
	step_timer = STEP_INTERVAL - 2.0

func stop_demo() -> void:
	if state != State.RUNNING:
		return

	state = State.IDLE
	set_process(false)

	if _turn_tween and _turn_tween.is_valid():
		_turn_tween.kill()

	if _player:
		_player.demo_mode = false
		_player.demo_direction = Vector3.ZERO

	var effects_list: Array = []
	for key in _active_effects:
		effects_list.append({"setting": key, "value": _active_effects[key]})

	demo_stopped.emit(current_step, ESCALATION_STEPS.size(), elapsed_time, effects_list)

func _process(delta: float) -> void:
	if state != State.RUNNING:
		return

	elapsed_time += delta
	step_timer += delta

	# Check for Escape
	if Input.is_action_just_pressed("ui_cancel"):
		stop_demo()
		return

	# Escalation
	if step_timer >= STEP_INTERVAL and current_step < ESCALATION_STEPS.size():
		_apply_next_step()
		step_timer = 0.0

	# Check if all steps completed and some extra time has passed
	if current_step >= ESCALATION_STEPS.size() and step_timer >= STEP_INTERVAL:
		stop_demo()
		return

	# Waypoint following
	_update_movement(delta)

	# Synthetic camera sway for mouse smoothing exercise
	_update_sway(delta)

func _apply_next_step() -> void:
	var step_data: Dictionary = ESCALATION_STEPS[current_step]
	var setting: String = step_data["setting"]
	var value = step_data["value"]

	SettingsManager.set(setting, value)
	_active_effects[setting] = value
	current_step += 1

	step_advanced.emit(current_step, ESCALATION_STEPS.size(), step_data["label"])

func _update_movement(delta: float) -> void:
	if not _player:
		return

	var target_wp: Vector3 = WAYPOINTS[_waypoint_index]
	var player_pos := _player.global_position
	var to_target := target_wp - player_pos
	to_target.y = 0.0

	var dist := to_target.length()

	if dist < WAYPOINT_ARRIVAL_DIST:
		_advance_waypoint()
		target_wp = WAYPOINTS[_waypoint_index]
		to_target = target_wp - player_pos
		to_target.y = 0.0
		_turn_toward(target_wp)

	_player.demo_direction = to_target.normalized()

func _advance_waypoint() -> void:
	_waypoint_index += _waypoint_direction
	if _waypoint_index >= WAYPOINTS.size():
		_waypoint_direction = -1
		_waypoint_index = WAYPOINTS.size() - 2
	elif _waypoint_index < 0:
		_waypoint_direction = 1
		_waypoint_index = 1

func _turn_toward(target_pos: Vector3) -> void:
	if not _player:
		return

	var dir := target_pos - _player.global_position
	dir.y = 0.0
	if dir.length_squared() < 0.01:
		return

	var target_angle := atan2(-dir.x, -dir.z)

	if _turn_tween and _turn_tween.is_valid():
		_turn_tween.kill()

	_turn_tween = create_tween()
	_turn_tween.tween_property(_player, "rotation:y", target_angle, 0.8)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _update_sway(delta: float) -> void:
	_sway_time += delta
	# Gentle sinusoidal sway to exercise mouse smoothing
	# Scale by delta so total rotation per second is constant regardless of framerate
	var sway_x := sin(_sway_time * 1.3) * 180.0 * delta
	var sway_y := cos(_sway_time * 0.9) * 90.0 * delta
	var event := InputEventMouseMotion.new()
	event.relative = Vector2(sway_x, sway_y)
	Input.parse_input_event(event)

func _find_closest_waypoint(pos: Vector3) -> int:
	var best_idx := 0
	var best_dist := INF
	for i in range(WAYPOINTS.size()):
		var d := pos.distance_squared_to(WAYPOINTS[i])
		if d < best_dist:
			best_dist = d
			best_idx = i
	return best_idx

func get_active_effects_display() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key in _active_effects:
		result.append({"setting": key, "value": _active_effects[key]})
	return result
