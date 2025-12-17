extends State

@export var controller: PlayerController

func enter(_msg := {} ) -> void:
	pass

func update(_delta: float) -> void:
	var body = controller.body()
	if body.is_on_floor():
		if controller.is_stopped():
			transition_to("Idle")
		else:
			transition_to("Move")
		
