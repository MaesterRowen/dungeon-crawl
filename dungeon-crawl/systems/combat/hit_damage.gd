class_name HitDamage extends RefCounted

var _instigator : Node3D = null
var _tag : String = ""
var _magnitude : float = 0.0
var _direction: Vector3 = Vector3.ZERO
var _knockback_strength := 0.0

func _init(magnitude: float, tag: String, instigator: Node3D ) -> void:
	_instigator = instigator
	_magnitude = magnitude
	_tag = tag
	_direction = Vector3.ZERO

func get_instigator() -> Node3D:
	return _instigator

func get_tag() -> String:
	return _tag
	
func get_magnitude() -> float:
	return _magnitude

func set_knockback(dir: Vector3, strength: float) -> void:
	_direction = dir
	_knockback_strength = strength

func set_direction(dir: Vector3) -> void:
	_direction = dir
	
func get_direction() -> Vector3:
	return _direction
	
func get_knockback_strength() -> float:
	return _knockback_strength
