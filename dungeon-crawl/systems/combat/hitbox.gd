class_name HitBox3D extends Area3D

signal hit_target( hurtbox: HurtBox3D )
signal pulled_from_target( hurtbox: HurtBox3D )

func _init() -> void:
	pass

func _ready() -> void:
	monitoring = false
	monitorable =false
	
	area_entered.connect(_on_hitbox_area_entered)
	area_exited.connect(_on_hitbox_area_exited)

func _on_hitbox_area_entered(other: Area3D) -> void:
	if other is not HurtBox3D:
		return
	
	hit_target.emit(other as HurtBox3D)
		
func _on_hitbox_area_exited(other: Area3D) -> void:
	if other is not HurtBox3D:
		return
		
	pulled_from_target.emit(other as HurtBox3D)
