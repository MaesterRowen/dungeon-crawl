extends State

func enter(_msg := {} ) -> void:
	print("entered None")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("light_attack"):
		transition_to("LightAttack", { "input" : "light_attack"})
	
	if event.is_action_pressed("magic"):
		transition_to("CastTarget", { "spell" : "fire"})
