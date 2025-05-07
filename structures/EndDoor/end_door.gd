extends Node2D

@onready var area = $Area2D
@onready var anim = $AnimationPlayer
@onready var prompt_label = $Label

var player_in_area = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	prompt_label.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		anim.play("fade_in_label")
		prompt_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		anim.play("fade_out_label")
		#prompt_label.visible = false

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("player_interact"):
		print("Player interacted with the EndDoor.")
		get_tree().change_scene_to_file("res://scenes/interface/end_game.tscn")
