extends Control

@onready var inventory: Inventory = preload("res://scenes/inventory/player_inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

func _ready():
	inventory.update.connect(update_slots)
	update_slots()
	close()
	
func update_slots():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_inventory_toggle"):
		Log.info("Inventory toggled")
		if is_open:
			close()
		else:
			open()

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
