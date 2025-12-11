class_name ProjectileMovementComponent extends Node

signal projectile_bounce( hit_result: Dictionary, velocity: Vector3)
signal projectile_stop( hit_result: Dictionary)

@export var destroy_after_seconds := 60.0
@export var use_gravity := true
@export var velocity : Vector3 = Vector3.ZERO
@export var destroy_on_impact := true
@export var floor_check_distance: float = 0.3

@export_group("Projectile")
@export var initial_speed := 25.0
@export var max_speed := 25.0
@export var rotation_follows_velocity := false
@export var rotation_remains_vertical := false
@export var initial_velocity_in_local_space := true
@export var projectile_gravity_scale := 1.0

@export_group("Projectile Bounces")
#BounceVelocityStopSimulatingThreshold
@export var should_bounce := false
@export var bounce_angle_affects_friction := false
@export var bounciness := 0.6
@export var friction := 0.2
@export var bounce_velocity_stop_simulation_threshold := 0.01
@export var min_friction_fraction := 0.0

@export_group("Projectile Simulation")
@export var force_substepping := false
@export var simulation_enabled := true
@export var sweep_collision := true
@export var max_simulation_time_step := 0.05
@export var max_simulation_iterations := 4
@export var bounce_additional_iterations := 1

const MIN_TICK_TIME := 0.000001

var gravity = -1.0 * ProjectSettings.get_setting("physics/3d/default_gravity")
var _should_simulate := true
var _time_alive := 0.0
var _is_sliding := false
var active := true
var pending_force := Vector3.ZERO
var pending_force_this_update := Vector3.ZERO

var controlled_node : Node3D = null

func _ready() -> void:
	controlled_node = get_parent()
	if velocity.length_squared() > 0.0:
		if initial_speed > 0.0:
			velocity = velocity.normalized() * initial_speed
		
		if initial_velocity_in_local_space:
			pass
		
		if rotation_follows_velocity:
			if controlled_node:
				pass

func _physics_process(delta: float) -> void:
	if not controlled_node or not active:
		return
	
	var remaining_time: float = delta
	var num_impacts := 0
	var num_bounces := 0
	var loop_count := 0
	var iterations := 0
	
	while simulation_enabled and remaining_time >= MIN_TICK_TIME and (iterations < max_simulation_iterations) and is_instance_valid(controlled_node) and active:
		iterations += 1
		loop_count += 1
		
		var initial_time_remaining = remaining_time
		var time_tick := remaining_time # handle substepping here
		remaining_time -= time_tick
		
		# Initial move state
		var old_velocity := velocity
		var move_delta := _compute_move_delta(old_velocity, delta)
		var new_rotation := 0.0
		
		if rotation_follows_velocity and rotation_remains_vertical:
			pass
	
		# Move the node
		controlled_node.global_position += move_delta
		
		# if we are no longer alive, then abort
		if not is_instance_valid(controlled_node) or not active:
			return
		
		# Check for collisions
		var from: Vector3 = controlled_node.global_position
		var to: Vector3 = from + velocity * delta
		var space = controlled_node.get_world_3d().direct_space_state
		var params := PhysicsRayQueryParameters3D.create(from, to)
		params.collide_with_areas = false
		params.collide_with_bodies = true
		params.collision_mask = 1
		var result := space.intersect_ray(params)
		if result.size() == 0:
			# No Hits
			_is_sliding = false
			if velocity == old_velocity:
				velocity = _compute_velocity(old_velocity, delta)
		else:
			if velocity == old_velocity:
				velocity = _compute_velocity(old_velocity, delta)
			
			num_impacts += 1
			var hit_result := _handle_blocking_hit(result, delta, move_delta)
			if hit_result == 2:
				break

func add_force(force: Vector3) -> void:
	pending_force += force		

func clear_pending_force(clear_immediate: bool) -> void:
	pending_force = Vector3.ZERO
	if clear_immediate:
		pending_force_this_update = Vector3.ZERO

func _handle_blocking_hit(hit, delta: float, move_delta: Vector3 ) -> int:
	_handle_impact(hit, delta, move_delta)
	if not active:
		return 2
	
	return 0

func _handle_impact(hit, delta: float, move_delta: Vector3) -> void:
	var stop_simulating = false
	if should_bounce:
		var old_velocity := velocity
		velocity = _compute_bounce_result(hit, delta, move_delta)
		projectile_bounce.emit(hit, old_velocity)
		velocity = _limit_velocity(velocity)
		if _is_velocity_under_simulation_threshold():
			stop_simulating = true
	else:
		stop_simulating = true
	
	if stop_simulating:
		_stop_simulating(hit)

func _compute_bounce_result(hit, delta: float, move_delta: Vector3) -> Vector3:
	var temp_velocity := velocity
	var normal : Vector3 = hit.normal
	var v_dot_normal : float = temp_velocity.dot(normal)
	
	if v_dot_normal <= 0.0:
		var projected_normal := normal * -v_dot_normal
		temp_velocity += projected_normal
		
		# Handle friction
		var scaled_friction = clampf(-v_dot_normal / temp_velocity.length(), min_friction_fraction, 1.0) * friction if (bounce_angle_affects_friction or _is_sliding) else friction
		temp_velocity *= clampf(1.0 - scaled_friction, 0.0, 1.0)
		
		# Handle restitution
		temp_velocity += (projected_normal * maxf(bounciness, 0.0))
		
		temp_velocity = _limit_velocity(temp_velocity)
	
	return temp_velocity
	

func _stop_simulating(hit: Dictionary) -> void:
	velocity = Vector3.ZERO
	pending_force = Vector3.ZERO
	pending_force_this_update = Vector3.ZERO
	controlled_node = null
	projectile_stop.emit(hit)

func _compute_move_delta(in_velocity: Vector3, delta: float) -> Vector3:
	var new_velocity := _compute_velocity(in_velocity, delta)
	var move_delta = (in_velocity * delta) + (new_velocity - in_velocity) * (0.5 * delta)
	return move_delta

func _compute_velocity(initial_velocity: Vector3, delta: float ) -> Vector3:
	# v = v0 + a * t
	var acceleration = _compute_acceleration(initial_velocity, delta)
	var new_velocity = initial_velocity + (acceleration * delta)
	return _limit_velocity(new_velocity)

func _compute_acceleration(in_velocity: Vector3, delta: float) -> Vector3:
	var acceleration := Vector3.ZERO
	acceleration.y += _get_gravity()
	
	# Apply other forces
	acceleration += pending_force_this_update
	
	# Apply Homing Acceleration
	
	return acceleration

func _limit_velocity(new_velocity: Vector3) -> Vector3:
	var current_max_speed := _get_max_speed()
	if current_max_speed > 0.0:
		new_velocity = _get_clamped_to_max_size(new_velocity, current_max_speed)
	return new_velocity

func _get_max_speed() -> float:
	return max_speed

func _get_gravity() -> float:
	if _should_apply_gravity():
		return gravity * projectile_gravity_scale
	
	return 0.0

func _should_apply_gravity() -> bool:
	return projectile_gravity_scale != 0.0

func _should_use_sub_stepping() -> bool:
	return force_substepping or _get_gravity() != 0.0 # Handle homing projectile

func _get_simulation_time_step(remaining_time: float, iterations: int) -> float:
	if remaining_time > max_simulation_time_step:
		if iterations < max_simulation_iterations:
			remaining_time = minf(max_simulation_time_step, remaining_time * 0.5)
	
	return maxf(MIN_TICK_TIME, remaining_time)

func _is_velocity_under_simulation_threshold() -> bool:
	return velocity.length_squared() < bounce_velocity_stop_simulation_threshold * bounce_velocity_stop_simulation_threshold

func _get_clamped_to_max_size(v: Vector3, max_size: float) -> Vector3:
	var length_sq = v.length_squared()
	var max_sq = max_size * max_size
	
	if length_sq > max_sq:
		return v.normalized() * max_size
	else:
		return v
