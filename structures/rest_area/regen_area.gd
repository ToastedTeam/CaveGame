extends Area2D

var player: PlayerCharacter
var isPlayerIn: bool = false
@export var hpRegenFac: float = 0
@export var manaRegenFac: float = 0
func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	pass

func _physics_process(delta: float) -> void:
	if isPlayerIn:
		player.current_hp += hpRegenFac * delta
		player.current_mana += manaRegenFac * delta
	pass

func _player_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		isPlayerIn = true
	pass # Replace with function body.


func _player_exited(body: Node2D) -> void:
	if "player" in body.get_groups():
		isPlayerIn = false
	pass # Replace with function body.
