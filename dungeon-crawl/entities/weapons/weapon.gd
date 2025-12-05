class_name Weapon3D extends Node3D

signal onWeaponHitTarget( target: HurtBox3D )
signal onWeaponPulledFromTarget( target: HurtBox3D )

@export var hit_boxes: Array[HitBox3D]

func _ready() -> void:
	for hitbox in hit_boxes:
		hitbox.hit_target.connect(_on_begin_overlap)
		hitbox.pulled_from_target.connect(_on_end_overlap)

func toggleWeaponCollision(state: bool) -> void:
	for hitbox in hit_boxes:
		hitbox.monitoring = state

func _on_begin_overlap( other: HurtBox3D ) -> void:
	onWeaponHitTarget.emit(other)

func _on_end_overlap( other: HurtBox3D ) -> void:
	onWeaponPulledFromTarget.emit(other)
