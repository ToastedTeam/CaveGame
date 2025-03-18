class_name Weapon
extends Node2D

@export var AnimName: String = "Attack"

signal on_hit(hitBody: Node2D)

func _ready() -> void:
	var player = get_tree().root.find_child("Player", true, false) as PlayerCharacter
	on_hit.connect(player._on_entity_hit)

func _process(delta: float) -> void:
	pass
	
func _attack() -> void:
	pass

func _on_damage_box_body_entered(body: Node2D) -> void:
	on_hit.emit(body);
