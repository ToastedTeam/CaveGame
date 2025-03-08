@tool
class_name IKPlayerAnimator
extends Node2D

@export var player: PlayerCharacter;
@export var animationPlayer: AnimationPlayer;

@export_category("IK Inhibitors")
@export var inhibitFH: bool;
@export var inhibitBH: bool;
@export var inhibitFF: bool;
@export var inhibitBF: bool;

var hip: Bone2D;
var hand: RemoteTransform2DExtended;
var lastDirection = 1;

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
				pass
		_Flip_All_Sprites(flipped)
		hand.rotation_degrees = default_states["hand_rot"] + (-1 if flipped else 1)
		# WHAT THE HELL IS GOING ON
		animationPlayer.get_parent().scale.x = -1 if flipped else 1
	pass

func _Hijack_Player_IK() -> void:
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
	_Hijack_Player_IK()
	pass

func _Flip_All_Sprites(flipped: bool, base: Node2D = player.get_node("sprites")) -> void:
	for sprite: Node2D in base.get_children(true):
		if sprite == null:
			continue;
		sprite.scale.x = -1 if flipped else 1;
	pass

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if hip == null:
		hip = player.get_node("Skeleton/hip")
	else:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(hip.global_position, hip.global_position + Vector2(0, 35))
		query.collision_mask = 0b00000000_00000000_00000000_00000001;
		var result = space_state.intersect_ray(query)
		if result:
			$BFTarget.global_position = result.position;
			$FFTarget.global_position = result.position;
		else:
			$BFTarget.global_position = hip.global_position + Vector2(0, 20);
			$FFTarget.global_position = hip.global_position + Vector2(0, 20);
			pass
		pass
		if !inhibitFH:
			$FHTarget.global_position = hip.global_position + Vector2(5, 5)
		if !inhibitBH:
			$BHTarget.global_position = hip.global_position + Vector2(-2, 5)
		if lastDirection != player.currentDirection:
			if player.currentDirection < 0:
				_IK_Bones_Set_Flipped(true)
			elif player.currentDirection > 0:
				_IK_Bones_Set_Flipped(false)
		lastDirection = player.currentDirection
	pass
