class_name PickupEmitter extends Node3D

@export var item_scene : PackedScene
@export var num_to_emit: int = 1
@export var launch_distance := 1.2 ## How far from the chest the item lands
@export var launch_height := 0.7 ## How high the arc goes

func emit() -> void:
	for i in num_to_emit:
		_emit_at_location(global_position)
	
func _emit_at_location(_location: Vector3) -> void:
	var item = item_scene.instantiate()
	get_parent().add_child(item)
	
	# Put the item at the chest's pivot point
	item.global_transform.origin = global_transform.origin
	
	# Compute the landing spot in front of the chest
	var forward = -global_transform.basis.z.normalized()
	var landing_pos = global_transform.origin + forward * launch_distance
	
	# Arc midpoint
	var mid_pos = (global_transform.origin + landing_pos) * 0.5	
	
	var sideways = global_transform.basis.x * randf_range(-2.75, 2.75)
	landing_pos += sideways
	mid_pos += sideways * 0.5
	mid_pos.y += launch_height
	
	# Tween movement
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(item, "global_transform:origin", mid_pos, 0.25)
	tween.tween_property(item, "global_transform:origin", landing_pos, 0.25)
