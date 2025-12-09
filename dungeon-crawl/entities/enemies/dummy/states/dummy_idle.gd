extends State

@export var controller : AIController
@export var perception : PerceptionComponent

@export var idle_time_min := 1.0
@export var idle_time_max := 3.0
@export var idle_turn_interval := 1.5		## How often to rotate
@export var turn_speed := 4.0				## Reused from AI Controller if desired

var timer := 0.0
var turn_timer := 0.0
var desired_yaw = null

func enter(_msg := {} ) -> void:
	# stop movement immediately
	controller.stop()
	
	timer = randf_range(idle_time_min, idle_time_max)
	turn_timer = idle_turn_interval
	
	# Listen for perception events
	if perception:
		perception.target_acquired.connect(_on_target_acquired)
	
func exit() -> void:
	if perception:
		perception.target_acquired.disconnect(_on_target_acquired)

func phsyics_update(delta: float) -> void:
	timer -= delta
	turn_timer -= delta
	
	# Look around occassionally
	if turn_timer <= 0.0:
		_pick_idle_turn_direction()
		turn_timer = idle_turn_interval
		
	# Rotate toward chosen idle yaw
	_rotate_idle(delta)
	
	# If time's up, transition to wander
	if timer <= 0:
		transition_to("Wander", {
			"preferred_direction" : controller.character.global_transform.basis.z * -1.0
		})


func _pick_idle_turn_direction() -> void:
	var current_yaw = controller.character.rotation.y
	var delta_angle = randf_range(-PI, PI)
	desired_yaw = current_yaw + delta_angle

func _rotate_idle(delta) -> void:
	if desired_yaw == null:
		return
		
	if controller.rotate_in_place(desired_yaw, delta):
		desired_yaw = null

func _on_target_acquired(target: Node3D) -> void:
	#transition_to("Chase", { "target" : target })
	pass
