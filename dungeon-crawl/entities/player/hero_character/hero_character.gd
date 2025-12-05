class_name HeroCharacter extends Node3D


@onready var anim_tree: AnimationTree = %AnimationTree


func _ready() -> void:
	anim_tree.active = true

func set_player_speed(ratio: float) -> void:
	ratio = clampf(ratio, 0.0, 1.0)
	anim_tree.set("parameters/locomotion/blend_position", ratio)

func fall() -> void:
	pass
