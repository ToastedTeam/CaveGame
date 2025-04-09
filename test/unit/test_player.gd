extends GutTest

var player_scene = load('res://entities/player/player.tscn') as PackedScene
var player: PlayerCharacter = null

func before_all():
	player = player_scene.instantiate()

func before_each():
	for action in InputMap.get_actions():
		Input.action_release(action)
	#watch_signals(player)
	#gut.p("Runs before each test.")

#func after_each():
	#gut.p("Runs after each test.")

#func after_all():
	#gut.p("Runs once after all tests")
	
func test_getPlayerMovement_left():
	Input.action_press("player_move_left")
	assert_eq(player._getPlayerMovement(), -1., "Move left")
	
func test_getPlayerMovement_right():
	Input.action_press("player_move_right")
	assert_eq(player._getPlayerMovement(), 1., "Move right")

func test_isPlayerJumping():
	Input.action_press("player_jump")
	assert_eq(player._isPlayerJumping(), true, "Move right")

func test_isPlayerDashing():
	Input.action_press("player_dash")
	assert_eq(player._isPlayerDashing(), true, "Move right")

func test_isPlayerJustAttackingMelee():
	Input.action_press("player_attack_melee")
	assert_eq(player._isPlayerJustAttackingMelee(), true, "Move right")
	
func test_isPlayerJustAttackingRanged():
	Input.action_press("player_attack_ranged")
	assert_eq(player._isPlayerJustAttackingRanged(), true, "Move right")
