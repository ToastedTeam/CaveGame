extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Log.LogObject = $Log
	pass # Replace with function body.

func eval_code(code):
	var script = GDScript.new()
	script.source_code += "extends Node\n"
	script.source_code += "static func _eval():\n\tpass"
	for line in code.split("\n"):
		script.source_code += "\n\t" + line
	# Reload the script since setting the source_code doesn't recompile it, according to the docs
	script.reload()
	return script._eval()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_console") and not visible:
		print("opening console")
		show()
		$Command.grab_focus()
		return
	elif event.is_action_pressed("ui_cancel") and visible:
		print("closing console")
		hide()
		return
	elif event.is_action_pressed("ui_accept") and visible:
		print("running script")
		eval_code($Command.text)
		hide()
		return
	if visible:
		get_viewport().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		$Log.offset_bottom = $Command.get_line_height()
		$Log.size.y = $Log.get_content_height()
	pass
