class_name DebugConsole
extends Control

@export var LogOutput: RichTextLabel

var history = [ "" ]
var historyPos = 0:
	get:
		return historyPos;
	set(value):
		if value > history.size()-1:
			historyPos = history.size()-1
		elif value < -1:
			historyPos = -1
		else:
			historyPos = value

func add_to_history(text: String) -> void:
	history.push_front(text)
	if history.size() > 20:
		history.pop_back()
	pass

func append_text(text: String) -> void:
	LogOutput.append_text(text + "\n");
	$Background.custom_minimum_size.y = LogOutput.get_content_height()
	pass

func get_curr_history() -> String:
	if historyPos < 0:
		return ""
	else:
		return history[historyPos]
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Log.LogObject = self
	pass # Replace with function body.

func eval_code(code):
	var script = GDScript.new()
	script.source_code += "extends Node\n"
	script.source_code += "static func _eval(root: Node, player: Node2D):\n\tpass"
	for line in code.split("\n"):
		script.source_code += "\n\t" + line
	# Reload the script since setting the source_code doesn't recompile it, according to the docs
	script.reload()
	var var_root = get_tree().root
	var var_player = var_root.find_child("Player", true, false)
	if script.has_method("_eval"):
		return script._eval(var_root, var_player)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_console") and not visible:
		get_tree().paused = true
		show()
		$Command.grab_focus()
		return
	elif event.is_action_pressed("ui_cancel") and visible:
		get_tree().paused = false
		hide()
		get_viewport().set_input_as_handled()
		return
	elif event.is_action_pressed("ui_accept") and visible:
		Log.info(eval_code($Command.text))
		add_to_history($Command.text)
		historyPos = -1
		$Command.text = ""
		get_tree().paused = false
		hide()
		return
	if visible:
		get_viewport().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if visible:
		#$Background/Log.offset_bottom = $Command.get_line_height()
		#$Background/Log.size.y = $Background/Log.get_content_height()
	pass
