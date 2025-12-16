extends State

@export var combat_component: CombatComponent
@export var player: CharacterBody3D
@export var character: HeroCharacter
@export var fire_attack : PackedScene

func enter(msg := {} ) -> void:
	var position := msg["position"] as Vector3
	_do_fire_attack(position)
	transition_to("ListenForInput")
	
func _do_fire_attack(pos: Vector3) -> void:
	var instance = fire_attack.instantiate() as MagicAttack
	instance.on_magic_hit.connect(combat_component._on_weapon_hit)
	instance.owner_actor = player
	get_tree().current_scene.add_child(instance)
	var pmc : ProjectileMovementComponent = instance.get_node_or_null("ProjectileMovementComponent")
	if pmc:
		pmc.velocity = (pos - player.global_position).normalized() * 50.0
		pmc.initial_speed = 100.0
		pmc.max_speed = 100.0
		instance.global_position = player.global_position + Vector3.UP
