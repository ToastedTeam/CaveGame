extends GutTest

# Load the SettingsScreen scene
@onready var SettingsScreen = preload("res://scenes/MenuScenes/SettingsScreen/settings.tscn")  # change path!

func test_volume_changes_when_slider_moves():
	var settings = SettingsScreen.instantiate()
	add_child(settings)
	
	var master_bus_index = AudioServer.get_bus_index("Master")
	var original_volume_db = AudioServer.get_bus_volume_db(master_bus_index)
	
	# Simulate moving the slider to 75%
	settings._on_volume_value_changed(75)
	
	var new_volume_db = AudioServer.get_bus_volume_db(master_bus_index)
	print("orgn" + str(original_volume_db))
	print("news" + str(new_volume_db))
	# Assert that the volume actually changed
	assert_ne(original_volume_db, new_volume_db, "Volume did not change after moving the slider")
	
	settings.queue_free()



func test_mute_button_toggles_mute():
	var settings = SettingsScreen.instantiate()
	add_child(settings)
	
	var mute_button = settings.get_node("PanelContainer/VBoxContainer/Mute sound")
	mute_button.button_pressed = true
	settings._on_mute_sound_toggled(true)
	
	assert_true(AudioServer.is_bus_mute(0), "Mute was not enabled after pressing mute button")
	
	settings.queue_free()


func test_resolution_changes():
	var settings = SettingsScreen.instantiate()
	add_child(settings)
	
	settings._on_resolutions_item_selected(2)  # Select 1280x720
	var window_size = DisplayServer.window_get_size()
	
	assert_eq(window_size, Vector2i(1280, 720), "Window size did not change to 1280x720 as expected")
	
	settings.queue_free()
