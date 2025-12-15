extends CharacterBody3D

@export_group("Prototype")
@export var ice_attack : PackedScene
@export var fire_attack : PackedScene

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
@onready var magic_controller: MagicController = $MagicController

var _camera_move := false
var _move_direction := Vector3.ZERO
var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.FORWARD
var _gravity := -30.0
var _offset := Vector3.ZERO
var _shake_tween: Tween
var _base_pos : Vector3

func _ready() -> void:
	_base_pos = _camera.position
	attack_controller.attack_started.connect(_on_attack_started)
	magic_controller.location_picked.connect(_on_spell_location_picked)
	# Connect to Animation Notify Signals
	_character.anim_notify_start_damage.connect(attack_controller.phase_enter_active)
	_character.anim_notify_stop_damage.connect(attack_controller.phase_exit_active)
	_character.anim_notify_exit_recovery.connect(attack_controller.phase_exit_recovery)
	_character.anim_notify_open_cancel.connect(attack_controller.enable_cancel)
	_character.anim_notify_close_cancel.connect(attack_controller.disable_cancel)
	
	SignalBus.camera_shake.connect(_on_camera_shake)
	
	# Equip Weapon
	_spawn_weapon()
	
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
	
func _on_attack_started( attack: AttackData ) -> void:
	_character.play_attack(attack.animation_name)

func _on_spell_hit_target(info: HitInfo) -> void:
	print("hit target: ", info.hurtbox.owner_actor.name)
	if _combat_component:
		_combat_component._on_weapon_hit(info)


func _on_spell_location_picked(pos: Vector3) -> void:
	# Rotate the player toward the cursor position
	_last_movement_direction = (pos - global_position).normalized()
	magic_controller.deactivate.call_deferred()
	#_do_ice_attack(pos)
	_do_fire_attack(pos)

func _do_fire_attack(pos: Vector3) -> void:
	var instance = fire_attack.instantiate() as MagicAttack
	instance.on_magic_hit.connect(_on_spell_hit_target)
	instance.owner_actor = self
	get_tree().current_scene.add_child(instance)
	var pmc : ProjectileMovementComponent = instance.get_node_or_null("ProjectileMovementComponent")
	if pmc:
		pmc.velocity = (pos - global_position).normalized() * 50.0
		pmc.initial_speed = 100.0
		pmc.max_speed = 100.0
		instance.global_position = global_position + Vector3.UP
	

func _do_ice_attack(pos: Vector3) -> void:
	var instance = ice_attack.instantiate() as MagicAttack
	instance.on_magic_hit.connect(_on_spell_hit_target)
	instance.owner_actor = self
	get_tree().current_scene.add_child(instance)	
	instance.look_at(pos, Vector3.UP)
	instance.global_position = pos	
	await get_tree().create_timer(2.0).timeout
	instance.queue_free()

func _input( event: InputEvent ) -> void:
	if magic_controller.is_active():
		if event.is_action_pressed("ui_cancel"):
			magic_controller.deactivate()
		return
	
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#if event.is_action_pressed("activate_camera"):
		#_camera_move = true
	#elif event.is_action_released("activate_camera"):
		#_camera_move = false
	if event.is_action_pressed("magic"):
		magic_controller.activate()

	
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
