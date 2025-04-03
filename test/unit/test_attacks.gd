class_name TestWeapon
extends GutTest

var player_scene = load('res://entities/player/player.tscn')
var player = null

class TestMelee:
	extends TestWeapon
	
	var weapon_script = load('res://weapons/weapon.gd') as Script
	var weapon = null

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

	func test_signal():
		weapon._on_damage_box_body_entered(player)
		assert_signal_emitted(weapon, 'on_hit', "On hit signal was not emitted")
	
class TestRanged:
	extends TestWeapon
	
	var weapon_script = load('res://weapons/ranged.gd')
	var weapon = null
	
	#var weapon_scene = load('res://weapons/')
	
	func before_all():
		weapon = weapon_script.new()
		player = player_scene.instantiate()
		#gut.p("Runs once before all tests")

	func before_each():
		watch_signals(weapon)
		#gut.p("Runs before each test.")
	
	func test_signal():
		weapon._on_damage_box_body_entered(player)
		assert_signal_emitted(weapon, 'on_hit', "On hit signal was not emitted")
		
	#func test_projectile_creation():
		#weapon._attack()
		
class TestProjectile:
	extends TestWeapon
	
	var projectile_script = load('res://weapons/projectile.gd')
	var projectile = null
	
	func before_all():
		projectile = projectile_script.new()
		#player = player_scene.instantiate()
		#gut.p("Runs once before all tests")

	func before_each():
		watch_signals(projectile)
		#gut.p("Runs before each test.")
		
	func test_signal():
		projectile._on_damage_box_body_entered(player)
		assert_signal_emitted(projectile, 'on_hit', "On hit signal was not emitted")
	
	func test_movement():
		projectile.rotation = 0
		simulate(projectile, 10, 0.1)
		print(projectile.position)
		assert_eq(projectile.position, Vector2(300, 0), "Not moved")
		
