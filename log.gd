class_name Log
extends Object

static var log = ""
static var LogObject: Control:
	get:
		return LogObject;
	set(value):
		for val in _textBuffer:
			value.append_text(val)
			print(val)
		LogObject = value;

static var _textBuffer: Array[String] = []

static func info(msg):
	if !LogObject:
		_textBuffer.push_back(str(msg))
	else:
		if msg != null:
			LogObject.append_text(str(msg));
			print(str(msg))
		pass
