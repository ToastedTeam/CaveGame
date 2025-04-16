extends GutTest

var inhibitorStates = [true, false]

var player = load('res://entities/player/player.tscn')
var _player: PlayerCharacter = null

var _sender: GutInputSender = InputSender.new(Input)

func before_all():
	_player = player.instantiate()
	
func after_each():
	_sender.release_all()
	_sender.clear()
	#var actions = InputMap.get_actions()
	#for action in actions:
		#Input.action_release(action)

func after_all():
	_player.queue_free()

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
	#Input.action_press("player_jump")
	#_sender.release_all()
	#_sender.clear()
	_sender.action_down("player_jump")
	_player.inhibitUserInput = params
	#Input.flush_buffered_events()
	print("is just pressed " + str(Input.is_action_just_pressed("player_jump")))
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
