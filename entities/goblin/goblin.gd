extends CharacterBody2D
class_name Goblin_Enemy

@export var directionFlip: Node2D
@export var groundDetection: Area2D
@export var groundDetection_Deep: Area2D
@export var jumpBlockDetection: Area2D

@export var FlipRules: Array[FlipRule];

const speed = 60
const jump_speed = 128
var is_goblin_chase: bool = false # Set to true if u want the goblin to chase the player
var is_jumping: bool = false

var dead: bool = false
var taking_damage: bool = false
var base_damage = 3
var is_dealing_damage: bool = false

var dir: Vector2
var lastDir: Vector2
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area: bool = false

var rng: RandomNumberGenerator;
var receivedGoblinInstruction = false
enum GoblinInstruction {
	None, Switch
}
var goblinInstruction: GoblinInstruction = GoblinInstruction.None

#IK values
@onready var fArm = $targets/fArm
@onready var bArm = $targets/bArm
@onready var fLeg = $targets/fLeg
@onready var bLeg = $targets/bLeg
var legRestPos = Vector2(0, 15)
var legIkScale = 5
var armRestPos = Vector2(-0.5, 6)
var armIkScale = 5
var ikDelta = 0

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false
	
	player = Global.playerBody
	
	move(delta)
	handle_sprite()
	_ik_process(delta*5)
	if is_jumping:
		handle_jump()
	
	move_and_slide()
	lastDir = dir

# Main movement logic
func move(delta):
	if !dead:
		# The goblin is wandering around
		if !is_goblin_chase:
			if player_in_area:
				velocity.x = 0
				dir.x = 0
				return
			
			# If the ground detector has detected floor in front of us, we can move
			if (groundDetection.has_overlapping_bodies() or groundDetection_Deep.has_overlapping_bodies()):
				# If the goblin touches a wall, he should try to jump
				if is_on_wall():
					# If the goblin can jump over this wall, he should try it
					if(!jumpBlockDetection.has_overlapping_bodies()):
						is_jumping = true
				velocity.x = dir.x * speed
			# Otherwise, try the other direction
			else:
				dir.x *= -1
				
				
		# The goblin is chasing the player
		elif is_goblin_chase:
			# If the ground detector has detected floor in front of us, we can chase
			# Otherwise it might be wise to wait on the ledge, maybe they will come back!
			if (groundDetection.has_overlapping_bodies() or groundDetection_Deep.has_overlapping_bodies()):
				var dir_to_player = position.direction_to(player.position)
				
				if(dir_to_player.x > 0):
					velocity.x = speed
				
				elif(dir_to_player.x < 0):
					velocity.x = -speed
					
				# If the goblin touches a wall, he should try to jump
				if is_on_wall():
					# If the goblin can jump over this wall, he should try it
					if(!jumpBlockDetection.has_overlapping_bodies()):
						is_jumping = true
				
				dir.x = abs(velocity.x) / velocity.x
			else:
				velocity.x = 0
				
		# Should later be expanded to include various other behaviours.
		
		is_roaming = true
	elif dead:
		velocity.x = 0

#IK processing
func _ik_process(delta: float):
	if dir.x == 0:
		fLeg.position = (fLeg.position as Vector2).lerp(legRestPos, delta)
		bLeg.position = (bLeg.position as Vector2).lerp(legRestPos, delta)
		fArm.position = (fArm.position as Vector2).lerp(armRestPos, delta)
		bArm.position = (bArm.position as Vector2).lerp(armRestPos, delta)
		ikDelta = 0;
	else:
		ikDelta += delta;
		var offset = Vector2(sin(ikDelta), 0)
		fLeg.position = (fLeg.position as Vector2).lerp(legRestPos + offset*legIkScale, delta)
		bLeg.position = (bLeg.position as Vector2).lerp(legRestPos - offset*legIkScale, delta)
		fArm.position = (fArm.position as Vector2).lerp(armRestPos - offset*armIkScale, delta)
		bArm.position = (bArm.position as Vector2).lerp(armRestPos + offset*armIkScale, delta)
	pass

# Basic jump function
func handle_jump():
	velocity.y = -jump_speed
	is_jumping = false

func _Flip_All_Sprites(flipped: bool, base: Node2D = get_node("sprites")) -> void:
	for sprite: Node2D in base.get_children(true):
		if sprite == null or sprite.is_in_group("noFlip"):
			continue;
		sprite.scale.x = -1 if flipped else 1;
	pass

func _Apply_FlipRules(flipped: bool):
	var sprites = $sprites
	for rule in FlipRules:
		var targetNode: Node2D = sprites.get_node(rule.NodeToFlip)
		sprites.move_child(targetNode, rule.FlippedPosition if flipped else rule.OriginalPosition)
		if rule.changeModulation:
			targetNode.modulate = rule.flippedModulation if flipped else rule.normalModulation

# Changes the sprite based on the direction of the goblin
func handle_sprite():
	if dir.x == -1:
		$targets.scale.x = 1
		directionFlip.scale.x = 1
	elif dir.x == 1:
		$targets.scale.x = -1
		directionFlip.scale.x = -1
	
	if lastDir != dir:
		var isFlipped = false if dir.x == -1 else true
		_Flip_All_Sprites(isFlipped);
		_Apply_FlipRules(isFlipped);
	
	pass
	#var sprite = $goblinSprite
	#if !dead and !taking_damage and !is_dealing_damage:
	#if dir.x == -1:
		#sprite.play("left")
		#directionFlip.scale.x = 1
	#elif dir.x == 1:
		#sprite.play("right")
		#directionFlip.scale.x = -1
	#elif dir.x == 0:
		#sprite.play("normal")
		#directionFlip.scale.x = 0

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = chose([1.5, 2.0, 2.5])
	
	if !is_goblin_chase:
		# Left, Right and stand still basically
		dir = chose([Vector2.LEFT, Vector2.UP, Vector2.RIGHT])
		velocity.x = 0

# Chose a random element of the array
func chose(array: Array):
	array.shuffle()
	return array.front()

func receive_goblin_instruction(instruction: GoblinInstruction, sender: Node2D):
	Log.info(name + " received instruction. " + str(GoblinInstruction.keys()[instruction]) + " from " + sender.name)
	receivedGoblinInstruction = true;
	match instruction:
		GoblinInstruction.Switch:
			dir.x *= -1;
	pass

func _on_damage_handler_goblin_died() -> void:
	Log.info(name + " died")
	self.queue_free()


func _on_entity_reached(body: Node2D) -> void:
	if body == self:
		return
	if body is PlayerCharacter:
		Log.info("Player approached")
		player_in_area = true
	elif body is Goblin_Enemy:
		dir.x *= -1;
		#if !receivedGoblinInstruction:
			#var instr: GoblinInstruction = GoblinInstruction.Switch #rng.randi_range(1,2)
			#body.receive_goblin_instruction(instr, self)
			#match instr:
				#GoblinInstruction.JumpOver:
					#return;
		pass
	pass # Replace with function body.


func _on_entity_left(body: Node2D) -> void:
	if body is PlayerCharacter:
		Log.info("Player left")
		player_in_area = false
	elif body is Goblin_Enemy:
		pass
	pass # Replace with function body.
