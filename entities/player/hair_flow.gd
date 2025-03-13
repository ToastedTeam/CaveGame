#@tool
extends Node2D

var prop: PackedVector2Array;
var nodes: Array[Node2D];
var lastS: PackedVector2Array;
var lastE: PackedVector2Array;
var lastGlobalPos: Vector2;
var acc: PackedVector2Array;
var mass: PackedFloat32Array;
var shouldSave: bool = false;
@export var pointCount: int;
@export var gravity: Vector2;
@export var restLength: float;
@export var deltaMult: float;
@export var iterations: int;

var frameCount = 0;
var frameLimit = 5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var initial = PackedVector2Array();
	acc = PackedVector2Array();
	for i in pointCount:
		var nodeLink = Node2D.new();
		add_child(nodeLink);
		nodes.append(nodeLink);
		acc.append(Vector2(0, 0));
		initial.append(Vector2.ZERO);
		
	($Render.material as ShaderMaterial).set_shader_parameter("numPoints", pointCount);
	prop = initial.duplicate();
	lastS = initial.duplicate();
	lastE = initial.duplicate();

	mass.append(0);
	for i in range(1, pointCount):
		mass.append(pointCount+1-i);
	pass # Replace with function body.

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouse:
		#prop[0] = (event as InputEventMouse).position
		#setPositions()
		#print(nodes[0].position)
		#pass
	#pass
	
func _process(delta: float) -> void:
	prop[0] = global_position;
	setPositions()
	pass

func getPositions() -> void:
	for i in pointCount:
		prop[i] = (nodes[i] as Node2D).position;

func setPositions() -> void:
	#$Render.position = prop[0];
	for i in range(0, pointCount):
		(nodes[i] as Node2D).position = prop[i];

func verlet(points: PackedVector2Array, idx: int, timeStep: float) -> void:
	var x = points[idx];
	var oldx = lastS[idx];
	
	var a_x = acc[idx];
	var diff = Vector2.ZERO #x - oldx;
	var xDiff = -abs(global_position.x - lastGlobalPos.x) #-abs(points[0].x - points[pointCount-1].x)/10
	var yDiff = global_position.y - lastGlobalPos.y
	var final = Vector2(yDiff, xDiff)
	x += diff + a_x*timeStep*timeStep + (Vector2(2, 5) * final/2 if hairPoint == idx else Vector2.ZERO);
	points[idx] = x;
	#print(anotherdiff)
	#print(nodes[pointCount-1].global_position.y - global_position.y)
	pass

func accumulateForces() -> void:
	for i in pointCount:
		acc[i] = gravity;

func satisfyConstraints(points: PackedVector2Array) -> void:
	for j in iterations:
		for i in range(1, pointCount):
			var x2 = points[i];
			var x1 = points[i-1];
			var delta = x2 - x1;
			var deltaLength = delta.length()
			
			var invmass1 = 1/mass[i-1] if mass[i-1] != 0 else 0;
			var invmass2 =  1/mass[i] if mass[i] != 0 else 0;
			
			var diff = (deltaLength - restLength)/(deltaLength*(invmass1+invmass2))
			if(diff < 0):
				diff = 0;
				
			x1 += invmass1*delta*diff;
			x2 -= invmass2*delta*diff;
				
			#print(deltaLength)
			points[i] = x2;
			points[i-1] = x1;
			pass
	pass

var dir = 0.001;

func copyLast() -> void:
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	frameCount += 1;
	#print(hairPoint)
	if shouldSave:
		lastS = prop.duplicate();
	shouldSave = !shouldSave;
	#var prop: PackedVector2Array =  (self.material as ShaderMaterial).get_shader_parameter("test")
	getPositions()
	accumulateForces()
	for i in range(1, prop.size()):
		verlet(prop, i, delta*deltaMult);
		pass
	satisfyConstraints(prop)
	setPositions();
	#prop[0].x += dir;
	#if(prop[0].x > 1):
		#dir = -dir;
	#elif (prop[0].x < 0):
		#dir = -dir
	#print(prop)
	($Render.material as ShaderMaterial).set_shader_parameter("points", prop)
	#lastE = prop.duplicate();
	#queue_redraw()
	lastGlobalPos = global_position;
	#lastGlobalPos = nodes[pointCount-1].global_position
	if frameCount > frameLimit:
		#yImpact = clamp(randf_range(yImpact-maxDiff,yImpact+maxDiff), min, max)
		#yImpact = randf_range(min, max)
		#print(yImpact)
		hairPoint = randi_range(1, pointCount)
		frameCount = 0
	pass

var hairPoint = 0;
var max = 10
var min = -10
var maxDiff = 10
var yImpact = 5

func _draw():
	pass
	#draw_line(Vector2(0,0), Vector2(100,0), Color.RED, 5);
	#draw_string(ThemeDB.fallback_font, Vector2.ZERO, "AAAAA")
	#for i in range(1, pointCount):
		#draw_line(prop[i], prop[i-1], Color.RED, 5);
