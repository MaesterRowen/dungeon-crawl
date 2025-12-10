extends Node3D

@onready var interactable: Interactable = $Interactable
@onready var anim_player: AnimationPlayer = $AnimationPlayer


var is_opened: bool = false

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact() -> void:
	if is_opened == true:
		return
	
	is_opened = true
	interactable.disable()
	anim_player.play("open")
	
