class_name RangedWeapon
extends Weapon

@export_file("*.tscn") var projectile_path: String

@onready var projectile = load(projectile_path)
var proj_instance: Projectile = null

func _physics_process(delta: float) -> void:
	if (key_pressed_duration >= 0):
		if Input.is_action_just_released("player_attack_ranged"):
			_on_attack_key_release()
		else:
			key_pressed_duration += delta
			_on_attack_key_hold()

func _projectile_init() -> void:
	proj_instance = projectile.instantiate()
	proj_instance.initial_angle = 0 if player.facing_right else PI
	proj_instance.global_position = $ProjectileMarker.global_position

func _projectile_start() -> void:
	self.add_child(proj_instance)

func _on_attack_key_release() -> void:
	super._on_attack_key_release()
	
func animateAttack(animator: IKPlayerAnimator, direction: float) -> void:
	pass
