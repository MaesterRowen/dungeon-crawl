class_name MagicController extends Node

signal location_picked(position: Vector3)

@export var _magic_cursor : PackedScene

func is_active() -> bool:
	return _is_active

var _is_active := false
var _cursor_instance : Node3D = null

func activate() -> void:
	_is_active = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_setup.call_deferred()
	
func deactivate() -> void:
	_is_active = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_instance_valid(_cursor_instance):
		_cursor_instance.queue_free()


func _setup() -> void:
	_cursor_instance = _magic_cursor.instantiate()
	get_tree().current_scene.add_child(_cursor_instance)
	
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	#print(mouse_pos)
	var plane = Plane(Vector3(0, 1, 0), get_parent().global_position.y)
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0
	var cursor_pos = plane.intersects_ray(from, to)
	if cursor_pos:
		_cursor_instance.global_position = cursor_pos
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and is_active():
		var pos := _cursor_instance.global_position
		location_picked.emit(pos)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return
	
	var is_camera_motion := (
		event is InputEventMouseMotion
	)
	
	if not is_camera_motion:
		return
	
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	#print(mouse_pos)
	var plane = Plane(Vector3(0, 1, 0), get_parent().global_position.y)
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0
	var cursor_pos = plane.intersects_ray(from, to)
	if cursor_pos:
		_cursor_instance.global_position = cursor_pos
		#print(result.position)

func get_mouse_world_position() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0
	var space = (get_parent() as Node3D).get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.collision_mask = 1
	params.exclude = [self]
	var result := space.intersect_ray(params)
	if result:
		return result.position
	return Vector3.ZERO

func _process(delta: float) -> void:
	if not _is_active:
		return
		
	#_cursor_instance.global_position = get_parent().global_position
