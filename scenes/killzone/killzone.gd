extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("You died!")
		Engine.time_scale = 0.5
		$Timer.start()
	else:
		body.queue_free()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
