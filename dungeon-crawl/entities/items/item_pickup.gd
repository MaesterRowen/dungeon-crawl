extends Area3D

@export_group("Item")
@export var item: ItemData
@export var quantity: int = 1
@export var add_to_inventory : bool = true

@export_group("Config")
#@export var pickup_sound : SoundEffect.SOUND_EFFECT_TYPE
@export var animator : AnimationPlayer = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered( other: Node3D ) -> void:
	if other.has_method("pickup"):
		other.pickup(item, quantity)
		
	_on_pickup_effect()

func _on_pickup_effect() -> void:
	# Disable Collision
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# Play Sound Effect
	#AudioManager.create_sound(pickup_sound)
	
	# Wink Out
	await wink_out()
	queue_free()

func wink_out() -> void:
	if animator and animator.has_animation("wink-out"):
		animator.play("wink-out")
		await animator.animation_finished
