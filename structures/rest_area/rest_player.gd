extends Node
var resting = false
func makePlayerRest(player: PlayerCharacter):
	if !resting:
		player.animPlayer.play("restFloor")
		resting = true
		var UI = get_tree().get_nodes_in_group("UI")[0]
		var weapons: Control = UI.get_node("WeaponSelector")
		weapons.show()
		return
	else:
		player.animPlayer.play("RESET")
		resting = false
		var UI = get_tree().get_nodes_in_group("UI")[0]
		var weapons: Control = UI.get_node("WeaponSelector")
		var attacks: AttackSelectionController = UI.get_node("WeaponSelector/Margin/Attacks")
		var fliphandler = player.get_node("sprites/FlipHandler")
		for child in fliphandler.get_children():
			child.queue_free()
			pass
		var inst = attacks.Table.GetData(attacks.Table.MeleeWeapons[attacks.currentMeleeWeapon].name).asset.instantiate()
		fliphandler.add_child(inst)
		
		weapons.hide()
		return
	pass
