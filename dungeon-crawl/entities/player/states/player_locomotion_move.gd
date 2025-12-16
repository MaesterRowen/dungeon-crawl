extends State

@export var character : HeroCharacter
@export var player : CharacterBody3D

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0
@export var stopping_speed := 20.0

var _move_direction := Vector3.ZERO
var _last_movement_direction := Vector3.FORWARD
var _gravity := -30.0
var _camera_rig : CameraRig

func enter(_msg := {} ) -> void:
	# Configure the camera rig to follow this player
	_camera_rig = get_tree().get_first_node_in_group("camera_rig") as CameraRig
	
func phsyics_update(delta: float) -> void:
	_process_movement_input(delta)
	
	# Apply gravity to the characters velocity
	player.velocity.y += _gravity * delta
	
	player.move_and_slide()
	
	# Cache last movement direction
	if _move_direction.length() > 0.2:
		_last_movement_direction = _move_direction
		
	# Rotate hero character to movement direction
	var target_angle := Vector3.FORWARD.signed_angle_to(_last_movement_direction, Vector3.UP)
	character.global_rotation.y = lerp_angle(character.rotation.y, target_angle, rotation_speed * delta)
	
	# Update animation states
	if not player.is_on_floor() and player.velocity.y < 0.0:
		character.fall()
	elif player.is_on_floor():
		var ground_speed := player.velocity.length()
		var speed_ratio = ground_speed / move_speed
		character.set_player_speed(speed_ratio)

func _process_movement_input(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera_rig.get_camera().global_basis.z
	var right := _camera_rig.get_camera().global_basis.x
	
	_move_direction = forward * raw_input.y + right * raw_input.x
	_move_direction.y = 0.0
	_move_direction = _move_direction.normalized()	
	player.velocity.y = 0.0
	player.velocity = player.velocity.move_toward(_move_direction * move_speed, acceleration * delta)
	if is_equal_approx(_move_direction.length_squared(), 0.0) and player.velocity.length_squared() < stopping_speed:
		player.velocity = Vector3.ZERO
		transition_to("Idle")
