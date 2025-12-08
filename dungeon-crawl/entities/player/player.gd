extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0
@export var stopping_speed := 20.0

@export_group("Combat")
@export var active_weapon: WeaponData = null

@onready var _character: HeroCharacter = %HeroCharacter
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera : Camera3D = %Camera3D

@onready var _combat_component : CombatComponent = $CombatComponent
@onready var attack_controller: AttackController = $AttackController
@onready var weapon_handler: WeaponHandler = $WeaponHandler


var _move_direction := Vector3.ZERO
var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.FORWARD
var _gravity := -30.0

func _ready() -> void:
	attack_controller.attack_started.connect(_on_attack_started)
	
	# Connect to Animation Notify Signals
	_character.anim_notify_start_damage.connect(attack_controller.phase_enter_active)
	_character.anim_notify_stop_damage.connect(attack_controller.phase_exit_active)
	_character.anim_notify_exit_recovery.connect(attack_controller.phase_exit_recovery)
	_character.anim_notify_open_cancel.connect(attack_controller.enable_cancel)
	_character.anim_notify_close_cancel.connect(attack_controller.disable_cancel)
	
	# Equip Weapon
	_spawn_weapon()
	
func _on_attack_started( attack: AttackData ) -> void:
	_character.play_attack(attack.animation_name)

func _input( event: InputEvent ) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event.is_action_pressed("light_attack"):
		attack_controller.request_attack("light_attack")

func _unhandled_input( event: InputEvent ) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	_process_camera(delta)
	
	_process_movement_input(delta)
	
	# Apply gravity to the characters velocity
	velocity.y += _gravity * delta
	
	move_and_slide()
	
	# Cache last movement direction
	if _move_direction.length() > 0.2:
		_last_movement_direction = _move_direction
		
	# Rotate hero character to movement direction
	var target_angle := Vector3.FORWARD.signed_angle_to(_last_movement_direction, Vector3.UP)
	_character.global_rotation.y = lerp_angle(_character.rotation.y, target_angle, rotation_speed * delta)
	
	# Update animation states
	if not is_on_floor() and velocity.y < 0.0:
		_character.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		var speed_ratio = ground_speed / move_speed
		_character.set_player_speed(speed_ratio)

func _process_camera(delta: float) -> void:
	_camera_pivot.rotation.x -= _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 3.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

func _process_movement_input(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	_move_direction = forward * raw_input.y + right * raw_input.x
	_move_direction.y = 0.0
	_move_direction = _move_direction.normalized()	
	velocity.y = 0.0
	velocity = velocity.move_toward(_move_direction * move_speed, acceleration * delta)
	if is_equal_approx(_move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
		velocity = Vector3.ZERO

func _spawn_weapon() -> void:
	if not active_weapon:
		return
	
	var weapon_instance = active_weapon.weapon_scene.instantiate()
	weapon_handler.register_spawned_weapon(active_weapon.weapon_tag, weapon_instance, true)
	_character.get_weapon_socket().add_child(weapon_instance)	
