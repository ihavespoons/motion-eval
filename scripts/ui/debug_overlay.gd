extends CanvasLayer

var _panel_visible := false
var _demo_active := false
@onready var panel: PanelContainer = $Panel
@onready var fps_label: Label = $FPSLabel
@onready var demo_button: Button = $Panel/Scroll/VBox/DemoButton

func _ready() -> void:
	panel.visible = false

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_menu"):
		if _demo_active:
			return
		_panel_visible = not _panel_visible
		panel.visible = _panel_visible
		if _panel_visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# --- Resolution ---
func _on_resolution_option_item_selected(index: int) -> void:
	SettingsManager.resolution = index

# --- Fullscreen ---
func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	SettingsManager.fullscreen = toggled_on

# --- FOV ---
func _on_fov_slider_value_changed(value: float) -> void:
	SettingsManager.fov = value
	$Panel/Scroll/VBox/FOV/Value.text = "%d°" % int(value)

# --- Head Bob ---
func _on_head_bob_option_item_selected(index: int) -> void:
	SettingsManager.head_bob = index

# --- Mouse Smoothing ---
func _on_mouse_smooth_option_item_selected(index: int) -> void:
	SettingsManager.mouse_smoothing = index

# --- Motion Blur ---
func _on_motion_blur_option_item_selected(index: int) -> void:
	SettingsManager.motion_blur = index

# --- Chromatic Aberration ---
func _on_ca_check_toggled(toggled_on: bool) -> void:
	SettingsManager.chromatic_aberration = toggled_on

# --- DOF ---
func _on_dof_option_item_selected(index: int) -> void:
	SettingsManager.dof = index

# --- Frame Rate Cap ---
func _on_fps_cap_option_item_selected(index: int) -> void:
	SettingsManager.frame_rate_cap = index

# --- Frame Pacing ---
func _on_frame_pacing_option_item_selected(index: int) -> void:
	SettingsManager.frame_pacing = index

# --- Movement Speed ---
func _on_speed_option_item_selected(index: int) -> void:
	SettingsManager.movement_speed = index

# --- Acceleration ---
func _on_accel_option_item_selected(index: int) -> void:
	SettingsManager.acceleration = index

# --- Reference Point ---
func _on_ref_point_option_item_selected(index: int) -> void:
	SettingsManager.reference_point = index

# --- Reset ---
func _on_reset_button_pressed() -> void:
	SettingsManager.reset_all()
	_sync_ui_to_settings()

func _sync_ui_to_settings() -> void:
	$Panel/Scroll/VBox/Resolution/Option.selected = SettingsManager.resolution
	$Panel/Scroll/VBox/Fullscreen/Check.button_pressed = SettingsManager.fullscreen
	$Panel/Scroll/VBox/FOV/Slider.value = SettingsManager.fov
	$Panel/Scroll/VBox/FOV/Value.text = "%d°" % int(SettingsManager.fov)
	$Panel/Scroll/VBox/HeadBob/Option.selected = SettingsManager.head_bob
	$Panel/Scroll/VBox/MouseSmooth/Option.selected = SettingsManager.mouse_smoothing
	$Panel/Scroll/VBox/MotionBlur/Option.selected = SettingsManager.motion_blur
	$Panel/Scroll/VBox/CA/Check.button_pressed = SettingsManager.chromatic_aberration
	$Panel/Scroll/VBox/DOF/Option.selected = SettingsManager.dof
	$Panel/Scroll/VBox/FPSCap/Option.selected = SettingsManager.frame_rate_cap
	$Panel/Scroll/VBox/FramePacing/Option.selected = SettingsManager.frame_pacing
	$Panel/Scroll/VBox/Speed/Option.selected = SettingsManager.movement_speed
	$Panel/Scroll/VBox/Accel/Option.selected = SettingsManager.acceleration
	$Panel/Scroll/VBox/RefPoint/Option.selected = SettingsManager.reference_point

# --- Demo Loop ---
func _on_demo_button_pressed() -> void:
	var controller = get_tree().current_scene.get_node_or_null("DemoLoopController")
	if not controller:
		return
	_demo_active = true
	demo_button.disabled = true
	_panel_visible = false
	panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	controller.start_demo()

func on_demo_ended() -> void:
	_demo_active = false
	demo_button.disabled = false
	_sync_ui_to_settings()
