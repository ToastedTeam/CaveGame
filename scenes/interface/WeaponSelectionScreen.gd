class_name AttackSelectionController
extends HBoxContainer
@export var Table: WeaponTable
var currentMeleeWeapon = 0
var currentRangedWeapon = 0

func _ready() -> void:
	loadMeleeWeapon()
	loadRangedWeapon()
	pass

func loadMeleeWeapon() -> void:
	var weaponData = WeaponTable.GetData(Table.MeleeWeapons[currentMeleeWeapon].name)
	$MeleeAttacks/InfoElements/Description.text = weaponData.description
	$MeleeAttacks/InfoElements/Texture.texture = weaponData.icon
	pass

func _on_previous_melee() -> void:
	print("Previous weapon")
	currentMeleeWeapon = (currentMeleeWeapon - 1) % Table.MeleeWeapons.size()
	loadMeleeWeapon()
	pass # Replace with function body.


func _on_next_melee() -> void:
	print("Next weapon")
	currentMeleeWeapon = (currentMeleeWeapon + 1) % Table.MeleeWeapons.size()
	loadMeleeWeapon()
	pass # Replace with function body.
	
func loadRangedWeapon() -> void:
	var weaponData = WeaponTable.GetData(Table.RangedWeapons[currentRangedWeapon].name)
	$RangedAttacks/InfoElements/Description.text = weaponData.description
	$RangedAttacks/InfoElements/Texture.texture = weaponData.icon
	pass

func _on_previous_ranged() -> void:
	print("Previous weapon")
	currentRangedWeapon = (currentRangedWeapon - 1) % Table.RangedWeapons.size()
	loadRangedWeapon()
	pass # Replace with function body.


func _on_next_ranged() -> void:
	print("Next weapon")
	currentRangedWeapon = (currentRangedWeapon + 1) % Table.RangedWeapons.size()
	loadRangedWeapon()
	pass # Replace with function body.
