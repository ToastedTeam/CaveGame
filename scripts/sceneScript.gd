extends Node2D
@export var viewport: SubViewportContainer;
@export var camera: GameplayCamera;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(camera)
	#camera.viewport_shader = viewport.material;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
