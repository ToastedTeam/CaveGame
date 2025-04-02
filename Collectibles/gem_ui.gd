extends Control

@onready var label = $TextureRect/Label

func _ready():
	EventController.connect("gem_collected",on_event_gem_collected)

func on_event_gem_collected(value: int) -> void:
	label.text = str(value)
