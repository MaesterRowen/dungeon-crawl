extends CharacterBody3D

@onready var combat_component: CombatComponent = $CombatComponent


func _ready() -> void:
	combat_component.received_damage.connect(_on_received_damage)
	

func _on_received_damage(amount: float, hit_info: HitInfo) -> void:
	print("damage received: ", str(amount))
