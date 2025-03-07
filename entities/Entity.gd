class_name Entity
# The generic entity class, has health and can receive damage
extends Node2D

@export var maxHealth: float = 1
# Replace with a property later, when implementing target dummies
var health: float

# OVERRIDE THIS IN CLASSES THAT INHERIT THIS CLASS FOR PROPER FUNCTIONALITY
func Damage(damage: float, source: Node2D):
	health -= damage;
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.05);
	tween.tween_property(self, "modulate", Color.WHITE, 0.05);
	Log.info(name + " took " + str(damage) + " damage, health left: " + str(health))
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = maxHealth;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
