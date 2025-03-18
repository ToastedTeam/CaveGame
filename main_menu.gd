extends Control


func _on_p_lay_pressed() -> void:
	get_tree().paused=false;
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit();
