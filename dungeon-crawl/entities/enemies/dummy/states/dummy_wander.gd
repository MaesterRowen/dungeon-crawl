extends State

@export var controller : AIController
@export var perception : PerceptionComponent

@export var wander_radius: float = 10.0
@export var min_wander_distance: float = 4.0
@export var chance_to_keep_wandering := 0.25 # 25% chance to skip Idle

var home_pos : Vector3
var preferred_direction : Vector3 = Vector3.ZERO

func enter(msg := {} ) -> void:
	home_pos = controller.character.global_position
	
	preferred_direction = msg.get("preferred_direction", Vector3.ZERO)
	
	_pick_new_wander_point()
	
	if perception:
		perception.target_acquired.connect(_on_target_acquired)
		
func exit() -> void:
	if perception:
		perception.target_acquired.disconnect(_on_target_acquired)	
	
func phsyics_update(delta: float) -> void:
	# If reached destination -> wait
	if controller.has_arrived():
		if randf() <= chance_to_keep_wandering:
			_pick_new_wander_point()
			return
			
		transition_to("Idle")
		return
	
	# Keep moving toward wander target
	controller.follow(delta)

func _on_target_acquired(target: Node3D) -> void:
	#transition_to("Chase", {"target": target})
	pass

func _pick_new_wander_point() -> void:
	var forward = preferred_direction
	
	# if no preferred direction (first wander), use a random one
	if forward.length() < 0.1:
		forward = Vector3(randf() * 2 - 1, 0, randf() * 2 - 1).normalized()
		
	var tries := 20
	
	while tries > 0:
		tries -= 1
		
		# A random directoin BUT biased toward forward
		var random_offset = Vector3(randf() * 2 - 1, 0, randf() * 2 - 1).normalized()
		var biased_dir = (forward + random_offset * 1.0).normalized()
		
		# Random radius
		var distance = randf() * wander_radius
		var raw_target = home_pos + biased_dir * distance
		
		var nav_target = controller.get_nav_point(raw_target)
		
		if nav_target.distance_to(home_pos) >= min_wander_distance:
			controller.move_to(nav_target)
			return
	
	controller.move_to(home_pos)
