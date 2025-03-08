@tool
extends CharacterBody2D

# Defining Player constants

@export var move_speed: float = 120
@export var jump_speed = 300.0
@export var dash_speed = move_speed * 6
@export var dash_dist = 80

@export var jump_count = 2

@export var max_hp = 20
@export var max_mana = 100
@export var health_bar: TextureProgressBar
@export var mana_bar: TextureProgressBar

@export var base_damage = 5
@export var attack_cooldown: float = 0.1

# Various Properties
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum dash {
	ON_COOLDOWN = -1,
	READY = 0,
	KEY_PRESSED = 1,
	IS_DASHING = 2
}

@export_subgroup("IK target overrides", "ik_")
@export var ik_overrides: Array[IKTargetResource]
@export_tool_button("Apply overrides") var ik_overridesBtn = _setupIK.bind()
#@export var headTarget: IKTargetResource
#@export var headTarget: Node2D
#@export var headTargetResourceName: String
#@export_subgroup("Leg Targets", "leg_")
#@export var leg_frontTarget: Node2D
#@export var leg_frontTargetResourceName: String
#@export var leg_backTarget: Node2D
#@export var leg_backTargetResourceName: String
#
#@export_subgroup("Arm Targets", "arm_")
#@export var arm_frontTarget: Node2D
#@export var arm_frontTargetResourceName: String
#@export var arm_backTarget: Node2D
#@export var arm_backTargetResourceName: String

# Variables
var current_hp: int = max_hp:
	get:
		return current_hp
	set(value):
		if value < 0:
			print("The player has died")
			current_hp = 0
		else:
			current_hp = value
		
		health_bar.value = current_hp
		
var current_mana: int = max_mana:
	get:
		return current_mana
	set(value):
		if value < 0:
			print("The player has run out of Mana")
			current_mana = 0
		else:
			current_mana = value
		
		mana_bar.value = current_mana
		
var damage: int = base_damage:
	get:
		return damage
	set(value):
		damage = value
		

var facing_right: bool = true
var jumpCount: int = 0;

var dash_state: dash = 0
var pre_dash_x: float = 0

var canAttack: bool = true;

func _setupIK() -> void:
	var modificationStack: SkeletonModificationStack2D = $Skeleton.get_modification_stack()
	for override in ik_overrides:
		for idx in modificationStack.modification_count:
			var modification = modificationStack.get_modification(idx)
			if override.targetModificationName == modification.resource_name:
				var target = get_node(override.targetNodePath)
				modification.target_nodepath = target.get_path()
		pass
	pass

# Setting current 
func _ready() -> void:	
	if Engine.is_editor_hint():
		return
	health_bar.max_value = max_hp
	mana_bar.max_value = max_mana
	$DashCooldownBar.max_value = $DashCooldown.wait_time
	# Min value setters removed, unnecessary, are set via the nodes
	
	health_bar.value = current_hp
	mana_bar.value = current_mana
	
	print("player hp: ", current_hp, " player mana: ", current_mana, " player damage: ", damage)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
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
			
			$DashParticles.restart()
			
			if facing_right:
				velocity.x = dash_speed
			else:
				velocity.x = -dash_speed
		
		dash.IS_DASHING:
			if abs(global_position.x - pre_dash_x) > dash_dist:
				if direction:
					velocity.x = move_toward(velocity.x, move_speed * direction, dash_speed)
					if abs(velocity.x) <= move_speed:
						dash_state = dash.ON_COOLDOWN
						$DashCooldown.start()
						$DashCooldownBar.show()
				else:
					velocity.x = move_toward(velocity.x, 0, dash_speed)
					if is_zero_approx(velocity.x):
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
			if Input.is_action_just_pressed("player_jump") and jumpCount < jump_count:
				velocity.y = -jump_speed
				jumpCount += 1
				
			if direction:
				velocity.x = direction * move_speed
				facing_right = direction > 0
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
	
	move_and_slide()
		
#	Player animations
	if is_on_floor():
		if direction:
			player_sprite.play("run")
		else:
			player_sprite.play("idle")
	else:
		player_sprite.play("jump")
	
	if facing_right:
		player_sprite.flip_h = false
		$FlipHandler.scale.x = 1
	else:
		player_sprite.flip_h = true
		$FlipHandler.scale.x = -1
		
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
	$DashCooldownBar.hide()
	dash_state = dash.READY
