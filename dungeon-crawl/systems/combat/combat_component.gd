class_name CombatComponent extends Node

signal dealt_damage(amount: float, hit_info: HitInfo)
signal received_damage(amount: float, hit_info: HitInfo)

@export var hurtbox: HurtBox3D
@export var health_component : HealthComponent
@export var weapon_handler : WeaponHandler

var owning_actor : Node

func _ready() -> void:
	owning_actor = get_parent() as Node
	
	if hurtbox:
		hurtbox.hurtbox_hit.connect(_on_hurtbox_hit)
	
	if weapon_handler:
		weapon_handler.weapon_hit.connect(_on_weapon_hit)

func _on_weapon_hit(info: HitInfo) -> void:
	info.damage = info.damage * 1.5
	info.knockback = Vector3.ZERO # no knockback
	info.hit_direction = (info.target_actor.global_position - info.origin_actor.global_position).normalized()
	if is_instance_valid(info.hurtbox):
		info.hurtbox.receive_hit(info)

func _on_hurtbox_hit( info: HitInfo ) -> void:
	print("enemy hurtbox hit by ", info.origin_actor.name)
	var final_damage = _calculate_damage_taken(info)
	_apply_damage(final_damage, info)
	
func _calculate_damage_taken(info: HitInfo ) -> float:
	return info.damage
	
func _apply_damage(amount: float, info: HitInfo ) -> void:
	if health_component:
		health_component.take_damage(amount)
	
	received_damage.emit(amount, info)
