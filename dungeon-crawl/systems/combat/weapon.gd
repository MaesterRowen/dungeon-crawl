class_name Weapon3D extends Node3D

signal weapon_hit( info: HitInfo )
signal attack_started(attack_data)
signal attack_ended(attack_data)

@onready var cast : ShapeCast3D = $ShapeCast3D

var base_damage : float = 10.0
var owner_actor : Node = null
var _prev_global: Transform3D
var _swing_active : bool = false
var _hit := {}
var _end_requested : bool = false

func _ready() -> void:
	_prev_global = global_transform
	cast.enabled = false
	
func _start_swing() -> void:
	_swing_active = true
	_hit.clear()
	_prev_global = global_transform
	_end_requested = false
	cast.enabled = true
	
func _end_swing() -> void:
	_swing_active = false
	_end_requested = true
	cast.enabled = false

func toggleWeaponCollision(state: bool) -> void:
	if state:
		_start_swing()
	else:
		_end_swing()

func _physics_process( _delta: float ) -> void:
	if not _swing_active:
		_prev_global = global_transform
		return
	
	_do_sweep()
	
	if _end_requested:
		_swing_active = false
		_end_requested = false
		cast.enabled = false
		
	_prev_global = global_transform	

func _do_sweep() -> void:
		# Compute how far the sword moved since the last physics tick
	cast.force_update_transform()
	var prev_pos : Vector3 = _prev_global.origin
	var curr_pos : Vector3 = global_transform.origin
	var delta_pos : Vector3 = curr_pos - prev_pos
	
	# Make the cast sweep from the previous pose to the current pose.
	# ShapeCast  casts from its current transform toward target_position.
	# So we temporarily place it at the previous transform and cast forward by delta_pos
	var saved_xform := cast.global_transform
	cast.global_transform = _prev_global
	cast.target_position = delta_pos
	
	# Force update so we can read collisions immediately this tick
	cast.force_shapecast_update()
	
	# Read all hits along the sweep
	var count := cast.get_collision_count()
	for i in count:
		var collider := cast.get_collider(i)
		if collider == null:
			continue
		if _hit.has(collider):
			continue
			
		_hit[collider] = true
		if collider is HurtBox3D:
			var info : HitInfo = HitInfo.new()	
			info.hitbox = null
			info.hurtbox = collider as HurtBox3D
			info.target_actor = info.hurtbox.owner_actor
			info.damage = base_damage
			weapon_hit.emit(info)
	
	cast.global_transform = saved_xform
