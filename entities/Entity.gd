class_name Entity
# The generic entity class, has health and can receive damage
extends Node2D

@export var maxHealth: float = 1
@export var maxInvincibilityFrames: int = 10;
# Replace with a property later, when implementing target dummies
var health: float:
	get:
		return health;
	set(value):
		if value < minHealth:
			health = minHealth;
			return;
		health = value;

var minHealth: float = 0
var invincibilityFrames: int = 0;

# OVERRIDE THIS IN CLASSES THAT INHERIT THIS CLASS FOR PROPER FUNCTIONALITY
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

# OVERRIDE THIS IN CLASSES WHICH MIGHT DIE IN MORE UNIQUE WAYS
func handleDeath():
	health = minHealth
	Log.info(name + " died")
	self.queue_free()	# Remove the current object from the game
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = maxHealth;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if invincibilityFrames > 0:
		invincibilityFrames -= 1;
	if health <= minHealth:
		handleDeath()
	pass
