class_name PlayerMotor extends Node

@export_node_path("HeroCharacter") var model_root_path
@onready var model_root: HeroCharacter = get_node(model_root_path)

@export_category("Movement")
@export var max_speed := 8.0
@export var gravity := -30.0
@export var accel := 30.0
@export var friction := 25.0
@export var turn_speed := 12.0
@export var stopping_speed := 20.0

@export_category("Jumping")
@export var jump_velocity := 6.5
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

var _jump_requested := false
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0

var desired_velocity: Vector3 = Vector3.ZERO

var _move_locks := {} 		# source -> true
var _speed_mults := {} 		# source -> float
var _action_locks := {} 	# source -> name

var _override_vel := Vector3.ZERO
var _override_time := 0.0

var _kb_vel := Vector3.ZERO
var _kb_time := 0.0
var _kb_face_lock := true
var _face_dir: Vector3 = Vector3.ZERO
var _rotation_locked_sources := {}

func body() -> CharacterBody3D:
	return get_parent() as CharacterBody3D

func set_desired_velocity(v: Vector3) -> void:
	desired_velocity = v

func max_ground_speed() -> float:
	return max_speed

func is_stopped() -> bool:
	return body().velocity.length_squared() < stopping_speed

func get_current_velocity() -> Vector3:
	return body().velocity

func set_move_lock(source: StringName, locked: bool) -> void:
	if locked: _move_locks[source] = true
	else: _move_locks.erase(source)

func set_speed_multiplier(source: StringName, mult: float) -> void:
	_speed_mults[source] = mult

func clear_speed_multiplier(source: StringName) -> void:
	_speed_mults.erase(source)

func set_action_lock(source: StringName, locked: bool ) -> void:
	if locked: _action_locks[source] = true
	else: _action_locks.erase(source)

func actions_locked() -> bool:
	return _action_locks.size() > 0

func set_velocity_override(source: StringName, vel: Vector3, duration: float) -> void:
	_override_vel = vel
	_override_time = max(duration, 0.0)

func request_jump() -> void:
	_jump_buffer_timer = jump_buffer_time

func apply_knockback(vel: Vector3, duration: float, lock_facing := true ) -> void:
	_kb_vel = vel
	_kb_time = max(duration, 0.0)
	_kb_face_lock = lock_facing

func set_rotation_lock(source: StringName, locked: bool) -> void:
	if locked: _rotation_locked_sources[source] = true
	else: _rotation_locked_sources.erase(source)

func set_face_direction(dir: Vector3) -> void:
	_face_dir = dir

func knockback_active() -> bool:
	return _kb_time > 0.0

func tick_physics(delta: float) -> void:	
	var b := body()
	if b == null: return	
	
	# Timers
	if _override_time > 0.0: _override_time -= delta
	if _kb_time > 0.0: _kb_time -= delta
	
	# Apply Gravity
	if not b.is_on_floor():
		b.velocity.y += gravity * delta
	elif b.velocity.y < 0.0:
		b.velocity.y = 0.0
	
	# Compute final horizontal target velocity
	var target := Vector3.ZERO
	
	# 1) Dominant knockback
	if knockback_active():
		b.velocity.x = _kb_vel.x
		b.velocity.z = _kb_vel.z
		if _kb_vel.y != 0.0:
			b.velocity.y = _kb_vel.y
		_apply_rotation(delta, (-_kb_vel).normalized() if _kb_face_lock else Vector3.ZERO)
		return
	
	if b.is_on_floor():
		_coyote_timer = coyote_time
		set_action_lock(&"airborne", false)
	else:
		_coyote_timer -= delta
	
	_jump_buffer_timer -= delta
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		_do_jump()
	
	# 2) Lunge/override
	if _override_time > 0.0:
		target = _override_vel
	else:
		# 3) locomotion + locks + multipliers
		var locked := _move_locks.size() > 0
		var mult := 1.0
		for k in _speed_mults.keys():
			mult *= float(_speed_mults[k])
		target = Vector3.ZERO if locked else desired_velocity * mult
	
	# Accelerate/floor friction on XZ
	var current_xz := Vector3(b.velocity.x, 0.0, b.velocity.z)
	var target_xz := Vector3(target.x, target.y, target.z)
	
	if target_xz.length() > 0.001:
		current_xz = current_xz.move_toward(target_xz, accel * delta)
	else:
		current_xz = current_xz.move_toward(Vector3.ZERO, friction * delta)
		
	b.velocity.x = current_xz.x
	b.velocity.z = current_xz.z
	
	# Rotation: face aim dir if provided, else face movement dir
	var face := _face_dir
	if face.length() < 0.001 and target_xz.length() > 0.05:
		face = target_xz
	_apply_rotation(delta, face)

func _apply_rotation(delta: float, face: Vector3) -> void:
	if face.length() < 0.001:
		return
	
	face.y = 0.0
	face = face.normalized()
	
	# yaw-only rotation for the visuals
	var current := model_root.global_transform.basis.get_euler().y
	var desired := atan2(-face.x, -face.z)
	var new_y := lerp_angle(current, desired, 1.0 - exp(-turn_speed * delta))
	
	var t:= model_root.global_transform
	t.basis = Basis(Vector3.UP, new_y)
	model_root.global_transform = t

func _do_jump() -> void:
	var body := body()
	if body == null:
		return
		
	body.velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	
	set_action_lock(&"airborne", true)
