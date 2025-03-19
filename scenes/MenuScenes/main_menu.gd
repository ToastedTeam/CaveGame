extends Control


func _on_play_pressed() -> void:
	get_tree().paused=false;
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

@onready var settings_scene = preload("res://scenes/settings.tscn")  # Preload settings scene
func _on_options_pressed() -> void:
	if not get_node_or_null("settings"):  # Prevent multiple instances
		var settings_instance = settings_scene.instantiate()
		add_child(settings_instance)  # Adds it as a child



func _on_exit_pressed() -> void:
	get_tree().quit();
