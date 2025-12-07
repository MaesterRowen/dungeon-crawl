class_name HitInfo extends RefCounted

var origin_actor : Node = null
var target_actor : Node = null
var hitbox : HitBox3D = null
var hurtbox : HurtBox3D = null
var source_weapon: Node = null
var damage : float = 0.0
var attack_type: String = "melee"
var knockback: Vector3  = Vector3.ZERO
var metadata : Dictionary = {}
