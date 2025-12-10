class_name ProjectileMovementComponent extends Node

@export var gravity : float = -9.8
@export var horizontal_movement_speed := 750.0
@export var vertical_movement_speed := 500.0
@export var destroy_after_seconds := 60.0
@export var use_gravity := true
@export var velocity : Vector3 = Vector3.ZERO
@export var destroy_on_impact := true
@export var floor_check_distance: float = 0.3

signal hit_floor(global_position: Vector3)

var _time_alive := 0.0


var controlled_node : Node3D = null

func _ready() -> void:
	controlled_node = get_parent()

func _physics_process(delta: float) -> void:
	if not controlled_node:
		return
	
	# Apply Gravity
	if use_gravity:
		velocity.y += gravity * delta
	
	# Predict the next position
	var next_pos = controlled_node.global_position + velocity * delta

	# Check floor collision with downward raycast
	if _check_floor_collision(controlled_node.global_position, next_pos):
		emit_signal("hit_floor", controlled_node.global_position)
	
		if destroy_on_impact:
			controlled_node.queue_free()
		else:
			velocity = Vector3.ZERO
		return

	# Move Object
	controlled_node.global_position = next_pos
	
	# Lifetime cleanup
	_time_alive += delta
	if destroy_after_seconds > 00 and _time_alive >= destroy_after_seconds:
		controlled_node.queue_free()

func _check_floor_collision(start: Vector3, end: Vector3) -> bool:
	var space = controlled_node.get_world_3d().direct_space_state
	
	var ray_origin = start
	var ray_end = end +Vector3.DOWN * floor_check_distance
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space.intersect_ray(query)
	return result.size() > 0
