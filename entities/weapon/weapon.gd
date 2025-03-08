class_name Weapon
extends Node2D

@export var AnimName: String = "Attack"

signal on_hit(hitBody: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_damage_box_body_entered(body: Node2D) -> void:
	on_hit.emit(body);
	pass # Replace with function body.
