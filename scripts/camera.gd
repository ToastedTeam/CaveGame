class_name GameplayCamera
extends Camera2D

@export var followTarget: Node2D;

var viewport_shader: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if position.distance_to(followTarget.position) > 0.5:
		#position = position.lerp(followTarget.position, 10 * delta)
	#else:
		#position = followTarget.position
	#print(7 * delta)
	
	position = position.lerp(followTarget.position, 7 * delta)
	var sub_pixel : Vector2 = Vector2(
		global_position.round().x - global_position.x,
		global_position.round().y - global_position.y
	)
	
	if sub_pixel.length() < 0.1:
		sub_pixel = Vector2.ZERO
		
		
	if viewport_shader:
		viewport_shader.set_shader_parameter("cam_offset", sub_pixel)
		viewport_shader.set_shader_parameter("cam_position", global_position)
		
		pass
	#pass
	
	
	#print(global_position)
