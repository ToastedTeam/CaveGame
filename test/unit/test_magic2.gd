extends GutTest


var weapon_scene = load('res://weapons/magic2/weapon.tscn') as PackedScene
var weapon: RangedWeapon = null

#const projectile_path = 'res://weapons/magic2/projectile.tscn'
var projectile_scene = load('res://weapons/magic2/projectile.tscn') as PackedScene
#var projectile = null

var player_scene = load('res://entities/player/player.tscn') as PackedScene
var player = null

func before_all():
	weapon = weapon_scene.instantiate()
	weapon.projectile = projectile_scene
	
	player = player_scene.instantiate()
		
	weapon.player = player

#func before_each():
	#watch_signals(weapon)
	#gut.p("Runs before each test.")

#func after_each():
	#gut.p("Runs after each test.")

#func after_all():
	#gut.p("Runs once after all tests")
	
func test_projectile_creation():
	var prev_count = weapon.get_child_count()
	weapon._attack()
	assert_eq(weapon.get_child_count() - prev_count, 1, "Projectile was not created")
	
	
#func test_attack_exists():
	#assert_has_method(weapon, "_attack", 'No _attack method found')
#
#func test_signal():
	#weapon._on_damage_box_body_entered(player)
	#assert_signal_emitted(weapon, 'on_hit', "On hit signal was not emitted")
