extends State

@export var attack_controller: AttackController
@export var character: HeroCharacter

func _ready() -> void:
	attack_controller.attack_started.connect(_on_attack_started)

func enter(_msg := {} ) -> void:
	attack_controller.request_attack("light_attack")
	transition_to("ListenForInput")

func _on_attack_started( attack: AttackData ) -> void:
	character.play_attack(attack.animation_name)
