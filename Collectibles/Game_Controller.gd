extends Node

var total_gems: int = 0

func gem_collected(value: int):
	total_gems += value
	EventController.emit_signal("gem_collected", total_gems)
