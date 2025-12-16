extends State

@export var combat_component: CombatComponent
@export var player: CharacterBody3D
@export var character: HeroCharacter
@export var ice_attack : PackedScene

func enter(msg := {} ) -> void:
	var position := msg["position"] as Vector3
	_do_ice_attack(position)
	transition_to("ListenForInput")
	
func _do_ice_attack(pos: Vector3) -> void:
	var instance = ice_attack.instantiate() as MagicAttack
	instance.on_magic_hit.connect(combat_component._on_weapon_hit)
	instance.owner_actor = player
	get_tree().current_scene.add_child(instance)
	instance.look_at(pos, Vector3.UP)
	instance.global_position = pos	
	await get_tree().create_timer(2.0).timeout
	instance.queue_free()
