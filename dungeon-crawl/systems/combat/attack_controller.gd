class_name AttackController extends Node

signal attack_started( attack: AttackData )
signal attack_ended( attack: AttackData )

@export var character : Node3D
@export var weapon_handler: WeaponHandler

@export var combo_tree: Dictionary[String, AttackData]
var current_attack: AttackData

var next_attack_name : String = ""
var can_queue_next : bool = false
var can_cancel_on_hit : bool = false

func _ready() -> void:
	pass
	
func request_attack(attack_name: String) -> void:
	# If we don't have a weapon equipped, then we can't attack
	if weapon_handler and not weapon_handler.can_attack():
		return
	
	# Case 1: No attack active -> start immediately
	if current_attack == null:
		var first_attack := _find_first_attack(attack_name)
		if first_attack != "":
			_start_attack(first_attack)
		return
		
	var next_attack := _find_next_attack_in_chain(attack_name, current_attack)
	if next_attack == "":
		return
	
	# Case 2: Attack in progress -> try to buffer the next one
	if can_queue_next or can_cancel_on_hit:
		next_attack_name = next_attack

func _find_first_attack(attack_name: String) -> String:
	for attack in combo_tree.keys():
		if attack.begins_with(attack_name + "_1"):
			return attack
	return ""
	
func _find_next_attack_in_chain(attack : String, current : AttackData ) -> String:
	for next_name in current.next_attacks:
		if next_name.begins_with(attack):
			return next_name
	return ""

func notify_hit_landed( info: HitInfo ) -> void:
	if current_attack and current_attack.can_cancel_on_hit:
		can_cancel_on_hit = true

func _start_attack(attack_name: String) -> void:
	current_attack = combo_tree[attack_name]
	next_attack_name = ""
	can_queue_next = false
	can_cancel_on_hit = false
	
	# Emit Signal
	attack_started.emit(current_attack)

func phase_enter_active() -> void:
	#print("HIT BOX ACTIVE")
	weapon_handler.toggle_weapon_collision(true)

func phase_exit_active() -> void:
	#print("HIT BOX INACTIVE")
	weapon_handler.toggle_weapon_collision(false)
	can_queue_next = true

func phase_exit_recovery() -> void:
	# Emit signal attack finished
	attack_ended.emit(current_attack)
	
	# If a next attack is queued, start it
	if next_attack_name != "":
		_start_attack(next_attack_name)
	else:
		current_attack = null
		can_queue_next = false
		can_cancel_on_hit = false

func enable_cancel() -> void:
	can_cancel_on_hit = true

func disable_cancel() -> void:
	can_cancel_on_hit = false
