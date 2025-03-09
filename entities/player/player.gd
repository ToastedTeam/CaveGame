extends CharacterBody2D

# Defining Player constants
const SPEED = 120.0
const JUMP_VELOCITY = -300.0
const MAX_JUMP_COUNT = 2
const MAX_HP = 20
const MAX_MANA = 100
const BASE_DAMAGE = 5
const DASH_SPEED = SPEED * 6
const DASH_DISTANCE = 80


# Various Properties
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var dash = $Dash
@onready var dashCooldownBar = $DashCooldownBar
@onready var dashParticles = $DashParticles
@export var health_bar: TextureProgressBar
@export var mana_bar: TextureProgressBar
@export var attack_cooldown: float

#var dash_was_pressed: bool = false
#var is_dashing: bool = false
enum dash {
	ON_COOLDOWN = -1,
	READY = 0,
	KEY_PRESSED = 1,
	IS_DASHING = 2
}
var dash_state: dash = 0
var pre_dash_x = 0

var facing_right: bool = true

# Variables
var current_hp: int = MAX_HP:
	get:
		return current_hp
	set(value):
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
var jumpCount = 0;

# Setting current 
func _ready() -> void:	
	health_bar.max_value = MAX_HP
	mana_bar.max_value = MAX_MANA
	$DashCooldownBar.max_value = $DashCooldown.wait_time
	# Min value setters removed, unnecessary, are set via the nodes
	
	health_bar.value = current_hp
	mana_bar.value = current_mana
	
	print("player hp: ", current_hp, " player mana: ", current_mana, " player damage: ", damage)

func _physics_process(delta: float) -> void:
	# DEBUG STUFF SO ITS EASY TO ACCESS
	if Input.is_action_just_pressed("DEBUG_takeDamage"):
		current_hp -= 5
		current_mana -= 5
		print("Current hp: ", current_hp, "; Current mana: ", current_mana)

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("player_move_left", "player_move_right")
	
	match dash_state:
		dash.KEY_PRESSED:
			dash_state = dash.IS_DASHING
			pre_dash_x = global_position.x
			velocity.y = 0
			
			dashParticles.restart()
			
			if facing_right:
				velocity.x = DASH_SPEED
			else:
				velocity.x = -DASH_SPEED
		
		dash.IS_DASHING:
			if abs(global_position.x - pre_dash_x) > DASH_DISTANCE:
				if direction:
					velocity.x = move_toward(velocity.x, SPEED * direction, DASH_SPEED)
					if abs(velocity.x) <= SPEED:
						dash_state = dash.ON_COOLDOWN
						$DashCooldown.start()
						$DashCooldownBar.show()
				else:
					velocity.x = move_toward(velocity.x, 0, DASH_SPEED)
					if velocity.x == 0:
						dash_state = dash.ON_COOLDOWN
						$DashCooldown.start()
						$DashCooldownBar.show()
			
			elif velocity.x == 0:
				dash_state = dash.ON_COOLDOWN
				$DashCooldown.start()
				$DashCooldownBar.show()
				
		_:
			
			# Dashing
			# Extra checks to prevent dashing while standing still
			# basically you have to click 'd' and have one of the directions pressed
			if dash_state != dash.ON_COOLDOWN:
				if Input.is_action_just_pressed("player_dash") and (direction or !is_on_floor()):
					dash_state = dash.KEY_PRESSED
			else:
				$DashCooldownBar.set_value_no_signal($DashCooldown.time_left)
			
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta
				
			
			# Handle jump.
			# Resetting jump count
			if is_on_floor() and jumpCount != 0:
				jumpCount = 0
			# Jumping
			if Input.is_action_just_pressed("player_jump") and jumpCount < MAX_JUMP_COUNT:
				velocity.y = JUMP_VELOCITY
				jumpCount += 1
				
			if direction:
				velocity.x = direction * SPEED
				facing_right = direction > 0
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
		$FlipHandler/Weapon/AnimationPlayer.play("player_attack")
		canAttack = false
		$AttackCooldown.start()


func _on_entity_hit(body: Node2D) -> void:
	var body_parent = body.get_parent()
	if body_parent is Entity:
		#Log.info("Hit entity, perform damage, don't forget invincibility frames, remove this later")
		body_parent.Damage(damage, self)
	pass # Replace with function body.

func _on_attack_cooldown_end() -> void:
	canAttack = true

func _on_dash_cooldown_end() -> void:
	#print("Dash cooldown ended")
	$DashCooldownBar.hide()
	dash_state = dash.READY
