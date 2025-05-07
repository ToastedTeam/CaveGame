extends RangedWeapon

@onready var sprite: Sprite2D = $BowSprite
@onready var animation: AnimatedSprite2D = $BowAnimation

var arrow_speed_mult = 1
var arrow_down_pull = 20

# Mult by witch player movement gets slowed down
const PLAYER_SLOWDOWN = 2

func _on_attack_key_press() -> void:
	super._on_attack_key_press()
	
	Global.playerBody.move_speed /= PLAYER_SLOWDOWN
	Global.playerBody.IkAnimator.walkDuration *= PLAYER_SLOWDOWN
	$BowAnimation.show()
	$bowstring.show()
	$Arrow.show()
	player.IkAnimator.hand1.node.hide()
	
	
	#sprite.hide()
	#animation.show()

func _on_attack_key_hold() -> void:
	super._on_attack_key_hold()
	
	if key_pressed_duration < 0.5:
		animation.frame = 0
		arrow_speed_mult = 0.35
		arrow_down_pull = 400
		$bowstring.points[0] = Vector2(1.5, -14)
		$bowstring.points[2] = Vector2(1.5, 14)
		
	elif key_pressed_duration < 1:
		animation.frame = 1
		arrow_speed_mult = 0.85
		arrow_down_pull = 200
		$bowstring.points[0] = Vector2(0.5, -14)
		$bowstring.points[2] = Vector2(0.5, 14)
		
	elif key_pressed_duration < 1.5:
		animation.frame = 2
		arrow_speed_mult = 1.25
		arrow_down_pull = 100
		$bowstring.points[0] = Vector2(-0.5, -13)
		$bowstring.points[2] = Vector2(-0.5, 13)
	else:
		animation.frame = 3
		arrow_speed_mult = 1.5
		arrow_down_pull = 50
		$bowstring.points[0] = Vector2(-1.5, -12)
		$bowstring.points[2] = Vector2(-1.5, 12)
		
func animateAttack(animator: IKPlayerAnimator, facing: float) -> void:
	animator.BHTargetPos.global_position = animator.collarOffsetBone.global_position + Vector2(21.5 * facing, 2.5);
	var progress = max(-(key_pressed_duration / 1.5), -1)
	var maxDraw = 7
	animator.FHTargetPos.global_position = $bowstring.global_position + Vector2(maxDraw * progress * facing, 0)
	$bowstring.points[1] = Vector2(1.5, 0) + Vector2(maxDraw * progress, 0)
	$Arrow.position = Vector2(9, 0) + Vector2(maxDraw * progress, 0)
	print(facing)
	pass

func _on_attack_key_release() -> void:
	super._on_attack_key_release()
	
	_projectile_init()
	
	proj_instance.launch_speed *= arrow_speed_mult
	proj_instance.down_pull_factor = arrow_down_pull
	$bowstring.points[1] = Vector2(1.5, 0)
	
	_projectile_start()
	$BowAnimation.hide()
	$bowstring.hide()
	$Arrow.hide()
	player.IkAnimator.hand1.node.show()
	Global.playerBody.move_speed *= PLAYER_SLOWDOWN
	Global.playerBody.IkAnimator.walkDuration /= PLAYER_SLOWDOWN
	
	#animation.hide()
	#sprite.show()
