class_name Log
extends Object

static var log = ""
static var LogObject: RichTextLabel

static func info(msg: String):
	LogObject.append_text("\n" + msg);
	pass
