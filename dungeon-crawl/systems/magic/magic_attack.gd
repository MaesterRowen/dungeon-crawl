class_name MagicAttack extends Node3D

signal on_magic_hit(info: HitInfo)

@onready var hitbox: HitBox3D = $HitBox3D

@export var projectile : ProjectileMovementComponent = null
@export var destroy_on_impact := false
@export var impact_effect : PackedScene
@export var camera_shake_strength: float = 0.1

var owner_actor : Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.hit_started.connect(_on_hit_started)
	if projectile:
		projectile.projectile_stop.connect(_on_projectile_stopped)

func _on_projectile_stopped(hit_result: Dictionary) -> void:
	if destroy_on_impact:
		await get_tree().create_timer(0.05).timeout
		if impact_effect:
			var instance = impact_effect.instantiate()
			get_tree().current_scene.add_child(instance)
			instance.global_position = global_position
		queue_free.call_deferred()	

func _on_hit_started(info : HitInfo) -> void:
	info.attack_type = "magic"
	info.damage = 50
	info.origin_actor = owner_actor
	on_magic_hit.emit(info)
	SignalBus.camera_shake.emit(camera_shake_strength)
	if destroy_on_impact:
		if impact_effect:
			var instance = impact_effect.instantiate()
			get_tree().current_scene.add_child(instance)
			instance.global_position = global_position
		queue_free.call_deferred()
