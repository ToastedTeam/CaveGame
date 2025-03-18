class_name RangedWeapon
extends Weapon

@export_file("*.tscn") var projectile_path: String

@onready var projectile = load(projectile_path)

func _attack() -> void:
	#$Projectile
	var proj_instance: Projectile = projectile.instantiate()
	proj_instance.rotation = 0 if player.facing_right else PI
	proj_instance.global_position = $ProjectileMarker.global_position
	
	get_tree().root.get_child(0).add_child(proj_instance)
