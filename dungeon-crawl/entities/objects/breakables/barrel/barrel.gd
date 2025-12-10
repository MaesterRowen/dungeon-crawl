extends Node3D

@onready var hurtbox: HurtBox3D = $HurtBox3D

var hit_dir : Vector3 = Vector3.ZERO
var strength : float = 1.0
var knockback_duration : float = 0.25
var knockback_velocity : Vector3 = Vector3.ZERO
var knockback_timer : float = 0.0

func _ready() -> void:
	hurtbox.hurtbox_hit.connect(_on_hurtbox_hit)

func apply_knockback(direction :Vector3, strength: float) -> void:
	direction.y = 0.0
	knockback_velocity = direction.normalized() * strength
	knockback_timer = knockback_duration

func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		knockback_timer -= delta
		knockback_velocity.y = 0.0
		global_position = global_position + knockback_velocity * delta

func _on_hurtbox_hit(info: HitInfo) -> void:
	print("hit barrel")
	AudioManager.create_sound(SoundEffect.SOUND_EFFECT_TYPE.CHEST_HIT)
	hit_dir = info.hit_direction
	shake_barrel()

func shake_barrel():
	var tween := create_tween()

	var original_pos := position
	var original_rot := rotation

	var offset := Vector3(0.05, 0, 0.05)
	var rot_offset := Vector3(0.05, 0.05, 0)

	tween.tween_property(self, "position", original_pos + offset, 0.05)
	tween.tween_property(self, "rotation", original_rot + rot_offset, 0.05)

	tween.tween_property(self, "position", original_pos - offset, 0.05)
	tween.tween_property(self, "rotation", original_rot - rot_offset, 0.05)

	tween.tween_property(self, "position", original_pos, 0.05)
	tween.tween_property(self, "rotation", original_rot, 0.05)
