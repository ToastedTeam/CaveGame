@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("RemoteTransform2DExtended", "Node2D", preload("remoteTransform.gd"), preload("res://icon.svg"))

	pass


func _exit_tree() -> void:
	remove_custom_type("RemoteTransform2DExtended")
	pass
