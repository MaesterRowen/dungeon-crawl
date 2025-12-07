class_name HeroCharacter extends Node3D

signal anim_notify_start_damage
signal anim_notify_stop_damage
signal anim_notify_exit_recovery
signal anim_notify_open_cancel
signal anim_notify_close_cancel

@onready var anim_tree: AnimationTree = %AnimationTree


func _ready() -> void:
	anim_tree.active = true

func set_player_speed(ratio: float) -> void:
	ratio = clampf(ratio, 0.0, 1.0)
	anim_tree.set("parameters/locomotion/blend_position", ratio)

func fall() -> void:
	pass

func testA() -> void:
	print("TEST-A")

func testB() -> void:
	print("TEST-B")
	
func testC() -> void:
	print("TEST-C")	

func play_attack( anim_name: String) -> void:
	var anim = anim_tree.tree_root.get_node("primary_attack") as AnimationNodeAnimation
	anim.animation = anim_name
	anim_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


# ---------------------------
# Animation Notifies
# ---------------------------
func emitAnimNotifyStartDamage() -> void:
	anim_notify_start_damage.emit()
	
func emitAnimNotifyStopDamage() -> void:
	anim_notify_stop_damage.emit()
	
func emitAnimNotifyExitRecovery() -> void:
	anim_notify_exit_recovery.emit()
	
func emitAnimNotifyOpenCancel() -> void:
	anim_notify_open_cancel.emit()
	
func emitAnimNotifyCloseCancel() -> void:
	anim_notify_close_cancel.emit()	
