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
	get_tree().change_scene_to_file("res://scenes/MenuScenes/main_menu.tscn")

@onready var settings_scene = preload("res://scenes/settings.tscn")  # Preload settings scene
func _on_settings_pressed() -> void:
	if not get_node_or_null("settings"):  # Prevent multiple instances
		var settings_instance = settings_scene.instantiate()
		add_child(settings_instance)  # Adds it as a child
