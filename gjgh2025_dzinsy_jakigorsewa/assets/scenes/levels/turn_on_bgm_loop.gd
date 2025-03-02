extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		SoundPlayer.update_bgm("BGM1Loop")
		queue_free()
