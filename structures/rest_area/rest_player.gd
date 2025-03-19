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
		player.animPlayer.play("restFloorUp")
		resting = false
		var UI = get_tree().get_nodes_in_group("UI")[0]
		var weapons: Control = UI.get_node("WeaponSelector")
		var attacks: AttackSelectionController = UI.get_node("WeaponSelector/Margin/Attacks")
		var fliphandler = player.get_node("sprites/FlipHandler")
		for child in fliphandler.get_children():
			# Unsafe, may break
			child.free()
			pass
		
		call_deferred("ApplyWeapons", attacks, fliphandler)
		 
		weapons.hide()
		return
	pass
	
func ApplyWeapons(attacks: AttackSelectionController, fliphandler: Node) -> void:
	var ranged_instance = attacks.Table.GetData(attacks.Table.RangedWeapons[attacks.currentRangedWeapon].name).asset.instantiate()
	ranged_instance.name = "Ranged"
	fliphandler.add_child(ranged_instance, true)
	var melee_instance = attacks.Table.GetData(attacks.Table.MeleeWeapons[attacks.currentMeleeWeapon].name).asset.instantiate()
	melee_instance.name = "Weapon"
	fliphandler.add_child(melee_instance, true)
	pass
