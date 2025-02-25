class_name Log
extends Object

static var log = ""
static var LogObject: Control

static func info(msg):
	if msg != null:
		LogObject.append_text(str(msg));
		print(str(msg))
	pass
