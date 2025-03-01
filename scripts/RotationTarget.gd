@tool
extends PinJoint2D

#@export var targetAngle: float = 0;
@export var currentAngleDifference: float = 0;
@export var powerFactor: float = 1;
@export var enabled: bool = false;
@export var debugPrint: bool = false;

@export_category("PD")
@export var Proportional: float = 0;
@export var Integral: float = 0;
@export var Derivative: float = 0;
var integralSum: float = 0;

var a: PhysicsBody2D
var b: PhysicsBody2D
var lastAngleDifference: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	motor_enabled = enabled;
	a = get_node(node_a)
	b = get_node(node_b)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		a = get_node(node_a)
		b = get_node(node_b)
		
	pass
	
func _physics_process(delta: float) -> void:
	# Me when rotation target needs PID controls, no clue if im using the right ones tho
	currentAngleDifference = a.global_rotation_degrees - b.global_rotation_degrees
	integralSum += currentAngleDifference;
	var rateOfChange = ((currentAngleDifference - lastAngleDifference)) * Derivative
	var P = currentAngleDifference * Proportional;
	var I = integralSum * Integral;
	var D = rateOfChange * Derivative;
	var motorPower = P + I - D
	motor_target_velocity = motorPower # * (-1 if currentAngleDifference < 0 else 1)
	if debugPrint:
		Log.info("P:" + str(P) + " I:" + str(I) + " D:" + str(D) + " Total:" + str(motor_target_velocity))
		
	lastAngleDifference = currentAngleDifference
	pass
