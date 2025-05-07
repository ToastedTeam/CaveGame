extends Control


func _on_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MenuScenes/MainMenu/main_menu.tscn")
