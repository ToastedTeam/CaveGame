class_name Log
extends Object

static var log = ""
static var LogObject: RichTextLabel

static func info(msg):
	LogObject.append_text("\n" + str(msg));
	print(str(msg))
	pass
