extends Node

func _ready() -> void:
	SettingsManager.frame_rate_cap_changed.connect(_on_frame_rate_cap_changed)
	SettingsManager.frame_pacing_changed.connect(_on_frame_pacing_changed)
	_on_frame_rate_cap_changed(SettingsManager.frame_rate_cap)

func _on_frame_rate_cap_changed(value: int) -> void:
	match value:
		0: Engine.max_fps = 0  # Uncapped
		1: Engine.max_fps = 60
		2: Engine.max_fps = 30
		3: Engine.max_fps = 0  # Variable handled in _process

func _on_frame_pacing_changed(_value: int) -> void:
	pass  # Handled in _process

func _process(_delta: float) -> void:
	# Variable frame rate: randomize cap each frame
	if SettingsManager.frame_rate_cap == 3:
		Engine.max_fps = randi_range(20, 60)

	# Jittery frame pacing
	if SettingsManager.frame_pacing == 1:
		OS.delay_msec(randi_range(0, 16))
