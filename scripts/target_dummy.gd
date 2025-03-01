extends Entity

func Damage(damage: float, source: Node2D):
	#Log.info("dummy got hit by " + source.name + " for " + str(damage) + " damage, health left: " + str(health))
	var force = (($body.global_position - source.global_position) as Vector2).normalized() * damage * 50
	$body.apply_impulse(force)
	Log.info(force)
	$Damage.text = str(damage)
	$Damage/Timer.start(2);
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.05);
	tween.tween_property(self, "modulate", Color.WHITE, 0.05);
	$Hurt.play()
	pass

func _timer_end() -> void:
	$Damage.text = ""
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
