class_name WeaponTable
extends Resource
@export var MeleeWeapons: Array[WeaponEntry]
@export var RangedWeapons: Array[WeaponEntry]

static func GetData(name: String) -> WeaponStats:
	return load("res://weapons/"+name+"/data.tres")
