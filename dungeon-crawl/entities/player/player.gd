extends CharacterBody3D

@export var active_weapon: WeaponData = null

@onready var _character: HeroCharacter = %HeroCharacter
@onready var attack_controller: AttackController = $AttackController
@onready var weapon_handler: WeaponHandler = $WeaponHandler
@onready var controller: PlayerController = $PlayerController

@onready var action_fsm: StateMachine = $StateMachines/ActionFSM
@onready var locomotion_fsm: StateMachine = $StateMachines/LocomotionFSM

var locomotion_state: String = ""
var action_state : String = ""

func _on_locomotion_state_changed(state: String) -> void:
	locomotion_state = state
	var label := get_tree().get_first_node_in_group("debug_label") as Label
	label.text = locomotion_state + "|" + action_state

func _on_action_state_changed(state: String) -> void:
	action_state = state
	var label := get_tree().get_first_node_in_group("debug_label") as Label
	label.text = locomotion_state + "|" + action_state

func _ready() -> void:
	# Configure the camera rig to follow this player
	var _camera_rig := get_tree().get_first_node_in_group("camera_rig") as CameraRig
	_camera_rig.set_camera_mode(CameraRig.CameraMode.FOLLOW)
	_camera_rig.set_follow_target(%CameraPivot)
	
	# Connect to Animation Notify Signals
	_character.anim_notify_start_damage.connect(attack_controller.phase_enter_active)
	_character.anim_notify_stop_damage.connect(attack_controller.phase_exit_active)
	_character.anim_notify_exit_recovery.connect(attack_controller.phase_exit_recovery)
	_character.anim_notify_open_cancel.connect(attack_controller.enable_cancel)
	_character.anim_notify_close_cancel.connect(attack_controller.disable_cancel)
	
	locomotion_fsm.state_changed.connect(_on_locomotion_state_changed)
	action_fsm.state_changed.connect(_on_action_state_changed)
	
	# Spawn & Equip Starting Weapon
	_spawn_weapon()

func _physics_process(delta: float) -> void:
	# Let the controller decide XZ + rotation
	controller.tick_physics(delta)
	
	# Update velocity related animation states
	if not is_on_floor() and velocity.y < 0.0:
		_character.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		var speed_ratio = ground_speed / controller.max_ground_speed()
		_character.set_player_speed(speed_ratio)	
	
	# Move the character
	move_and_slide()

func _spawn_weapon() -> void:
	if not active_weapon:
		return
	
	var weapon_instance = active_weapon.weapon_scene.instantiate()
	weapon_handler.register_spawned_weapon(active_weapon.weapon_tag, weapon_instance, true)
	_character.get_weapon_socket().add_child(weapon_instance)	
