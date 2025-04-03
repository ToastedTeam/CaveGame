class_name TestWeapon
extends GutTest

var player_scene = load('res://entities/player/player.tscn')
var player = null

class TestMelee:
	extends TestWeapon
	
	var weapon_script = load('res://weapons/weapon.gd') as Script
	var weapon: Weapon = null

	func before_all():
		weapon = weapon_script.new()
		player = player_scene.instantiate()
		#gut.p("Runs once before all tests")

	func before_each():
		watch_signals(weapon)
		#gut.p("Runs before each test.")

	#func after_each():
		#gut.p("Runs after each test.")

	#func after_all():
		#gut.p("Runs once after all tests")
		
	func test_attack_exists():
		assert_has_method(weapon, "_attack", 'No _attack method found')

	func test_signal():
		weapon._on_damage_box_body_entered(player)
		assert_signal_emitted(weapon, 'on_hit', "On hit signal was not emitted")
	
class TestRanged:
	extends TestWeapon
	
	var weapon_script = load('res://weapons/ranged.gd')
	var weapon: RangedWeapon = null
	
	#var weapon_scene = load('res://weapons/')
	
	func before_all():
		weapon = weapon_script.new()
		player = player_scene.instantiate()
		#gut.p("Runs once before all tests")
		
	func before_each():
		watch_signals(weapon)
		#gut.p("Runs before each test.")
	
	func test_attack_exists():
		assert_has_method(weapon, "_attack", 'No _attack method found')
		
	func test_signal():
		weapon._on_damage_box_body_entered(player)
		assert_signal_emitted(weapon, 'on_hit', "On hit signal was not emitted")
		
class TestProjectile:
	extends TestWeapon
	
	var projectile_script = load('res://weapons/projectile.gd')
	var projectile: Projectile = null
	
	func before_all():
		projectile = projectile_script.new()
		#player = player_scene.instantiate()
		#gut.p("Runs once before all tests")

	func before_each():
		watch_signals(projectile)
		projectile.position = Vector2.ZERO
		#gut.p("Runs before each test.")
	
	func test_attack_exists():
		assert_has_method(projectile, "_attack", 'No _attack method found')
		
	func test_signal():
		projectile._on_damage_box_body_entered(player)
		assert_signal_emitted(projectile, 'on_hit', "On hit signal was not emitted")
	
	func test_movement_left():
		projectile.rotation = PI
		simulate(projectile, 10, 0.1)
		assert_almost_eq(projectile.position, Vector2(-300, 0), Vector2(0.01, 0.01), "Not moved")
	
	func test_movement_right():
		projectile.rotation = 0
		simulate(projectile, 10, 0.1)
		assert_almost_eq(projectile.position, Vector2(300, 0), Vector2(0.01, 0.01), "Not moved")
		
	func test_when_off_screen():
		projectile._on_screen_exited()
		await wait_frames(2)
		assert_null(projectile, "Projectile was not destroyed")
		
		
