class_name Weapon
extends Node2D

@export var AnimName: String = "Attack"

@onready var player = get_tree().root.find_child("Player", true, false) as PlayerCharacter

var key_pressed_duration: float = -1

signal on_hit(hitBody: Node2D)

func _ready() -> void:
	on_hit.connect(player._on_entity_hit)

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if (key_pressed_duration >= 0):
		if (Input.is_action_just_released("player_attack_melee")):
			_on_attack_key_release()
		else:
			key_pressed_duration += delta
			_on_attack_key_hold()

func _on_attack_key_press() -> void:
	key_pressed_duration = 0
	pass

func _on_attack_key_hold() -> void:
	pass

func _on_attack_key_release() -> void:
	key_pressed_duration = -1
	pass

func _on_damage_box_body_entered(body: Node2D) -> void:
	on_hit.emit(body);
