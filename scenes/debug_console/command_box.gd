extends TextEdit

var DbgConsole: DebugConsole;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DbgConsole = get_parent()
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") and get_caret_line() == 0:
		DbgConsole.historyPos += 1
		text = DbgConsole.get_curr_history()
	if event.is_action_pressed("ui_down") and get_caret_line() == get_line_count()-1:
		DbgConsole.historyPos -= 1
		text = DbgConsole.get_curr_history()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
