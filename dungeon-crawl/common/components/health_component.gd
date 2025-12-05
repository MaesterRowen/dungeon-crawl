class_name HealthComponent extends Node

signal health_changed(current: float, max: float)
signal died()

@export var max_health : float = 0.0

var current_health : float = 0.0
var is_dead : bool = false


func _ready() -> void:
	current_health = max_health
	is_dead = false
	
	
func take_damage(damage: float) -> bool:
	if is_dead:
		return false
		
	current_health = clampf(current_health - damage, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		is_dead = true
		died.emit()

	return true
