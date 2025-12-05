class_name PerceptionComponent extends Node3D

# Configurable Settings
@export var vision_range := 15.0
@export var vision_angle := 90.0
@export var vision_layer_mask := 2
@export var target_group := "player"
@export var prediction_time := 0.5  ## Seconds into the future

# Tracking
var tracked_targets := {} # { body: { visible = bool, last_seen = Vector3 }

# Runtime Nodes
var vision_area : Area3D
var los_raycast : RayCast3D

# Signals
signal target_acquired(target)
signal target_lost(target)

# Life Cycle
func _ready() -> void:
	_create_vision_area()
	_create_los_raycast()

func _physics_process(delta: float) -> void:
	_update_visibility(delta)

# Create Runtime Nodes
func _create_vision_area() -> void:
	vision_area = Area3D.new()
	vision_area.collision_mask = vision_layer_mask
	vision_area.collision_layer = 0
	add_child(vision_area)
	
	var shape = SphereShape3D.new()
	shape.radius = vision_range
	
	var coll = CollisionShape3D.new()
	coll.shape = shape
	vision_area.add_child(coll)
	
	vision_area.body_entered.connect(_on_body_entered)
	vision_area.body_exited.connect(_on_body_exited)

func _create_los_raycast() -> void:
	los_raycast = RayCast3D.new()
	los_raycast.enabled = true
	add_child(los_raycast)
	
# Area Callbacks
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(target_group):
		tracked_targets[body] = {
			"visible": false,
			"last_seen" : body.global_position,
			"previous_seen": body.global_position,
			"velocity" : Vector3.ZERO,
			"predicted" : body.global_position
		}
		set_physics_process(true)

func _on_body_exited(body: Node3D) -> void:
	if tracked_targets.has(body):
		if tracked_targets[body]["visible"]:
			emit_signal("target_lost", body)
		
		tracked_targets.erase(body)
		
		if tracked_targets.is_empty():
			set_physics_process(false)

# Core visibility update
func _update_visibility(delta: float) -> void:
	for target in tracked_targets.keys():
		var entry = tracked_targets[target]
		var is_target_visible := _is_visible(target)
		var was_target_visible : bool = entry["visible"]
		
		if is_target_visible:
			# Movement Tracking
			entry["previous_seen"] = entry["last_seen"]
			entry["last_seen"] = target.global_position
			
			if entry["previous_seen"] != Vector3.ZERO:
				entry["velocity"] = (entry["last_seen"] - entry["previous_seen"]) / delta
			
			# Predicted future position linear
			entry["predicted"] = entry["last_seen"] + entry["velocity"] * prediction_time
			
			if not was_target_visible:
				entry["visible"] = true
				emit_signal("target_acquired", target)
		else:
			if was_target_visible:
				tracked_targets[target]["visible"] = false
				emit_signal("target_lost", target)

# Visibility Test
func _is_visible(target: Node3D) -> bool:
	if not is_instance_valid(target):
		return false
		
	var to_target := target.global_position - global_position
	
	# Distance
	if to_target.length() > vision_range:
		return false
		
	# FOV
	var forward := -global_transform.basis.z
	var angle := rad_to_deg(forward.angle_to(to_target.normalized()))
	if angle > vision_angle * 0.5:
		return false
		
	# Line of Sight
	los_raycast.global_transform.origin = global_position + Vector3.UP
	los_raycast.target_position = los_raycast.to_local(target.global_position + Vector3.UP)
	los_raycast.force_raycast_update()
	
	if los_raycast.is_colliding():
		return los_raycast.get_collider() == target
		
	return true

# Public Query API
## Get all visible targets
func get_visible_targets() -> Array:
	var arr := []
	for target in tracked_targets:
		if tracked_targets[target]["visible"]:
			arr.append(target)
	
	return arr

## Get closest visible target
func get_closest_visible_target() -> Node3D:
	var visible_targets = get_visible_targets()
	if visible_targets.is_empty():
		return null
	
	var closest: Node3D = visible_targets[0]
	var closest_dist := global_position.distance_to(closest.global_position)
	
	for target in visible_targets:
		var d = global_position.distance_to(target.global_position)
		if d < closest_dist:
			closest = target
			closest_dist = d
			
	return closest

## Get last-known-locations for all tracked targets
func get_last_known_locations() -> Array[Vector3]:
	var arr: Array[Vector3] = []
	for target in tracked_targets.keys():
		arr.append(tracked_targets[target]["last_seen"])
	return arr

## Get the closest last-known-location
func get_closest_last_known_location() -> Vector3:
	var closest_loc: Vector3 = Vector3.ZERO
	var closest_dist := INF
	var self_pos := global_position
	
	for target in tracked_targets.keys():
		var loc: Vector3 = tracked_targets[target]["last_seen"]
		var d:= self_pos.distance_to(loc)
		
		if d < closest_dist:
			closest_dist = d
			closest_loc = loc
	
	return closest_loc if closest_dist < INF else Vector3.ZERO

## Get the target whose last-known location is closest
func get_closest_last_known_target() -> Node3D:
	var closest_target: Node3D = null
	var closest_dist := INF
	var self_pos := global_position
	
	for target in tracked_targets.keys():
		var loc: Vector3 = tracked_targets[target]["last_seen"]
		var d:= self_pos.distance_to(loc)
		
		if d < closest_dist:
			closest_dist = d
			closest_target = target
	
	return closest_target

## Get the closest tracked target overall (visible OR not)
func get_closest_tracked_target() -> Node3D:
	var closest : Node3D = null
	var closest_dist := INF
	var self_pos := global_position
	
	for target in tracked_targets.keys():
		var d := self_pos.distance_to(target.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = target
	
	return closest

## Get predicted position of a specific target
func get_predicted_position(target: Node3D) -> Vector3:
	if tracked_targets.has(target):
		return tracked_targets[target]["predicted"]
	return Vector3.ZERO

## Get all predicted positions
func get_all_predicted_positions() -> Array[Vector3]:
	var arr := []
	for body in tracked_targets.keys():
		arr.append(tracked_targets[body]["predicted"])
	return arr

## Get closest predicted position (Vector3)
func get_closest_predicted_position() -> Vector3:
	var best_pos := Vector3.ZERO
	var best_dist := INF
	
	for body in tracked_targets.keys():
		var pos = tracked_targets[body]["predicted"]
		var d = global_position.distance_to(pos)
		if d < best_dist:
			best_dist = d
			best_pos = pos
	
	return best_pos if best_dist < INF else Vector3.ZERO

## Get closest preducted target (Node3D)
func get_closest_predicted_target() -> Node3D:
	var best_target : Node3D = null
	var best_dist := INF
	
	for target in tracked_targets.keys():
		var pos = tracked_targets[target]["predicted"]
		var d = global_position.distance_to(pos)
		if d < best_dist:
			best_dist = d
			best_target = target
	
	return best_target
