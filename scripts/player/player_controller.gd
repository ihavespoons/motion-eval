extends CharacterBody3D

const GRAVITY: float = 9.8

var _intent_velocity := Vector3.ZERO
var demo_mode: bool = false
var demo_direction: Vector3 = Vector3.ZERO

@onready var head_pivot: Node3D = $HeadPivot

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Input direction
	var direction: Vector3
	if demo_mode:
		direction = demo_direction
		direction.y = 0.0
		if direction.length_squared() > 0.01:
			direction = direction.normalized()
		else:
			direction = Vector3.ZERO
	else:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var speed := SettingsManager.get_speed_value()
	var target := direction * speed

	match SettingsManager.acceleration:
		0:  # Linear (instant)
			velocity.x = target.x
			velocity.z = target.z
		1:  # Smoothed
			velocity.x = lerpf(velocity.x, target.x, 8.0 * delta)
			velocity.z = lerpf(velocity.z, target.z, 8.0 * delta)
		2:  # Delayed (two-stage)
			_intent_velocity = _intent_velocity.lerp(target, 4.0 * delta)
			velocity.x = lerpf(velocity.x, _intent_velocity.x, 6.0 * delta)
			velocity.z = lerpf(velocity.z, _intent_velocity.z, 6.0 * delta)

	move_and_slide()
