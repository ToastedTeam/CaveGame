@tool
class_name IKPlayerAnimator
extends Node2D

@export var player: PlayerCharacter;
@export var animationPlayer: AnimationPlayer;

@export var maxFootDistanceFromTarget = 100;
@export var FlipRules: Array[FlipRule];

@export_category("IK Inhibitors")
@export var inhibitFH: bool;
@export var inhibitBH: bool;
@export var inhibitFF: bool;
@export var inhibitBF: bool;

@export_category("IK Parameters")
@export var IdleLegOffset: Vector2 = Vector2(0, 5);
@export var ArmRestOffset: Vector2 = Vector2(0, 5);
@export var FArmRest: Vector2 = Vector2(0, 0);
@export var BArmRest: Vector2 = Vector2(0, 0);

var last_grounded = true;

var hip: Bone2D;
var hand: RemoteTransform2DExtended;
var lastDirection = 1;

var FFTargetPos: Node2D;
var BFTargetPos: Node2D;
var FHTargetPos: Node2D;
var BHTargetPos: Node2D;

var collarBone: Bone2D;
var collarOffsetBone: Bone2D;

var default_states = {}

enum AnimState {
	Walking,
	Dashing,
	Idle
}

enum WalkState {
	FrontFoot,
	BackFoot,
	None
}


@export var state: AnimState = AnimState.Idle
@export var lastState: AnimState = AnimState.Idle

var currentWalk: WalkState = WalkState.None;
var currentWalkChanged = false;
var stepOriginPos: Vector2 = Vector2.ZERO
var footOriginalPos: Vector2 = Vector2.ZERO;
var walkTime = 0.0;
var walkDuration = 0.2;
var walkStepSize = 30;

func setAnimState(newState: AnimState):
	lastState = state;
	state = newState;

# Attacks return true if player has a weapon, otherwise false
func Attack_Melee() -> bool:
	if not hand.node.has_node("Weapon"):
		return false
	# We're doing a rough assumption that what the hands have is only a weapon
	var weapon = hand.node.get_node("Weapon") as Weapon
	animationPlayer.play(weapon.AnimName)
	return true

func Attack_Ranged() -> bool:
	if not hand.node.has_node("Ranged"):
		return false
	#Log.info("Perform magic attack, play some animation or something...")
	var weapon = hand.node.get_node("Ranged") as RangedWeapon
	weapon._attack()
	return true

func Start_Dash() -> void:
	setAnimState(AnimState.Dashing)
	pass

func _IK_Bones_Set_Flipped(flipped: bool) -> void:
	if player != null:
		var skeleton: Skeleton2D = player.get_node("Skeleton")
		var modificationStack: SkeletonModificationStack2D = skeleton.get_modification_stack()
		for idx in modificationStack.modification_count:
			var modification = modificationStack.get_modification(idx)
			if modification is SkeletonModification2DTwoBoneIK:
				modification.flip_bend_direction = !default_states[idx] if flipped else default_states[idx];
			elif modification is SkeletonModification2DLookAt:
				var flip: Node2D = skeleton.get_bone(modification.bone_index).get_node("flipHandler")
				flip.scale = Vector2.ONE * -1 if flipped else Vector2.ONE
				#pass
		_Flip_All_Sprites(flipped)
		hand.rotation_degrees = default_states["hand_rot"] + (-1 if flipped else 1)
		collarBone.rotation = PI if flipped else 0
		collarOffsetBone.rotation = PI if flipped else 0
		# WHAT THE HELL IS GOING ON
		animationPlayer.get_parent().scale.x = -1 if flipped else 1
		
		var sprites = player.get_node("sprites")
		for rule in FlipRules:
			var targetNode: Node2D = sprites.get_node(rule.NodeToFlip)
			sprites.move_child(targetNode, rule.FlippedPosition if flipped else rule.OriginalPosition)
			if rule.changeModulation:
				targetNode.modulate = rule.flippedModulation if flipped else rule.normalModulation
		(player.get_node("targetPositions/HipTarget/Synchroniser") as RemoteTransform2DExtended).rotationOffset = PI if flipped else 0
	pass

func _Get_Player_Params() -> void:
	var skeleton: Skeleton2D = player.get_node("Skeleton")
	var modificationStack: SkeletonModificationStack2D = skeleton.get_modification_stack()
	for idx in modificationStack.modification_count:
		var modification = modificationStack.get_modification(idx)
		if modification is SkeletonModification2DTwoBoneIK:
			default_states[idx] = modification.flip_bend_direction
	hand = skeleton.find_child("Hand", true, false)
	default_states["hand_rot"] = hand.rotation_degrees;
	

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_Get_Player_Params()
	var animParent = animationPlayer.get_parent()
	FFTargetPos = animParent.find_child("FFTarget_pos", true, false)
	BFTargetPos = animParent.find_child("BFTarget_pos", true, false)
	FHTargetPos = animParent.find_child("FHTarget_pos", true, false)
	BHTargetPos = animParent.find_child("BHTarget_pos", true, false)
	hip = player.get_node("Skeleton/hip")
	collarBone = hip.find_child("collar", true, false);
	collarOffsetBone = collarBone.find_child("offset", true, false);
	pass

func _Flip_All_Sprites(flipped: bool, base: Node2D = player.get_node("sprites")) -> void:
	for sprite: Node2D in base.get_children(true):
		if sprite == null or sprite.is_in_group("noFlip"):
			continue;
		sprite.scale.x = -1 if flipped else 1;
	pass
	
#var shouldMoveFF = false;
#var FF_t = 0.0
#var FF_duration = 0.2;
#var FF_originalPos: Vector2;
#
#var shouldMoveBF = false;
#var BF_t = 0.0;
#var BF_duration = 0.2;
#var BF_originalPos: Vector2;


func _process(delta: float) -> void:
	if state != AnimState.Dashing:
		if player.currentDirection != 0 and !player.hitWall:
			setAnimState(AnimState.Walking)
			match currentWalk:
				WalkState.FrontFoot:
					BFTargetPos.global_position = $BFTarget.global_position
				WalkState.BackFoot:
					FFTargetPos.global_position = $FFTarget.global_position
					pass
		else:
			setAnimState(AnimState.Idle)
	
	pass

# Returns hip.global_position if there's no result 
func getGroundPosition() -> Vector2:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(hip.global_position, hip.global_position + Vector2(0, 50))
	query.collision_mask = 0b00000000_00000000_00000000_00000001;
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	else:
		return hip.global_position
	pass

func IKStateMachine(delta, grounded, just_grounded) -> void:
	if just_grounded:
		setAnimState(AnimState.Idle)
	# Find where to put player's feet
	if state != AnimState.Dashing:
		if !grounded: # Curl up player's legs if they're in the air
			(FFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = true;
			(BFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = true;
			FFTargetPos.global_position = hip.global_position + Vector2(0, 20);
			BFTargetPos.global_position = hip.global_position + Vector2(0, 20);
			currentWalk = WalkState.None
			currentWalkChanged = true
		else:
			match state:
				AnimState.Idle:
					if !inhibitBF and !inhibitFF:
						if lastState != AnimState.Idle:
							(FFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = true;
							(BFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = true;
						setAnimState(AnimState.Idle)
						var ground = getGroundPosition()
						if ground != hip.global_position:
							FFTargetPos.global_position = ground + IdleLegOffset;
							BFTargetPos.global_position = ground + IdleLegOffset;
						pass
				AnimState.Walking:
					#Engine.time_scale = 0.1
					if !inhibitBF and !inhibitFF:
						if player.currentDirection == 0:
							currentWalk = WalkState.None
							walkTime = 0
							return
						if lastState != AnimState.Walking:
							(FFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = false;
							(BFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = false;
							currentWalk = WalkState.None
						setAnimState(AnimState.Walking)
						var ground = getGroundPosition()
						if ground == hip.global_position:
							pass
						hip.position.y = (abs(sin(walkTime*PI))-0.5)

						match currentWalk:
							WalkState.None:
								currentWalk = WalkState.FrontFoot;
								currentWalkChanged = true
								pass
							WalkState.FrontFoot:
								if currentWalkChanged:
									stepOriginPos = ground
									currentWalkChanged = false
									walkTime = 0
									footOriginalPos = $FFTarget.global_position
								walkTime += delta/walkDuration;
								FFTargetPos.global_position = stepOriginPos + Vector2(player.currentDirection*walkStepSize, 5);
								var positionC = (FFTargetPos.global_position + footOriginalPos)/2 + Vector2(0, -25)
								var q0 = footOriginalPos.lerp(positionC, min(walkTime, 1.0))
								var q1 = positionC.lerp(FFTargetPos.global_position, min(walkTime, 1.0))
								$FFTarget.global_position = q0.lerp(q1, min(walkTime, 1.0))
								if $FFTarget.global_position.distance_squared_to(FFTargetPos.global_position) < 10:
									currentWalk = WalkState.BackFoot
									currentWalkChanged = true
								pass
							WalkState.BackFoot:
								if currentWalkChanged:
									stepOriginPos = ground
									currentWalkChanged = false
									walkTime = 0
									footOriginalPos = $BFTarget.global_position
								walkTime += delta/walkDuration;
								BFTargetPos.global_position = stepOriginPos + Vector2(player.currentDirection*walkStepSize, 5);
								var positionC = (BFTargetPos.global_position + footOriginalPos)/2 + Vector2(0, -25)
								var q0 = footOriginalPos.lerp(positionC, min(walkTime, 1.0))
								var q1 = positionC.lerp(BFTargetPos.global_position, min(walkTime, 1.0))
								$BFTarget.global_position = q0.lerp(q1, min(walkTime, 1.0))
								if $BFTarget.global_position.distance_squared_to(BFTargetPos.global_position) < 10:
									currentWalk = WalkState.FrontFoot
									currentWalkChanged = true
								pass
						pass
				_:
					pass
	if state == AnimState.Dashing and lastState != AnimState.Dashing and !inhibitBF and !inhibitFF:
		(FFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = true;
		(BFTargetPos.get_node("Synchroniser") as RemoteTransform2DExtended).Position = true;
		FFTargetPos.global_position = hip.global_position + Vector2(-20, 20);
		BFTargetPos.global_position = hip.global_position + Vector2(10, 20);
		setAnimState(AnimState.Dashing)
		pass
	pass

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if hip == null:
		hip = player.get_node("Skeleton/hip")
	else:
		var grounded = player.is_on_floor()
		var just_grounded = grounded and !last_grounded;
		IKStateMachine(delta, grounded, just_grounded)
		
		# Arm rest inhibition
		if !inhibitFH:
			FHTargetPos.global_position = hip.global_position + ArmRestOffset + FArmRest
		if !inhibitBH:
			BHTargetPos.global_position = hip.global_position + BArmRest + ArmRestOffset
		
		if lastDirection != player.currentDirection:
			if player.currentDirection < 0:
				_IK_Bones_Set_Flipped(true)
			elif player.currentDirection > 0:
				_IK_Bones_Set_Flipped(false)
		lastDirection = player.currentDirection
		last_grounded = grounded
		# NOTE: many of the position setting makes the player's limbs kinda
		# lag behind. Now i got this accidentally, but personally I like it
		# as it makes the movements feel a bit more organic,
		# so it is intended :P
	pass
