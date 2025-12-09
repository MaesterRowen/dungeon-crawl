class_name InteractingComponent extends Node3D

@onready var interaction_prompt: Label = $InteractionPrompt

var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interaction_prompt.hide()
			await current_interactions[0].interact.call()
			can_interact = true
		
func _process(_delta : float) -> void:
	if current_interactions and can_interact:
		if current_interactions.size() > 1:
			current_interactions.sort_custom(_sort_by_distance)
		if current_interactions[0].is_interactable:
			interaction_prompt.text = current_interactions[0].interact_prompt
			interaction_prompt.show()
	else:
		interaction_prompt.hide()

func _sort_by_distance(area1: Area3D, area2: Area3D):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

func _on_interact_range_area_entered(area: Area3D) -> void:
	current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area3D) -> void:
	current_interactions.erase(area)
