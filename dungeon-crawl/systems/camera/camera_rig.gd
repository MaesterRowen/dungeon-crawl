class_name CameraRig extends Node3D

@onready var _springarm: SpringArm3D = $SpringArm3D
@onready var _camera: Camera3D = %Camera3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var follow_target : Node3D = null

enum CameraMode { FOLLOW, AIM, FREEZE }

var _camera_input_direction := Vector2.ZERO
var _shake_tween: Tween
var _base_pos : Vector3
var _camera_mode : CameraMode = CameraMode.FOLLOW

func get_springarm() -> SpringArm3D: return _springarm
func get_camera() -> Camera3D: return _camera

func set_camera_mode(mode: CameraMode) -> void:
	_camera_mode = mode

func set_follow_target(target: Node3D) -> void:
	follow_target = target
	

func _ready() -> void:
	_base_pos = _camera.position
	SignalBus.camera_shake.connect(_on_camera_shake)

func _unhandled_input( event: InputEvent ) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _process_camera(delta: float) -> void:
	rotation.x -= _camera_input_direction.y * delta
	rotation.x = clamp(rotation.x, -PI / 3.0, PI / 3.0)
	rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	_process_camera(delta)
	
	# Update the camera position
	if is_instance_valid(follow_target):
		global_position = follow_target.global_position
	
func shake(intensity: float = 0.2, duration: float = 0.25, frequency: int = 20) -> void:
	if _shake_tween:
		_shake_tween.kill()

	_base_pos = _camera.position

	_shake_tween = _camera.create_tween()
	_shake_tween.set_trans(Tween.TRANS_SINE)
	_shake_tween.set_ease(Tween.EASE_IN_OUT)

	var step_time := duration / float(max(frequency, 1))

	for i in range(frequency):
		var jitter := Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			0.0
		)
		_shake_tween.tween_property(_camera, "position", _base_pos + jitter, step_time)

	_shake_tween.tween_property(_camera, "position", _base_pos, step_time)
	
	
func _on_camera_shake(intensity: float) -> void:
	shake(intensity, 0.25, 20)
