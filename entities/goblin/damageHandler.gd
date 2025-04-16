extends Entity

signal goblin_died

var parent: Node2D

func _ready() -> void:
	parent = get_parent()
	Log.info(health)

func Damage(damage: float, source: Node2D):
	if source == null:
		Log.info(name + " took damage form a null source")
		return
	if invincibilityFrames > 0:
		return
	health -= damage;
	
	var tween = get_tree().create_tween()
	tween.tween_property(parent, "modulate", Color.RED, 0.05);
	tween.tween_property(parent, "modulate", Color.WHITE, 0.05);
	invincibilityFrames = maxInvincibilityFrames;
	Log.info(name + " took " + str(damage) + " damage, health left: " + str(health))

func handleDeath():
	#health = minHealth
	
	goblin_died.emit()
