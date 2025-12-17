extends State

@export_group("Movement")
@export var controller: PlayerController
@export var move_speed := 8.0

#var _move_direction := Vector3.ZERO
var _camera_rig : CameraRig

func enter(_msg := {} ) -> void:
	# Configure the camera rig to follow this player
	_camera_rig = get_tree().get_first_node_in_group("camera_rig") as CameraRig

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		transition_to("Jump")

func update(_delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera_rig.get_camera().global_basis.z
	var right := _camera_rig.get_camera().global_basis.x
	
	var _move_direction := forward * raw_input.y + right * raw_input.x
	_move_direction.y = 0.0
	_move_direction = _move_direction.normalized()	
	controller.set_desired_velocity(_move_direction * move_speed)
	
	if is_equal_approx(_move_direction.length_squared(), 0.0) and controller.is_stopped():
		controller.set_desired_velocity(Vector3.ZERO)
		transition_to("Idle")
		
	if not controller.body().is_on_floor():
		transition_to("Fall")
