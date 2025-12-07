class_name HitBox3D extends Area3D

signal hit_started( hit_info: HitInfo )
signal hit_ended( hit_info: HitInfo )

var enabled: bool = true

func _ready() -> void:
	monitoring = false
	monitorable = false
	
	area_entered.connect(_on_hitbox_area_entered)
	area_exited.connect(_on_hitbox_area_exited)

func _on_hitbox_area_entered(other: Area3D) -> void:
	if not enabled:
		return
		
	if other is HurtBox3D:
		var info : HitInfo = HitInfo.new()	
		info.hitbox = self
		info.hurtbox = other as HurtBox3D
		hit_started.emit(info)
		
func _on_hitbox_area_exited(other: Area3D) -> void:
	if not enabled:
		return
		
	if other is HurtBox3D:
		var info : HitInfo = HitInfo.new()	
		info.hitbox = self
		info.hurtbox = other as HurtBox3D
		hit_ended.emit(info)
