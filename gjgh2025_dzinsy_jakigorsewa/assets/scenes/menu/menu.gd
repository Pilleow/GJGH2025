extends Node2D


func _start_game():
	get_tree().change_scene_to_file("res://assets/scenes/levels/level_1.tscn")

func _on_button_pressed():
	_start_game()

func _physics_process(delta):
	if Input.is_action_just_pressed("space"):
		_start_game()

