extends Popup

@export var inventory: Inventory
@onready var label = $NinePatchRect/MarginContainer/CenterContainer/ItemName

var origin = ""
var slot = ""
var valid = false

func set_text(text: String) -> void:
	label.text = text
