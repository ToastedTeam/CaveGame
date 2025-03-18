extends Control
func resume():
	get_tree().paused=false;
	$AnimationPlayer.play_backwards("Blur")

func pause():
	get_tree().paused=true;
	$AnimationPlayer.play("Blur")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and !get_tree().paused and !visible:
		pause()
	elif event.is_action_pressed("escape") and get_tree().paused and visible:
		resume()

func _on_resume_pressed() -> void:
	resume()


func _on_main_menu_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.
