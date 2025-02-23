extends CharacterBody2D

# Defining Player constants
const SPEED = 120.0
const JUMP_VELOCITY = -300.0
const MAX_HP = 20
const MAX_MANA = 100
const BASE_DAMAGE = 5

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Defining these as variables because they can change overtime
var current_hp
var current_mana
var damage

# Setting current 
func _ready() -> void:
	current_hp = MAX_HP
	current_mana = MAX_MANA
	damage = BASE_DAMAGE
	print("player hp: ", current_hp, " player mana: ", current_mana, " player damage: ", damage)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("DEBUG_takeDamage"):
		changeHealth(-5)
		print("Current hp: ", current_hp)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("player_move_left", "player_move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
		
#	Player animations
	if is_on_floor():
		if direction:
			player_sprite.play("run")
		else:
			player_sprite.play("idle")
	else:
		player_sprite.play("jump")
	
	if direction < 0:
		player_sprite.flip_h = true
	elif direction > 0:
		player_sprite.flip_h = false


func changeHealth(amount):
	current_hp += amount
	if current_hp <= 0:
		current_hp = 0
		print("The player has Died")
	
func changeMana(amount):
	current_mana += amount
