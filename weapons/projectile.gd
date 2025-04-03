class_name Projectile
extends RangedWeapon

@export var speed = 300

func _ready() -> void:
	super()
	set_as_top_level(true)

func _physics_process(delta: float) -> void:
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta
	pass

func _on_damage_box_body_entered(body: Node2D) -> void:
	super._on_damage_box_body_entered(body)
	queue_free()

func _on_screen_exited() -> void:
	queue_free()
