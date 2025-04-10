class_name TestGoblin
extends GutTest



class TestGoblinBase:
	extends TestGoblin

	var goblin_scene = load('res://entities/goblin/goblin.tscn')
	var goblin: Goblin_Enemy = null



	func before_each():
		# Load up a new goblin for each test
		goblin = goblin_scene.instantiate()
		# Listen to signals for each test
		watch_signals(goblin)


	# The created goblins should be cleared out and we should have less sad orphants
	func after_each():
		if goblin:
			goblin.free()


	# Test if the goblin class contains all required methods
	func test_move_exists():
		assert_has_method(goblin, "move", 'No move method found')
	
	func test_jump_exists():
		assert_has_method(goblin, "handle_jump", 'No jump method found')
	
	func test_handle_sprite_exists():
		assert_has_method(goblin, "handle_sprite", 'No handle_sprite method found')
	
	func test_chose_exists():
		assert_has_method(goblin, "chose", 'No chose method found')



	# Test goblin death
	func test_goblin_death():
		# The goblin receives a signal, calling for his death
		goblin._on_damage_handler_goblin_died()
		# We wait a few frames to allow the engine to process everything
		await wait_frames(2)
		# The goblin should be freed from memory
		assert_freed(goblin)



	# Test goblin death, if dmg handler emits its signal (Integration test)
	func test_goblin_dies_when_damage_handler_emits_signal():
		# Create a new handler object
		var damage_handler = preload("res://entities/goblin/damageHandler.gd").new()
		# Add it to the goblin object
		goblin.add_child(damage_handler)
		# Connect the signal
		damage_handler.connect("goblin_died", Callable(goblin, "_on_damage_handler_goblin_died"))
		
		# Watch for any signals that the goblin sees
		watch_signals(goblin)
		
		# The damage handler emits a signal
		damage_handler.emit_signal("goblin_died")
		# We wait a few frames to allow for processing
		await wait_frames(2)
		# If the goblin is freed, we know the signal was received
		assert_freed(goblin, "Goblin should free itself after receiving goblin_died signal.")
		
		# Removing potential orphan nodes
		if damage_handler:
			damage_handler.free()



	# Test the sprite flipping script
	func test_handle_sprite_flips_correctly_right():
		var sprite = AnimatedSprite2D.new()
		goblin.add_child(sprite)
		goblin.set("goblinSprite", sprite)
		goblin.directionFlip = Node2D.new()
		
		goblin.dir = Vector2.RIGHT
		goblin.handle_sprite()
		assert_almost_eq(goblin.directionFlip.scale.x, -1.0, 0.001, "Should flip when going right")
		
		# Removing potential orphan nodes
		if sprite:
			sprite.free()



	# Test the sprite flipping script
	func test_handle_sprite_flips_correctly_left():
		var sprite = AnimatedSprite2D.new()
		goblin.add_child(sprite)
		goblin.set("goblinSprite", sprite)
		goblin.directionFlip = Node2D.new()
		
		goblin.dir = Vector2.LEFT
		goblin.handle_sprite()
		assert_almost_eq(goblin.directionFlip.scale.x, 1.0, 0.001, "Should flip when going left")
		
		# Removing potential orphan nodes
		if sprite:
			sprite.free()



	# Test the sprite flipping script
	func test_handle_sprite_flips_correctly_center():
		var sprite = AnimatedSprite2D.new()
		goblin.add_child(sprite)
		goblin.set("goblinSprite", sprite)
		goblin.directionFlip = Node2D.new()
		
		goblin.dir = Vector2.ZERO
		goblin.handle_sprite()
		assert_almost_eq(goblin.directionFlip.scale.x, 0.0, 0.001, "Should face front when idle")
		
		# Removing potential orphan nodes
		if sprite:
			sprite.free()


	# Test the chose method, it should only pick from the numbers given to it, not random numbers
	func test_chose_returns_element_from_array():
		var options = [1, 2, 3]
		var result = goblin.chose(options.duplicate()) # Duplicate so shuffle doesn't mutate test source
		assert_true(result in options, "Chose() should return an item from the given array.")
		
		# Removing potential orphan nodes
		options.clear()



class TestGoblinMovement:
	extends TestGoblin

	var goblin_scene = load('res://entities/goblin/goblin.tscn')
	var goblin: Goblin_Enemy = null



	func before_each():
		# Load up a new goblin for each test
		goblin = goblin_scene.instantiate()
		# Listen to signals for each test
		watch_signals(goblin)


	# The created goblins should be cleared out and we should have less sad orphants
	func after_each():
		if goblin:
			goblin.free()



	func test_handle_jump_sets_velocity_and_resets_flag():
		goblin.velocity = Vector2.ZERO
		goblin.is_jumping = true
		goblin.handle_jump()
		
		assert_eq(goblin.velocity.y, -128, "Y velocity should be set to -jump_speed (128).")
		assert_false(goblin.is_jumping, "Jump flag should be reset to false after jumping.")



	# Create a little stub goblin class for testing the move method
	class NoWallGoblinStub:
		extends Goblin_Enemy

		func is_on_wall_custom() -> bool:
			return false

		func has_ground() -> bool:
			return true

	func test_goblin_moves_with_mocked_methods():
		var goblin = NoWallGoblinStub.new()
		goblin.dead = false
		goblin.is_goblin_chase = false
		goblin.dir = Vector2.LEFT
		
		goblin.move(0.016)
		assert_eq(goblin.velocity.x, -60, "Goblin should move left when has_ground is true and not on wall.")
		
		# Removing potential orphan nodes
		if goblin:
			goblin.free()



	func test_goblin_does_not_move_when_dead():
		var goblin = NoWallGoblinStub.new()
		goblin.dead = true
		goblin.dir = Vector2.LEFT
		goblin.velocity = Vector2.ZERO

		goblin.move(0.016)
		assert_eq(goblin.velocity.x, 0, "Goblin should not move if dead.")
		
		# Removing potential orphan nodes
		if goblin:
			goblin.free()


	# Testing of the goblin correctly switches his direction if there is no ground in front of him
	# Using a new stub
	class NoGroundGoblinStub:
		extends Goblin_Enemy

		func has_ground() -> bool:
			return false

		func is_on_wall_custom() -> bool:
			return false

	func test_goblin_reverses_direction_when_no_ground():
		var goblin = NoGroundGoblinStub.new()
		goblin.dead = false
		goblin.is_goblin_chase = false
		goblin.dir = Vector2.LEFT

		goblin.move(0.016)

		assert_eq(goblin.dir.x, 1, "Goblin should flip direction when no ground is detected.")
		
		# Removing potential orphan nodes
		if goblin:
			goblin.free()



	class WallJumpGoblin:
		extends Goblin_Enemy

		func has_ground() -> bool:
			return true

		func is_on_wall_custom() -> bool:
			return true

		func is_jump_blocked() -> bool:
			return false

	func test_goblin_sets_jump_flag_when_not_blocked():
		var goblin = WallJumpGoblin.new()
		goblin.dead = false
		goblin.is_goblin_chase = false
		goblin.dir = Vector2.RIGHT

		goblin.move(0.016)
		assert_true(goblin.is_jumping, "Goblin should jump when on wall and not blocked.")
		
		# Removing potential orphan nodes
		if goblin:
			goblin.free()



	class BlockedWallJumpGoblin:
		extends Goblin_Enemy

		func has_ground() -> bool:
			return true

		func is_on_wall_custom() -> bool:
			return true

		func is_jump_blocked() -> bool:
			return true
	
	func test_goblin_does_not_jump_when_blocked():
		var goblin = BlockedWallJumpGoblin.new()
		goblin.dead = false
		goblin.is_goblin_chase = false
		goblin.dir = Vector2.RIGHT

		goblin.move(0.016)
		assert_false(goblin.is_jumping, "Goblin should not jump if jump is blocked.")
		
		# Removing potential orphan nodes
		if goblin:
			goblin.free()





class TestGoblinDmgHandler:
	extends TestGoblin
	
	var dmg_handler

	func before_each():
		# Load and instance the damage handler script
		dmg_handler = preload("res://entities/goblin/damageHandler.gd").new()
		
		# Listen for any signals
		watch_signals(dmg_handler)


	# The created handlers should be cleared out and we should have less sad orphants
	func after_each():
		if dmg_handler:
			dmg_handler.free()



	func test_damage_handler_shouldnt_emit_goblin_died_signal_on_positive_hp():
		# Set goblins damage handlers hp to 0, which means the goblin has died
		dmg_handler.health = 10
		# Simulate 2 frames
		simulate(dmg_handler, 2, 1)
		# If the signal "goblin_died" is emitted, we know the goblin has died
		assert_signal_not_emitted(dmg_handler, "goblin_died")



	func test_damage_handler_emits_goblin_died_signal_on_zero_hp():
		# Set goblins damage handlers hp to 0, which means the goblin has died
		dmg_handler.health = 0
		# Simulate 2 frames
		simulate(dmg_handler, 2, 1)
		# If the signal "goblin_died" is emitted, we know the goblin has died
		assert_signal_emitted(dmg_handler, "goblin_died")



	func test_damage_handler_emits_goblin_died_signal_on_negative_hp():
		# Set goblins damage handlers hp to 0, which means the goblin has died
		dmg_handler.health = -10
		# Simulate 2 frames
		simulate(dmg_handler, 2, 1)
		# If the signal "goblin_died" is emitted, we know the goblin has died
		assert_signal_emitted(dmg_handler, "goblin_died")
