extends State

@export var controller: PlayerController

func enter(_msg := {} ) -> void:
	# Configure the camera rig to follow this player
	controller.request_jump()

func update(_delta: float) -> void:
	var velocity = controller.get_current_velocity()
	if velocity.y < 0.0:
		transition_to("Fall")
		
