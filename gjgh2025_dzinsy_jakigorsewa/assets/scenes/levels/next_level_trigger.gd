extends Area2D

@export_file("*.tscn") var nextLevelPath = ""

func _on_body_entered(body):
	if body.name == "Player" and body.enemiesToKill <= 0:
		GlobalData.prev_scene = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file(nextLevelPath)
