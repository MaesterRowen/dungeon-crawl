class_name InventorySlot extends RefCounted

@export var item_key : StringName = "empty"
@export var quantity : int = 0

static func Create(key: StringName = "empty", qty: int = 0) -> InventorySlot:
	var instance = InventorySlot.new()
	instance.item_key = key
	instance.quantity = qty
	return instance
