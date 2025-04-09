class_name TestPlayer
extends GutTest

var player = load('res://entities/player/player.gd')
var _player: PlayerCharacter = null
var _sender: GutInputSender = InputSender.new(Input)

func after_each():
	_sender.release_all()
	_sender.clear()

func before_each():
	_player = player.new()
	add_child_autofree(_player)

# This class is the general class for testing player movement
class TestPlayerMovement:
	extends TestPlayer
	var inhibitorStates = [true, false]
	
# This class tests whether all movement inputs for the player 
# work, along with if they react to input blockers within the player
class TestMovementRead:
	extends TestPlayerMovement

	func before_each():
		_player = player.new()
		add_child_autoqfree(_player)
		
	func test_getPlayerMovement_Left(params=use_parameters(inhibitorStates)):
		_sender.action_down("player_move_left")
		_player.inhibitUserInput = params
		if params == false:
			assert_eq(_player._getPlayerMovement(), -1., "Player moves left")
		else:
			assert_eq(_player._getPlayerMovement(), 0.0, "Player doesn't move left")
		pass

	func test_getPlayerMovement_Right(params=use_parameters(inhibitorStates)):
		_sender.action_down("player_move_right")
		_player.inhibitUserInput = params
		if params == false:
			assert_eq(_player._getPlayerMovement(), 1., "Player moves right")
		else:
			assert_eq(_player._getPlayerMovement(), 0.0, "Player doesn't move right")
		pass
		
	func test_isPlayerJumping(params=use_parameters(inhibitorStates)):
		_sender.action_down("player_jump")
		_player.inhibitUserInput = params

		if params == false:
			assert_true(_player._isPlayerJumping(), "Player jumps")
		else:
			assert_false(_player._isPlayerJumping(), "Player doesn't jump")
		pass
		
	func test_isPlayerDashing(params=use_parameters(inhibitorStates)):
		_sender.action_down("player_dash")
		_player.inhibitUserInput = params
		if params == false:
			assert_eq(_player._isPlayerDashing(), true, "Player dashes")
		else:
			assert_eq(_player._isPlayerJumping(), false, "Player doesn't dash")
		pass

	func test_isPlayerJustAttackingMelee(params=use_parameters(inhibitorStates)):
		_sender.action_down("player_attack_melee")
		_player.inhibitUserInput = params
		if params == false:
			assert_eq(_player._isPlayerJustAttackingMelee(), true, "Player is just attacking melee")
		else:
			assert_eq(_player._isPlayerJustAttackingMelee(), false, "Player isn't attacking melee")
		pass
		
	func test_isPlayerJustAttackingRanged(params=use_parameters(inhibitorStates)):
		_sender.action_down("player_attack_ranged")
		_player.inhibitUserInput = params
		if params == false:
			assert_eq(_player._isPlayerJustAttackingRanged(), true, "Player is just attacking ranged")
		else:
			assert_eq(_player._isPlayerJustAttackingRanged(), false, "Player isn't attacking ranged")
		pass

# This class tests whether the player actually moves according to the given inputs
class TestMovementBehavior:
		extends TestPlayerMovement

		func test_player_move_right(params=use_parameters(inhibitorStates)):
			_player.inhibitUserInput = params
			_sender.action_down("player_move_right")
			simulate(_player, 60, 1/60)
			if !params:
				assert_almost_eq(_player.position.x, _player.move_speed, 30., "Player moved right")
			else:
				assert_almost_eq(_player.position.x, 0., .01, "Player didn't move right")

		func test_player_move_left(params=use_parameters(inhibitorStates)):
			_player.inhibitUserInput = params
			_sender.action_down("player_move_left")
			simulate(_player, 60, 1/60)
			if !params:
				assert_almost_eq(_player.position.x, -_player.move_speed, 30., "Player moved left")
			else:
				assert_almost_eq(_player.position.x, 0., .01, "Player didn't move left")

	# TODO: RE-ADD INHIBITOR STATES
		func test_player_jump():
			var inst = partial_double(player).new()
			stub(inst._isPlayerJumping).to_return(true)
			add_child_autoqfree(inst)
			PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2.DOWN)
			print(inst.get_gravity())
			
			#_sender.action_down("player_jump")
			simulate(inst, 1, 60)
			stub(inst._isPlayerJumping).to_return(false) # we are simulating just_pressed
			 
			simulate(inst, 60, 60)
			
			assert_almost_eq(inst.position.y, -inst.jump_speed, 30., "Player jumped")

	# TODO: RE-ADD INHIBITOR STATES
	# This tests comprehensively the entire process of the dashing using partial
	# doubles to get around a testing problem we're encountering, and also
	# just placeholder nodes to prevent any errors
		func test_player_dash_left():
			var inst = partial_double(player).new()
			var fakeParticles = GPUParticles2D.new()
			var fakeTimer = Timer.new()
			var fakeTimerBar = ProgressBar.new()
			fakeTimer.name = "DashCooldown"
			fakeTimerBar.name = "DashCooldownBar"
			var fakeAnimator = double(IKPlayerAnimator).new()
			inst.IkAnimator = fakeAnimator
			stub(inst._isPlayerDashing).to_return(true)
			fakeParticles.name = "DashParticles"
			inst.add_child(fakeParticles)
			inst.add_child(fakeTimer)
			inst.add_child(fakeTimerBar)
			
			add_child_autofree(inst)
			_sender.action_down("player_move_left")
			simulate(inst, 1, 1/60)
			assert_eq(inst.dash_state, PlayerCharacter.dash.KEY_PRESSED)
			stub(inst._isPlayerDashing).to_return(false)
			simulate(inst, 1, 1/60)
			assert_eq(inst.dash_state, PlayerCharacter.dash.IS_DASHING)
			_sender.action_up("player_move_left")
			simulate(inst, 58, 1/60)
			assert_eq(inst.dash_state, PlayerCharacter.dash.ON_COOLDOWN)
			inst._on_dash_cooldown_end()
			assert_eq(inst.dash_state, PlayerCharacter.dash.READY)
			assert_almost_eq(inst.position.x, -_player.dash_dist as float, 10.)

	# TODO: RE-ADD INHIBITOR STATES
	# This tests comprehensively the entire process of the dashing using partial
	# doubles to get around a testing problem we're encountering, and also
	# just placeholder nodes to prevent any errors
		func test_player_dash_right():
			var inst = partial_double(player).new()
			var fakeParticles = GPUParticles2D.new()
			var fakeTimer = Timer.new()
			var fakeTimerBar = ProgressBar.new()
			fakeTimer.name = "DashCooldown"
			fakeTimerBar.name = "DashCooldownBar"
			var fakeAnimator = double(IKPlayerAnimator).new()
			inst.IkAnimator = fakeAnimator
			stub(inst._isPlayerDashing).to_return(true)
			fakeParticles.name = "DashParticles"
			inst.add_child(fakeParticles)
			inst.add_child(fakeTimer)
			inst.add_child(fakeTimerBar)
			
			add_child_autofree(inst)
			_sender.action_down("player_move_right")
			simulate(inst, 1, 1/60)
			assert_eq(inst.dash_state, PlayerCharacter.dash.KEY_PRESSED)
			stub(inst._isPlayerDashing).to_return(false)
			simulate(inst, 1, 1/60)
			assert_eq(inst.dash_state, PlayerCharacter.dash.IS_DASHING)
			_sender.action_up("player_move_right")
			simulate(inst, 58, 1/60)
			assert_eq(inst.dash_state, PlayerCharacter.dash.ON_COOLDOWN)
			inst._on_dash_cooldown_end()
			assert_eq(inst.dash_state, PlayerCharacter.dash.READY)
			assert_almost_eq(inst.position.x, _player.dash_dist as float, 10.)

# This class is the general class for testing player inverse kinematics
class TestPlayerInverseKinematics:
	extends TestPlayer
	func before_each():
		pass
	
	func createNamedNode(name, type):
		var newnode = type.new()
		newnode.name = name;
		return newnode;
	
	func createIkAnimator():
		var ikAnimator = IKPlayerAnimator.new()
		ikAnimator.add_child(createNamedNode("FFTarget_pos", Node2D), true)
		ikAnimator.add_child(createNamedNode("BFTarget_pos", Node2D), true)
		ikAnimator.add_child(createNamedNode("FHTarget_pos", Node2D), true)
		ikAnimator.add_child(createNamedNode("BHTarget_pos", Node2D), true)
		return ikAnimator
	
	func generateModifications():
		var modificationStack = SkeletonModificationStack2D.new()
		
		var modification1 = SkeletonModification2DTwoBoneIK.new()
		modification1.target_nodepath = get_path()
		modification1.resource_name = "testModification1"
		modificationStack.add_modification(modification1)
		
		var modification2 = SkeletonModification2DTwoBoneIK.new()
		modification2.target_nodepath = get_parent().get_path()
		modification2.resource_name = "testModification2"
		
		modificationStack.add_modification(modification2)
		return modificationStack
		
	func generateFullAnimator():
		var animator: IKPlayerAnimator = createIkAnimator()
		var playerSkeleton = Skeleton2D.new()
		playerSkeleton.name = "Skeleton"
		playerSkeleton.set_modification_stack(generateModifications())
		
		var hipnode = createNamedNode("hip", Bone2D)
		var collarnode = createNamedNode("collar", Bone2D)
		var offsetnode = createNamedNode("offset", Bone2D)
		playerSkeleton.add_child(hipnode, true)
		
		var handnode: RemoteTransform2DExtended = createNamedNode("Hand", RemoteTransform2DExtended)
		playerSkeleton.add_child(handnode, true)
		var handTargetNode = createNamedNode("target", Node2D)
		handnode.node = handTargetNode
		
		hipnode.add_child(collarnode, true)
		collarnode.add_child(offsetnode, true)
		
		var animPlayer = AnimationPlayer.new()
		animator.add_child(animPlayer)
		animator.animationPlayer = animPlayer
		
		_player = player.new();
		_player.name = "Player"
		animator.player = _player
		_player.add_child(playerSkeleton, true)
		add_child_autoqfree(handTargetNode)
		return animator;
		
	func test_player_setupIK_noOverrideArray_shouldntAffectModificationStack():
		var playerSkeleton = Skeleton2D.new()
		playerSkeleton.name = "Skeleton"
		
		playerSkeleton.set_modification_stack(generateModifications())
		
		_player = player.new();
		_player.add_child(playerSkeleton, true)
		add_child_autoqfree(_player, true)
		
		assert_eq(playerSkeleton.get_modification_stack().get_modification(0).target_nodepath, get_path())
		assert_eq(playerSkeleton.get_modification_stack().get_modification(1).target_nodepath, get_parent().get_path())

	func test_player_setupIK_emptyOverrideArray_shouldntAffectModificationStack():
		var playerSkeleton = Skeleton2D.new()
		playerSkeleton.name = "Skeleton"
		
		playerSkeleton.set_modification_stack(generateModifications())
		
		var overrides: Array[IKTargetResource] = [];
		
		_player = player.new();
		_player.ik_overrides = overrides
		_player.add_child(playerSkeleton, true)
		add_child_autoqfree(_player, true)
		
		assert_eq(playerSkeleton.get_modification_stack().get_modification(0).target_nodepath, get_path())
		assert_eq(playerSkeleton.get_modification_stack().get_modification(1).target_nodepath, get_parent().get_path())
		
	func test_player_setupIK_existingOverrides_shouldAffectModificationStack():
		var playerSkeleton = Skeleton2D.new()
		playerSkeleton.name = "Skeleton"
		
		playerSkeleton.set_modification_stack(generateModifications())
		
		var overrides: Array[IKTargetResource] = [];
		var override1: IKTargetResource = IKTargetResource.new()
		override1.targetModificationName = "testModification1"
		override1.targetNodePath = get_parent().get_path()
		overrides.append(override1)
		
		var override2: IKTargetResource = IKTargetResource.new()
		override2.targetModificationName = "testModification2"
		override2.targetNodePath = get_path()
		overrides.append(override2)
		
		_player = player.new();
		_player.ik_overrides = overrides
		_player.add_child(playerSkeleton, true)
		add_child_autoqfree(_player, true)
		
		assert_eq(playerSkeleton.get_modification_stack().get_modification(0).target_nodepath, get_parent().get_path())
		assert_eq(playerSkeleton.get_modification_stack().get_modification(1).target_nodepath, get_path())

	func test_playerIkAnimator_setAnimState_savesHistory():
		var animator = generateFullAnimator()
		
		add_child_autoqfree(_player, true)
		add_child_autoqfree(animator, true)
		
		animator.setAnimState(IKPlayerAnimator.AnimState.Walking)
		assert_eq(animator.state, IKPlayerAnimator.AnimState.Walking)
		assert_eq(animator.lastState, IKPlayerAnimator.AnimState.Idle)

	func test_playerIkAnimator_AttackMelee_returnsFalseWhenNoWeapon():
		var animator = generateFullAnimator()
		
		add_child_autoqfree(_player, true)
		add_child_autoqfree(animator, true)
		
		assert_false(animator.Attack_Melee())

	func test_playerIkAnimator_AttackMelee_returnsTrueWhenWeaponExists():
		var animator = generateFullAnimator()
		add_child_autoqfree(_player, true)
		add_child_autoqfree(animator, true)
		var wpn: Weapon = createNamedNode("Weapon", Weapon)
		wpn.AnimName = "RESET"
		animator.hand.node.add_child(wpn)
		wpn.player = _player
		assert_true(animator.Attack_Melee())

	func test_playerIkAnimator_AttackRanged_returnsFalseWhenNoWeapon():
		var animator = generateFullAnimator()
		
		add_child_autoqfree(_player, true)
		add_child_autoqfree(animator, true)
		
		assert_false(animator.Attack_Ranged())

	func test_playerIkAnimator_AttackRanged_returnsTrueWhenWeaponExists():
		var animator = generateFullAnimator()
		add_child_autoqfree(_player, true)
		add_child_autoqfree(animator, true)
		var wpn: RangedWeapon = createNamedNode("Ranged", RangedWeapon)
		wpn.add_child(createNamedNode("ProjectileMarker", Node2D))
		wpn.projectile_path = "res://test/unit/emptyProjectile.tscn"
		animator.hand.node.add_child(wpn)
		wpn.player = _player
		assert_true(animator.Attack_Ranged())
