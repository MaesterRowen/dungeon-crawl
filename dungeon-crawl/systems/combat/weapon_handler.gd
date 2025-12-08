class_name WeaponHandler extends Node

# CONFIGURATION
@export var character: CharacterBody3D = null:
	set(value):
		character = value
		update_configuration_warnings()

## Maps a Tag -> WeaponBase instance
var _carried_weapon_map: Dictionary

## The currently equipped weapon Tag
var _current_equipped_weapon_tag: StringName = ""

## Tracks waht the waepon has already hit during its active collision window
var _overlapped_objects: Array[Node3D] = []

# SIGNALS
signal weapon_equipped(weapon: Weapon3D)
signal weapon_unequipped(weapon: Weapon3D)
signal weapon_hit(target: Node3D, weapon: Weapon3D)

# ---------------------------------------------------------
# REGISTERING AND MANAGING WEAPONS
# ---------------------------------------------------------
func register_spawned_weapon(weapon_tag: StringName, weapon: Weapon3D, equip_now := false) -> void:
	if _carried_weapon_map.has(weapon_tag):
		push_warning("Weapon with tag '%s' already registered." % weapon_tag)
		return
	
	# Store weapon instance
	_carried_weapon_map[weapon_tag] = weapon
	
	# Connect hit events
	weapon.weapon_hit.connect(_on_weapon_hit)
	
	if equip_now:
		equip_weapon(weapon_tag)

func equip_weapon(weapon_tag: StringName) -> void:
	if not _carried_weapon_map.has(weapon_tag):
		push_warning("Cannot equip weapon '%s': not registered" % weapon_tag)
		return
	
	# If swapping weapons, unequip previous
	if _current_equipped_weapon_tag != "" and _current_equipped_weapon_tag != weapon_tag:
		var old_weapon = get_current_weapon()
		weapon_unequipped.emit(old_weapon)
	
	_current_equipped_weapon_tag = weapon_tag
	var new_weapon = _carried_weapon_map[weapon_tag]
	
	weapon_equipped.emit(new_weapon)

func unequip_current_weapon() -> void:
	if _current_equipped_weapon_tag == "":
		return
		
	var weapon = get_current_weapon()
	weapon_unequipped.emit(weapon)
	_current_equipped_weapon_tag = ""

func can_attack() -> bool:
	return _current_equipped_weapon_tag != ""

func get_current_weapon() -> Weapon3D:
	if _carried_weapon_map.has(_current_equipped_weapon_tag):
		return _carried_weapon_map[_current_equipped_weapon_tag]
	return null

func get_weapon_by_tag(tag: StringName) -> Weapon3D:
	if _carried_weapon_map.has(tag):
		return _carried_weapon_map[tag]
	return null

# ---------------------------------------------------------
# COLLISION CONTROL
# Used by Attack Controller during strike windows
# ---------------------------------------------------------
func toggle_weapon_collision(enabled: bool) -> void:
	var weapon := get_current_weapon()
	if not weapon:
		return
	
	weapon.toggleWeaponCollision(enabled)
	
	if not enabled:
		# Clear previous hit list for next attack
		_overlapped_objects.clear()

# ---------------------------------------------------------
# INTERNAL CALLBACKS
# ---------------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not character:
		warnings.append("Character must be set for this node to function properly")
	return warnings

func _on_weapon_hit( info: HitInfo ) -> void:
	info.origin_actor = character
	weapon_hit.emit(info)
