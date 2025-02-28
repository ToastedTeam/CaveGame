class_name Entity
# The generic entity class, has health and can receive damage
extends Node2D

@export var maxHealth: float = 1
# Replace with a property later, when implementing target dummies
var health: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
