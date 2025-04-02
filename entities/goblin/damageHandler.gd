extends Entity

func Damage(damage: float, source: Node2D):
	if invincibilityFrames > 0:
		return;
	health -= damage;
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.05);
	tween.tween_property(self, "modulate", Color.WHITE, 0.05);
	invincibilityFrames = maxInvincibilityFrames;
	Log.info(name + " took " + str(damage) + " damage, health left: " + str(health))
	pass
