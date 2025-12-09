class_name Interactable extends Area3D

@export var interact_prompt: String = ""
@export var is_interactable: bool = true

var interact : Callable = func() :
	pass
	
func enable() -> void:
	is_interactable = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
func disable() -> void:
	is_interactable = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
