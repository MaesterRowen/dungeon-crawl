extends State

@export var controller : PlayerMotor

func enter(_msg := {} ) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		transition_to("Jump")

func update(_delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if not is_equal_approx(raw_input.length_squared(), 0.0):
		transition_to("Move")
