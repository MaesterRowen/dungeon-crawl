extends State

@export var player: CharacterBody3D
@export var character: HeroCharacter
@export var magic_cursor : PackedScene

var _cursor_instance : Node3D = null

func enter(_msg := {} ) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_create_cursor()

func exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_release_cursor()
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var pos := _cursor_instance.global_position
		transition_to("IceSpikeSpell", { "position" : pos})
	elif event.is_action_pressed("ui_cancel"):
		transition_to.call_deferred("ListenForInput")

func unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	_update_cursor()

func _create_cursor() -> void:
	_cursor_instance = magic_cursor.instantiate()
	get_tree().current_scene.add_child(_cursor_instance)
	_update_cursor()

func _update_cursor() -> void:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	#print(mouse_pos)
	var plane = Plane(Vector3(0, 1, 0), player.global_position.y)
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0
	var cursor_pos = plane.intersects_ray(from, to)
	if cursor_pos:
		_cursor_instance.global_position = cursor_pos

func _release_cursor() -> void:
	if is_instance_valid(_cursor_instance):
		_cursor_instance.queue_free()
