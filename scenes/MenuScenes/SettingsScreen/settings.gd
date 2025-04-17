extends Control

const resolutions = [ Vector2i(1920,1080), Vector2i(1600,900), Vector2i(1280,720) ]

@onready var input_button_scene = preload("uid://bthc5hdvcfj20")
@onready var action_list = %ActionList

var is_remaping = false
var action_to_remap = null
var remapping_button = null
var shouldBlur = true

var input_actions = {
	"player_jump" : "Jump",
	"player_move_left" : "Move left",
	"player_move_right" : "Move right",
	"player_attack_melee" : "Melee Attack",
	"player_attack_ranged" : "Ranged Attack",
	"player_interact" : "Interact",
	"player_dash" : "Dash",
	"player_inventory_toggle" : "Inventory",
}

func resume():
	$AnimationPlayer.play_backwards("Blur")

func pause():
	if shouldBlur:
		$AnimationPlayer.play("Blur")
	else:
		$AnimationPlayer.play("NoBlur")
	
func _ready():
	%Volume.value = AudioServer.get_bus_volume_linear(0)*100
	%"Mute sound".button_pressed = AudioServer.is_bus_mute(0)
	
	_create_action_list()
	
	for resolution in resolutions:
		%Resolutions.add_item(str(resolution.x)+"x"+str(resolution.y))
	var size = DisplayServer.window_get_size(0)
	var idx = resolutions.find(size)
	if idx > -1:
		%Resolutions.selected = idx;

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
func _create_action_list():
	#InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button,action))
		
		
func _on_input_button_pressed(button, action):
	if !is_remaping:
		is_remaping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."

func _input(event):
	if is_remaping:
		if(
			event is InputEventKey || 
			(event is InputEventMouseButton && event.pressed)
		):
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remaping = false
			action_to_remap = null
			remapping_button = null
			accept_event()
func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")			


func _on_reset_pressed() -> void:
	InputMap.load_from_project_settings()
	_create_action_list()
