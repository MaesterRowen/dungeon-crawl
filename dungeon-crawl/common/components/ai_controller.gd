class_name AIController extends Node

@warning_ignore("unused_signal")
signal velocity_changed(vel: Vector3)

@export var character : CharacterBody3D
@export var agent : NavigationAgent3D

@export var move_speed: float = 4.0
@export var turn_speed: float = 6.0

var targetPoint : Vector3 = Vector3.ZERO
var current_velocity: Vector3 = Vector3.ZERO

func set_velocity(vel: Vector3) -> void:
	character.velocity = vel

# MOVEMENT HELPERS
func move_to(position: Vector3) -> void:
	agent.target_position = position
	
func stop() -> void:
	set_velocity(Vector3.ZERO)
	
func has_arrived() -> bool:
	if agent.is_navigation_finished():
		stop()
		return true
	return false

func follow(delta: float) -> void:
	if has_arrived():
		stop()
		return
	
	var next_pos = get_next_path_point()
	var dir = (next_pos - character.global_position).normalized()
	dir.y = 0.0
	
	set_velocity(dir * move_speed)
	rotate_toward_direction(dir, delta)

# ROTATION HELPERS
## Rotate to a specific yaw angle (in radians)
func rotate_in_place(target_yaw: float, delta: float) -> bool:
	var current_yaw = character.rotation.y
	var new_yaw = lerp_angle(current_yaw, target_yaw, turn_speed * delta)
	character.rotation.y = new_yaw
	
	# return true if close enoguh (rotation complete)
	return absf(wrapf(target_yaw - new_yaw, -PI, PI)) < 0.05

## Rotate toward a direction vector
func rotate_toward_direction(dir: Vector3, delta: float) -> bool:
	if dir.length() < 0.001:
		return false
		
	dir = dir.normalized()
	var target_pos = character.global_position + dir
	
	var target_basis = character.global_transform.looking_at(target_pos, Vector3.UP).basis
	
	character.global_transform.basis = character.global_transform.basis.slerp(target_basis, turn_speed * delta)
	var forward = -character.global_transform.basis.z
	return forward.dot(dir) > 0.98

## Rotate to face a given world position
func rotate_toward_position(position: Vector3, delta: float) -> bool:
	var dir = (position - character.global_position)
	dir.y = 0
	return rotate_toward_direction(dir, delta)

## Get closest navmesh point
func get_nav_point(position: Vector3) -> Vector3:
	if not agent or not agent.get_navigation_map():
		return position
	return NavigationServer3D.map_get_closest_point(agent.get_navigation_map(), position)

## Get Random point in navigable radius
func get_random_point_around(origin: Vector3, radius: float, min_distance: float = 0.0) -> Vector3:
	var tries := 20
	var nav_map = agent.get_navigation_map()
	
	while tries > 0:
		tries -= 1
		
		# Random Direction
		var random_dir = Vector3(randf() * 2 - 1, 0, randf() * 2 - 1).normalized()
		var random_dist = randf() * radius
		var raw_point = origin + random_dir * random_dist
		
		if nav_map:
			var nav_point = get_nav_point(raw_point)
			if origin.distance_to(nav_point) >= min_distance:
				return nav_point
	
	# Fallback
	return origin

## Get a point AWAY from a target (flee behavior)
func get_point_away_from(origin: Vector3, threat: Vector3, distance: float) -> Vector3:
	var dir = (origin - threat).normalized()
	var target_point = origin + dir * distance
	return get_nav_point(target_point)

## Pick a point inside a ring / donut
func get_point_in_annulus(center: Vector3, min_radius: float, max_radius: float) -> Vector3:
	var angle = randf() * TAU
	var radius = randf_range(min_radius, max_radius)
	var raw = center + Vector3(cos(angle), 0, sin(angle)) * radius
	return get_nav_point(raw)

## Find a patrol point around a location using sampling
func find_patrol_point(center: Vector3, radius: float) -> Vector3:
	return get_random_point_around(center, radius)

## Generate multiple random navigable points
func get_random_points(center: Vector3, radius: float, count: int) -> Array:
	var pts := []
	for i in range(count):
		pts.append(get_random_point_around(center, radius))
	return pts

## Get reachable point toward a direction
func project_direction(origin: Vector3, direction: Vector3, distance: float) -> Vector3:
	var raw = origin + direction.normalized() * distance
	return get_nav_point(raw)
	
## Is a point on the navmesh
func is_navigable(point: Vector3) -> bool:
	if not agent.get_navigation_map():
		return false
	var projected = NavigationServer3D.map_get_closest_point(agent.get_navigation_map(), point)
	return projected.distance_to(point) < 0.5

func get_next_path_point() -> Vector3:
	return agent.get_next_path_position()
