class_name AttackData extends Resource

@export var name: String = "Unnamed Attack"

@export_group("Timing")
@export var startup_time : float = 0.15 	#before hitboxes turn on
@export var active_time: float = 0.25 		# hitboxes active
@export var recovery_time: float = 0.25 	# after hitboxes are turned off
@export var time_scale_factor: float = 1.0

@export_group("Hit Cancel")
@export var can_cancel_on_hit: bool = false
@export var cancel_window_start: float = 0.0
@export var cancel_window_end: float = 0.0

@export_group("Combo Chaining")
@export var next_attacks : Array[String] = []  # valid follow-ups

@export_group("Damage")
@export var damage_multiplier : float = 1.0

@export_group("Animation")
@export var animation_name: StringName = "attack_01"

@export_group("Other")
@export var metadata : Dictionary = {}
