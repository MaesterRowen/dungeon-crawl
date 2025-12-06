class_name ItemData extends Resource

enum Type {
	INVALID,
	COLLECTIBLE,
	CONSUMABLE,
	KEYITEM
}

@export_group("Item")
@export var key: StringName = ""
@export var type : Type = Type.INVALID
@export var display_name: String = ""
@export var description: String = ""
@export var icon : Texture2D = null
@export var max_stack_size : int = 99
@export var is_stackable : bool = true
