class_name Projectile
extends Weapon

@export var launch_speed = 300
@export var down_pull_factor = 10

var initial_position = Vector2.ZERO
var initial_angle = 0

var t = 0

func _ready() -> void:
	super()
	initial_position = global_position
	set_as_top_level(true)

func _physics_process(delta: float) -> void:
	t += delta
	
	var dx = launch_speed * cos(initial_angle) * delta
	var dy = (launch_speed * sin(initial_angle) + (down_pull_factor * t)) * delta
	var d = Vector2(dx, dy)
	
	position += d
	rotation = d.angle()

func _on_damage_box_body_entered(body: Node2D) -> void:
	super._on_damage_box_body_entered(body)
	queue_free()

func _on_screen_exited() -> void:
	queue_free()
