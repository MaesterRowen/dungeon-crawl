extends State

@export var attack_controller: AttackController
@export var character: HeroCharacter
@export var controller : PlayerMotor

func _ready() -> void:
	attack_controller.attack_started.connect(_on_attack_started)
	attack_controller.attack_ended.connect(on_attack_ended)

func enter(_msg := {} ) -> void:
	attack_controller.request_attack("light_attack")
	transition_to("ListenForInput")

func _on_attack_started( attack: AttackData ) -> void:
	character.play_attack(attack.animation_name)
	#controller.set_move_lock("attack", true)
	#var world := character.to_global(attack.lunge_direction)
	#controller.set_velocity_override("attack", world, attack.lunge_duration)

	
func on_attack_ended( attack: AttackData) -> void:
	#controller.set_move_lock("attack", false)
	pass
	
