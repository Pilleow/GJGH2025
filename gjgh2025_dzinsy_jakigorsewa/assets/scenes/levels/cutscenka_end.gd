extends Node2D

@onready var animSprite = $AnimatedSprite2D

func _ready():
	SoundPlayer.update_bgm("")
	animSprite.play("default")

func _process(delta):
	if not animSprite.is_playing():
		$Music.stop()
		GlobalData.prev_scene = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file("res://assets/scenes/menu/menu.tscn")
