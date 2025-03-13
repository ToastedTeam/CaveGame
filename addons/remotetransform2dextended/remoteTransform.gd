@tool
class_name RemoteTransform2DExtended
extends Node2D

@export var node: Node2D
@export var Position: bool
@export var Rotation: bool
@export var Scale: bool
@export var Smoothing: float = 1;

func _process(delta: float) -> void:
	if node:
		if Position:
			node.global_position = node.global_position.lerp(global_position, Smoothing);
		if Rotation:
			node.global_rotation = lerp(node.global_rotation, global_rotation, Smoothing);
		if Scale:
			node.scale = node.scale.lerp(scale, Smoothing)
	pass
