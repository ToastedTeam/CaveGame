extends CharacterBody2D

class_name Goblin_Enemy

const speed = 30
var is_goblin_chase: bool = false

var dead: bool = false
var taking_damage: bool = false
var base_damage = 3
var is_dealing_damage: bool = false

var dir: Vector2
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area: bool = false

func _physics_process(delta: float) -> void:
	if !is_on_floor():	# Precaution if the charachter is ever not on the ground (should be very rare)
		velocity.y += get_gravity().y
		velocity.x = 0
	
	player = Global.playerBody
	
	move(delta)
	handle_sprite()
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_goblin_chase:
			velocity.x = dir.x * speed
		elif is_goblin_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position)
			if(dir_to_player.x > 0):
				velocity.x = speed
			elif(dir_to_player.x < 0):
				velocity.x = -speed
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var kb_dir = position.direction_to(player.position) * -20
			velocity.x = kb_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0
		
func handle_sprite():
	var sprite = $goblinSprite
	#if !dead and !taking_damage and !is_dealing_damage:
	sprite.play("left")
	if dir.x == -1:
		sprite.play("left")
	elif dir.x == 1:
		sprite.play("right")
	elif dir.x == 0:
		sprite.play("normal")

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = chose([1.5, 2.0, 2.5])
	
	if !is_goblin_chase:
		dir = chose([Vector2.LEFT, Vector2.UP, Vector2.RIGHT])
		velocity.x = 0
	
func chose(array: Array):
	array.shuffle()
	return array.front()
