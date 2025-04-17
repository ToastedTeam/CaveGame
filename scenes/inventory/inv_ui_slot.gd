extends Panel

@onready var item_display: Sprite2D = $CenterContainer/Panel/ItemDisplay
@onready var amount_text: Label = $CenterContainer/Panel/Label

@onready var tool_tip_scene = preload("res://scenes/inventory/tool_tip.tscn")
@onready var center_container = $CenterContainer
var tool_tip_inst: Popup
var current_slot: InvSlot

func _ready():
	# Pre-instantiate the tooltip so we can reuse it
	tool_tip_inst = tool_tip_scene.instantiate()
	get_tree().root.add_child(tool_tip_inst) # add to scene root
	tool_tip_inst.hide()

func update(slot: InvSlot):
	current_slot = slot
	
	if !slot.item:
		item_display.visible = false
		amount_text.visible = false
	else:
		item_display.visible = true
		item_display.texture = slot.item.texture
		if slot.amount > 1:
			amount_text.visible = true
		amount_text.text = str(slot.amount)


func _on_center_container_mouse_entered() -> void:
	if current_slot and current_slot.item:
		tool_tip_inst.set_text(current_slot.item.name)
		var global_position = center_container.get_screen_position()
		tool_tip_inst.position = global_position + Vector2(0, -50)
		tool_tip_inst.popup()


func _on_center_container_mouse_exited() -> void:
	tool_tip_inst.hide()
