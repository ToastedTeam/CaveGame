class_name TestGoblin
extends GutTest

var player_scene = load('res://entities/player/player.tscn')
var player = null

var goblin_scene = load('res://entities/goblin/goblin.tscn')
var goblin: Goblin_Enemy = null

class TestGoblinBase:
	extends TestGoblin
	
	var goblin_script = load('res://entities/goblin/goblin.gd') as Script
	var goblin_test: Goblin_Enemy = null

	func before_all():
		player = player_scene.instantiate()
		goblin = goblin_scene.instantiate()
		#gut.p("Runs once before all tests")

	func before_each():
		watch_signals(goblin)
		#gut.p("Runs before each test.")

	#func after_each():
		#gut.p("Runs after each test.")

	#func after_all():
		#gut.p("Runs once after all tests")
		
	func test_move_exists():
		assert_has_method(goblin, "move", 'No move method found')
		
	func test_jump_exists():
		assert_has_method(goblin, "handle_jump", 'No jump method found')
		
	func test_handle_sprite_exists():
		assert_has_method(goblin, "handle_sprite", 'No handle_sprite method found')
		
	func test_chose_exists():
		assert_has_method(goblin, "chose", 'No chose method found')
		
		
	func test_goblin_death():
		goblin._on_damage_handler_goblin_died()
		#await get_tree().process_frame
		await wait_frames(2)
		assert_freed(goblin)
	
	
	#func test_goblin_random_movement():
		#goblin.position = Vector2.ZERO
		##goblin.move(0.1)
		#goblin.velocity.x = 200
		#goblin.move_and_slide()
		#assert_ne(goblin.position, Vector2.ZERO, 'The goblin has not moved')
		

	#func test_signal():
		#weapon._on_damage_box_body_entered(player)
		#assert_signal_emitted(weapon, 'on_hit', "On hit signal was not emitted")
