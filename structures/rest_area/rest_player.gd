extends Node
var resting = false
func makePlayerRest(player: PlayerCharacter):
	if !resting:
		player.animPlayer.play("restFloor")
		resting = true
		return
	else:
		player.animPlayer.play("RESET")
		resting = false
		return
	pass
