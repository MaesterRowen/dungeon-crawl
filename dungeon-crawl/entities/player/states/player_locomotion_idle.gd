extends State

@export var player : CharacterBody3D
@export var character : HeroCharacter

func enter(_msg := {} ) -> void:
	character.set_player_speed(0.0)


func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func phsyics_update(_delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if not is_equal_approx(raw_input.length_squared(), 0.0):
		transition_to("Move")

	player.move_and_slide()
