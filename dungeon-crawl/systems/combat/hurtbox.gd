class_name HurtBox3D extends Area3D

signal hurtbox_hit( info: HitInfo )

@export var owner_actor : Node = null
var invulnerable : bool = false

func receive_hit(info: HitInfo ) -> void:
	if invulnerable:
		return
	
	info.target_actor = owner_actor
	hurtbox_hit.emit(info)
