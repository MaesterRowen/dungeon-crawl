class_name Weapon3D extends Node3D

signal weapon_hit( info: HitInfo )
signal attack_started(attack_data)
signal attack_ended(attack_data)

var base_damage : float = 10.0
var owner_actor : Node = null
var hitboxes: Array[HitBox3D]

func _ready() -> void:
	_collect_hitboxes()

func _collect_hitboxes() -> void:
	hitboxes.clear()
	for child in get_children():
		if child is HitBox3D:
			hitboxes.append(child)
			child.hit_started.connect(_on_hit_started)

func toggleWeaponCollision(state: bool) -> void:
	for hitbox in hitboxes:
		hitbox.monitoring = state

func _on_hit_started( info: HitInfo ) -> void:
	# Decorate hit info
	info.damage = base_damage
	info.source_weapon = self
	info.origin_actor = owner_actor
	weapon_hit.emit(info)
