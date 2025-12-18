class_name PlayerStateCoordinator extends Node

signal state_changed(machine_type: MachineType, state: String)

@export var action_fsm : StateMachine
@export var locomtion_fsm : StateMachine

enum MachineType { ACTION, LOCOMOTION }

var state_machine_active_states : Dictionary[MachineType, String] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_fsm.state_changed.connect(_on_state_changed.bind(MachineType.ACTION))
	locomtion_fsm.state_changed.connect(_on_state_changed.bind(MachineType.LOCOMOTION))
	
func _on_state_changed(state: String, machine_type: MachineType) -> void:
	print("[", MachineType.keys()[machine_type], "]: ", state)
	state_machine_active_states[machine_type] = state
	state_changed.emit(machine_type, state)
	
	if machine_type == MachineType.LOCOMOTION:
		if state == "Jump" or state == "Fall":
			action_fsm.interrupt_to("ListenForInput", "Locomotion")

func get_current_state_by_machine_type(machine_type: MachineType) -> String:
	if state_machine_active_states.has(machine_type):
		return state_machine_active_states[machine_type]
	return ""
