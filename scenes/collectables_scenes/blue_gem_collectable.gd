extends StaticBody2D

@export var item: InvItem 

func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# If the body that entered is the player, we can safely assume he is the player because he was the player
		var player: PlayerCharacter = body
		player.collect(item)
		
		self.queue_free()
	pass # Replace with function body.
