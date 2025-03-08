extends Node2D

@export var player: PlayerCharacter;
var hip: Bone2D
var lastDirection = 1;

var default_states = {}

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
	pass

func _ready() -> void:
	var skeleton: Skeleton2D = player.get_node("Skeleton")
	var modificationStack: SkeletonModificationStack2D = skeleton.get_modification_stack()
	for idx in modificationStack.modification_count:
		var modification = modificationStack.get_modification(idx)
		if modification is SkeletonModification2DTwoBoneIK:
			default_states[idx] = modification.flip_bend_direction
	pass

func _Flip_All_Sprites(flipped: bool, base: Node2D = player.get_node("sprites")) -> void:
	for sprite: Node2D in base.get_children(true):
		if sprite == null:
			continue;
		sprite.scale.x = -1 if flipped else 1;
	pass

func _physics_process(delta: float) -> void:
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
		$FHTarget.global_position = hip.global_position + Vector2(5, 5)
		$BHTarget.global_position = hip.global_position + Vector2(-2, 5)
		if lastDirection != player.currentDirection:
			if player.currentDirection < 0:
				_IK_Bones_Set_Flipped(true)
			elif player.currentDirection > 0:
				_IK_Bones_Set_Flipped(false)
		lastDirection = player.currentDirection
	pass
