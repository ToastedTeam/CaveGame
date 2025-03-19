@tool
extends EditorPlugin

var enabled = false
var edited_animation_player: AnimationPlayer
var helper = preload("res://addons/godot-animation-reverser/helper.gd")

func _handles(object: Object) -> bool:
	var does_handle = object is AnimationPlayer
	print(does_handle)

	if does_handle:
		if not enabled:
			enabled = true
			add_tool_menu_item("Reverse animation", activate)

	elif enabled:
		enabled = false
		remove_tool_menu_item("Reverse animation")

	return does_handle

func _edit(object: Object) -> void:
	edited_animation_player = object

func activate(ud = null):
	helper.reverse_current(edited_animation_player)

func _exit_tree():
	remove_tool_menu_item("Reverse animation")
