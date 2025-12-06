class_name SoundEffect extends Resource
## Sound effect resource, used to configure unique sound effects for use with the AudioManager.  Passed to [method Audio.create_2d_audio_at_location and [method AudioManager.create_audio] to play sound effects.

enum SOUND_EFFECT_TYPE {
	CHEST_HIT,
	CHEST_DESTROYED,
	COIN_COLLECTED
}

@export_range(0, 10) var limit: int = 5 ## Maximum number of this SoundEffect to play simultaneously before culled.
@export var type: SOUND_EFFECT_TYPE ## The unique sound effect in the [enum SOUND_EFFECT_TYPE] to associate with this effect.  Each sound resource should have it's own unique [enum SOUND_EFFECT_TYPE] setting.
@export var sound_effect: AudioStream ## The [AudioStream] audio resource to play.
@export_range(-40, 20) var volume: float = 0 ## The volume of the [member sound_effect].
@export_range(0.0, 4.0, 0.01) var pitch_scale: float = 1.0 ## The pitch scale of the [member sound_effect].
@export_range(0.0, 1.0, 0.01) var pitch_randomness: float = 0.0 ## The pitch randomness setting of the [member sound_effect].
@export var audio_bus: StringName = &"SFX" ## The audio bus that the [member sound_effect] will play on.

var audio_count: int = 0 ## the instances of this [AudioStream] currently playing.

## Takes [param amount] to change the [member audio_count].
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)
	
## Checks whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return audio_count < limit

## Connect to the [member sound_effect]'s finished signal to decrement the [member audio_count].
func on_audio_finished() -> void:
	change_audio_count(-1)
