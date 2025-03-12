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
@export var ArmRestOffset: Vector2 = Vector2(0, 5);
@export var FArmRest: Vector2 = Vector2(0, 0);
@export var BArmRest: Vector2 = Vector2(0, 0);


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
func Attack_Melee() -> void:
	# We're doing a rough assumption that what the hands have is only a weapon
	var weapon = hand.node.get_node("Weapon") as Weapon
	animationPlayer.play(weapon.AnimName)
	pass

func Attack_Magic() -> void:
	Log.info("Perform magic attack, play some animation or something...")
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
				print("old modulation: ", targetNode.modulate)
				targetNode.modulate = rule.flippedModulation if flipped else rule.normalModulation
				print("new modulation: ", targetNode.modulate)
			
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
	FFTargetPos = animParent.find_child("FFTarget_pos")
	BFTargetPos = animParent.find_child("BFTarget_pos")
	FHTargetPos = animParent.find_child("FHTarget_pos")
	BHTargetPos = animParent.find_child("BHTarget_pos")
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
	
var shouldMoveFF = false;
var FF_t = 0.0
var FF_duration = 0.2;
var FF_originalPos: Vector2;

var shouldMoveBF = false;
var BF_t = 0.0;
var BF_duration = 0.2;
var BF_originalPos: Vector2;

var last_grounded = true;

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if hip == null:
		hip = player.get_node("Skeleton/hip")
	else:
		var grounded = player.is_on_floor()
		var just_grounded = grounded and !last_grounded;
		# Find where to put player's feet
		if grounded:
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(hip.global_position, hip.global_position + Vector2(0, 35))
			query.collision_mask = 0b00000000_00000000_00000000_00000001;
			var result = space_state.intersect_ray(query)
			if result: # If there's ground below, we set it to the ground
				FFTargetPos.global_position = result.position + Vector2(player.currentDirection*10, 5);
				BFTargetPos.global_position = result.position + Vector2(player.currentDirection*10, 5);
		else: # Otherwise, we make the player curl up a little bit
			FFTargetPos.global_position = hip.global_position + Vector2(0, 20);
			BFTargetPos.global_position = hip.global_position + Vector2(0, 20);
			pass
		pass
		if abs($FFTarget.global_position.x - FFTargetPos.global_position.x) > maxFootDistanceFromTarget and !shouldMoveBF:
			shouldMoveFF = true;
			FF_originalPos = $FFTarget.global_position;
		
		if abs($BFTarget.global_position.x - BFTargetPos.global_position.x) > maxFootDistanceFromTarget and !shouldMoveFF:
			shouldMoveBF = true;
			BF_originalPos = $BFTarget.global_position
			#$BFTarget.global_position = BFTargetPos.global_position
			
		if just_grounded:
			$FFTarget.global_position = FFTargetPos.global_position
			$BFTarget.global_position = BFTargetPos.global_position
			
		
		if shouldMoveFF and grounded:
			FF_t += delta/FF_duration;
			# interpolate in an arc, currently unimplemented
			var positionC = (FFTargetPos.global_position + FF_originalPos)/2 + Vector2(0, -10)
			var q0 = FF_originalPos.lerp(positionC, min(FF_t, 1.0))
			var q1 = positionC.lerp(FFTargetPos.global_position, min(FF_t, 1.0))
			$FFTarget.global_position = q0.lerp(q1, min(FF_t, 1.0))
			if $FFTarget.global_position.distance_squared_to(FFTargetPos.global_position) < 10:
				FF_t = 0;
				shouldMoveFF = false;
		elif !grounded:
			$FFTarget.global_position = FFTargetPos.global_position
		if shouldMoveBF:
			BF_t += delta/BF_duration;
			var positionC = (BFTargetPos.global_position + BF_originalPos)/2 + Vector2(0, -10)
			var q0 = BF_originalPos.lerp(positionC, min(BF_t, 1.0))
			var q1 = positionC.lerp(BFTargetPos.global_position, min(BF_t, 1.0))
			$BFTarget.global_position = q0.lerp(q1, min(BF_t, 1.0))
			if $BFTarget.global_position.distance_squared_to(BFTargetPos.global_position) < 10:
				BF_t = 0;
				shouldMoveBF = false;
		elif !grounded:
			$BFTarget.global_position = BFTargetPos.global_position
		
		if !inhibitFH:
			$FHTarget.global_position = hip.global_position + ArmRestOffset + FArmRest
		if !inhibitBH:
			$BHTarget.global_position = hip.global_position + BArmRest + ArmRestOffset
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
