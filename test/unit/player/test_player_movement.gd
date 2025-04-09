class_name MovementTest
extends GutTest

var inhibitorStates = [true, false]

var player = load('res://entities/player/player.gd')
var _player: PlayerCharacter = null
var _sender: GutInputSender = InputSender.new(Input)

func after_each():
	_sender.release_all()
	_sender.clear()

# This class tests whether all movement inputs for the player 
# work, along with if they react to input blockers within the player
class TestMovementRead:
	extends MovementTest

	func before_each():
		_player = player.new()
		add_child_autofree(_player)
		


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
	extends MovementTest
	
	
	#func before_all():
		#_sender = InputSender.new(_player)
	
	func before_each():
		_player = player.new()
		var skeleton = Skeleton2D.new();
		add_child_autofree(_player)

	func test_player_move_right(params=use_parameters(inhibitorStates)):
		_player.inhibitUserInput = params
		_sender.action_down("player_move_right")
		simulate(_player, 60, 1/60)
		if !params:
			assert_almost_eq(_player.position.x, _player.move_speed, 1., "Player moved right")
		else:
			assert_almost_eq(_player.position.x, 0., .01, "Player didn't move right")

	func test_player_move_left(params=use_parameters(inhibitorStates)):
		_player.inhibitUserInput = params
		_sender.action_down("player_move_left")
		simulate(_player, 60, 1/60)
		if !params:
			assert_almost_eq(_player.position.x, -_player.move_speed, 1., "Player moved left")
		else:
			assert_almost_eq(_player.position.x, 0., .01, "Player didn't move left")

# TODO: RE-ADD INHIBITOR STATES
	func test_player_jump():
		var inst = partial_double(player).new()
		add_child_autofree(inst)
		stub(inst._isPlayerJumping).to_return(true)
		
		#_sender.action_down("player_jump")
		simulate(inst, 60, 1/60)
		assert_almost_eq(inst.position.y, -inst.jump_speed, 1., "Player jumped")

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
