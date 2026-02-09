extends CanvasLayer

@onready var step_label: Label = $Panel/VBox/StepLabel
@onready var progress_bar: ProgressBar = $Panel/VBox/ProgressBar
@onready var effect_label: Label = $Panel/VBox/EffectLabel
@onready var hint_label: Label = $Panel/VBox/HintLabel
@onready var panel: PanelContainer = $Panel

var _announcement_tween: Tween

func _ready() -> void:
	visible = false

func show_hud() -> void:
	visible = true
	step_label.text = "Starting demo..."
	progress_bar.value = 0
	effect_label.text = ""
	hint_label.text = "Press Escape to stop"

func hide_hud() -> void:
	visible = false
	if _announcement_tween and _announcement_tween.is_valid():
		_announcement_tween.kill()

func update_step(step: int, total: int, label: String) -> void:
	step_label.text = "Step %d / %d" % [step, total]
	progress_bar.max_value = total
	progress_bar.value = step
	_announce_effect(label)

func _announce_effect(label: String) -> void:
	effect_label.text = label
	effect_label.modulate = Color.WHITE

	if _announcement_tween and _announcement_tween.is_valid():
		_announcement_tween.kill()

	_announcement_tween = create_tween()
	_announcement_tween.tween_interval(3.0)
	_announcement_tween.tween_property(effect_label, "modulate:a", 0.3, 1.5)
