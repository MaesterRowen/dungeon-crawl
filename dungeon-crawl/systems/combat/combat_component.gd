class_name CombatComponent extends Node

signal dealt_damage(amount: float, hit_info: HitInfo)
signal received_damage(amount: float, hit_info: HitInfo)

@export var hurtbox: HurtBox3D
@export var health_component : HealthComponent
@export var weapon_handler : WeaponHandler

var owning_actor : Node

func _ready() -> void:
	owning_actor = get_parent() as Node

func _on_hurtbox_hit( info: HitInfo ) -> void:
	var final_damage = _calculate_damage_taken(info)
	_apply_damage(final_damage, info)
	
func _calculate_damage_taken(info: HitInfo ) -> float:
	return info.damage
	
func _apply_damage(amount: float, info: HitInfo ) -> void:
	if health_component:
		health_component.take_damage(amount)
	
	received_damage.emit(amount, info)
