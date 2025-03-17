extends Control
func resume():
	get_tree().paused=false;
	$AnimationPlayer.play_backwards("Blur")

func pause():
	get_tree().paused=true;
	$AnimationPlayer.play("Blur")

func testEsc():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()


func _on_main_menu_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _process(delta):
	testEsc()
