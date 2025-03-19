extends Area2D

var player: PlayerCharacter
var anim: AnimationPlayer
var playerPresent: bool = false;
var events = []
var lastPressed = false;
signal onPlayerInteract(player: PlayerCharacter)

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	anim = player.get_node("InteractionHint/anim")
	events = InputMap.action_get_events("player_interact").map(func(x: InputEventKey): return x.physical_keycode)
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode in events:
		if event.is_pressed() and !lastPressed:
			lastPressed = true
			if playerPresent:
				Log.info("Player interacted")
				onPlayerInteract.emit(player)
		elif !event.is_pressed() and lastPressed:
			lastPressed = false

func _on_interaction_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if anim.assigned_animation == "popup":
		return
	else:
		anim.play("popup")
		playerPresent = true
	pass # Replace with function body.

func _on_interaction_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if anim.assigned_animation == "popdown":
		return
	else:
		anim.play("popdown")
		playerPresent = false
	pass # Replace with function body.
