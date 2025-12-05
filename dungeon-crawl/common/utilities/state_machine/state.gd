class_name State extends Node

var state_machine : Node

func enter(_msg := {} ) -> void:
	pass
	
func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func phsyics_update(_delta: float) -> void:
	pass
	
func transition_to(state_name: String, msg := {} ) -> void:
	state_machine.transition_to(state_name, msg)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
