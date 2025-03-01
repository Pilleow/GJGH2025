extends Node2D

var motor_sound = preload("res://assets/sounds/sfx/car-moving_175bpm_F_major.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = motor_sound
		$AudioStreamPlayer2D.play()
