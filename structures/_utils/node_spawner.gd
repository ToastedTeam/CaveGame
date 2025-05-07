extends Node2D
class_name NodeSpawner

@export var sceneToSpawn: PackedScene
@export_range(0, 100, 0.01) var probability: float = 100

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	var randomval = rng.randf_range(0, 100);
	Log.info(randomval)
	if(randomval <= probability):
		Log.info("Rng check succeded for " + name);
		var gameobjs = get_tree().root.find_child("GameObjects", true, false);
		var spawned: Node2D = sceneToSpawn.instantiate()
		gameobjs.add_child(spawned);
		spawned.global_position = global_position;
	queue_free()
	pass
