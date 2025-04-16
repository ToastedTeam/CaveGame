extends RangedWeapon

@onready var sprite: Sprite2D = $BowSprite
@onready var animation: AnimatedSprite2D = $BowAnimation

var arrow_speed_mult = 1
var arrow_down_pull = 20

func _on_attack_key_press() -> void:
	super._on_attack_key_press()
	
	sprite.hide()
	animation.show()

func _on_attack_key_hold() -> void:
	super._on_attack_key_hold()
	
	if key_pressed_duration < 0.5:
		animation.frame = 0
		arrow_speed_mult = 0.15
		arrow_down_pull = 500
		
	elif key_pressed_duration < 1:
		animation.frame = 1
		arrow_speed_mult = 1
		arrow_down_pull = 50
		
	elif key_pressed_duration < 1.5:
		animation.frame = 2
		arrow_speed_mult = 1.2
		arrow_down_pull = 50
		
	else:
		animation.frame = 3
		arrow_speed_mult = 1.4
		arrow_down_pull = 50

func _on_attack_key_release() -> void:
	super._on_attack_key_release()
	
	_projectile_init()
	
	proj_instance.launch_speed *= arrow_speed_mult
	proj_instance.down_pull_factor = arrow_down_pull
	
	_projectile_start()
	
	animation.hide()
	sprite.show()
