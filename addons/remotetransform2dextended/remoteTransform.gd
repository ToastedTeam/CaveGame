@tool
extends Node2D

@export var node: Node2D
@export var Position: bool
@export var Rotation: bool
@export var Scale: bool

func _process(delta: float) -> void:
	if node:
		if Position:
			node.global_position = global_position;
		if Rotation:
			node.global_rotation = global_rotation;
		if Scale:
			node.global_scale = global_scale
	pass
