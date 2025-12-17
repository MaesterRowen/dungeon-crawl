class_name StateMachine extends Node

signal state_changed(state: String)

@export var initial_state: String = ""

var states : Dictionary = {}
var current_state : State

func _ready() -> void:
	_init_machine()

func _init_machine() -> void:
	_cache_states()
	_enter_initial_state()

func _cache_states() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self

func _enter_initial_state() -> void:
	if not states.has(initial_state):
		push_warning("Initial state '%s' not found" % initial_state)
		return
	current_state = states[initial_state]
	state_changed.emit.call_deferred(initial_state)
	current_state.enter()

func interrupt_to(target: String, reason: StringName, ctx := {} ) -> bool:
	if not states.has(target):
		push_warning("Cannot interrupt to unknown state '%s'" % target)
		return false
	
	if current_state:
		if current_state.name == target: return true
		if not current_state.can_be_interrupted(reason): return false
		current_state.handle_interrupt(reason, ctx)
		current_state.exit()
	
	current_state = states[target]
	state_changed.emit(target)
	var enter_msg := ctx.duplicate()
	enter_msg["interrupt_reason"] = reason
	current_state.enter(enter_msg)
	return true

func transition_to(target: String, msg := {} ) -> void:
	if not states.has(target):
		push_warning("Cannot transition to unknown state '%s'" % target)
		return
	
	if current_state:
		current_state.exit()
	current_state = states[target]
	state_changed.emit(target)
	current_state.enter(msg)
	
func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.unhandled_input(event)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.phsyics_update(delta)
