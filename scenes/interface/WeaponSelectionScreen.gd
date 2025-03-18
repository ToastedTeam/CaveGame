class_name AttackSelectionController
extends HBoxContainer
@export var Table: WeaponTable
var currentMeleeWeapon = 0
var currentMagicWeapon = 0

func _ready() -> void:
	loadMeleeWeapon()
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
