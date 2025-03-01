extends CharacterBody2D

# Defining Player constants
const SPEED = 120.0
const JUMP_VELOCITY = -300.0
const MAX_HP = 20
const MAX_MANA = 100
const BASE_DAMAGE = 5

# Various Properties
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var health_bar: TextureProgressBar
@export var mana_bar: TextureProgressBar
@export var attack_cooldown: float

# Variables
var current_hp: int = MAX_HP:
	get:
		return current_hp
	set(value):
		# These seem to not work as I want
		# If current_hp <= 0 then it always sets it to 0 (ig cuz this is before _ready() script)
		# Otherwise it allows HP to go into the negatives. Commented this out for now, maybe
		# this can be fixed or implemented somehow different.
		# Same thing with current_mana variable
		# Currently moved to _physics_process() function
		
		# Fixed, you were checking the current hp, which is not the same as value, aka the new
		# value, which is called "value". That allowed it to reach negative values. However, 
		# below the if statement there was a `current_hp = value` statement which simply negates
		# the if statement
		# - Toaster
		if value < 0:
			print("The player has died")
			current_hp = 0
		else:
			current_hp = value
		
		health_bar.value = current_hp

var current_mana: int = MAX_MANA:
	get:
		return current_mana
	set(value):
		if value < 0:
			print("The player has run out of Mana")
			current_mana = 0
		else:
			current_mana = value
		
		mana_bar.value = current_mana

var damage: int = BASE_DAMAGE:
	get:
		return damage
	set(value):
		damage = value

var canAttack = true;

# Setting current 
func _ready() -> void:
	#current_hp = MAX_HP
	#current_mana = MAX_MANA
	#damage = BASE_DAMAGE
	
	health_bar.max_value = MAX_HP
	mana_bar.max_value = MAX_MANA
	health_bar.min_value = 0	# This is also set to 0 in the ProgressBar Node
	mana_bar.min_value = 0		# This is also set to 0 in the ProgressBar Node
	
	health_bar.value = current_hp
	mana_bar.value = current_mana
	
	print("player hp: ", current_hp, " player mana: ", current_mana, " player damage: ", damage)

func _physics_process(delta: float) -> void:
	# DEBUG STUFF SO ITS EASY TO ACCESS
	if Input.is_action_just_pressed("DEBUG_takeDamage"):
		current_hp -= 5
		current_mana -= 5
		print("Current hp: ", current_hp, "; Current mana: ", current_mana)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
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
		$FlipHandler.scale.x = -1
	elif direction > 0:
		player_sprite.flip_h = false
		$FlipHandler.scale.x = 1
		
	if Input.is_action_just_pressed("player_attack") and canAttack:
		$FlipHandler/AnimationPlayer.play("player_attack")
		canAttack = false
		$AttackCooldown.start()


func _on_entity_hit(body: Node2D) -> void:
	var body_parent = body.get_parent()
	if body_parent is Entity:
		Log.info("Hit entity, perform damage, don't forget invincibility frames, remove this later")
		body_parent.Damage(damage, self)
	pass # Replace with function body.

func _on_attack_cooldown_end() -> void:
	canAttack = true
