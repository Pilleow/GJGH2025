extends Node2D


func _start_game():
	GlobalData.prev_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://assets/scenes/levels/cutscenka_start.tscn")

func _on_button_pressed():
	_start_game()

func _physics_process(delta):
	if Input.is_action_just_pressed("space"):
		_start_game()
