extends CharacterBody3D

@onready var combat_component: CombatComponent = $CombatComponent
@onready var perception: PerceptionComponent = %PerceptionComponent
@onready var animator: AnimationPlayer = $AnimationPlayer

const GRAVITY := -9.8
var animation_locked := false

func _ready() -> void:
	combat_component.received_damage.connect(_on_received_damage)
	
	perception.target_acquired.connect(_on_perception_target_acquired)
	perception.target_lost.connect(_on_perception_target_lost)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	move_and_slide()
	_update_animations()

func _update_animations() -> void:
	if animation_locked:
		return
		
	var horizontal_speed := Vector3(velocity.x, 0.0, velocity.z).length()
	if horizontal_speed < 0.2:
		pass
		#_play_safe("slime_anims/Slime_IdleNormal")
	else:
		pass
		#_play_safe("slime_anims/Slime_Walk")

func _play_safe(anim_name: String) -> void:
	if not animator.is_playing() or animator.current_animation != anim_name:
		animator.play(anim_name)

func _on_received_damage(amount: float, hit_info: HitInfo) -> void:
	print("damage received: ", str(amount))

func _on_perception_target_acquired(target: Node3D) -> void:
	print("Target Acquired: ", target)

func _on_perception_target_lost(target: Node3D) -> void:
	print("Target Lost: ", target)
