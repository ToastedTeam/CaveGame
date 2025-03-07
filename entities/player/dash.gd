extends Node2D

const DASH_CD = 5

@onready var timer = $DashTimer	
@onready var cooldown = $DashCooldown

func startDash(dur):
	timer.wait_time = dur
	cooldown.wait_time = DASH_CD
	timer.start()
	cooldown.start()
	
func isDashing():
	return !timer.is_stopped()

func isReady():
	return cooldown.is_stopped()
	
func getCooldown():
	return cooldown.time_left
