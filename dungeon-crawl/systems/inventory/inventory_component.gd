class_name InventoryComponent extends Node

signal item_added(item: ItemData, new_count: int)
signal item_removed(item_key: StringName, new_count: int)

var slot_count : int = 20
var inventory_slots: Array[InventorySlot] = []

func _ready() -> void:
	inventory_slots.resize(slot_count)
	for i in slot_count:
		inventory_slots[i] = InventorySlot.Create()

func has_item(item_key: StringName) -> bool:
	for slot in inventory_slots:
		if slot.item_key == item_key:
			return true
	return false

func add_item(item: ItemData, quantity: int) -> bool:
	if not item or item.type == ItemData.Type.INVALID or quantity <= 0: 
		return false
	
	# if item is stackable, search for a slot that can be used
	if item.is_stackable:
		for slot in inventory_slots:
			if slot.item_key != item.key:
				continue
			# found a matching slot
			if slot.quantity <= item.max_stack_size:
				slot.quantity = mini(item.max_stack_size, slot.quantity + quantity)
				item_added.emit(item, slot.quantity)
				return true
			
			return false
	# if item is not stackable, or an existing stack could not be found
	for slot in inventory_slots:
		if slot.item_key != "empty":
			continue
		
		slot.item_key = item.key
		slot.quantity = mini(item.max_stack_size, quantity)
		
		item_added.emit(item, slot.quantity)
		return true
	
	# no available slots
	return false

func remove_item(item_key: StringName, quantity: int) -> bool:
	if item_key == "empty" or quantity <= 0:
		return false
	
	for slot in inventory_slots:
		if slot.item_key != item_key:
			continue
		if slot.quantity < quantity:
			return false
		
		slot.quantity -= quantity
		if slot.quantity == 0:
			slot.item_key = "empty"
			slot.quantity = 0
		
		item_removed.emit(item_key, slot.quantity)
		return true
	
	return false
