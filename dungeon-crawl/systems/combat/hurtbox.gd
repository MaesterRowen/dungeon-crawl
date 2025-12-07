class_name HurtBox3D extends Area3D

signal hurtbox_hit( info: HitInfo )

var owner_actor : Node = null
var damage_multiplier : float = 1.0
var invulnterable : bool = false

func receive_hit(info: HitInfo ) -> void:
	if invulnterable:
		return
	
	info.target_actor = owner_actor
	hurtbox_hit.emit(info)
