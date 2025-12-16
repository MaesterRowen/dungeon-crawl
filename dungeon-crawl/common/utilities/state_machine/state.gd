class_name State extends Node

var state_machine : Node

func enter(_msg := {} ) -> void:
	pass
	
func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func unhandled_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func phsyics_update(_delta: float) -> void:
	pass
	
func transition_to(state_name: String, msg := {} ) -> void:
	state_machine.transition_to(state_name, msg)
