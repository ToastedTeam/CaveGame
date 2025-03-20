extends Control

func resume():
	$AnimationPlayer.play_backwards("Blur")

func pause():
	$AnimationPlayer.play("Blur")
	
func _ready():
	$PanelContainer/VBoxContainer/Volume.value = AudioServer.get_bus_volume_linear(0)*100
	$"PanelContainer/VBoxContainer/Mute sound".button_pressed = AudioServer.is_bus_mute(0)
	pause()

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0,value/100)

func _on_mute_sound_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	#AudioServer.set_bus_volume_db(0,toggled_on)
	
func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2(1600,900))
		2:
			DisplayServer.window_set_size(Vector2(1280,720))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and get_tree().paused and visible:
		resume()
		
func _on_exit_settings_pressed() -> void:
		resume()
		#queue_free()  # Removes this settings menu from the scene
